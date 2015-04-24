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
 titleKeys = []
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
  Class[k.toUpperCase()] = i
  code = k.charCodeAt 0
  tcase = k
  if code <= 122 and code >= 97
   tcase = (k.substr 0, 1).toUpperCase() + k.substr 1
  titleKeys.push tcase
  do (i) ->
   Class.prototype["set#{tcase}"] = (val) ->
    @views[i][@pos] = val

   Class.prototype["get#{tcase}"] = ->
    @views[i][@pos]

 Class.id = id
 Class.name = name
 Class.keys = keys
 Class.titleKeys = titleKeys
 Class.types = types
 Class.offsets = offsets
 Class.n = n
 Class.bytes = bytes
 Class.Object = RawObject
 Class

Array = (struct, length) ->
 views = null
 class Class
  constructor: ->
   @struct = struct
   @length = length
   @buffer = new ArrayBuffer struct.bytes * length
   views = @views = []
   for t, i in struct.types
    @views.push new ArrayTypes[t] @buffer,
     struct.offsets[i] * length
     length

  #functions for Struct instance
  begin: -> @get 0

  end: -> @get length-1

  get: (i) ->
   if i < 0 or i >= length
    null
   new struct null, views, i

  set: (i, val) ->
   if i < 0 or i >= length
    return off
   if struct.id isnt val.id
    return off

   for j in [0...struct.n]
    views[j][i] = val.views[j][val.pos]
   return on


  #functions for objects
  get_object: (p) ->
   o = new struct.Object()
   for k, i in struct.keys
    o[k] = views[i][p]
   o

  set_object: (p, obj) ->
   if obj?
    for k, i in struct.keys
     if obj[k]?
      views[i][p] = obj[k]
   null


  set_prop: (p, i, v) ->
   views[i][p] = v
   null

  get_prop: (p, i) -> views[i][p]

  get_views: -> views

 #functions for individual getters and setters
 for k, i in struct.titleKeys
  do (i) ->
   Class.prototype["set#{k}"] = (p, val) ->
    views[i][p] = val
    null

   Class.prototype["get#{k}"] = (p) ->
    views[i][p]

 new Class()


INT_SIZE = 16
MAX_SIZE = 1<<26
MAX_LINEAR_ARRAY_INDEX = 2

ITER_CHANGE_VIEW = 1
ITER_SUCCESS = 0
ITER_FAIL = -1


ArrayList = (struct, start_size, min_capacity) ->
 arrays = null
 allViews = null
 sum = null

 capacity = 0
 length = 0

 lastArr = null
 lastViews = null
 i_lastArr = i_lastPos = 0
 i_llp = -1
 i_lla = 0

 findRes = [0, 0]
 MAX_LINEAR_FIND_INDEX = MAX_SIZE * (MAX_LINEAR_ARRAY_INDEX + 1)

 find_linear = (p) ->
  findRes[0] = 0
  while true
   if p < sum[findRes[0]]
    break
   findRes[0]++
  if findRes[0] is 0
   findRes[1] = p
  else
   findRes[1] = p - sum[findRes[0]-1]
  return null

 find_binary_search = (p) ->
  bs_l = 0
  bs_r = i_lastArr
  while bs_l < bs_r
   bs_m = bs_l + ((bs_r-bs_l) >> 1)
   if p >= sum[bs_m]
    bs_l = bs_m + 1
   else
    bs_r = bs_m
  findRes[0] = bs_l
  if bs_l is 0
   findRes[1] = p
  else
   findRes[1] = p - sum[bs_l-1]
  return

 #find = find_inline
 ###
 # linear find is faster for small number of arrays
 # binar search should be used after
 #
 #P.S. This seems to be of no use. Having binary search for all cases
 ####
 find_hybrid = (p) ->
  if p < MAX_LINEAR_FIND_INDEX
   find_linear p
  else
   find_binary_search p

 find = find_binary_search

 GetArrayListIterator = (i_arr, i_pos) ->
  arr = null
  views = null
  class ArrayListIterator
   constructor: ->
    arr = arrays[i_arr]
    views = arr.views

   next: ->
    #pos comes first considered the probabilities
    if i_pos is i_lastPos-1 and i_arr is i_lastArr
     return ITER_FAIL

    i_pos++
    if i_pos is arr.length
     i_pos = 0
     i_arr++
     arr = arrays[i_arr]
     views = arr.views
     ITER_CHANGE_VIEW
    else
     ITER_SUCCESS

   prev: ->
    #pos comes first considering the probabilities
    if i_pos is 0 and i_arr is 0
     return ITER_FAIL
    i_pos--
    if i_pos is -1
     i_arr--
     arr = arrays[i_arr]
     views = arr.views
     i_pos = arr.length - 1
     ITER_CHANGE_VIEW
    else
     ITER_SUCCESS

   get: ->
    #arr.get i_pos
    if i_pos is i_lastPos and i_arr is i_lastArr
     null
    new struct null, views, i_pos

   set: (val) ->
    #arr.set i_pos, val
    if i_pos is i_lastPos and i_arr is i_lastArr
     return off
    if struct.id isnt val.id
     return off

    tarV = val.views
    pos = val.pos
    for j in [0...struct.n]
     views[j][i_pos] = tarV[j][pos]
    return on

   get_object: ->
    arr.get_object i_pos

   set_object: (obj) ->
    arr.set_object i_pos, obj

   get_prop: (prop) ->
    views[prop][i_pos]

   set_prop: (prop, val) ->
    views[prop][i_pos] = val
    null

   get_views: -> views

  #functions for individual getters and setters
  for k, i in struct.titleKeys
   do (i) ->
    ArrayListIterator.prototype["set#{k}"] = (val) ->
     views[i][i_pos] = val
     null

    ArrayListIterator.prototype["get#{k}"] =  ->
     views[i][i_pos]

  new ArrayListIterator

 class ArrayListClass
  constructor: ->
   arrays = @arrays = []
   allViews = []
   sum = []
   length = @length = 0
   @struct = struct
   size = 0

   if start_size?
    length = @length = start_size
    n = start_size
    size = INT_SIZE
    while size isnt MAX_SIZE and n > size
     size = size << 1

    ls = 0
    while true
     lastArr = TDS.Array struct, size
     capacity += size
     lastViews = lastArr.views
     arrays.push lastArr
     allViews.push lastViews
     ls += size
     sum.push ls

     if n <= size
      i_lastArr = arrays.length-1
      i_lastPos = n
      i_lla = i_lastArr
      i_llp = n-1
      break

     n -= size
     if size isnt MAX_SIZE
      size = size << 1
   else
    capacity = INT_SIZE
    if min_capacity?
     while capacity isnt MAX_SIZE and capacity < min_capacity
      capacity = capacity << 1
    size = capacity
    lastArr = TDS.Array struct, capacity
    lastViews = lastArr.views
    arrays.push lastArr
    allViews.push lastViews
    sum.push capacity

   if i_lastArr >= MAX_LINEAR_ARRAY_INDEX
    MAX_LINEAR_FIND_INDEX = sum[MAX_LINEAR_ARRAY_INDEX]

  begin: ->
   if length is 0
    return null
   GetArrayListIterator 0, 0

  end: ->
   if length is 0
    return null
   GetArrayListIterator i_lastArr, i_lastPos

  get: (p) ->
   if p < 0 or p >= length
    return null
   find p
   arrays[findRes[0]].get findRes[1]

  set: (p, val) ->
   if p < 0 or p >= length
    return off
   if struct.id isnt val.id
    return off

   find p
   tarViews = arrays[findRes[0]].views
   srcViews = val.views
   valPos = val.pos
   for j in [0...struct.n]
    tarViews[j][findRes[1]] = srcViews[j][valPos]
   return on

  get_object: (p) ->
   if p < 0 or p >= length
    return null
   find p
   arrays[findRes[0]].get_object findRes[1]

  set_object: (p, obj) ->
   if p < 0 or p >= length
    return off
   find p
   arrays[findRes[0]].set_object findRes[1], obj

  get_prop: (i, prop) ->
   if i < 0 or i >= length
    return null
   find i
   allViews[findRes[0]][prop][findRes[1]]

  set_pro: (i, prop, val) ->
   if i < 0 or i >= length
    return off
   find i
   allViews[findRes[0]][prop][findRes[1]] = val
   return on

  get_lastViews: -> lastViews
  get_allViews: -> allViews

  set_lastProp: (prop, val) ->
   lastViews[prop][i_llp] = val
   return null

  get_lastProp: (prop) ->
   lastViews[prop][i_llp]

  push: (val) ->
   res = off
   if i_lastPos is lastArr.length
    @addArray()
    i_lla++
    i_llp = 0
    res = on
   else
    i_llp++

   if val?
    #lastArr.set i_lastPos, o
    srcViews = val.views
    valPos = val.pos
    for j in [0...struct.n]
     lastViews[j][i_lastPos] = srcViews[j][valPos]
   i_lastPos++
   @length++
   length++
   return res

  addArray: ->
   n = lastArr.length
   if n isnt MAX_SIZE
    n = n << 1

   capacity += n
   lastArr = TDS.Array struct, n
   lastViews = lastArr.views
   arrays.push lastArr
   allViews.push lastViews
   sum.push sum[i_lastArr] + n
   i_lastArr++
   i_lastPos = 0

   if i_lastArr >= MAX_LINEAR_ARRAY_INDEX
    MAX_LINEAR_FIND_INDEX = sum[MAX_LINEAR_ARRAY_INDEX]

 #functions for individual getters and setters
 for k, i in struct.titleKeys
  do (i) ->
   ArrayListClass.prototype["set#{k}"] = (p, val) ->
    if p < 0 or p >= length
     return off
    find p
    allViews[findRes[0]][i][findRes[1]] = val
    return on

   ArrayListClass.prototype["get#{k}"] = (p) ->
    if p < 0 or p >= length
     return null
    find p
    allViews[findRes[0]][i][findRes[1]]

 new ArrayListClass

TDS =
 Types: Types
 Struct: Struct
 Array: Array
 ArrayList: ArrayList
 IteratorConsts:
  ITER_CHANGE_VIEW: ITER_CHANGE_VIEW
  ITER_SUCCESS: ITER_SUCCESS
  ITER_FAIL: ITER_FAIL

if GLOBAL?
 module.exports = TDS
else
 window.TDS = TDS

