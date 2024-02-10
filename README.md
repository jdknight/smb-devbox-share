# Samba Development Box Share

*(this is a crude secondary channel over using a VirtualBox shared mount)*

The following provides support to run smbd in a container with the
purpose of sharing a folder between a Linux-based virtual environment
with a Windows machine. This is specifically designed for running a
Samba share from a Linux host running in VirtualBox, that is bound to
an explicit IP on a Host-only adapter. The Windows box running this
virtual machine can create a mapped drive for this share, and can freely
modify its contents.

An overview:

- Create a second network interface on the VirtualBox container selecting
  `Host-only Adapter`.
- When the container is running, assign a static IP for the newly added
  interface.
- In the virtual machine which will run the container, prepare the mount
  path by invoking the following:

  ```
  sudo install -d -m 0755 -o $USER -g $USER /srv/share
  ```

- If not already done, clone this repository into virtual machine.
- Move into the cloned directory and invoke the following:

  ```
  ./register <ip>
  ```

- With the container running, the share should be accessible from the
  Windows host environment. Try navigating to the share using Windows
  Explorer by entering `\\<ip>\Share`.
- Users can create a mount for this share using the following:

  ```
  net use %mount%: \\<ip>\Share
  ```

## Windows mount share support script

For environments where the container may not be always accessible, the
following script can be used to help monitor and manage the mount
automatically. This is to help avoid Explorer [timeout issues][su853430]
a user may experience when the share is not available.

```
@echo off

REM ====================================================================

set ip=ENTER_VM_IP
set mount=z
set share_dir=Share

REM ====================================================================

set last_state=na

:begin
    set state=down

    for /f %%i in ('ping -n 1 %ip% -w 1000 ^| findstr /C:"Reply from %ip%"') do (
        set state=up
    )

    if not %state% == %last_state% (
        set last_state=%state%
        if %state% == up (
            net use %mount%: \\%ip%\%share_dir% >nul 2>&1
        )
        if %state% == down (
            net use %mount%: /delete /y >nul 2>&1
            mountvol %mount%: /D >nul 2>&1
        )
    )

    timeout /t 5 /nobreak >nul 2>&1
goto begin
```


[su853430]: https://superuser.com/a/853430/164099
