extends Node

var none := Vector2.ZERO
var n := Vector2.UP
var ne := Vector2(1, -1)
var e := Vector2.RIGHT
var se := Vector2(1, 1)
var s := Vector2.DOWN
var sw := Vector2(-1, 1)
var w := Vector2.LEFT
var nw := Vector2(-1, -1)

var all := [n, ne, e, se, s, sw, e, nw]

func v2s(v: Vector2) -> String:
  match v:
    n: return "n"
    ne: return "ne"
    e: return "e"
    se: return "se"
    s: return "s"
    sw: return "sw"
    w: return "w"
    nw: return "nw"

func s2v(st: String) -> Vector2:
  match st:
    "n": return n
    "ne": return ne
    "e": return e
    "se": return se
    "s": return s
    "sw": return sw
    "w": return w
    "nw": return nw

func closest(v: Vector2, dirs := ["n", "ne", "e", "se", "s", "sw", "w", "nw"]) -> Vector2:
  var closest_angle = 2 * PI
  var closest_dir = none
  for dir in dirs:
    var dirvec = s2v(dir)
    var angle = abs(dirvec.angle_to(v))
    if angle < closest_angle:
      closest_angle = angle
      closest_dir = dirvec
  return closest_dir