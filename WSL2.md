# WSL2

## Graphics

WSL 2 needs manual steps for graphics to be enabled. They are available at https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps, and you only need to follow some of its steps:

* `Install support for Linux GUI apps`
* `Run Linux GUI apps > Update the packages in your distribution`
* `Run Linux GUI apps > Install X11 apps`

Then do the following to install all the X (display) libraries needed for Java:

```shell
sudo apt install default-jre
```

A paid alternative is https://x410.dev/. If you use x410, then install fonts with https://x410.dev/cookbook/wsl/sharing-windows-fonts-with-wsl/, use the "Floating Desktop" mode, and run the following before any graphical applications like the Android Emulator:

```sh
export GDK_SCALE=1 DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2; exit;}'):0.0
```

## Connecting Android Devices

When your Android device is connected through a USB cable to your Windows PC, the Android
device is connected to Windows instead of Linux.

There are two different ways to let Linux see your Android device. The first method
is more general; it provides a way for any USB device to work in WSL2 including
USB cameras for QR codes.

### Method 1 - Use USBIP

FIRST,

Follow https://learn.microsoft.com/en-us/windows/wsl/connect-usb to install the latest USBIP `.msi`
and follow the `apt` instructions. You do not need to follow the `usbip` commands yet.

> If you use Debian instead of Ubuntu, you will need:
> 
> ```shell
> sudo apt update
> sudo apt install hwdata usbip usbutils
> ```

SECOND,

> **If you restart or unplug your Android device, you have to start back here**

In PowerShell, find the Android device you are using (ex. Lenovo Tab M8), and bind
and attach it using its `BUSID`:

```powershell
C:\Users\beckf> usbipd wsl list
BUSID  VID:PID    DEVICE                                                        STATE
1-5    17ef:201c  Lenovo Tab M8 3rd Gen                                         Not attached
1-12   8087:0aa7  Intel(R) Wireless Bluetooth(R)                                Not attached
3-3    046d:08e5  HD Pro Webcam C920                                            Not attached
3-5    0fd9:0082  Game Capture HD60 X, USB Input Device                         Not attached
5-3    046d:085e  Logitech BRIO, USB Input Device                               Not attached
10-2   20b1:0008  HIFI DSD, XMOS  DFU                                           Not attached

C:\Users\beckf> usbipd bind --busid=1-5 --force
usbipd: warning: A reboot may be required before the changes take effect.

C:\Users\beckf> usbipd wsl attach --busid=1-5
usbipd: info: Using default WSL distribution 'Debian'; specify the '--distribution' option to select a different one.
```

> NOTE 1: If you received a `usbipd: warning: A reboot may be required before the changes take effect.` you
> will need to reboot before the following `usbipd wsl attach ...` works.

> NOTE 2: Yes, you can bind and attach USB cameras as well.

THIRD,

Verify the Linux kernel can see the attached Android device. In a Linux terminal run:

```shell
$ lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 17ef:201c Lenovo Lenovo Tab M8 3rd Gen
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

FOURTH,

> **If you need to restart Android Studio, you have to start back here.**

The Linux kernel now has access to the Android device, but regular "user" Linux programs
like Android Studio will need permission.

There are somewhat complicated "udev" rules to get permission to
the Android Device at https://github.com/M0Rf30/android-udev-rules.

You can bypass the udev rules by **closing Android Studio** and
starting the ADB server as the superuser `root`:

```shell
$ .ci/local/share/android-sdk/platform-tools/adb kill-server

$ sudo .ci/local/share/android-sdk/platform-tools/adb start-server
* daemon not running; starting now at tcp:5037
* daemon started successfully

$ .ci/local/share/android-sdk/platform-tools/adb devices
List of devices attached
HA1Q16K0        unauthorized
```

If you see the `unauthorized`, go to your Android device and select "Always allow from
this computer" and choose `ALLOW` in the `Allow USB debugging?` popup.

Then you should see:

```shell
$ .ci/local/share/android-sdk/platform-tools/adb devices
List of devices attached
HA1Q16K0        device
```

You can now restart Android Studio, go to Tools > Device Manager and see your
Android device in the Physical tab.

### Method 2 - ADB TCP server

Follow https://stackoverflow.com/questions/62145379/how-to-connect-android-studio-running-inside-wsl2-with-connected-devices-or-andr/66084929#66084929

## Enabling Android Emulator

Inside Android Studio you can (and should) install a Virtual Device (aka. the Android Emulator) in the `Tools > Device Manager` menu. It run it within Android Studio requires some minor manual steps.

Then open an editor:

```shell
sudo vim /etc/wsl.conf
```

And add the following lines (press lowercase "i" to insert text):

```text
[wsl2]
nestedVirtualization=true
```

Press ESCAPE and then :wq (COLON, w, q) to exit and save. Make sure you use COLON and not SEMICOLON.

Finally, you will need to all your WSL2 programs and from the Command Prompt run:

```shell
wsl --shutdown
```

Those steps come from https://serverfault.com/a/1115773

