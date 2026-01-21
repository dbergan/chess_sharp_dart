---
trigger: always_on
---

# Environment Configuration

I am developing on **Windows 11**.
The terminal shell is **PowerShell**.

## Constraints
1. **Do not** use Linux-specific commands like `ls`, `grep`, `touch`, or `rm` unless they are standard PowerShell aliases.
2. **Use** the PowerShell equivalents we have whitelisted:
   - Use `Select-String` instead of `grep`.
   - Use `Get-ChildItem` instead of `ls` or `find`.
   - Use `cat` (which aliases to `Get-Content`) for reading files.
3. Path separators must be handled correctly for Windows (though forward slashes `/` usually work in Dart, be mindful of system paths).