# QEMU Manager
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?logo=git)  ![License](https://img.shields.io/badge/license-gpl-brightgreen.svg?logo=open-source-initiative)  

An adventurous re-imagining of a macOS frontend for [QEMU](https://www.qemu.org), originally created by **Jean-David Gadina (XS-Labs)**. This project is intended for users who know their way around virtualization, emulation, and QEMU’s many moving parts. While its user interface has been modernized, it’s still a power-user tool at heart.

![Screenshot](Assets/Screenshots/Screenshot.png "Screenshot")

---

## Why This Rework?
- **Fresh Codebase:** Old, deprecated, or redundant code has been pruned and replaced with cleaner, modern Swift.
- **More Features:** Hypervisor Framework integration, UEFI boot, USB, advanced networking, and more.
- **Wider Architecture Coverage:** From m68k Mac classics to Windows 11 ARM, it supports a broad range of QEMU architectures for retro-computing fans and cutting-edge testers alike. Allows to create virtual machines like a real champ.
- **Enhanced UI:** Though not fully Apple HIG-compliant, the interface is far smoother, more intuitive, and offers direct access to powerful settings, all while keeping the older-style Cocoa interface framework.
- **QEMU built-in:** Instead of requiring the user to install qemu on their system, this project already bundles a modern and up-to-date version ready to work out-of-the-box.

---

## Quick Heads-Up
- **Complexity:** If you’re new to QEMU, be prepared for a learning curve. This app exposes QEMU’s depth rather than hiding it.
- **Experimental UI:** It’s improved, but still evolving. User feedback is welcome.

---

## License
Released under **GNU General Public License (GPLv3)**, maintaining the original project’s licensing terms.

---

## Credits & Original Repo
- Originally developed by: **Jean-David Gadina (XS-Labs)**
- Check out the original: [QEMU-Manager on GitHub](https://github.com/macmade/QEMU-Manager)
