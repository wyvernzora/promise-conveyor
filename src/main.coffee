pcon = require('./conveyor.js')
Promise = require('bluebird')

plugin1 = pcon 'plugin 1', -> console.log @pipeline.current
plugin2 = pcon 'plugin 2', -> console.log @pipeline.current
plugin3 = pcon 'plugin 3', -> console.log @pipeline.current

new pcon.Conveyor(test: 'This is a test property!')
  .then plugin1()
  .then plugin2()
  .then plugin3()
  .catch (error) ->
    console.log error
  .done()
