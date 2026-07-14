# Just List Files

Small scripts that collect file names from a target directory and write them
to `file-list.txt`. The output file is always created in the same directory as
the script, regardless of the terminal's current working directory.

## General behavior

- Lists only files directly inside the target directory by default.
- Provides a recursive option to include files from subdirectories. See the
  platform-specific commands below.
- Includes hidden files and sorts the results by file name.
- Writes file names only, without their directory paths.
- Uses UTF-8 and excludes both `file-list.txt` and the running script from the
  results.
- Prompts for the target directory if no directory argument is provided.
  Press Enter without typing a path to use the directory containing the script.

## Windows

Requirement: Windows PowerShell 5.1 or later, included with Windows 10 and 11.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\list-files-windows.ps1 "C:\path to\directory"
```

List files recursively:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\list-files-windows.ps1 "C:\path to\directory" -Recurse
```

## Linux & macOS

```sh
chmod +x list-files-unix.sh
./list-files-unix.sh "/path/to/directory"
```

List files recursively:

```sh
./list-files-unix.sh --recursive "/path/to/directory"
```

> Note: The text format uses one file name per line. A file name containing a
> newline character—which is possible but uncommon on Linux and macOS—will
> occupy multiple lines in the output.
