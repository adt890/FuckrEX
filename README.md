#[fuckr](http://fuckr.me/): Grindr™ for [Mac](http://fuckr.me/downloads/Fuckr.dmg) and [Windows](http://fuckr.me/downloads/Fuckr.dmg)

fuckr is a Grindr™ client for desktop built with Node Webkit, node-xmpp and Angular.

##This is VictorGrego improvements of Fuckr

Patch Notes:
- Emits a notification sound when a message arrives.
- Names are now shown over the profile pictures when you hover your mouse;
- Profiles now display their names on the profile view;
- Profiles now display the "Last Seen" information;
- Unread messages are shown in lighter gray until you read them;
- Images received are now links, therefore, you can see them bigger;
- Update Profile now includes "Show Distance" and "Show Age" options;
- Update Profile now have a Display Name Field;
- Other small improvements;

NOTE: I coded all in the fuckr.js, therefore you should not be able to get the best of compiling the .coffee

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
Package structure and landing page originally copied from [Kyle Power's](https://twitter.com/mfkp/)'s [Tinder++](https://github.com/mfkp/tinderplusplus).
