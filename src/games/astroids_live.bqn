⟨c⇐color, win⇐window, font, d⇐draw, m⇐mouse, key, raymath, rayffi⇐raylib⟩ ← •Import "../../rayed-bqn/rayed.bqn"

center ← w‿h ← 0‿0
ShapeCenter ← (+˝÷(≠˘⍉))>

Rotate ← {a‿offset𝕊x‿y:
	s ← •math.Sin a
	c ← •math.Cos a

	x‿y ↩ x‿y-offset

	x‿y ↩ ⟨(x×c) - y×s
	 	   (x×s) + y×c⟩

	x‿y+offset
}

Player ← {𝕊:
	life⇐3
	pos←center, vel←0‿0, rot←0, size ← 35, fric ← 0.999
	speed ← 0.02, rot_speed ← π×0.01
	player_shape ← ⟨0‿0, 1‿0, 0.5‿1.5⟩
	shape_center ← ShapeCenter player_shape

	ShapePlayer ← {𝕊: pos⊸+¨ size × rot‿shape_center⊸Rotate¨ player_shape}
	PlayerTip ← {𝕊: ⊑⌽ShapePlayer @}

	BulletInfo ⇐ {𝕊: (PlayerTip@)‿rot }
	Boost ⇐ {𝕊: vel +↩ speed × rot‿(0‿0) Rotate 0‿1 }
	Orient ⇐ {𝕊: rot +↩ 𝕩×rot_speed }
	Update ⇐ {𝕊:
		pos ({x‿y: (w|x)‿(h|y)} +)↩ vel, vel ×↩ fric
	}
	Draw ⇐ {𝕊: rayffi.DrawTriangleLines (ShapePlayer@)∾<c.white }
}

Bullet ← {𝕊 pos‿rot:
	life ⇐ 1
	vel ← 5 × rot‿(0‿0) Rotate 0‿1
	size ← 2

	Update ⇐ {𝕊: pos+↩vel, {∨´pos>w‿h ? life ↩ 0 ; @}}
	Draw ⇐ {𝕊: c.white d.Rectangle ⌊(pos(-≍+)size÷2)  }
}

Astroid ← {𝕊:
	life ⇐ 1
	size ← 1+•rand.Range 5
	scale ← 20
	vel ← {(𝕩÷2)-•rand.Range 𝕩}¨ 5‿5
	pos ← center + {(𝕩÷2)-•rand.Range 𝕩}¨ ⌊(w÷2)‿(h÷2)

	CreateShape ← {𝕊 v_count‿off_chance‿off_size:
		Circle ← {{𝕩‿(0‿0) Rotate 0‿1}¨ 𝕩÷˜π×2 × 1+ ↕𝕩}
		{(𝕩 - {÷⟜10 •rand.Range 𝕩×10}¨ 2⥊off_size) ×0≡•rand.Range off_chance}¨ Circle v_count
	}
	my_shape ← CreateShape 10‿3‿0.4
	ShapeShape ← {𝕊: (⊢∾<∘⊑) pos⊸+¨ scale×size × my_shape}

	Draw ⇐ {𝕊: {c.white⊸d.Line 𝕩≍𝕨, 𝕩}` ShapeShape@ }
	Update ⇐ {𝕊: pos ({x‿y: (w|x)‿(h|y)} +)↩ vel}
}

CleanWorld ← {𝕊 world:
	{𝕩⊑world}¨ / {𝕩.life ≢ 0}¨ world
}

_OnStart ← {Game _𝕣 𝕩:
	win.SetPos 1820‿0
	rayffi.SetWindowState win.configFlags.window_resizable
	Resize⟨⟩

	player ← Player @
	astroids ← Astroid¨ ↕5

	Game player∾astroids
}

Resize ← {𝕊:
	w‿h ↩ win.GetSize@
	center ↩ w‿h ÷ 2
}

Input ← {𝕊 world:
	player ← ⊑world
	{key.IsDown key.up ? player.Boost 1; 0}
	{key.IsDown key.right ? player.Orient 1; 0}
	{key.IsDown key.left ? player.Orient ¯1; 0}
	{key.IsPressed key.space ?
		world ∾↩ Bullet player.BulletInfo @ ; @
	}
	world
}

PerFrame ← {𝕊 world:
	{rayffi.IsWindowResized⟨⟩ ? Resize⟨⟩ ; @}

	player ← ⊑world
	world Input↩

	{𝕩.Update @}¨ world
	{𝕩.Draw @}¨ world

	world CleanWorld↩

	world
} d._withCanvas_ c.black

Game ← PerFrame •_While_ (¬win.ShouldClose) _OnStart
Game win._openAs "Astroids"
