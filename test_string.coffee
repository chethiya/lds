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


print2 = (arr) ->
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
  ps = "#{p}"
  if s? and ps isnt s.substr 0, ps.length
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

test_js_random_write = (n) ->
 console.time 'test_js_random_write'
 M = 1000000
 arr = new Array M
 for i in [0...n]
  p = Math.floor Math.random()*M
  p-- if p is M
  arr[p] = "#{p}#{i}#{STR}"
 print2 arr
 console.timeEnd 'test_js_random_write'

test_random_write = (n) ->
 console.time 'test_random_write'
 M = 1000000
 arr = TDS.Array TDS.Struct.String, M
 for i in [0...n]
  p = Math.floor Math.random()*M
  p-- if p is M
  arr.set p, "#{p}#{i}#{STR}"
 print2 arr
 console.timeEnd 'test_random_write'


test = (n) ->
 console.time 'test'
 arr = TDS.Array TDS.Struct.String, n
 for i in [0...n]
  arr.set i, "#{i}#{STR}"
 print arr
 console.timeEnd 'test'

run = (n) ->
 #test_js n
 test_js_random_write n
 #test_random_write n
 #test n

if GLOBAL?
 #exports.run = run
 run 100000000
else
 window.run = run


