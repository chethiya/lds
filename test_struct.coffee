TDS = require './tds'

Person = TDS.Struct "Person",
 {property: 'name', type: TDS.Types.String, length: 1}

p = new Person
p.setName 'asdf'
console.log p.getName()
