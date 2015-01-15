(function() {
  var Promise, pcon, plugin1, plugin2, plugin3;

  pcon = require('./conveyor.js');

  Promise = require('bluebird');

  plugin1 = pcon('plugin 1', function() {
    return console.log(this.pipeline.current);
  });

  plugin2 = pcon('plugin 2', function() {
    return console.log(this.pipeline.current);
  });

  plugin3 = pcon('plugin 3', function() {
    return console.log(this.pipeline.current);
  });

  new pcon.Conveyor({
    test: 'This is a test property!'
  }).then(plugin1()).then(plugin2()).then(plugin3())["catch"](function(error) {
    return console.log(error);
  }).done();

}).call(this);
