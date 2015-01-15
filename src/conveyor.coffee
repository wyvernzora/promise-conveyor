# --------------------------------------------------------------------------- #
#                                                                             #
# Promise Conveyor: Pipe data down the promise chain.                         #
#                                                                             #
# --------------------------------------------------------------------------- #
_       = require('underscore')
Promise = require('bluebird')

# --------------------------------------------------------------------------- #
# Conveyor object, start of the conveyor line.                                #
# --------------------------------------------------------------------------- #
class Conveyor

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
    if _.isString(path) then return [Conveyor.util.prop(@data, path)]
    # ARRAY: return the array of specified properties
    if _.isArray(path) then return _.map path, (i) => Conveyor.util.prop(@data, i)
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
      Conveyor.util.prop(@data, path, value)
      return @
    # UNDEFINED: there are two possibilities here...
    if _.isUndefined(path)
      # STRING INPUT: output right there
      if _.isString(@lastInput)
        @lastOutput = @lastInput
        Conveyor.util.prop(@data, @lastInput, value)
      # NO STRING INPUT: ignore this one
      else
        @lastOutput = null
      return @
    # OTHER: scream run and panic!
    throw new Error('Pipeline.insert: Unexpected path type: ' + typeof path)

  # Something went wrong! We shall scream, run, and panic!
  panic: (message, details) ->
    throw new Conveyor.Error(message, details)

  # Wrapper for chaining promises
  # then([config], fn)
  then: ->
    # No config if the first argument is a function
    if _.isFunction(arguments[0])
      config = { }
      fn = arguments[0]
    else
      config = arguments[0]
      fn = arguments[1]
    # Create the wrapper function for the fn
    wrapper = (pipeline) ->
      # Extract arguments
      args = pipeline.extract(config.input)
      # Create the context object
      context = _.extend({ }, config:config, conveyor:pipeline)
      # Call the callback and save the result
      result = fn.apply(context, args)
      # result may be a promise, so make sure to resolve it
      return Promise.resolve(result)
        .then (result) -> pipeline.insert(config.output, result)
    # Append to the promise chain
    @promise = @promise.then(wrapper)
    return @

  # Wrapper for handling errors
  catch: ->
    @promise = @promise.catch.apply(@promise, arguments)
    return @

  # @wrapper for throwing unhandled exceptions
  done: ->
    @promise.done()
    return @

  # STATIC: utility functions
  @util =
    prop: (obj, prop, value) ->
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

# --------------------------------------------------------------------------- #
# Error class.                                                                #
# --------------------------------------------------------------------------- #
class Conveyor.Error extends Error

  constructor: (@message, @details) ->
    # Append details to message if it has custom toString() function
    if @details and @details.toString isnt Object.prototype.toString
      @message += ' (' + @details.toString() + ')'
    super(@message)

  toString: ->
    return @message

# --------------------------------------------------------------------------- #
# Export the Conveyor class.                                                  #
# --------------------------------------------------------------------------- #
module.exports = Conveyor
