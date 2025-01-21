extends Node


func lerp_scale():
	if self.cursor.is_pinning:
		if not is_equal_approx(self.scale.x, 1.0):
			self.scale *= 1.1
			self.sprite.modulate.a = 1.0
			self.scale = clamp(self.scale, Vector2(0.1,0.1), Vector2.ONE)
		else:
			self.collision_shape.disabled = false
	else:
		if not is_equal_approx(self.scale.x, 0.0):
			self.scale *= 0.9
			self.sprite.modulate.a *= 0.95
			self.scale = clamp(self.scale, Vector2.ZERO, Vector2.ONE)
		else:
			self.collision_shape.disabled = true
