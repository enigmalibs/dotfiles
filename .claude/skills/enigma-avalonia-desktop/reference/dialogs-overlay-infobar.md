# ContentDialog, Overlay & InfoBar (host services)

Three service + host-control pairs sharing one pattern:

1. Place the host control (`ContentDialog` / `Overlay` / `InfoBar`) as one of the **last** children of
   MainWindow's root `Panel`, `x:Name`d (see `setup.md`).
2. `RegisterHost(...)` it once at startup in `App.OnFrameworkInitializationCompleted`, **before the
   window is shown**.
3. Inject the service into a ViewModel and `await service.ShowAsync(...)`.

This wiring is the whole contract. A service whose host is still unregistered throws
`InvalidOperationException` from every `Show*` call — `"ContentDialog host has not been registered. Call
RegisterHost first."`, `"No Overlay registered. Call RegisterHost first."`, `"InfoBar host has not been
registered. Call RegisterHost first."`. All three `HideAsync` methods are silent no-ops instead, because
there is nothing to hide. Calling `RegisterHost` twice is allowed — the last host wins.

The three controls derive from `ContentControl`, not `TemplatedControl`.

---

## ContentDialog — modal dialog

**`IContentDialogService`** (`…Services`)

| Member | Returns |
|---|---|
| `RegisterHost(ContentDialog dialog)` | `void` |
| `ShowMessageAsync(string title, string message, string closeButtonText = "OK")` | `Task<DialogResult>` |
| `ShowAsync(Action<ContentDialog> configure)` | `Task<DialogResult>` |
| `HideAsync()` | `Task` — resolves the pending dialog with `DialogResult.None` |

**`ContentDialog`** (`…Controls.ContentDialog`) — set these inside `configure`:

- `Title` : `string?`, `Content` : `object?` (inherited from `ContentControl` — a string or any control)
- `PrimaryButtonText` / `SecondaryButtonText` / `CloseButtonText` : `string?`, each with a matching
  `…ButtonCommand` : `ICommand?` and `Is…ButtonEnabled` : `bool`
- `DefaultButton` : `DefaultButton` (default `None`) — declares intent only
- `IconData` : `Geometry?`, `IconBrush` : `IBrush?`
- `IsOpen` : `bool`, `OverlayBrush` : `IBrush?` (default `#4D000000` — the scrim; clicking it closes with
  `DialogResult.None`), `DialogResult` : `DialogResult` (set to the closing button just before `Closed`
  fires)
- **Six size properties**: `DialogWidth` / `DialogHeight` (default `double.NaN` — auto-size within the
  bounds), `DialogMinWidth` / `DialogMaxWidth` (`320` / `600`), `DialogMinHeight` / `DialogMaxHeight`
  (`0` / `double.PositiveInfinity` — set the max to make tall content scroll inside the card)
- Also on the control itself: `Task<DialogResult> ShowAsync()`, `Task HideAsync()`, and
  `event EventHandler<DialogResult>? Closed`

**Enums** (`…Controls.ContentDialog`): `DialogResult { None, Primary, Secondary, Close }` and
`DefaultButton { None, Primary, Secondary, Close }`.

The size properties are **not** reset between dialogs, so set them on the host in XAML rather than in
every `configure`:

```xml
<contentDialog:ContentDialog x:Name="HostDialog"
                             DialogMinWidth="360"
                             DialogMaxWidth="900"
                             DialogMaxHeight="520" />
```

For a **Yes/No confirmation**, set `PrimaryButtonText = "Yes"` and `CloseButtonText = "No"`, then treat
**only `DialogResult.Primary`** as confirmed — dismissing with `Escape` or a scrim click returns `None`,
not `Close`, so `== DialogResult.Primary` is the only correct check.

```csharp
using Avalonia.Controls;
using Avalonia.Media;
using Enigma.Avalonia.Desktop.Controls.ContentDialog;

// Simple confirmation
var result = await _dialogService.ShowAsync(dialog =>
{
    dialog.Title = "Delete file";
    dialog.Content = "This cannot be undone.";
    dialog.PrimaryButtonText = "Delete";
    dialog.CloseButtonText = "Cancel";
});
if (result == DialogResult.Primary) { /* … */ }

// Rich content, three buttons, a coloured icon
await _dialogService.ShowAsync(dialog =>
{
    dialog.Title = "Confirm action";
    dialog.IconData = PhosphorIconSet.Instance
        .GetGlyph(PhosphorIcon.Warning, PhosphorWeight.Regular).ToGeometry();
    dialog.IconBrush = new SolidColorBrush(Color.Parse("#E8A33D"));
    dialog.Content = new StackPanel
    {
        Spacing = 8,
        Children = { new TextBlock { Text = "Are you sure?", TextWrapping = TextWrapping.Wrap } }
    };
    dialog.PrimaryButtonText = "Confirm";
    dialog.SecondaryButtonText = "Maybe later";
    dialog.CloseButtonText = "Cancel";
});

// One-liner message
await _dialogService.ShowMessageAsync("Done", "The export finished.");
```

Capture input by putting a control in `Content` and reading it after the await:

```csharp
var box = new TextBox { PasswordChar = '•' };
var result = await _dialogService.ShowAsync(d => { d.Title = "Password"; d.Content = box;
                                                   d.PrimaryButtonText = "OK"; });
if (result == DialogResult.Primary) Use(box.Text);
```

`ShowAsync` resets the host's content and button configuration before applying your `configure`, so only
set what you need — but remember the size properties are excluded from that reset.

---

## Overlay — modal blocking layer

**`IOverlayService`** (`…Services`): `void RegisterHost(Overlay presenter)`,
`Task ShowAsync(Control control)`, `Task HideAsync()`.

**`Overlay`** (`…Controls`) — `IsOpen` : `bool`, `OverlayBrush` : `IBrush?` (translucent black by
default). `ShowAsync` takes any `Control` as content, typically a small progress card you build and then
mutate while a task runs.

```csharp
var card = new ProgressOverlayCard { Title = "Processing", IsIndeterminate = true, Message = "Starting…" };
await _overlayService.ShowAsync(card);
try
{
    card.IsIndeterminate = false;
    card.Progress = 50;
    card.Message = "Halfway…";
    await DoWorkAsync();
}
finally
{
    await _overlayService.HideAsync();   // always, or the overlay stays stuck open
}
```

`ProgressOverlayCard` is **your** control, not the library's — the showcase's version is a
`ContentControl` subclass exposing `Title`, `Message`, `IsIndeterminate`, `Progress`, `Minimum` and
`Maximum` styled properties over a templated `ProgressBar`. Guard the triggering command with an
`IsBusy` flag and `NotifyCanExecuteChanged()` to prevent re-entry.

---

## InfoBar — inline notification

**`IInfoBarService`** (`…Services`): `void RegisterHost(InfoBar infoBar)`,
`Task ShowAsync(Action<InfoBar>? configure = null)`, `Task HideAsync()`.

**`InfoBar`** (`…Controls.InfoBar`) — `Title` : `string?`, `Message` : `string?`, `Severity` :
`InfoBarSeverity`, `IsOpen` : `bool`. **Enum**: `InfoBarSeverity { Info, Success, Warning, Error }`; each
severity resolves its own `Enigma*Background` / `Enigma*Border` brush pair.

```csharp
using Enigma.Avalonia.Desktop.Controls.InfoBar;

await _infoBarService.ShowAsync(bar =>
{
    bar.Title = "Success";
    bar.Message = "The operation completed successfully.";
    bar.Severity = InfoBarSeverity.Success;
});
// later: await _infoBarService.HideAsync();
```

---

## Injecting the services

```csharp
public class MyPageViewModel(
    IContentDialogService dialogService,
    IOverlayService overlayService,
    IInfoBarService infoBarService) : ObservableObject
{
    private readonly IContentDialogService _dialogService = dialogService;
    private readonly IOverlayService _overlayService = overlayService;
    private readonly IInfoBarService _infoBarService = infoBarService;
}
```

## Common mistakes

- **`ShowAsync` before `RegisterHost`** → `InvalidOperationException`. Wire all three hosts at startup.
- **Treating a dismissal as `Close`** → `Escape` and scrim clicks yield `DialogResult.None`. Check for
  `Primary`.
- **Setting the six size properties inside `configure`** → they are not reset between dialogs, so set
  them once on the host in XAML.
- **Not wrapping overlay work in `try`/`finally`** → an exception mid-task leaves the overlay open and
  the app unusable.
- **Missing `using Enigma.Avalonia.Desktop.Controls.ContentDialog;`** → `DialogResult` and
  `DefaultButton` are invisible; likewise `…Controls.InfoBar;` for `InfoBarSeverity`.
- **Placing the hosts before the app content in the `Panel`** → they render underneath it. They must be
  the last children.
