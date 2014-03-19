# Coloury shit
ANSI =
  black: '\x1B[31;0m'
  red:   '\x1B[31;1m'
  rgb: (r, g, b) -> "\x1B[38;5;#{16+r*36+g*6+b}m"
  inc: (n, m=216) -> "\x1B[38;5;#{16+1+0|n*216/m}m"   # 0| floors, n is step along from 0 to m, 216 over m scales it to 216
  ci: (n, m=216) -> ANSI.inc(parseInt(n,10), m) + n + ANSI.reset
  reset: '\x1B[0m'
  colour: (r,g,b) -> (str) -> ANSI.rgb(r, g, b) + str + ANSI.reset
  randomColour: () -> ANSI.colour Math.random()*6|0, Math.random()*6|0, Math.random()*6|0
  hashColour: (msg) ->
    n = 0
    n = (n + letter.charCodeAt(0)*(index+21)) % 216 for letter, index in msg
    
    (str) -> ANSI.inc(n) + str + ANSI.reset

colourHash = {}

pad = (s, n=2) ->
  s = s.toString()
  if s.length < n then pad("0#{s}") else s
ts = timestamp = () ->
  d = new Date
  a = '/'
  b = ' '
  c = ':'
  ANSI.ci(pad(d.getUTCDate()), 31) + a + ANSI.ci(pad(d.getUTCMonth()+1), 12) + b +   # Why does getUTCMonth go 0-11? ><
    ANSI.ci(pad(d.getUTCHours()), 24) + c + ANSI.ci(pad(d.getUTCMinutes()), 60) +
    c + ANSI.ci(pad(d.getUTCSeconds()), 60)

# colour hash
ch = (msg) ->
  msg ?= ''
  msg = msg.toString()
  colourHash[msg] = ANSI.hashColour(msg) unless colourHash[msg]?
  colourHash[msg] msg

exports.log = (msg) ->
  console.log "#{ts()}: #{msg}"  

exports.bind = (title, width) ->
  title = ' ' + title while title.length < width if width
  (msg) -> console.log "#{ts()} #{ch title}: #{msg}"

exports.ANSI = ANSI
exports.ts = ts
exports.ch = ch
