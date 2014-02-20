str = ""
for r in [0..5]
  for g in [0..5]  
    for b in [0..5]  
      c = 16+r*36 +g*6 + b
      str += "\x1B[38;5;#{c}m\u2588"
    str += " "
  str += "\n"

str += '\n'
for x in [0..255]
  str += "\x1B[38;5;#{x}m\u2588"
  str += "\n" if x % 16 == 1
str += "\x1B[0m"
console.log str
