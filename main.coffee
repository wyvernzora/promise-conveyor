pcon = require('./conveyor.js')
Promise = require('bluebird')

plugin1 = pcon 'plugin 1', -> console.log 'Hello Plugin 1!'
plugin2 = pcon 'plugin 2', -> throw new Error('Test Error')
plugin3 = pcon 'plugin 3', -> console.log 'Hello Plugin 3!'

new pcon.Conveyor(test: 'This is a test property!')
  .then plugin1()
  .then plugin2()
  .then plugin3()
  .catch (error) -> console.log 'ERROR!'
  .done()