require 'opal'
require 'jquery-2.1.0.min'
require 'opal-jquery'
require 'hammer.min'
require 'hammer.fakemultitouch'
require 'jquery.hammer.min'

`
Hammer.plugins.fakeMultitouch();
$('#container').hammer().on('tap', function(event) {
  $('#container .CodeMirror').toggleClass('flipped');
});`
