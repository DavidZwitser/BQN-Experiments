⟨c⇐color, win⇐window, font, d⇐draw, m⇐mouse, key, raymath, rayffi⇐raylib⟩←r←•Import "../../rayed-bqn/rayed.bqn"

Dist ← +´⌾(×˜)- 		# Credits to Brian E
ShapeCenter ← (+˝÷(≠˘⍉))>

fontBQN ← @
frame ← time ← dt ← deltatime ← 1
center ← w‿h ← size ← 0‿0

states ← {start‿play‿reset‿dieing ⇐ ↕4}

Rotate ← { info 𝕊 x‿y:
	angle ← 0, orig ← 0‿0
	{(≠info) ≡ 2 ? angle‿orig ↩ info ; angle ↩ info}

	s←•math.Sin angle, c←•math.Cos angle
	orig + {x‿y: ⟨(x×c) - y×s, (x×s) + y×c⟩} x‿y - orig
}

RR←•rand.Range
Rand ← {
	𝕊range: (≠range)≡1 ? 				RR¨ ≠⊸⥊range;
	𝕊range‿offset: 	offset +   		RR¨ ≠⊸⥊range;
	𝕊range‿offset‿res: offset + ÷⟜res 	RR¨ ≠⊸⥊(range × res)
}

player_base_shape ← (⊢∾<∘⊑)⟨0.2‿0.3, 0‿0, 0.5‿1.5, 1‿0, 0.8‿0.3⟩
Player ← {type ⇐ 𝕤
	pos ← center, vel ← 0‿0, rot ← 0, life ⇐ 3
	rocket_power ← 0.05, rot_speed ← 0.02, size ← 20, fric ← 0.995, color ← c.white
	boosting ← 0

	shape ← {
		base_center‿base_shape ⇐ (ShapeCenter⋈⊢) player_base_shape

		ShapeShape ← {pos⊸+¨ size⊸× rot‿base_center⊸Rotate¨𝕩}
		FullBody ⇐ {𝕊: ShapeShape base_shape}
		FullShapePoint ⇐ {𝕊: 2⊑ FullBody@}

		base_flame ⇐ (⊢∾<∘⊑)⟨0.5‿¯0.2, 0.2‿0.3, 0.8‿0.3⟩
		FullFlame ⇐ {𝕊: ShapeShape base_flame}
	}

	Orient ⇐ {𝕊: rot +↩ π×rot_speed×𝕩}
	Boost  ⇐ {𝕊: 𝕩>0? boosting ↩ 1, vel +↩ rocket_power × rot‿(0‿0) Rotate 0‿𝕩; boosting↩0 }
	GetBulletInfo  ⇐ {𝕊: (shape.FullShapePoint @)‿rot}

	Update ⇐ {𝕊: pos ({x‿y: (w|x)‿(h|y)}+)↩ vel, vel ×↩ fric }

	Draw ⇐ {𝕊:
		{color⊸d.Line 𝕩≍𝕨, 𝕩}` shape.FullBody @
		{boosting ∧ 5<10|frame? {color⊸d.Line 𝕩≍𝕨, 𝕩}` shape.FullFlame@ ;@}
	}

	CollBody ⇐ {𝕊: shape.FullBody@}
	GotHit ⇐ {𝕊: life -↩ 1, vel↩0‿0 }
	Dieing ⇐ {𝕊: color ↩ (10>20|frame)⊑⟨c.white,c.black⟩}
	CenterMe ⇐ {𝕊: pos↩center}
}

Astroid ← {𝕊info: type ⇐ 𝕤
	max_size ← 6, scale ← 10, life ⇐ 1
	size ← 1 + •rand.Range max_size - 1
	pos ← Rand (w‿h)‿(center+100)

	{info≢@ ? size‿pos ↩ info; @}

	vel ← 0.5 × Rand {(𝕩‿𝕩)‿(-𝕩÷2)‿1000} max_size-size

	CreateShape ← {𝕊 v_count‿off_chance‿off_size:
		Circle ← {{𝕩‿(0‿0) Rotate 0‿1}¨ 𝕩÷˜π×2 × 1+ ↕𝕩}
		{𝕩 - ({Rand (𝕩‿𝕩)‿0‿10} off_size) × 0≡•rand.Range off_chance }¨  Circle v_count
	}
	shape ← CreateShape 10‿3‿0.8
	FullBody ← {𝕊: (⊢∾<∘⊑) pos⊸+¨ scale × size × shape }

	Update ⇐ {𝕊: pos ({x‿y: (w|x)‿(h|y)}+) ↩ vel}

	Draw ⇐ {𝕊: {c.white⊸d.Line 𝕩≍𝕨, 𝕩}` FullBody @ }
	CollBody ⇐ {𝕊: pos‿(scale×size) }
	Split ⇐ {𝕊: life ↩ 0, ⋈˜(size-1)‿pos}
}
Bullet ← {pos‿vel: type ⇐ 𝕤
	life ⇐ 100, size ← 2

	Update ⇐ {𝕊: pos ({x‿y: (w|x)‿(h|y)}+) ↩ vel, life -↩ dt }
	Draw   ⇐ {𝕊: c.white d.Rectangle ⌊pos (-≍+) 2⥊ size÷2}
	CollBody ⇐ {𝕊: pos≍2⥊size}
	Kill ⇐ {𝕊: life ↩ 0}
}

DrawUI ← {𝕊 lives:
	lives > 0 ?
		shapes ← {(𝕩×40)‿0⊸+¨ (w×0.04)‿(h×0.08)⊸+¨ 20 × π⊸Rotate¨ player_base_shape}¨ ↕lives
		{c.white⊸d.Line 𝕩≍𝕨, 𝕩}`¨ shapes
	; @
}

Input ← {𝕊 world:
	player←⊑world
	{key.IsDown key.right ? player.Orient 1; @}
	{key.IsDown key.left ? player.Orient ¯1; @}
	{key.IsDown key.up ? player.Boost 1; player.Boost 0}
	{key.IsPressed key.space ?
		pos‿rot ← player.GetBulletInfo @
		world ∾↩Bullet pos‿(rot‿(0‿0) Rotate 0‿7)
		; @
	}
	world
}
Collision ← {𝕊 state‿world:
	bullets ← {𝕩 ⊑ world}¨ / {𝕩.type ≡ bullet}¨ world
	astroids ← {𝕩 ⊑ world}¨ / {𝕩.type ≡ astroid}¨ world
	player ← ⊑world

	new_astroids ← ⟨⟩
	BullHit ← {bullet 𝕊 astroid:
		rayffi.CheckCollisionCircleRec (astroid.CollBody@)∾(<bullet.CollBody@) ?
			bullet.Kill @
			new_astroids ∾↩ astroid.Split @
		; @
	}
	bullets BullHit⌜ astroids
	world ∾↩ Astroid¨ new_astroids

	player_bod ← player.CollBody @
	player_is_hit ← ∨´∨˝ player_bod {
 		player_point𝕊astroid: rayffi.CheckCollisionPointCircle (<𝕨)∾𝕩.CollBody @
	}⌜ astroids

	{player_is_hit ? player.GotHit @, state↩states.dieing; @}
	{player.life ≡ 0 ? state ↩ states.reset ;@}

	state‿world
}

Run ← {state‿world:
	{state ≡ states.start ?
		size ← 40
		{
			(150|frame)>50?@
				c.white‿fontBQN‿size d.Text { (⌊ center - (size × 0.5× ≠𝕩)‿(|size÷2))‿𝕩 } "space to s↑art"
			;
				@
		}
		{key.IsDown key.space ? state ↩ states.play, frame↩0 ; @}

		state‿world
	; state ≡ states.play ?
		{𝕩.Draw @}¨ world
		DrawUI (⊑world).life

		{frame≡1? {𝕩.Update@}¨ world ;@}
		{ frame<200?
				font_size ← 40
				c.white‿fontBQN‿font_size d.Text {(center - (font_size × 0.5× ≠ 𝕩)‿font_size÷2)‿𝕩} •Fmt ⌈3-3×frame÷200
			;
				world Input↩
				world Clean ↩
				{𝕩.Update @}¨ world
		}

		state‿world Collision↩

		{state ≡ states.dieing ? frame↩0; @}
		state‿world

	; state ≡ states.dieing ?
		player ← (⊑world)
		{frame < 100 ?
			DrawUI player.life
			player.Dieing @
			{𝕩.Draw@}¨ world
			state‿world
		;
			player.CenterMe@
			states.play‿world
		}

	; state ≡ states.reset ?
		world ↩ CreateWorld 10‿@
		state ↩ states.start
		state‿world

	;state.reset‿world}
}

Clean ← {𝕊 world:
	{𝕩⊑world}¨ / {𝕩.life≢0}¨ world
}

CreateWorld ← {𝕊 astroid_amount‿prev_player:

	{prev_player≡@? prev_player ↩ Player @; @}
	astroids ← Astroid¨ astroid_amount⥊@
	prev_player∾astroids

}

_OnStart ← {System _𝕣 𝕩:
	# win.SetPos 1820‿0
	rayffi.SetWindowState win.configFlags.window_resizable

	Resize ⟨⟩
	fontBQN ↩ font.LoadBQN 80

	System states.reset‿⟨⟩
}

Resize ← {𝕊 world:
	w‿h ↩ size ↩ win.GetSize@, center ↩ size÷2
}

PerFrame ⇐ {𝕊 state‿world:
	frame +↩ 1, time +↩ dt ← deltatime ← rayffi.GetFrameTime⟨⟩
	{ rayffi.IsWindowResized⟨⟩ ? Resize world ; @}

	# rayffi.DrawFPS 20‿30
	Run state‿world
} d._withCanvas_ c.black

System ← PerFrame •_While_ (¬win.ShouldClose) _OnStart
System win._openAs "Astroids"
