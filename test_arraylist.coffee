if GLOBAL?
 TDS = require './tds'
else
 TDS = window.TDS

Point = TDS.Struct "Point",
 {key: "x", type: TDS.Types.Int32}
 {key: "y", type: TDS.Types.Int32}

test = ->
 n = 10000

 console.time 'time'
 list = TDS.ArrayList Point
 p = new Point
 for i in [0...n]
  p.setX i
  p.setY i*2
  list.push()
  list.set i, p

 for i in [0...10]
  p = Math.floor Math.random()*n
  console.log p, (list.get p).get()
 console.timeEnd 'time'


test_iter = ->
 n = 1000

 console.time 'time_iter'
 list = TDS.ArrayList Point
 p = new Point
 v = p.views
 X = Point.X
 Y = Point.Y
 for i in [0...n]
  v[X][0] = i
  v[Y][0] = i*2
  list.push p

 for i in [0...10]
  p = Math.floor Math.random()*n
  console.log p, (list.get p).get()

 iter = list.begin()
 views = iter.getViews()
 console.log views
 c = 0
 err = off
 ITER_FAIL = TDS.IteratorConsts.ITER_FAIL
 ITER_CHANGE_VIEW = TDS.IteratorConsts.ITER_CHANGE_VIEW
 while true
  console.log views[X][c], views[Y][c]
  res = iter.next()
  if res is ITER_FAIL
   break
  else if res is ITER_CHANGE_VIEW
   views = iter.getViews()
   c = 0
  else
   c++

 console.timeEnd 'time_iter'

run = (iter) ->
 test()
 test_iter()

if GLOBAL?
 #exports.run = run
 run 20
else
 window.run = run

