coffee -cj fuckr.js services/*.coffee controllers/*.coffee fuckr.coffee
uglifyjs fuckr.js -o fuckr.min.js
rm fuckr.js
