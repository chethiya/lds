if GLOBAL?
 TDS = require './tds'
else
 TDS = window.TDS

Point = TDS.Struct "Point",
 {key: "x", type: TDS.Types.Int32}
 {key: "y", type: TDS.Types.Int32}

test1 = (iter) ->
 iter ?= 10
 n = 10000000

 console.time 'time'

 get = (arr, p, i) ->
  arr.views[i][p]

 set = (arr, p, i, v) ->
  arr.views[i][p] = v

 points = null
 last = new Point()
 cnt = 0
 X = Point.X
 Y = Point.Y
 for j in [0...iter]
  if points?
   last.copyFrom points.end()
  else
   last.set x: 1, y: 3

  points = TDS.Array Point, n

  points.set 0, last
  views = points.get_views()
  for i in [1...n]
   #if j is 1
   # console.log (points.get_i i-1, 0)
   # break


   #points.setX i, (points.getX i-1) + i
   #points.setY i, (points.getY i-1) + 2


   #points.set_prop i, 0, (points.get_prop i-1, 0) + i
   #points.set_prop i, 1, (points.get_prop i-1, 1) + 2

   #set points, i, 0, (get points, i-1, 0) + i
   #set points, i, 1, (get points, i-1, 1) + 2

   views[X][i] = views[X][i-1] + i
   views[Y][i] = views[Y][i-1] + 2

   #points.views[0][i] = (points.get_i i-1, 0) + i
   #points.views[1][i] = (points.get_i i-1, 1) + 2

   cnt++


 console.log points.getObject 1
 console.log points.getObject n-1
 console.log cnt
 console.timeEnd 'time'


test2 =  (iter) ->
 iter ?= 10
 n = 10000000

 console.time 'time'
 lx = 1
 ly = 3
 cnt = 0
 for j in [0...iter]
  buffer1 = new ArrayBuffer n * 4
  buffer2 = new ArrayBuffer n * 4
  x = new Int32Array buffer1
  y = new Int32Array buffer2

  x[0] = lx
  y[0] = ly
  for i in [1...n]
   x[i] = x[i-1] + i
   y[i] = y[i-1] + 2
   cnt++

  lx = x[n-1]
  ly = y[n-1]

 console.log x[1], y[1]
 console.log x[n-1], y[n-1]
 console.log cnt

 console.timeEnd 'time'

run = (iter) ->
 test1 iter
 test2 iter

if GLOBAL?
 #exports.run = run
 run 20
else
 window.run = run
