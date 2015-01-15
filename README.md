# Promise Conveyor
A library to pipe data down a promise chain. Similar to, yet different from `async.waterfall`. API documentation is [this way](API.md).

## What is this for?
If you have a series of tasks that all depend on successful execution of all previous tasks, and any of them may or may not be asynchronous, then this library is for you. Promise Conveyor allows you to chain operations in a way that output of any previously executed operation can be available in any of the following tasks. Simply put, it does something like this:
```
someAsyncOperation()
  .then(
    function(data) {
      anotherAsyncOperation()
        .then(function(result) {
          data.property1 = result;
          return data;
        });
    })
  .then(
    function(data) {
      yetAnotherAsyncOperation()
        .then(function(result) {
          data.property2 = result;
          return data;
        });
    })
```
Messy, isn't it? Well, Promise Conveyor can clean it up this way:
```
new Conveyor()
  .then(someAsyncOperation)
  .then(anotherAsyncOperation)
  .then(yetAnotherAsyncOperation)
  .catch(errorHandler)
```
Better? This is only the tip of the iceberg. Read on to find out more awesome features.

## Piping Data
Let's say, you want to find a user from the database, authenticate and then display user's information. You have the following steps to run:
 1. Find the user record by some criteria.
 2. Compare user supplied password with the one stored in database.
 3. Get user's information and format it for display.

As you can see, both step 2 and step 3 need data produced by step 1. Meanwhile, step 3 should only execute if step 2 is successful. Following is the Promise Conveyor way of doing this:
```
new Conveyor({password: '...', email: '...'})
  .then({input: 'email', output: 'user'}, db.findUser)
  .then({input: ['user', 'password']}, crypto.compare)
  .then({input: 'user'}, formatUserInfo)
  .catch(somethingWentWrong)
```
So let me explain what this code does:
 1. This line creates a new conveyor and makes `email` and `password` available for its conveyor steps.
```
new Conveyor({password: '...', email: '...'})
```
 2. This line appends the `db.findUser` function as a conveyor step, and tells conveyor to use `email` as the function's argument, and output the returned value to the `user`. `db.findUser` can either return a user object or a promise that resolves with a user object.
```
  .then({input: 'email', output: 'user'}, db.findUser)
```
 3. This line is similar to the previous one, but in this case `crypto.compare` accepts 2 arguments, therefore `input` property of the config object is an array: `['user', 'password']`. Note that it does not have an output defined: if `crypto.compare` throws an exception or returns a rejected promise, the entire conveyor would terminate and the error callback will be called.
```
  .then({input: ['user', 'password']}, crypto.compare)
```
 4. This line tells conveyor to call `formatUserInfo`, and pass in `user` as the argument. As you can see here, the `user` value produced by line 2 is still available here.
```
  .then({input: 'user'}, formatUserInfo)
```
 5. This line defined an error callback, which will be called if any step in conveyor encounters an error.
```
  .catch(somethingWentWrong)
```

## Input/Output Inference
In some cases, you can omit `input` and `output` values, and Conveyor will try to determine what they are. For example:
```
increment = function(a) { return a + 1; };

new Conveyor(data: 0)
  .then({input: 'data'}, increment)
  .then(increment)
  .then(increment)
  .then(increment)
```
In this case, the first `increment` step will accept the `data` as its argument, increment it by 1, and output it back to `data`. Then the next `increment` will get the output value of the last step, and output back to it. This allows very convenient creation of long chains of transforms that operate on the same object.

Precise rules of inference are the following:
 + **Input**
  + if this is the first conveyor step, defaults to `null` (passes all available data)
  + if last step has an output, then uses that output
  + if last step did not output anything, then defaults back to `null`
 + **Output**
  + if this is the first conveyor step, does not output anything
  + if this step has one single input value, outputs there
  + if this step has multiple input values, outputs nothing

## Config Object
As you have seen from the previous examples, the `then` function of the Conveyor accepts an optional config object and a function. You can add any information you wish to pass to your function into the config object, and it will be accessible as `this.config` inside conveyor steps.

Similarly, you can access the Conveyor object using `this.conveyor`.

## License
### The MIT License

Copyright (c) 2014-2015 Cellaflora Design LLP, Denis Luchkin-Zhou

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
