---
layout: project
title: capacitor alarm clock
description: capacitor go kaboom human wake up
---

Blows up capacitors to wake you up in the morning.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/eKc19qRxZ5o" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

There are 3 separate capacitor slots, each with its own relay. Powered from USB-C or barrel jack, 12-15v (though 15v is generally more reliable). The microcontroller used is an ESP32, so the time is fetched using NTP. There also is an SSD1315 OLED to display the time and show a configuration menu.
 
### Links

- [Github Repo](https://github.com/ArcaEge/capacitor-alarm-clock)