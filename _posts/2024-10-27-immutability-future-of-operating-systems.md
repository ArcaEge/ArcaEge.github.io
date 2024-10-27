---
title: Immutability: the future of operating systems?
date: 2024-10-27 22:00:00 +0000
categories: [Operating_Systems, Atomic]
tags: [fedora]
image: 
    path: /assets/img/content/2024-10-27-immutability-future-of-operating-systems/cover.jpg
    alt: An abstract render of a floating icosahedron
---

# Immutability: the future of operating systems?

A recent trend in the design of operating systems has been the emergence of so-called “immutable” operating systems. They sometimes go by the names “image-based” or “atomic” operating systems but they all have the same goal: to have an operating system (OS) that is never in a broken, unbootable state. And they accomplish this goal well, because I’ve been using an immutable Linux-based OS, Fedora Silverblue, for the last five months as an experiment and I’d like to share my findings. However, to be able to properly understand the purpose of immutable operating systems, we first need to start by looking at the drawbacks of the traditional OS model.

## Traditional operating systems

### Updates

In traditional operating systems, when the system is being updated, a patch which contains the files that need to be changed is downloaded[^1] from the manufacturer’s website. The system is then rebooted into “update mode”: an alternative, small environment where the entire system is usually loaded into RAM instead of running off the disk[^2]. This now means that every aspect of the operating system can be updated – even the kernel – since the “update mode” environment is running from RAM. Once the patches have been applied, the system is rebooted back into “normal mode”.

However, there are a few problems with this. Imagine that the system lost power during the patching process or the update failed in some way. The system is now left in an undefined, potentially broken state. Secondly, assume that the update, let’s say, caused your webcam drivers to stop functioning and you need to revert the update. Or worse, the update completed successfully but happened to brick your system. Trying to revert an update whilst you don’t even have a functioning computer is not a very exciting process.

[^1]: This is the case in Windows, although in Linux updates usually come in the form of many small patches that are downloaded from a package repository. This is handled by the package manager (e.g apt in Debian-based distributions, dnf in Red Hat-based and pacman in Arch-based distributions)

[^2]: I am very much simplifying here. Modern operating systems use a variety of different mechanisms for this and it can also depend on what is being updated. This would usually only be done when updating key processes such as the kernel. When updating something that isn’t as important, the update is usually applied while the system is in “normal mode” and the process is restarted afterwards, avoiding a reboot. In some Linux distributions such as SUSE, some parts of the kernel can be updated whilst the system is running using a process called ‘live patching’.

### Installing/uninstalling software

Let’s say you are trying to install a program such as Firefox using Ubuntu, a traditional Debian-based Linux distribution. You would run something like `sudo apt-get install firefox` which would download Firefox and its dependencies and install all of it onto your system. Now imagine that the configuration for one of the dependencies for Firefox was corrupted and is configured so that it required a critical part of your system to be uninstalled. You would end up with an unbootable system in this case.

In addition, sometimes programs can leave small files lying around in your system folders after uninstallation. For example, when you uninstall a program on Windows, you may have noticed that sometimes some traces such as its folder under `C:\Program Files\` or its registry changes still remain, cluttering up your system, taking up space and sometimes even degrading performance.

## Immutable operating systems

> [!NOTE]  
> I will be mainly focusing on Fedora Silverblue[^3] in this section, an immutable version of Fedora Linux since it is one of the most widely used atomic Linux distributions. It also is the operating system I’ve been using for the last five months and therefore have the most experience with, as I have said in the introduction. However, there are other immutable operating systems too, such as Vanilla OS (Debian-based) and blendOS (Arch-based). NixOS is outside the scope of this since it takes a slightly different approach to immutability.
>
> [^3]:This also applies to Fedora Kinoite, Sway etc., since they are the same core OS with a different desktop environment.

Immutable operating systems work using a different principle. The core operating system directories are read-only (hence the name immutable), except for the configuration and log directories, which are typically under `/etc/` and `/var/` in a UNIX-based system. So how do we install programs and updates? Obviously, updates require the system folders to be modified. Programs usually require this as well. For example, if you were to install Firefox, in a normal system it would put the firefox executable under `/usr/bin/`, a directory that is read-only on an immutable system.

When updating the system, instead of downloading and installing many small patches to system files, a whole new known-to-be-working base system image is downloaded and installed as a secondary system image[^4], separately from the system image that the OS is currently running off of. After this, if everything is successful, the bootloader settings are updated in a single atomic operation (hence the name atomic) so that the new system image becomes the primary boot image and the old system image (the one the system is currently running off of) becomes the secondary image. To the running system, nothing changes, however after a reboot, the bootloader (GRUB in this case) loads the new primary image. However, the secondary image is also still retained and the user can choose to boot from the secondary image from the bootloader.

This has a few big advantages. Firstly, the chances of an update failing are near-zero. There isn’t very much that can go wrong when downloading a known-good system image and installing it onto a secondary space. Secondly, even if something goes wrong – for example if the image is in some way incompatible with the drivers for your graphics card and now your display output doesn’t work once your graphics drivers get initialised and you have research homework due the next day and it’s 11:27 PM (thanks Nvidia 🙂) – you can easily roll back by choosing to boot from the secondary image in the bootloader and running a single command, `rpm-ostree rollback` in the case of Fedora Silverblue, which sets the secondary image that the OS is currently running off of as the primary image, which means that the working, non-broken old image is loaded by default when the system is restarted. This means that the OS is always in a working state or can be restored to a working state instantly. In addition, it means that you never need to wait for an update to finish – you can continue using the system normally whilst the update is installed and do a quick restart to apply it[^5], even with any kind of kernel update.

Another key advantage of the immutable approach is that it makes the core operating system modular, which means that it can be easily swapped out for another version through a process called “rebasing”. For example, if you were on Fedora Silverblue, you could run a command like

``` bash
rpm-ostree rebase fedora:fedora/40/x86_64/kinoite
```

to rebase your system to Fedora Kinoite, a version of Fedora Linux with the KDE Plasma desktop environment. After a quick reboot, your system would be indistinguishable compared to if you had installed Fedora Kinoite from the start, and you would now start receiving system updates from the Fedora Kinoite repository. This is extremely powerful, since you can rebase to any system image – you can even create your own, thanks to the emergence of projects such as Universal Blue, which let you easily create your own system images from a simple configuration file. Want to deploy the exact same operating system with its custom set of programs on a fleet of computers? Just create a custom system image and rebase to it on each computer, job done. If you release a new version of your system image, the fleet of computers will update to it automatically.

So how do we install programs? This is done through a process called “layering”. In short, when you install a program, a copy of the system image is created and the program is installed (or “layered”) onto that copy by the package manager. Afterwards, the copy image is set to become the primary system image so that it is loaded on the next boot[^5]. When the system is being updated, the programs that have been installed are layered on top of the new system image before the new image is set as the primary image.

[^4]: Again, this is a bit of a simplification for the sake of ease of explanation. In reality (at least in operating systems that use the tool OSTree for immutability, such as Fedora Silverblue), a Git-like approach is used where it works using “commits” instead of wholly separate system images. This saves space – especially when pinned deployments are involved – since only the difference between the commits is stored instead of storing separate system images.

[^5]: If you aren’t updating the kernel, you don’t even need to restart. You can simply run `sudo rpm-ostree apply-live` or an equivalent command to do an in-place application of the update. You can also use this command to avoid restarting when you install a program. The explanation of how that works is outside of the scope of this footnote.

### Downsides of immutable operating systems

A downside of this is that layering packages slows down system updates since each package adds an additional step, therefore layering isn’t recommended unless you have to. Instead, alternative formats such as Flatpaks are used, which is a common format used for Linux applications where programs are installed in a sandboxed environment. Alternatively, programs can be installed in a container tool such as Distrobox, which seamlessly integrates a container of your preferred Linux distribution into the system.

Another downside is that since the core operating system is read-only, this can break compatibility with programs that need to modify the core files. Luckily, these programs are extremely rare and you can usually install them in container tools like Distrobox.

## My experience and conclusion

Over my five months of using an immutable Linux distribution, the main difficulty I’ve had was just getting used to a new way of installing programs and modifying system files. Even then, it only took me a few weeks to get used to it and I didn’t have much difficulty afterwards thanks to the ever-growing community and documentation around Silverblue that allowed me to easily find ways around any issues I encountered. Overall, it has been the most stable OS experience I’ve ever had by far.