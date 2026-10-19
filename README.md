# VSCodeConfig

Scott's VS Code setup, kept in one place to sync between the home laptop, work (Windows + WSL) and
code-server on the BrandBully dev box.

| Path | Holds |
|---|---|
| `User/settings.json` | User settings: the JetBrains light theme, Visual Studio Light colours for C#, ClaudeLog's palette for Markdown source, `.md` opening as a rendered preview |
| `User/keybindings.json` | Key bindings (Visual Studio style: Ctrl+D duplicates a line, Alt+Enter is quick fix) |
| `extensions.txt` | Every installed extension, one ID per line |
| `vsix/` | Extensions code-server can't get: they aren't on Open VSX, the marketplace code-server uses |

## Applying it

**Windows:** `.\install.ps1` (or `-SkipExtensions` for only the settings). Files it replaces are kept
as `*.bak`.

**Linux / code-server:** `./install.sh` picks code-server if it's installed, otherwise desktop VS Code
(`./install.sh code-server` or `./install.sh code` to force one). Microsoft-only extensions (C# Dev Kit,
Pylance, …) aren't on Open VSX, so they fail on code-server; the script lists them at the end and
carries on.

**WSL and Remote-SSH need nothing from here.** The remote uses the Windows-side settings and themes;
VS Code installs workspace extensions on the remote when asked.

## Saving changes back

Change settings in VS Code as usual, then `.\export.ps1`, review `git diff`, and commit.

## Backing up a new extension

If a new extension isn't on Open VSX (check `https://open-vsx.org/api/<publisher>/<name>`; a 404 means
it isn't), download its `.vsix` into `vsix/`:

```bash
curl -L --compressed -o vsix/<publisher>.<name>.<version>.vsix \
  "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/<publisher>/vsextensions/<name>/<version>/vspackage"
```

Backed up so far: the **Laravel Extra JetBrains** colour theme (`assmdx.vscode-theme-laravel-beta`, the
one in use) and the **IntelliJ IDEA Light** theme (`undx.undx-intellij-idea-light-theme`). The JetBrains
icon theme is on Open VSX, so `extensions.txt` covers it.

## The colour rules

`settings.json` keeps the theme for everything except two languages. VS Code can't set a theme per
language, so the rules are scoped instead:

- **C#:** `editor.semanticTokenColorCustomizations` rules ending in `:csharp` (with C# Dev Kit) and
  `editor.tokenColorCustomizations` TextMate rules under `source.cs` (the built-in grammar), with
  Visual Studio Light's colours.
- **Markdown source:** TextMate rules under `text.html.markdown`, from ClaudeLog's
  `Views/Editing/MarkdownPalette.cs` (light variant).

Both are nested under `"[Laravel Extra - JetBrains Clasic]"`, so they switch off with any other theme.
