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



test_capacity = (n) ->
 n ?= 10000000

 console.time 'time_capacity'
 list = TDS.ArrayList Point, n
 p = new Point
 iter = list.begin()
 for i in [0...n]
  p.setX i
  p.setY i*2
  iter.set p
  iter.next()

 console.timeEnd 'time_capacity'
 print list


run = (iter) ->
 n = 1<<30
 test_capacity n

if GLOBAL?
 #exports.run = run
 run 20
else
 window.run = run


