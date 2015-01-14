(function() {
  var Promise, pcon, plugin1, plugin2, plugin3;

  pcon = require('./conveyor.js');

  Promise = require('bluebird');

  plugin1 = pcon('plugin 1', function() {
    return console.log('Hello Plugin 1!');
  });

  plugin2 = pcon('plugin 2', function() {
    return console.log('Hello Plugin 2!');
  });

  plugin3 = pcon('plugin 3', function(test) {
    console.log(test);
    return 'Another test value!';
  });

  new pcon.Conveyor({
    test: 'This is a test property!'
  }).then(plugin1()).then(plugin2()).then(plugin3({
    input: 'test'
  })).then(plugin3())["catch"](function(error) {
    return console.log(error);
  }).done();

}).call(this);
