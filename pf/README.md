---
layout: post
title:  "Firewall dengan OpenBSD PF bagian Kedua"
date:   2020-02-03 12:26:56 +0800
categories: pf
---

# Bismillah,

Sebagaimana yang saya tulis pada tutorial nftables bagian 
[keempat](https://www.muntaza.id/nftables/2020/01/30/nftables-keempat.html),
bahwa, walaupun sudah level 3, namun settings nftables tersebut
masih belum mampu melindungi server dari serangan:
-   [DDOS](https://en.wikipedia.org/wiki/Denial-of-service_attack#Distributed_DoS_attack)

    DDOS ini bahkan bisa saja hanya menggunakan tools semisal 
    [apache benchmark](https://blog.getpolymorph.com/7-tips-for-heavy-load-testing-with-apache-bench-b1127916b7b6),
    sehingga sangat perlu sebuah firewall memiliki fitur anti DDOS.

-   [SYN Attack](https://en.wikipedia.org/wiki/SYN_flood)

    SYN Attack ini termasuk kategori DDOS juga, sehingga sebuah firewall
    haruslah mampu menahan serangan jenis ini.

Di sini, saya akan melanjutkan tulisan saya sebelumnya tentang 
[pf firewall](https://www.muntaza.id/openbsd/2019/08/31/openbsd-pf-cloud.html),
walaupun pada tulisan kali ini, akan saya ulang kembali beberapa hal yang telah 
saya sebutkan pada tulisan tersebut.

    

# Penutup


# Alhamdulillah


Daftar Pustaka

- [OpenBSD PF FAQ](https://www.openbsd.org/faq/pf/)
