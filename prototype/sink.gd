extends Area2D

func _ready():
  var res = connect("body_entered", self, "body_entered");
  assert(res == OK);
  res = connect("body_exited", self, "body_exited");

func body_entered(body):
  if body is Entity && body.is_player():
    body.sink = 4

func body_exited(body):
  if body is Entity && body.is_player():
    body.sink = 0
