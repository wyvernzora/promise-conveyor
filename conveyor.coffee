# --------------------------------------------------------------------------- #
#                                                                             #
# Promise Conveyor: Pipe data down the promise chain.                         #
#                                                                             #
# --------------------------------------------------------------------------- #
_       = require('underscore')
Promise = require('bluebird')



# --------------------------------------------------------------------------- #
# Plugin factory, ahem, factory.                                              #
# --------------------------------------------------------------------------- #
pcon = module.exports = (name, fn) ->
  # Callback factory
  plugin = (config) ->
    # Create configuration object
    config ?= { }
    # Callback wrapper
    return (pipeline) ->
      # Update current pipeline position
      pipeline.currentPlugin = plugin
      # Extract arguments
      args = pipeline.extract(config.input)
      # Create the context object
      context = _.extend({ }, config:config, pipeline:pipeline)
      # Call the callback and save the result
      result = fn.apply(context, args)
      # result may be a promise, so make sure to resolve it
      return Promise.resolve(result)
        .then (result) -> pipeline.insert(config.output, result)

  # Attach plugin metadata here
  plugin.name = name
  return plugin

# --------------------------------------------------------------------------- #
# Conveyor object, start of the conveyor line.                                #
# --------------------------------------------------------------------------- #
class pcon.Conveyor

  constructor: (data) ->
    @data = _.extend {}, data
    @lastInput  = null  # Input path of the last plugin
    @lastOutput = null  # Output path of the last plugin
    @currentPlugin = null # Currently running plugin
    @promise = Promise.resolve(_.omit @, 'then', 'catch', 'done')

  # Extracts data from @data as specified by path parameter.
  extract: (path) ->
    # UNDEFINED: use last output as path
    if _.isUndefined(path) then path = @lastOutput
    # Set the last input path
    @lastInput = path
    # NULL: return the entire @data
    if _.isNull(path) then return [@data]
    # STRING: return the deep property of the @data
    if _.isString(path) then return [vetluga.prop(@data, path)]
    # ARRAY: return the array of specified properties
    if _.isArray(path) then return _.map path, (i) => vetluga.prop(@data, i)
    # We do not know what this is, so we run scream and panic!
    throw new Error('Pipeline.extract: Unexpected path type: ' + typeof path)

  # Inserts data returned by plugin into the pipeline.
  insert: (path, value) ->
    # NULL: directly extend @data
    if _.isNull(path)
      @lastOutput = null
      _.extend @data, value
      return @
    # STRING: deep property access
    if _.isString(path)
      @lastOutput = path
      vetluga.prop(@data, path, value)
      return @
    # UNDEFINED: there are two possibilities here...
    if _.isUndefined(path)
      # STRING INPUT: output right there
      if _.isString(@lastInput)
        @lastOutput = @lastInput
        vetluga.prop(@data, @lastInput, value)
      # NO STRING INPUT: ignore this one
      else
        @lastOutput = null
      return @
    # OTHER: scream run and panic!
    throw new Error('Pipeline.insert: Unexpected path type: ' + typeof path)

  # Something went wrong! We shall scream, run, and panic!
  panic: (message, status = 500, details) ->

  # Wrapper for chaining promises
  then: (plugin) ->
    @promise = @promise.then(plugin)
    return @

  # Wrapper for handling errors
  catch: (handler) ->
    @promise = @promise.catch(handler)
    return @

  # @wrapper for throwing unhandled exceptions
  done: ->
    @promise.done()
    return @

# --------------------------------------------------------------------------- #
# Error class.                                                                #
# --------------------------------------------------------------------------- #
class pcon.Error extends Error

  constructor: (@pluginName, @message, @details) ->
    # Append details to message if it has custom toString() function
    if @details.toString isnt Object.prototype.toString
      @message += ' (' + @details.toString() + ')'
    super(@message)

  toString: ->
    return 'Plugin [#{@pluginName}] panic: #{@message}'

# --------------------------------------------------------------------------- #
# Utility functions and such.                                                 #
# --------------------------------------------------------------------------- #
prop = (obj, prop, value) ->
  # Make sure that object and prop are defiend
  if (not prop) or (not obj) then return
  # Convert to dot notation and split property path
  list = prop.replace(/\[(\w+)\]/g, '.$1').replace(/^\./, '').split('.')
  # Find the specified property
  while list.length > 1
    n = list.shift()
    # Handle undefined properties
    if _.isUndefined obj[n]
      # ..in case of retrieval, abort
      if _.isUndefined(value) then return
      # ..in case of assignment, create empty object
      else obj[n] = { }
    obj = obj[n]
  # Perform the operation
  if _.isUndefined value
    return if not obj then null else obj[list[0]]
  else
    obj[list[0]] = value
