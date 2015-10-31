var NwBuilder = require('node-webkit-builder');
var nw = new NwBuilder({
  files: 'fuckr/**',
  platforms: ['win32', 'osx64', 'linux64', 'win64'],
  version: '0.13.0-alpha4',
  appName: 'Fuckr',
  appVersion: '0.13.0-alpha4',
  winIco: /^win/.test(process.platform) ? 'icons/win.ico' : null,
  macIcns: 'icons/mac.icns'
});

nw.on('log', console.log);

nw.build().then(function () {
  console.log('all done!');
}).catch(function (error) {
  console.error(error);
});
