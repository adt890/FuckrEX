var NwBuilder = require('nw-builder');
var nw = new NwBuilder({
  files: 'fuckr/**',
  platforms: ['win32', 'osx64', 'linux64', 'win64'],
  version: '0.12.1',
  appName: 'Fuckr',
  appVersion: '1.3.0',
  winIco: /^win/.test(process.platform) ? 'icons/win.ico' : null,
  macIcns: 'icons/mac.icns'
});

nw.on('log', console.log);

nw.build().then(function () {
  console.log('all done!');
}).catch(function (error) {
  console.error(error);
});
