LDS = require './lds'

Person = LDS.Struct "Person",
 {property: 'name', type: LDS.Types.String, length: 1}
 {property: 'age', type: LDS.Types.Int16}
 {property: 'values', type: LDS.Types.Int32, length: 5}
 {property: 'address', type: LDS.Types.String, length: 5}


StringStruct = LDS.Struct "StringStruct",
 {property: "name", type: LDS.Types.String, length: 1}

test_add = (n) ->
 console.time 'time_add'
 arr = new LDS.ArrayList StringStruct
 for i in [0...n]
  instance = arr.add instance
  instance.setName "#{i}"
 console.timeEnd 'time_add'

 for i in [0...n]
  #p = (Math.floor Math.random()*n) % n
  p = i
  instance = arr.get i, instance
  res = instance.getName()
  if res isnt "#{i}"
   console.log "error: #{res} instead of #{i}"
   break

run = (n) ->
 test_add n

run 3000000
