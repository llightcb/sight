```
       ______
      (  mu  )
       ------
          \   ^__^
           \  (oo)\_______                s i g h t            ←
              (__)\       )\/\
                  ||----w |
                  ||     ||

```

<br/>

## 1: howtostart

[alpine](https://alpinelinux.org/downloads/) standard | extended | virtual image & [installation](https://docs.alpinelinux.org/user-handbook/0.1a/Installing/manual.html)

```bash
# example
setup-keymap → setup-hostname → setup-interfaces  ↓
  rc-service networking start → setup-timezone    ↓
setup-apkrepos → passwd → setup-sshd → setup-ntp  ↓
rc-update add networking boot → setup-disk → reboot
```

## 2: git, clone

```
# apk add git
# git clone https://github.com/llightcb/sight.git
```

## 3: run script

```
# sh sight/install.sh
```

## overview

<p align="center">
  <img width="900" height="500" src="./screen.png">
</p>

## consider

```
 - enable xwayland → comment sway config line 2
 ~ resolution, refresh rate sway config line 12
 ~ cursor theme and/or size sway config line 43
 + gpu accel. for browser → sway config line 78
 ~ default terminal font - size foot.ini line 7

 - if laptop: $ doas powertop --html=power.html
 ~ hour (daily) for updatedb: $ doas crontab -e
 ~ hour/day (weekly) for trim:      — „ —
 - interrupt key = ctrl+shift+c (ctrl+c = copy)
 - VMSVGA → $ set -Ux WLR_NO_HARDWARE_CURSORS 1

 $ dnv /etc/dnscrypt-proxy/dnscrypt-proxy.toml
 | list → https://dnscrypt.info/public-servers
 $ dnv /etc/chrony/chrony.conf → change to nts
 | an _example_: branch platonic → chrony.conf
 - run: $ ipt --sf / $ bll -r / $ bll -g # end
```

## function

```bash
$ cbb       # <cmd> busybox ?
$ dnv       # doasnvim ~/init
$ 2fa       # <foo>  oathtool
$ cpu       # (oo) → $ cpu -h
$ esa       # eval → ssh agent
$ img       # picture overview
$ chc       # chrony check ntp
$ iso       # wipe -a/-o write
$ cfn       # cleanup filename
$ bit       # suid / sgid bits
$ info      # (oo) → $ info -h
$ mpvl      # mpv localprofile
$ pkgi      # info: $ pkgi -h
$ fhd       # <foo> dd fish ↓
$ ffp       # (oo) → $ ffp -h
$ sfm       # (oo) → $ sfm -h
$ man       # more less 4 man
$ ipt       # (oo) → $ ipt -h
$ bll       # (oo) → $ bll -h
$ mpc       # kernel ↓modules
$ sh2       # sync /home/ to:
$ rcl       # rclog: $ rcl -h
$ vlk       # (v)lock  screen
$ tf        # ↑ @ transfer.sh
$ ff        # ? → $ ff --help
$ pw        # pass: → $ pw -h
$ cd        # cd + list files
$ nt        # note: → $ nt -h
$ se        # hwmon  coretemp
$ pv        # ⏎ search/stream
$ rs        # reset  terminal
$ vi        # stands 4 neovim
$ gd        # git diff less+c

# fish abbreviations : $ abbr
```

## testing

```bash
# example

qemu-img \
create -f qcow2 testa.img 10G

qemu-system-x86_64 \
-m 1024 \
-boot d \
-enable-kvm \
-cpu host \
-smp 3 \
-net nic \
-net user \
-hda testa.img \
-display gtk \
-cdrom alpine-<x>.iso

# login as root
# setup-alpine¹
# done poweroff

qemu-system-x86_64 \
-m 1024 \
-boot d \
-enable-kvm \
-cpu host \
-smp 3 \
-net nic \
-net user \
-hda testa.img \
-display gtk

# login as root
# take step 2,3 ↑
# better reboot
# login as root
# poweroff

-testing ↓

# login as user

qemu-system-x86_64 \
-m 1024 \
-boot d \
-enable-kvm \
-cpu host \
-smp 3 \
-net nic \
-net user \
-hda testa.img \
-vga qxl \
-device virtio-gpu-pci \
-display gtk,full-screen=on,gl=on,show-cursor=on,grab-on-hover=on
```
→ [ ¹ ](https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html) ←
