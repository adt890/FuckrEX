var NwBuilder = require('node-webkit-builder');
var nw = new NwBuilder({
  files: 'fuckr/**',
  platforms: ['osx64'],
  version: '0.12.1',
  appName: 'Fuckr',
  appVersion: '1.1.0',
  winIco: 'icons/win.ico',
  macIcns: 'icons/mac.icns'
});

nw.on('log', console.log);

nw.build().then(function () {
  console.log('all done!');
}).catch(function (error) {
  console.error(error);
});
