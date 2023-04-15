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
 ~ $ de /etc/dnscrypt-proxy/dnscrypt-proxy.toml
 | list →  https://dnscrypt.info/public-servers

 $ de /etc/chrony/chrony.conf → consider "nts"
 | an _example_: branch platonic → chrony.conf
 - nvim toogle syntax-check on/off with Ctrl+l
 | check :Plug{Status,Install,Update,Upgrade}∞
 - vmsvga: $ set -Ux WLR_NO_HARDWARE_CURSORS 1
 - run $ ipt --sf / $ bll -r / maybe¬ $ bll -g
```

## function

```bash
$ chc       # chrony check ntp
$ esa       # eval → ssh agent
$ iso       # wipe -a/-o write
$ img       # picture overview
$ cbb       # <cmd> busybox ?
$ 2fa       # <foo>  oathtool
$ cpu       # (oo) → $ cpu -h
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
$ 2s        # (oo) →  $ 2s -h
$ tf        # ↑ @ transfer.sh
$ lm        # run → shell_gpt
$ ff        # ? → $ ff --help
$ pw        # pass: → $ pw -h
$ cd        # cd + list files
$ nt        # note: → $ nt -h
$ se        # hwmon  coretemp
$ pv        # ⏎ search/stream
$ gd        # git diff less+c
$ cfn       # cleanup filename
$ bit       # suid / sgid bits
$ info      # (oo) → $ info -h
$ mpvl      # mpv localprofile

# fish - abbreviations: $ abbr
```

## testing

```bash
# example

qemu-img \
create -f qcow2 alpine.img 10G

qemu-system-x86_64 \
-m 1024 \
-boot d \
-enable-kvm \
-cpu host \
-smp 3 \
-net nic \
-net user \
-hda alpine.img \
-display gtk \
-cdrom alpine-<x>.iso

# login as root
# setup-alpine¹
# poweroff done

qemu-system-x86_64 \
-m 1024 \
-boot d \
-enable-kvm \
-cpu host \
-smp 3 \
-net nic \
-net user \
-hda alpine.img \
-vga qxl \
-device virtio-gpu-pci \
-display gtk,full-screen=on,gl=on,show-cursor=on,grab-on-hover=on

# login as root
# take step 2,3 ↑
# reboot system
# login as user
```
→ [ ¹ ](https://docs.alpinelinux.org/user-handbook/0.1a/Installing/setup_alpine.html) ←
