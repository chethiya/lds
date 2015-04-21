nTypes = 4
Types =
 Uint8: 0
 Int32: 1
 Float32: 2
 Float64: 3

ArrayTypes = [
 Uint8Array
 Int32Array
 Float32Array
 Float64Array
]

TypeLenghts = [
 1
 4
 4
 8
]

names = {}
namesCnt = 0

Struct = ->
 id = null
 name = null
 keys = []
 types = []
 offsets = []
 n = 0
 bytes = 0

 if typeof arguments[0] isnt 'string' or arguments[0].length is 0
  throw new Error 'No name for the struct'
 name = arguments[0]
 if names[name]?
  throw new Error "An Struct already defined with name: #{name}"
 names[name] = namesCnt
 id = namesCnt++

 for k, v of arguments
  if v?.key? and v?.type? and
  (typeof v.key is 'string') and (typeof v.type is 'number') and
  v.type >= 0 and v.type < nTypes
   keys.push v.key
   types.push v.type
   n++
   offsets.push bytes
   bytes += TypeLenghts[v.type]

 if n is 0
  throw new Error "No properties in the struct #{name}"

 class RawObject
  constructor: ->
   for k in keys
    this[k] = null

 class Class
  constructor: (obj, views, pos) ->
   @id = id
   if views?
    @views = views
    @pos = pos
   else
    buffer = new ArrayBuffer bytes
    @pos = 0
    @views = []
    for t, i in types
     @views.push new ArrayTypes[t] buffer, offsets[i], 1
   if obj?
    @set obj

  set: (obj) ->
   if obj?
    for k, i in keys
     if obj[k]?
      @views[i][@pos] = obj[k]
   null

  get: ->
   o = new RawObject()
   for k, i in keys
    o[k] = @views[i][@pos]
   o

  copyFrom: (struct) ->
   if @id isnt struct.id
    return off
   for i in [0...types.length]
    @views[i][@pos] = struct.views[i][struct.pos]
   return true

  next: ->
   if @pos < @views[0].length-1
    @pos++
    return on
   else
    return off

  prev: ->
   if @pos > 0
    @pos--
    return on
   else
    return off

 for k, i in keys
  code = k.charCodeAt 0
  tcase = k
  if code <= 122 and code >= 97
   tcase = (k.substr 0, 1).toUpperCase() + k.substr 1
  do (i) ->
   Class.prototype["set#{tcase}"] = (val) ->
    @views[i][@pos] = val

   Class.prototype["get#{tcase}"] = ->
    @views[i][@pos]

 Class.id = id
 Class.name = name
 Class.keys = keys
 Class.types = types
 Class.offsets = offsets
 Class.n = n
 Class.bytes = bytes
 Class.Object = RawObject
 Class

class Array
 constructor: (struct, size) ->
  @struct = struct
  @size = size
  @buffer = new ArrayBuffer @struct.bytes * @size
  @views = []
  for t, i in @struct.types
   @views[i] = new ArrayTypes[t] @buffer, @struct.offsets[i]*size, @size

  #functions for individual getters and setters


 #functions for Struct instance
 begin: ->

 end: ->

 get: (i) ->
  if i < 0 or i >= @size
   null
  new @struct null, @views, i

 set: (i, val) ->
  if i < 0 or i >= @size
   return off
  if @struct.id isnt val.id
   return off

  o = new @struct null, @views, i
  o.copyFrom val
  return on

 #functions for objects




TDS =
 Types: Types
 Struct: Struct
 Array: Array

module.exports = TDS


###
#Example
#

Point = Struct({}) #returns a class
a = new Point({}) # allocates a typed array
a.setX(val)
a.getX()

l = new Array(Point, n)
l.set(i, {})
l.get(i) #returns an object
l.setX(i, val)
l.getX(i)

p = l.begin()
p.get() #struct get
p.next()


Point = Struct({}) #returns a class
p = new Point({x: 1, y: 2}) # allocates a typed array
a.setX(val)
a.getX()

l = new Array Point, n
l.set(i, {})
l.get(i) #returns an object
l.setX(i, val)
l.getX(i)

p = l.begin()
p.get() #struct get
p.next()



###
