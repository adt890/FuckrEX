#[fuckr](http://fuckr.me/): Grindr™ for [Mac](http://fuckr.me/downloads/Fuckr.dmg) and [Windows](http://fuckr.me/downloads/Fuckr.dmg)

fuckr is a Grindr™ client for desktop built with Node-Webkit, AngularJS and a modified version of [jacasr](https://github.com/tdebarochez/jacasr).

##Run
First, install node-webkit (eg. `npm install -g nodewebkit`). Then

    cd fuckr/
    nw .

##Package

    npm install
    node package.js

And to package as a DMG for OSX: 

    npm install -g appdmg
    appdmg dmg.json

##Reverse engineering grindr
If there's anything you wanna know about Grindr that's not in the code, you can easily analyse the HTTP part with [mitmproxy](http://mitmproxy.org/)'s [regular proxy](https://mitmproxy.org/doc/modes.html) mode and the XMPP part with... just Wireshark (and [ettercap](http://www.kioptrix.com/blog/ettercap-command-line-basics/) to save time) since grindr XMPP client doesn't bother encrypting!

##Tip to Contribute
Releases history is hosted in gh-pages branch so to fetch code only use
`git clone https://github.com/tomlandia/fuckr.git --branch master --single-branch`

##Credits
- Logo: [Reyson Morales](http://reyson-morales.deviantart.com/)
- Contributions: [Victor Grego](https://github.com/victorgrego)
- Download Page: [Kyle Power's](https://twitter.com/mfkp/) (copied from [Tinder++](https://github.com/mfkp/tinderplusplus))
