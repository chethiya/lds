LDS = require './lds'

Str = LDS.Struct "StringS",
 {property: 'name', type: LDS.Types.String, length: 1}

run = (n) ->
 arr = LDS.Array Str, n
 instance = arr.get 0
 for i in [0...n]
  instance.setName "Name #{i}"
  console.log instance.getName()
  instance.next()
 temp = arr.get 0
 for i in [0...n]
  p = (Math.floor Math.random()*n) % n
  p = i
  instance = arr.get p, instance
  instance.copyFrom temp

 LDS.cleanup()
run 10

