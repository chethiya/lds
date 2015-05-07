TDS = require './tds'

Person = TDS.Struct "Person",
 {property: 'name', type: TDS.Types.String, length: 1}
 {property: 'age', type: TDS.Types.Int16}
 {property: 'values', type: TDS.Types.Int32, length: 5}
 {property: 'address', type: TDS.Types.String, length: 5}



p = new Person
p.setName 'asdf'
p.setAge 23
p.setValues [1, 2, 3]
p.setAddress ["No. 123", "Street 1", "Street 2", ""]
console.log p.get()

p2 = new Person
p2.copyFrom p
console.log p2.get()


test_struct = (n) ->
 console.time 'time_struct'
 arr = new Array 5
 people = []
 for i in [0...n]
  p = new Person
  p.copyFrom p2
  for j in [0...5]
   arr[j] = "#{i}-#{j}"
  p.setAddress arr
  people.push p
 console.timeEnd 'time_struct'

 console.log 'created'

 for i in [0...10]
  p = (Math.floor Math.random()*n) % n
  console.log p, people[p].get().address


test_js = (n) ->
 class JSPeople
  constructor: ->
   @name = "asdf"
   @age = 23
   @values = [1, 2, 3, 0, 0]
   @address = ["No. 123", "Street 1", "Street 2", '', null]

 console.time 'time_js'
 people = []
 for i in [0...n]
  p = new JSPeople
  for j in [0...5]
   p.address[j] = "#{i}-#{j}"
  people.push p
 console.timeEnd 'time_js'

 console.log 'created'

 for i in [0...10]
  p = (Math.floor Math.random()*n) % n
  console.log p, people[p].address

run = (n) ->
 #test_struct n
 test_js n

run 10000000
