---
layout: post
title:  "Firewall dengan nftables bagian Keempat"
date:   2020-01-30 12:26:56 +0800
categories: nftables
---

# Bismillah,

Saya telah menulis
tentang [nftables](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)
ini secara bertahap, yaitu bagian
[pertama](https://www.muntaza.id/nftables/2019/12/15/nftables-01.html),
[kedua](https://www.muntaza.id/nftables/2019/12/16/nftables-kedua.html) dan
[ketiga](https://www.muntaza.id/nftables/2019/12/17/nftables-ketiga.html).

Terkadang, seorang admin tidak berani mengaktifkan firewall, alasannya?
Aplikasi saya kok jadi error kalau firewall aktif... Sebenarnya bukan error,
tapi setting firewall nya yang belum tepat... he... he...

Kemudian, agar pada admin bisa mencoba nftables ini, saya akan menulis kan
setting dengan cara bertingkat, yaitu dari level 0 sampai level tertinggi
yaitu level 3. Sehingga, kalau ternyata error, maka firewallnya bisa di
turunkan dulu levelnya.

# Level 0

Pada level ini, firewall aktif, namun semua koneksi di izinkan. Istilah yang
saya pernah dengar (secara makna) dari Pak Budi Rahardjo pada kursus online "Keamanan
Informasi" adalah seorang admin mensetting firewall dengan rules __from any to
any allow__

```text
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
        chain input {
                type filter hook input priority 0;
        }
        chain forward {
                type filter hook forward priority 0;
        }
        chain output {
                type filter hook output priority 0;
        }
}
```

Nah, sebagaimana yang anda lihat, semua koneksi diizinkan. Baik masuk atau
keluar. Keberadaan setting ini sama saja dengan tanpa firewall sama sekali.
Kita kadang perlu mengaktifkan setting ini saat terjadi error jaringan, atau
error di aplikasi, maka kita coba setting ini, untuk mendisable firewall. Bila
ternyata bisa akses ke aplikasi, berarti ada kesalahan setting pada level di
atasnya, namun bila ternyata tidak bisa juga mengakses ke aplikasi, berarti
bukan masalah firewallnya.

# Level 1

Ini level default menurut saya, yaitu izinkan masuk koneski ke tiga port penting, yaitu:
- ssh
- http
- https

Kemudian, mengizinkan semua akses keluar.

```text
#!/usr/sbin/nft -f

flush ruleset

define lo_if  = "lo"

table ip filter {
        chain INPUT {
                type filter hook input priority 0; policy drop;
                ct state established,related accept
                iifname $lo_if accept
                tcp dport { ssh, http, https } accept
        }

        chain FORWARD {
                type filter hook forward priority 0; policy drop;
        }

        chain OUTPUT {
                type filter hook output priority 0; policy accept;
        }
}
```

Sebagaimana yang anda lihat, chain output policy default nya __accept__
sehingga semua koneksi keluar dizinkan.

# Level 2

Nah, pada level ini, semua koneksi masuk hanya dari IP yang berasal dari
Indonesia

```text
#!/usr/sbin/nft -f

flush ruleset

define lo_if  = "lo"

table ip filter {
        include "/etc/ip_indonesia.conf"

        chain INPUT {
                type filter hook input priority 0; policy drop;
                ct state established,related accept
                iifname $lo_if accept
                ip saddr @ip_indonesia tcp dport { ssh, http, https } ct state new accept
                drop
        }

        chain FORWARD {
                type filter hook forward priority 0; policy drop;
        }

        chain OUTPUT {
                type filter hook output priority 0; policy accept;
        }
}
```

File [ip_indonesia.conf](https://www.muntaza.id/assets/ip_indonesia.conf) ini
adalah daftar IP yang berasal dari Indonesia, sebagaimana yang sudah saya
jelaskan pada tulisan bagian
[ketiga](https://www.muntaza.id/nftables/2019/12/17/nftables-ketiga.html).

File ip_indonesia.conf ini di letakkan di direktor /etc.

Saat anda merasa terjadi error di level 2 ini, bisa di turunkan ke level 1.
Namun, pada level ini, anda bisa mendownload aplikasi apapun, karena koneksi
keluar bebas, hanya koneksi masuk yang di batasi.


# Level 3

Pada level 3 ini, fitur anti reverse telnet aktif, yaitu koneksi keluar hanya
pada IP yang kita definisikan. Mengapa perlu melindungi dari serangan reverse
telnet? Jawabannya adalah, kadang terdapat lubang keamanan (security hole) pada
aplikasi, sehingga attacker dapat mengeksekusi tools seperti netcat untuk
membaypas firewall (firewalking) seperti contoh di
[sini](https://www.dummies.com/programming/networking/test-firewall-rules-to-prevent-network-hacks/)
dan di [sini](https://www.cyberciti.biz/tips/howto-linux-iptables-bypass-firewall-restriction.html)

Sangat saya sarankan, untuk website yang memerlukan security tinggi, agar
mengaplikasikan level 3 ini.

```text
#!/usr/sbin/nft -f

flush ruleset

define lo_if  = "lo"

table ip filter {
        include "/etc/ip_indonesia.conf"
        include "/etc/ip_output.conf"

        chain INPUT {
                type filter hook input priority 0; policy drop;
                ct state established,related accept
                iifname $lo_if accept
                ip saddr @ip_indonesia tcp dport { ssh, http, https } ct state new accept
                drop
        }

        chain FORWARD {
                type filter hook forward priority 0; policy drop;
        }

        chain OUTPUT {
                type filter hook output priority 0; policy drop;
                ct state established,related accept
                oifname $lo_if accept
                ip daddr @ip_output accept
                drop
        }
}
```

Mirip seperti level 2, namun anda bisa lihat, bahwa chain output hanya
mengizinkan koneksi ke IP yang di daftar kan di table ip_output. Ini isi file
ip_output.conf:


```text
        set ip_output {
                type ipv4_addr
                flags interval
                auto-merge
                elements = { 8.8.4.4, 8.8.8.8,
                             128.31.0.63,
                             128.61.240.73, 128.101.240.215,
                             149.20.4.14, 151.101.10.133,
                             200.17.202.197, 212.211.132.250,
                             217.196.149.233 }
        }
```

Pada contoh ini, saya hanya mengizinkan koneksi keluar kepada:
- DNS Google
- web.debian.org
- security.debian.org

Hal ini agar saya bisa menginstall aplikasi dari distro debian ini, sebagaimana
mirror yang terdaftar di /etc/apt/sources.list

```text
muntaza@kalsel:~$ cat /etc/apt/sources.list
#

deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main

deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main

# buster-updates, previously known as 'volatile'
deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main
```

Kita bisa menggunakan tools __host__ untuk melihat IP suatu domain, contoh:

```text
muntaza@kalsel:~$ host security.debian.org
security.debian.org has address 128.61.240.73
security.debian.org has address 128.31.0.63
security.debian.org has address 200.17.202.197
security.debian.org has address 128.101.240.215
security.debian.org has address 149.20.4.14
security.debian.org has address 217.196.149.233
security.debian.org has address 212.211.132.250
security.debian.org has IPv6 address 2001:4f8:1:c::14
security.debian.org has IPv6 address 2001:a78:5:1:216:35ff:fe7f:6ceb
security.debian.org has IPv6 address 2801:82:80ff:8009:e61f:13ff:fe63:8e88
security.debian.org has IPv6 address 2603:400a:ffff:bb8::801f:3f
security.debian.org has IPv6 address 2607:ea00:101:3c0b::1deb:215
security.debian.org has IPv6 address 2610:148:1f10:3::73
security.debian.org has IPv6 address 2a02:16a8:dc41:100::233
security.debian.org mail is handled by 10 mailly.debian.org.
security.debian.org mail is handled by 10 muffat.debian.org.
```

Ketika server anda (yang seyogyanya memakai level 3 ini), perlu untuk
terhubung keluar, tinggal anda tambahkan IP server tujuan itu ke file
ip_output.conf ini. Terlihat seperti memberatkan, kok saya harus sering
mengedit file ip_output.conf sih? Iya, itu hanya sementara saja, saat semua
IP yang anda perlukan sudah terdaftar, anda bisa tidur lebih nyenyak dan lebih
tenang beristirahat, karena salah satu celah penting (reverse telnet) telah di tutup.

# Penutup

Walaupun sudah level 3, masih ada beberapa kekurangan pada setting firewall nftables
ini. yaitu:

- Synproxy
- Anti DDOS

Akhirnya, jangan lupa berdo'a, semoga Allah Ta'ala selalu menjaga kita. Semoga
Allah Ta'ala menjaga server kita di dunia maya. Aamiin.

# Alhamdulillah


Daftar Pustaka
- [Debian Linux: nftables](https://wiki.debian.org/nftables)
- [Moving from iptables to nftables](https://wiki.nftables.org/wiki-nftables/index.php/Moving_from_iptables_to_nftables)
- [Using nftables in Red Hat Enterprise Linux 8](https://www.redhat.com/en/blog/using-nftables-red-hat-enterprise-linux-8)
- [Redhat: Chapter 30. Getting started with nftables](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking)
- [Arch Linux: nftables](https://wiki.archlinux.org/index.php/Nftables)
