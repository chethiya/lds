TDS = require './tds'

Person = TDS.Struct "Person",
 {property: 'name', type: TDS.Types.String, length: 1}
 {property: 'age', type: TDS.Types.Int16}
 {property: 'values', type: TDS.Types.Int32, length: 1}



p = new Person
p.setName 'asdf'
p.setAge 23
p.setValues 123
console.log p.get()
