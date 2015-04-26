if GLOBAL?
 TDS = require './tds'
else
 TDS = window.TDS

STR = "Test567890"

print = (arr) ->
 get = (i) ->
  if arr instanceof Array
   arr[i]
  else
   arr.get i

 n = arr.length
 if n < 32
  for i in [0...n]
   console.log get i

 pass = on
 for i in [0...1000]
  p = Math.floor Math.random()*n
  p-- if p is n
  s = get p
  if "#{p}#{STR}" isnt s
   pass = off
   console.log p, s
   break
 console.log "res: ", pass

test_js = (n) ->
 console.time 'test_js'
 arr = []
 for i in [0...n]
  arr.push "#{i}#{STR}"
 print arr
 console.timeEnd 'test_js'

test = (n) ->
 console.time 'test'
 arr = TDS.Array TDS.Struct.String, n
 for i in [0...n]
  arr.set i, "#{i}#{STR}"
 print arr
 console.timeEnd 'test'

run = (n) ->
 test_js n
 test n

if GLOBAL?
 #exports.run = run
 run 100000000
else
 window.run = run


