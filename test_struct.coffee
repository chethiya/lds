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
console.log p.get()
