⟨c⇐color, win⇐window, d⇐draw, key, raymath, rayffi⇐raylib, mouse⟩←r←•Import "../../rayed-bqn/rayed.bqn"

w‿h ← 1200‿1200
Norm ← ÷⟜(0⊸=⊸++´⌾(×˜)) # Credits to Brian E

Take ← {v𝕊m: (Size m)↑⎉1 (Pos m)↓⎉1 v}
FromTo ← {v𝕊mf‿mt: mt⊸×⎉1 (≠mt)⊸⥊⎉1 v Take mf }
Map ← {val𝕊m: m⊸×⎉1 val}
NormM ← ¬⊸(+⎉1)
Pos ← ⊑/
Size ← +´

PS ← {𝕊amount:
	max_life ← 2
	spawn_point ⇐ ÷⟜2 w‿h

	m ← {
		p‿v‿f‿l‿s ← options ← ↕5
		comp ← p‿p‿v‿v‿f‿l‿s
		[pos, vel, fric, life, size] ⇐ options =⌜ comp
	}

	Get ← {𝕊:
		pos ← spawn_point + •rand.Range¨ + 20‿20
		vel ← (10-•rand.Range¨ 20‿20) ÷ 10
		fric ← 1 - 0.0001 × •rand.Range 200
		life ← (•rand.Range max_life×100)÷100
		size ← 4 + 0.1 × •rand.Range 30

		pos∾vel∾fric∾life∾size
	}
	p ← >Get¨ ↕amount

	Update ⇐ {𝕊 attractors‿sp:
		spawn_point ↩ sp
		p {𝕩 - m.life × 0.01}˘↩
		p {0 ≥⊑ 𝕩 Take m.life ? Get @ ; 𝕩}˘ ↩

		{p {p𝕊attr:
			to_attr ← Norm˘ attr -⎉1 p Take m.pos
			p + ⟨1‿1, m.vel⟩ FromTo˜ ×⟜0.4 to_attr
		}↩ 𝕩 }˘ attractors

		p {m.vel NormM 𝕩 FromTo m.fric‿m.vel}⊸×↩
		p {𝕩 FromTo m.vel‿m.pos}⊸+↩
	}

	Draw ⇐ {𝕊:
		poss ← p Take m.pos
		sizes ← ∾˘˜ p Take m.size
		shapes ← poss (⊣≍+)˘ sizes

		life ← p Take m.life
		colors ← 255 ∾˜˘ 255⊸-˘ ⌊|255 × 3⥊˘ ÷˘⟜max_life life

		colors d.Rectangle˘ ⌊shapes
	}
}

Attr ← {a𝕊w‿h:
	amount ← a
	attrs ⇐ •rand.Range¨ amount‿2⥊w‿h
	goal_poss ← attrs

	NewPos ⇐ {𝕊w‿h: goal_poss ↩ •rand.Range¨ amount‿2⥊w‿h}
	Draw ⇐ {𝕊: {c.black d.Ellipse ⌊ 𝕩 (⊣≍+) 20‿20}˘ attrs }
	Update ⇐ {𝕊: attrs +↩ 0.04 × goal_poss-attrs }
}

particles ← PS 400
attractors ← 3 Attr w‿h

_OnStart ← {System _𝕣 𝕩:
	win.SetSize w‿h
	particles←PS 400
	attractors← 3 Attr w‿h
	System particles‿attractors
}

PerFrame ← {𝕊 world:

	attractors.Update⟨⟩
	particles.Update attractors.attrs‿(mouse.GetPos⟨⟩)
	particles.Draw⟨⟩
	attractors.Draw⟨⟩

	{key.IsPressed key.space ? attractors.NewPos w‿h ; @}
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "test"
