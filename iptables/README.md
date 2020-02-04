---
layout: post
title:  "Konfigurasi IPTABLES untuk Laptop"
date:   2019-10-19 12:26:56 +0800
categories: linux
---

# Bismillah,

Firewall IPTABLES saat ini sudah jarang di pakai, namun disini
saya menggunakan IPTABLES untuk memblokir akses dari luar ke
Laptop, dan mengizinkan akses dari Laptop ke Internet. Konfigurasi
ini di tulis dengan script sederhana, yang akan saya jelaskan sedikit
makna nya.

Adapun untuk penjelasan yang lebih lanjut, bisa melihat toturial
IPTABLES di [sini](https://wiki.archlinux.org/index.php/Simple_stateful_firewall)

Linux yang saya gunakan adalah Linux Mint 19. Berikut ini script
IPTABLES nya:

```text
#!/bin/bash
echo "jalankan firewall"

IPTABLES=/sbin/iptables

$IPTABLES -F
$IPTABLES -X

#Set default policies
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P INPUT DROP

#Accept localhost
$IPTABLES -A INPUT -i lo -j ACCEPT

$IPTABLES -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

echo
echo "iptables firewall is up `date`"
```

Berikut ini penjelasan ringkas nya:

```text
$IPTABLES -F
$IPTABLES -X
```

Membersihkan Perintah IPTABLES sebelumnya, jika ada.

```text
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P INPUT DROP
```

Koneksi Masuk dan Forward di Tolak, Koneksi Keluar di izinkan

```text
$IPTABLES -A INPUT -i lo -j ACCEPT
```

Izinkan koneksi dari dan ke Localhost

```text
$IPTABLES -I INPUT 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

Saat koneksi keluar, paket yang datang dari luar memiliki penanda
ESTABLISHED, yang berarti paket tersebut adalah balasan dari server
yang dituju, maka izin kan paket tersebut Masuk.

Sekian penjelasan makna nya. File script tersebut saya simpan di:

```text
/home/muntaza/bin/iptables_mint.sh
```

Kemudian, agar tiap booting firewall ini aktif, kita perlu mengkonfigurasi
modul [rc-local](https://www.linuxbabe.com/linux-server/how-to-enable-etcrc-local-with-systemd)
di systemd. Berikut langkahnya:

Edit file
```text
$ vim /etc/systemd/system/rc-local.service
```

Lalu isi file tersebut adalah:

```text
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 RemainAfterExit=yes

[Install]
 WantedBy=mutli-user.target
```

Buat file /etc/rc.local yang isinya:

```text
#!/bin/bash

/home/muntaza/bin/iptables_mint.sh
```

Lalu jadikan file tersebut executable:

```text
$ sudo chmod +x /etc/rc.local
```

Aktifkan modul rc-local dan cek hasilnya:

```text
$ sudo systemctl stop rc-local
$ sudo systemctl start rc-local
$ sudo systemctl enable rc-local
$ sudo systemctl status rc-local
● rc-local.service - /etc/rc.local Compatibility
   Loaded: loaded (/etc/systemd/system/rc-local.service; enabled; vendor preset: enabled)
  Drop-In: /lib/systemd/system/rc-local.service.d
           └─debian.conf
   Active: active (exited) since Sun 2019-12-01 12:53:09 WITA; 20s ago
    Tasks: 0 (limit: 2127)
   CGroup: /system.slice/rc-local.service

Dec 01 12:53:09 E202SA systemd[1]: Starting /etc/rc.local Compatibility...
Dec 01 12:53:09 E202SA rc.local[8568]: jalankan firewall
Dec 01 12:53:09 E202SA rc.local[8568]: iptables firewall is up Sun Dec  1 12:53:09 WITA 2019
Dec 01 12:53:09 E202SA systemd[1]: Started /etc/rc.local Compatibility.


$ sudo iptables -L -v

Chain INPUT (policy DROP 2 packets, 348 bytes)
 pkts bytes target     prot opt in     out     source               destination
   18  3162 ACCEPT     all  --  any    any     anywhere             anywhere             ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     all  --  lo     any     anywhere             anywhere

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 20 packets, 17275 bytes)
 pkts bytes target     prot opt in     out     source               destination

```


Semoga bermanfaat.

# Alhamdulillah
