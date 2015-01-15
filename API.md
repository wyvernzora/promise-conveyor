# Promise Conveyor Documentation

## Getting Started
Install the npm module:
```
$ npm install promise-conveyor --save
```
Require the Conveyor:
```
Conveyor = require('promise-conveyor');
```
And you are all set!

## Conveyor

### #constructor([data])
Creates a new conveyor instance. You can optionally pass in a `data` object whose properties will be available to all conveyor steps as inputs.

### #extract(path)
Extracts an input value from the conveyor data. `path` can be a deep property like `user.name` or even an array index like `user.posts[0].time`.

### #insert(path, value)
Does the opposite of the `#extract`: inserts the value into conveyor data, overwriting existing objects and creating new properties where appropriate. For example, `conveyor.insert('user.email.confirmed', true)` will create `user`, `user.email` and `user.email.confirmed` if either one does not exist in conveyor data.

### #panic(message, details)
You usually would need to call this from within conveyor steps: `this.conveyor.panic('Something went wrong!')`. Throws an Conveyor.Error. The benefit is that you can supply a `details` object, which can contain useful information about the error. If the `details` object has a non-default `toString()` function, then `details.toString()` will be appended to the `message`.

### #then([config], func)
Appends a step to the conveyor line. `config` can be used to specify input, output and any additional information you want accessible from within the `func`.

### #catch([type], func)
Adds an error handler. You can optionally pass in a constructor for `type`, which will make that handler only handle error of that type. In the event of an error, `func` is called with one `error` argument.

### #done()
Marks completion of the conveyor line, and throws any errors that are not otherwise handled.
