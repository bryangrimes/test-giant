# test-giant

**test-giant** is a Neovim plugin that leverages [vim-test](https://github.com/vim-test/vim-test) and [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to run tests at the current scope (a test method or class) based on your cursor position. It is designed to work primarily with Python test files (by default, those starting with `test_`), and you can configure inclusion and exclusion patterns as needed. If a file doesn't match your configured patterns or the language isn't set up, test-giant will defer to vim-test's default behavior.

## Features

- **Scope-Aware Test Execution:** Uses Tree-sitter to detect your current test method or class.
- **Customizable Key Binding:** Default mapping is `<leader>r`, configurable via setup.
- **File Filtering:** Run tests only in files that match a specified inclusion pattern (default: `^test_`) and exclude files using a regex (default: `test_fixtures`).
- **Configurable Pytest Options:** Automatically appends extra pytest options (`-srA --disable-warnings --showlocals`), which you can override.
- **Language-Aware Behavior:** Currently supports Python with pytest; if a file's language isn't configured, it falls back to vim-test's `TestNearest`.

## Installation

Using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- In your Lazy.nvim config:
return {
  {
    "bryangrimes/test-giant",
    config = function()
      require("test_giant").setup({
        keymap = "<leader>r",               -- Key mapping to run tests in the current scope
        include_pattern = "^test_",         -- Only include files starting with 'test_'
        exclude_pattern = "test_fixtures",  -- Regex pattern to exclude certain files
        pytest_options = "-srA --disable-warnings --showlocals",  -- Additional pytest options
      })
    end,
  },
}
```

## Usage

1. **Open a Test File:**
   Open a Python test file (e.g. one whose name starts with `test_`) in Neovim.

2. **Place Your Cursor:**
   Position your cursor inside a test method or test class.

3. **Run the Test:**
   Press `<leader>r` (or your configured key binding) to run the test for the current scope.
   - The plugin uses Tree-sitter to detect the current test method or class.
   - It constructs a pytest command by appending the detected scope (e.g. `::test_method`) to the file path.
   - The command is executed with your specified pytest options.

4. **Fallback Behavior:**
   If the current file's type isn't configured for custom behavior, test-giant falls back to vim-test's `TestNearest` command, letting vim-test handle test execution.

## Behavior Overview

### File Filtering

When invoked, test-giant checks that the current file name matches the configured inclusion pattern (default: files starting with `test_`) and does not match the exclusion pattern (default: `test_fixtures`). This ensures that only valid test files are processed.

### Scope Detection via Tree-sitter

The plugin traverses the Tree-sitter syntax tree upward from your current cursor position. It looks for a function or class definition and extracts its name. This detected name is then appended to the file path as a scope specifier (e.g. `::test_method`).

### Test Command Construction

For Python files, the plugin builds a pytest command that includes:

- The full file path.
- The scope specifier (if a test method or class is detected).
- Your custom pytest options.

For example, if your file is `/path/to/test_example.py` and the detected test method is `test_function`, the command might look like:

```bash
pytest /path/to/test_example.py::test_function -srA --disable-warnings --showlocals
```

### Language-Based Configuration

The plugin currently provides a configuration for Python, but it is designed to be extended to other languages. If the file's language is not configured, test-giant will notify you and fall back to vim-test's default behavior.

## Configuration

You can override the default settings by passing a table to the setup function:

- **keymap** (string):
  - The key mapping to trigger the test runner.
  - Default: `"<leader>r"`

- **include_pattern** (string):
  - Lua pattern that test file names must match.
  - Default: `"^test_"`

- **exclude_pattern** (string):
  - Lua pattern to exclude certain test files (e.g. to ignore files like test_fixtures).
  - Default: `"test_fixtures"`

- **pytest_options** (string):
  - Additional options appended to the pytest command.
  - Default: `"-srA --disable-warnings --showlocals"`

- **Language-Specific Configuration:**
  - The default configuration currently only includes Python. Future language configurations can be added under the languages table.
  - If the current filetype is not configured, test-giant will fall back to vim-test's TestNearest.

## Requirements

- **Neovim:** Version 0.5 or later.
- **nvim-treesitter:** For parsing code structures and detecting test scopes.
- **vim-test:** For integration and potential future enhancements.

## License

This project is licensed under the MIT License.
