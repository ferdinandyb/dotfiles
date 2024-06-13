# WSL stuff

## GPG

The easiest is to just symlink the windows executable, the CLI works the same.

## Proper windowing

WSL(g) doesn't work well with Windows really, because you can't even snap the windows with the built-in tiling. The solution is running vxcsrv.

To fix firewall issues:
```
Set-NetFirewallProfile -Profile Public -DisabledInterfaceAliases "vEthernet (WSL)"
```

Force usage without disabling wayland:
```
export MY_EXT_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}')
export DISPLAY=$MY_EXT_IP:0.0
export GDK_BACKEND=x11
```

## C:\Users\bferdinandy\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

Starting up WSL:
```
❯ cat startwsl.bat
@echo  off
echo "Starting Ubuntu"
wsl -u root service dbus start
echo "Done"
```

- switcheroo is a pretty good launcher and window changer
