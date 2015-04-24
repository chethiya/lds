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

 pass = on
 for i in [0...1000]
  p = Math.floor Math.random()*n
  p-- if p is n
  o = list.get_object p
  if o.x isnt p or o.y isnt p*2
   pass = off
 console.log "res: ", pass


test_js = (n, opt) ->
 n ?= 10000000

 console.time 'time_js'
 x = []
 y = []
 for i in [0...n]
  x.push i
  y.push i*2

 console.timeEnd 'time_js'

 pass = on
 for i in [0...1000]
  p = Math.floor Math.random()*n
  p-- if p is n
  if x[p] isnt p or y[p] isnt p*2
   pass = off
 console.log "res: ", pass

test_push_type = (n, opt) ->
 n ?= 10000000

 console.time 'time_push_type'
 list = TDS.ArrayList Point, null, opt.min_cap
 p = new Point
 for i in [0...n]
  p.setX i
  p.setY i*2
  list.push p

 console.timeEnd 'time_push_type'

 print list

test_copy = (n, opt) ->
 n ?= 10000000

 console.time 'time_copy'
 list = TDS.ArrayList Point, null, opt.min_cap
 p = new Point
 for i in [0...n]
  p.setX i
  p.setY i*2
  list.push()
  list.set i, p

 console.timeEnd 'time_copy'
 print list

test_set_last_prop = (n, opt) ->
 n ?= 10000000

 console.time 'time_set_last_prop'
 list = TDS.ArrayList Point, null, opt.min_cap
 X = Point.X
 Y = Point.Y
 for i in [0...n]
  list.push()
  list.set_lastProp X, i
  list.set_lastProp Y, i*2

 console.timeEnd 'time_set_last_prop'
 print list

test_iter = (n, opt) ->
 n ?= 10000000
 ITER_FAIL = TDS.IteratorConsts.ITER_FAIL
 ITER_CHANGE_VIEW = TDS.IteratorConsts.ITER_CHANGE_VIEW

 console.time 'time_iter'
 list = TDS.ArrayList Point, null, opt.min_cap
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

test_iter_prop = (n, opt) ->
 n ?= 10000000
 ITER_FAIL = TDS.IteratorConsts.ITER_FAIL
 ITER_CHANGE_VIEW = TDS.IteratorConsts.ITER_CHANGE_VIEW

 console.time 'time_iter_prop'
 list = TDS.ArrayList Point, null, opt.min_cap
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

test_push = (n, opt) ->
 n ?= 10000000

 console.time 'time_push_with_views'
 list = TDS.ArrayList Point, null, opt.min_cap
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
 #test_js n
 test_push_type n, min_cap: n
 test_copy n, min_cap: n
 test_set_last_prop n, min_cap: n
 test_iter n, min_cap: n
 test_iter_prop n, min_cap: n
 test_push n, min_cap: n

if GLOBAL?
 #exports.run = run
 run 20
else
 window.run = run

