⟨c⇐color, win⇐window, d⇐draw, m⇐mouse⟩←r←•Import "../../rayed-bqn/rayed.bqn"
rf ← •Import "../../rayed-bqn/ffi/raylib.bqn"

w‿h←size←800‿800
win.SetSize size

Rot ← (•math.Cos∾•math.Sin)⊸(-´∘×⋈·+´⌽⊸×)

LFO ← {𝕊 step‿size:
	×⟜size +⟜0.5 ÷⟜2 •math.Sin ×⟜(gc.Time⟨⟩) ×⟜step π÷2
}

gc ← r.StartClock @

_OnStart ← {System _𝕣 𝕩:
	# {System 𝕩} r.texture._WithImage ⌊200‿200‿4⥊c.white
	System @
}

PerFrame←{𝕊tex:
	l1 ← LFO 1‿1
	l2 ← LFO 0.5‿1

	pos ← size×l2‿l1
	size ← size×0.1

	c.orange⊸d.Ellipse ⌊pos (-≍+) size

} d._withCanvas_ c.white

System ← PerFrame•_While_(¬r.window.ShouldClose) _OnStart
System r.window._openAs "example"
