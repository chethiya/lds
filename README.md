# lds
Memory limits in v8 is limited to somewhere around ~1.7GB when it comes to Object and Arrays. LargeDS (LDS) tries to overcome this barrier by making use of Typed Arrays by defining basic data structure like Hashtables and ArrayLists

### The Problem

 I use CoffeeScript (Node.js) extensively to analyze large data sets. Time to time I run out of available memory provided by v8 for JS Objects and Arrays.
 >>> ["CoffeeScript is a little language that compiles into JavaScript."](http://coffeescript.org/)

 Even in 64-bit Node.js (as of version 0.12) there is ~1.5GB memory limit. But this memory limit does not apply for Types Arrays. I don't believe this is case where we need to look for another resort like C, specially given the flexibility offered by JavaScript.

### What is LDS

 [LDS](https://github.com/chethiya/lds) (Large Data Structures) is a library that implements some of basic data structure based on JavaScript Typed Arrays to overcome this memory limit issue.
 >>> You can get LDS from here: (https://github.com/chethiya/lds)

 It's still not fine tuned to gain the best performance but very much usable. There can be considerable performance hit in when it comes to strings since the lack of support from JS API to convert between JS String and Buffers

 Here's how to use LDS to implement ``<string,number>`` map in Coffescript.

 >>> At the moment LDS only supports String keys in hash tables

 ```coffeescript
  LDS = require 'lds'
  n = 10000000
  map = LDS.HashtableBase n, LDS.Types.Int32
  for i in [0...n]
   map.set "#{i}", i
  for i in [0..10]
   console.log "#{i} -> #{map.get "#{i}"}"
 ```

### How to get it
 #### Node.js
  ```
   npm install lds
  ```

  And require it as follows

  ```javascript
   LDS = require('lds')
  ```

 #### Browser
  ```html
   <script src="https://github.com/chethiya/lds/blob/master/build/lds.js"></script>
  ```

  And consume it as follows

  ```javascript
   LDS = window.LDS
  ```

###Struct

 To represent related values, LDS has an implementation of Struct. A struct definition contains a list of root level property names and the types. Supported types are:

 ```
  UInt8
  UInt32
  UInt16
  Float32
  Float64
  String
 ```

 >>> LDS has it's own implementation of String. It uses 2-byte fixed with character encoding so that there is always one-to-one transformation between JS native String and LDS.String

 Here's an example definition of Struct

 ```coffeescript
  Person = LDS.Struct "Person",
   {property: 'name', type: LDS.Types.String, length: 1}
   {property: 'age', type: LDS.Types.Int16}
   {property: 'values', type: LDS.Types.Int32, length: 5}
   {property: 'address', type: LDS.Types.String, length: 5}
 ```

 * property 'name' is a String
 * property 'age' is a 16-bit integer
 * property 'values' is a fixed-length array of 32-bit integer
 * property 'address' is a fixed-length array of Strings

 ```coffeescript
  p = new Person
  p.setName 'Bob'
  p.setAge 23
  p.setValues [1, 2, 3]
 ```
 >>> Only first 3 values of ``values`` will be set


 ```coffeescript
  p.setAddress ["No. 123", "Street 1", "Street 2", ""]
  p.setAddress "index-3-new", 3
 ```

 >>> 4th element in ``address`` array is changed to a new value ``index-3-new``

 ```coffeescript
  str = new LDS.String "4-fourth"
  p.setAddress str, 4, on
 ```

 >>> Sets the 5th element of ``address`` to LDS.string ``str``

 By setting the 3rd argument to ``true`` in all setter functions, one can pass in an LDS.String values instead of a JS native String


 ```coffeescript
  str.release()
 ```

 If you are to create LDS.String, you must release those string objects by calling ``release()`` method. In most cases you will not create LDS.Strings. But you might create Hashtables and ArrayLists having LDS.Strings in their Structs. In such cases you'll have to call ``release()`` method of those objects once you are done working with that data structure.


 ```coffeescript
  console.log p.get()
 ```

 >>> LDS.StructClass.get() method returns a JSON object of the struct instance.

 ```coffeescript
  console.log p.getAddress 2
 ```

 >>> If a property in a Struct is an array, then the 1st argument of getters will be  the index of the respective array.

 ```coffeescript
  str = p.getAddress 0, on

  console.log str.toString()
  str.release()

  p2 = new Person
  p2.copyFrom p
  console.log p2.get()
 ```

 >>> 2nd argument of getters is the ```string_flag``` that indicates the return value is a LDS.String object. You'll have to ``release()`` those objects after consuming.

 ``Struct.copyFrom()`` method copies the content from source struct buffer area to target struct buffer area. LDS.Strings are copied by reference.

  * Reference counts to existing strings in source are decremented by 1.

  * Reference counts to strings in target are incremented by 1.


###Array List

 There is an implementation of LDS.Array. But LDS.Array hits a 32-bit limitation as size in ``new ArrayBuffer size`` has to be somewhere around ``2^30`` at max. Therefore LDS.Array has a maximum size limit of ``2^29 / (#bytes_per_strcut)``

 ArrayList is build on top of LDS.Array and it is a list of LDS.Arrays. Therefore it has a size limit much greater than ``2^32``.

 Here's hoe to make a large LDS.ArrayList using the ``sturct Person``.

 ```coffeescript
  testArratList = (n) ->
   arr = new Array 5
   people = new LDS.ArrayList Person
   instanece = null
   for i in [0...n]
    instance = people.add instance # same as people.add()
    instance.copyFrom p2
    instance.setName "#{i}"

    for j in [0...5]
     arr[j] = "#{i}-#{j}" # or instance.setAddress "#{i}-#{j}", j
    instance.setAddress arr
   console.log 'Done pushing elements'
   console.log 'Reading from ArrayList'
   for i in [0...10]
    p = (Math.floor Math.random()*n) % n
    #following is equal to (people.get p).getAddress()
    console.log p, (people.get p, instance).getAddress()
 ```
 >>> An object of the struct is passed in to ``add()`` and ``get()`` methods so that those methods can resume passed in ``Object`` rather than creating new one. If such an object is not passed in as an argument the methods will create a new ``Object``.

###Hash Table

LDS.HastableBase is a ``<string,number>`` implementation. LDS.Hashtable is a more generic ``<string,LDS.Struct>`` hashtable that is based on LDS.HashtableBase.

```coffeescript
 testHashtable = (n) ->
  console.time 'time_hashtable'
  arr = new Array 5
  people = LDS.Hashtable n, Person #creates a hashtable of size n
  instance = null
  for i in [0...n]
   instance = people.get "#{i}", instance #gets the value in key #{i}
   instance.copyFrom p2

   for j in [0...5]
    instance.setAddress "#{i}-#{j}", j
  console.timeEnd 'time_hashtable'
  console.log 'Done populating the hastable'
  console.log 'Reading from hashtable'

  for i in [0...20]
   p = (Math.floor Math.random()*n*2) % (2*n)
   if not people.check "#{p}" #checks whether key exists
    console.log p, null
   else
    console.log p, (people.get "#{p}", instance).getAddress()
```

>>> ``get(key)`` method returns LDS.Struct instance of the given ``key``. If ``key`` doesn't exists in the hash table, it creates a new key-value pair and returns the created instance.

