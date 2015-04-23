if GLOBAL?
 TDS = require './tds'
else
 TDS = window.TDS

Point = TDS.Struct "Point",
 {key: "x", type: TDS.Types.Int32}
 {key: "y", type: TDS.Types.Int32}

print = (list) ->
 n = list.length
 if n < 32
  iter = list.begin()
  while true
   console.log iter.get_object()
   if iter.next() is TDS.IteratorConsts.ITER_FAIL
    break

 console.log 'Random test'
 pass = on
 for i in [0...1000]
  p = Math.floor Math.random()*n
  p-- if p is n
  o = list.get_object p
  if o.x isnt p or o.y isnt p*2
   pass = off
 console.log "res: ", pass


test_push_type = (n) ->
 n ?= 10000000

 console.time 'time_push_type'
 list = TDS.ArrayList Point
 p = new Point
 for i in [0...n]
  p.setX i
  p.setY i*2
  list.push p

 console.timeEnd 'time_push_type'

 print list

test_copy = (n) ->
 n ?= 10000000

 console.time 'time_copy'
 list = TDS.ArrayList Point
 p = new Point
 for i in [0...n]
  p.setX i
  p.setY i*2
  list.push()
  list.set i, p

 console.timeEnd 'time_copy'
 print list

test_set_last_prop = (n) ->
 n ?= 10000000

 console.time 'time_set_last_prop'
 list = TDS.ArrayList Point
 X = Point.X
 Y = Point.Y
 for i in [0...n]
  list.push()
  list.set_lastProp X, i
  list.set_lastProp Y, i*2

 console.timeEnd 'time_set_last_prop'
 print list

test_iter = (n) ->
 n ?= 10000000
 ITER_FAIL = TDS.IteratorConsts.ITER_FAIL
 ITER_CHANGE_VIEW = TDS.IteratorConsts.ITER_CHANGE_VIEW

 console.time 'time_iter'
 list = TDS.ArrayList Point
 iter = null
 X = Point.X
 Y = Point.Y
 views = null
 c = 0
 for i in [0...n]
  list.push()
  if i is 0
   iter = list.begin()
   views = iter.get_views()
   c = 0
  else
   if ITER_CHANGE_VIEW is iter.next()
    views = iter.get_views()
    c = 0
   else
    c++
  views[X][c] = i
  views[Y][c] = i*2

 console.timeEnd 'time_iter'
 print list

test_iter_prop = (n) ->
 n ?= 10000000
 ITER_FAIL = TDS.IteratorConsts.ITER_FAIL
 ITER_CHANGE_VIEW = TDS.IteratorConsts.ITER_CHANGE_VIEW

 console.time 'time_iter_prop'
 list = TDS.ArrayList Point
 iter = null
 X = Point.X
 Y = Point.Y
 for i in [0...n]
  list.push()
  if i is 0
   iter = list.begin()
  else
   iter.next()
  iter.set_prop X, i
  iter.set_prop Y, i*2

 console.timeEnd 'time_iter_prop'
 print list

test_push = (n) ->
 n ?= 10000000

 console.time 'time_push_with_views'
 list = TDS.ArrayList Point
 X = Point.X
 Y = Point.Y
 views = list.get_lastViews()
 c = 0
 for i in [0...n]
  if list.push() is on
   views = list.get_lastViews()
   c = 0
  views[X][c] = i
  views[Y][c] = i*2
  c++

 console.timeEnd 'time_push_with_views'
 print list

run = (iter) ->
 n = 100000000
 test_push_type n
 test_copy n
 test_set_last_prop n
 test_iter n
 test_iter_prop n
 test_push n

if GLOBAL?
 #exports.run = run
 run 20
else
 window.run = run

