TDS = require './tds'

iter = parseInt process.argv[2]
if isNaN iter
 iter = null
iter ?= 20
n = 10000000

console.time 'time'

Point = TDS.Struct "Point",
 {key: "x", type: TDS.Types.Int32}
 {key: "y", type: TDS.Types.Int32}

get = (arr, p, i) ->
 arr.views[i][p]

set = (arr, p, i, v) ->
 arr.views[i][p] = v

points = null
last = new Point()
for j in [0...iter]
 if points?
  last.copyFrom points.end()
 else
  last.set x: 1, y: 3

 points = TDS.Array Point, n

 points.set 0, last
 for i in [1...n]
  #if j is 1
  # console.log (points.get_i i-1, 0)
  # break


  #points.setX i, (points.getX i-1) + i
  #points.setY i, (points.getY i-1) + 2

  #points.set_i i, 0, (points.get_i i-1, 0) + i
  #points.set_i i, 1, (points.get_i i-1, 1) + 2

  #set points, i, 0, (get points, i-1, 0) + i
  #set points, i, 1, (get points, i-1, 1) + 2

  points.views[0][i] = points.views[0][i-1] + i
  points.views[1][i] = points.views[1][i-1] + 2

  #points.views[0][i] = (points.get_i i-1, 0) + i
  #points.views[1][i] = (points.get_i i-1, 1) + 2


console.log points.getObject 1
console.log points.getObject n-1
console.timeEnd 'time'
#
