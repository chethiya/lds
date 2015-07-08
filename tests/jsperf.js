var N = 4
var lens = [100, 10000, 10000, 1000000]
var keyName = "key";
var map = null;
var LDS = window.LDS;
var ind = null;

function createInd(n) {
 n = lens[n];
 ind = [];
 for (var i=0; i<n; ++i) {
  ind.push(Math.round(Math.random()*n) % n);
 }
}

function loadJS(n) {
 n = lens[n];
 map = {};
 for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
  map[keyName + "-" + i] = i;
 }
}

function sumJS(n) {
 n = lens[n];
 var s = 0;

 for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
  p = ind[i];
  v = map[keyName + "-" + p];
  s += v;
 }
 console.log(s);
}

function loadLDS(n) {
 n = lens[n];
 map = LDS.HashtableBase(n, LDS.Types.Int32);

 for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
  map.set(keyName + "-" + i, i);
 }
}

function sumLDS(n) {
 n = lens[n];
 var s = 0;
 for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
  p = ind[i];
  v = map.get(keyName + "-" + p);
  s += v;
 }
 console.log(s);
}



