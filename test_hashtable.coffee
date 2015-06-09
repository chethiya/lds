TDS = require './tds'
ind = []

test_tds = (n) ->
 console.time 'time_tds_add'
 map = TDS.HashtableBase n, TDS.Types.Int32

 #map.set "key-0", 3
 #map.set "key-1", 4
 #console.log map.get "key-1"
 #return

 for i in [0...n]
  map.set "#{i}", i
  #console.log i, map.get "key-#{i}"
 console.timeEnd 'time_tds_add'

 console.time 'time_tds_get'
 s = 0
 for i in [0...n]
  p = ind[i]
  v = map.get "#{p}"
  s += v
  #console.log p, v
 console.timeEnd 'time_tds_get'
 console.log s

 map.summarize()
 TDS.cleanup()

test_js = (n) ->
 console.time 'time_js_add'
 map = {}
 for i in [0...n]
  map["key-#{i}"] = i
 console.timeEnd 'time_js_add'

 console.time 'time_js_get'
 s = 0
 for i in [0...n]
  p = ind[i]
  v = map["key-#{p}"]
  #console.log p, v
  s += v
 console.timeEnd 'time_js_get'
 console.log s

run = (n) ->
 for i in [0...n]
  p = (Math.floor Math.random()*n) % n
  ind.push p

 test_js n
 test_tds n
 test_tds n
 TDS.cleanup()

run 1000

