# Setup

How to get `Enigma.Icons.Avalonia` into an Avalonia app. This is the shortest setup of any Enigma
library: one package, one `xmlns`, nothing in `App.axaml`.

## 1. Packages

```bash
dotnet add package Enigma.Icons.Avalonia      # 1.0.0
```

That is the whole icon dependency. `Enigma.Icons.Phosphor` (the artwork) and `Enigma.Icons` (the model
and parser) arrive transitively — reference them explicitly only to pin a version, or when a
non-Avalonia project in the same solution needs the model.

```xml
<ItemGroup>
  <PackageReference Include="Enigma.Icons.Avalonia" Version="1.0.0" />
  <PackageReference Include="Avalonia.Desktop" Version="12.1.0" />   <!-- your app's backend, not ours -->
</ItemGroup>
```

**What you get transitively:** `Enigma.Icons.Phosphor`, `Enigma.Icons`, `Avalonia` (floor **12.1.0**).

**What you do NOT get** — add these yourself if you want them: `Avalonia.Desktop`,
`Avalonia.Themes.Fluent`, `Avalonia.Fonts.Inter`, any MVVM toolkit, any DI container. This library has
no opinion about any of them and registers no services.

The Avalonia package set is **version-coupled** — bump `Avalonia`, `Avalonia.Desktop`,
`Avalonia.Themes.Fluent`, `Avalonia.Fonts.Inter` and `Avalonia.Headless*` together, never one alone.

> **Check nuget.org before assuming the package id resolves.** The 1.0.0 line is feature-complete in
> the repo, but publishing is a manual step the maintainer owns. If `dotnet add package` fails with
> `NU1101`, consume the projects directly instead:
> ```xml
> <ProjectReference Include="..\..\Enigma.Icons\src\Enigma.Icons.Avalonia\Enigma.Icons.Avalonia.csproj" />
> ```
> or `dotnet pack src/Enigma.Icons.Avalonia/Enigma.Icons.Avalonia.csproj -c Release` into a local feed.

## 2. The XAML namespace

One declaration reaches the control **and** both markup extensions, because the assembly maps two CLR
namespaces onto one XML namespace URI:

```xml
xmlns:ei="https://github.com/josueclement/Enigma.Icons"
```

That URI is the repository URL and is **not** fetched at build or run time — it is an identifier. Both
`[assembly: XmlnsDefinition]` entries point at it (`Enigma.Icons.Avalonia` and
`Enigma.Icons.Avalonia.Markup`).

The `using:` form still works and is the documented fallback, but Avalonia's `using:` mapping covers one
CLR namespace and **not** its sub-namespaces, so it needs two prefixes:

```xml
xmlns:ei="using:Enigma.Icons.Avalonia"           <!-- reaches <ei:Icon> only -->
xmlns:eim="using:Enigma.Icons.Avalonia.Markup"   <!-- reaches {eim:IconGeometry}, {eim:IconImage} -->
```

Prefer the URI form. A single `xmlns:ei="using:Enigma.Icons.Avalonia"` compiles the control fine and
then fails on `{ei:IconGeometry …}` with an unresolved-type XAML error, which reads like a typo.

## 3. `App.axaml` — nothing to add

```xml
<Application xmlns="https://github.com/avaloniaui"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             x:Class="MyApp.App"
             RequestedThemeVariant="Default">
  <Application.Styles>
    <FluentTheme />        <!-- your app's theme; this library contributes nothing here -->
  </Application.Styles>
</Application>
```

`Icon` derives from `Control` and overrides `MeasureOverride` and `Render`. It is not a
`TemplatedControl`, so the package ships **no** `.axaml`, declares **no** `ControlTheme`, and exposes
**no** resource keys. There is nothing to merge and nothing to get wrong.

`RequestedThemeVariant="Default"` makes the app follow the OS light/dark preference — worth using
during development, because it is what exercises `Icon.Foreground`'s inheritance
(see `theming-and-performance.md`).

## 4. Minimal working app

`Program.cs` — standard Avalonia, no icon-specific wiring:

```csharp
using Avalonia;

internal sealed class Program
{
    [STAThread]
    public static void Main(string[] args)
        => BuildAvaloniaApp().StartWithClassicDesktopLifetime(args);

    public static AppBuilder BuildAvaloniaApp()
        => AppBuilder.Configure<App>().UsePlatformDetect().WithInterFont().LogToTrace();
}
```

`MainWindow.axaml`:

```xml
<Window xmlns="https://github.com/avaloniaui"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:ei="https://github.com/josueclement/Enigma.Icons"
        x:Class="MyApp.MainWindow">
  <StackPanel Margin="20" Spacing="12">
    <ei:Icon Kind="Acorn" Size="32" />
    <TextBlock Foreground="Tomato">
      <ei:Icon Kind="Heart" Weight="Fill" Size="20" />   <!-- inherits Tomato -->
    </TextBlock>
  </StackPanel>
</Window>
```

No DI registration, no service, no startup hook. If an icon does not appear, the cause is a null
`Foreground` or a zero `Size`, not missing wiring — see `icon-control.md`.

## 5. Unit-testing icons headlessly

Avalonia's headless platform is required even for pure geometry assertions: `Geometry.Parse` needs the
platform render interface, and a test method missing `[AvaloniaFact]` fails with an obscure
`Unable to locate IPlatformRenderInterface` rather than an assertion failure.

```xml
<ItemGroup>
  <PackageReference Include="xunit.v3" Version="3.2.2" />
  <PackageReference Include="Avalonia.Headless.XUnit" Version="12.1.0" />
</ItemGroup>
```

```csharp
using Avalonia;
using Avalonia.Headless;
using MyApp.Tests;

[assembly: AvaloniaTestApplication(typeof(TestAppBuilder))]

namespace MyApp.Tests;

public static class TestAppBuilder
{
    public static AppBuilder BuildAvaloniaApp()
        => AppBuilder.Configure<Application>()
            .UseHeadless(new AvaloniaHeadlessPlatformOptions());
}
```

No `FluentTheme` is needed — nothing in this library is templated.

```csharp
[AvaloniaFact]           // NOT [Fact]
public void Icon_resolves_its_glyph()
{
    IconGlyph glyph = PhosphorIconSet.Instance.GetGlyph(PhosphorIcon.Acorn, PhosphorWeight.Bold);
    Geometry geometry = glyph.ToGeometry();

    Assert.False(geometry.Bounds.IsEmpty());
}
```

Because `Icon.Render` swallows everything, **do not** assert icon names through the control. Assert them
through `GetGlyph`, which throws `IconNotFoundException` on a miss.

## 6. Trimming, AOT and payload size

All three packages are marked `IsTrimmable` and `IsAotCompatible` on the modern TFMs and build free of
`IL2xxx`/`IL3xxx` warnings. Resource names are built from a compile-time literal plus an array index —
never `Enum.GetName`/`ToString`/`Parse` — precisely so trimming cannot break the lookup.

Size to be aware of: the Phosphor artwork is six embedded `.dat` resources totalling roughly **3.9 MB**
uncompressed (~0.55–0.78 MB per weight), and trimming will **not** remove them — they are resources, not
code, and are reachable through a table. They compress well in the `.nupkg` and in a single-file bundle.
Nothing is read at startup: touching `PhosphorIconSet.Instance` does no I/O, and a weight's table is
loaded on first use of that weight and then kept for the life of the process.

If 3.9 MB is unacceptable, reference `Enigma.Icons` alone and ship your own `.svg` files via
`SvgIconSet` (`custom-icon-sets.md`) — but note that `Enigma.Icons.Avalonia` depends on
`Enigma.Icons.Phosphor`, so using the control or the extension methods always brings the artwork with it.

## Common mistakes

- **Adding a `StyleInclude` or `ResourceInclude` for this package** → the URI resolves to nothing. There
  is no XAML in the package. Nothing goes into `App.axaml`.
- **One `using:` prefix instead of the URI** → the control resolves, `{ei:IconGeometry …}` does not.
- **Expecting a DI registration extension** → there is none, and none is needed. `PhosphorIconSet` is a
  thread-safe singleton reached through `PhosphorIconSet.Instance`.
- **`[Fact]` instead of `[AvaloniaFact]`** → `Unable to locate IPlatformRenderInterface`, even for a test
  that only parses geometry.
- **Referencing `Enigma.Icons.Avalonia` from a `netstandard2.0` project** → no compatible asset. Only
  `Enigma.Icons` and `Enigma.Icons.Phosphor` target `netstandard2.0`.
- **Bumping `Avalonia` alone** → mismatched Avalonia assemblies. Move the whole coupled set together.
