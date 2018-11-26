## installr

A bare-bones tool to install macOS and a set of packages on a target volume.
Typically these would be packages that "enroll" the machine into your management system; upon completion of the macOS install these tools would take over and continue the setup and configuration of the machine.

installr is designed to run in Recovery boot (and also possibly Internet Recovery), allowing you to reinstall a machine for redeployment.

If you are preparing a fresh-out-of-the-box machine, consider NOT reinstalling macOS and just installing your additional packages. [bootstrappr](https://github.com/munki/bootstrappr) can help you with that task. 

### macOS Installer

Copy an Install macOS application into the install/ directory. This must be a "full" installer, containing the Contents/Resources/startosinstall tool.

I've tested the 10.13.4 (17E199), 10.13.6 (17G65), 10.14 (18A391), and 10.14.1 (18B75) installers. Older installers may or may not work.

### Packages

Add desired packages to the `install/packages` directory. Ensure all packages you add can be properly installed to volumes other than the current boot volume.

`startosinstall` requires that all additional packages be Distribution-style packages (typically built with `productbuild`) and not component-style packages (typically built with `pkgbuild`).

If your packages just have payloads, they should work fine. Pre- and postinstall scripts need to be checked to not use absolute paths to the current startup volume. The installer system passes the target volume in the third argument `$3` to installation scripts.

`startosinstall` in High Sierra ignores additional package's RestartActions. This means that if software installed by one or more or your packages requires a restart for full functionality, it won't be fully functional when the High Sierra installer completes its work.

### Order

The startosinstall tool will work through the packages in alphanumerical order. To control the order, you can prefix filenames with numbers.

#### T2 Macs

installr is particularly useful with Macs with T2 chips, which do not support NetBoot, and are tricky to get to boot from external media. To use installr to install macOS and additional packages on a T2 Mac, you'd boot into Recovery (Command-R at start up), and mount the installr disk and run installr.

### Usage scenarios

#### Scenario #1: USB Thumb drive

* Preparation:
  * Copy the contents of the install directory to a USB Thumb drive.
* Running installr:
  * Start up in Recovery mode.
  * Connect USB Thumbdrive.
  * Open Terminal (from the Utilities menu if in Recovery).
  * `/Volumes/VOLUME_NAME/run` (use `sudo` if not in Recovery)

#### Scenario #2: Disk image via HTTP

* Preparation:
  * Create a disk image using the `make_dmg.sh` script.
  * Copy the disk image to a web server.
* Running installr:
  * Start up in Recovery mode.
  * Open Terminal (from the Utilities menu if in Recovery).
  * `hdiutil mount <your_bootstrap_dmg_url>`
  * `/Volumes/install/run` (use `sudo` if not in Recovery)

