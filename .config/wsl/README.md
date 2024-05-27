# WSL stuff

## GPG

The easiest is to just symlink the windows executable, the CLI works the same

## C:\Users\bferdinandy\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

Starting up WSL:
```
❯ cat startwsl.bat
@echo  off
echo "Starting Ubuntu"
wsl -u root service dbus start
echo "Done"
```
