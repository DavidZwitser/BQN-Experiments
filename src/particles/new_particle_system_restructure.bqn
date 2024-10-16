⟨c⇐color, win⇐window, d⇐draw, key, raymath, rayffi⇐raylib, mouse⟩←r←•Import "../../rayed-bqn/rayed.bqn"

w‿h ← 1200‿1200
Norm ← ÷⟜(0⊸=⊸++´⌾(×˜)) # Credits to Brian E

Take ← {v𝕊m: (Size m)↑⎉1 (Pos m)↓⎉1 v}
FromTo ← {v𝕊mf‿mt: mt⊸×⎉1 (≠mt)⊸⥊⎉1 v Take mf }
NormM ← ¬⊸(+⎉1)#  6           m,cc
Pos ← ⊑/
Size ← +´

Function ← {5+𝕩}
Function ¬ 3

Function ˜


particle_system ← {
	max_life ← 2

	m ← {
		p‿v‿f‿l‿s ← options ← ↕5
		comp ← p‿p‿v‿v‿f‿l‿s
		[pos, vel, fric, life, size] ⇐ options =⌜ comp
	}

	Get ⇐ {𝕊amount‿spawn_point: >{𝕊:
		pos ← spawn_point + •rand.Range¨ + 20‿20
		vel ← (10-•rand.Range¨ 20‿20) ÷ 10
		fric ← 1 - 0.0001 × •rand.Range 200
		life ← (•rand.Range max_life×100)÷100
		size ← 4 + 0.1 × •rand.Range 30

		pos∾vel∾fric∾life∾size
	}¨ ↕amount}

	Update ⇐ {𝕊⟨p, attractors‿spawn_point⟩:
		p {𝕩 - m.life × 0.01}˘↩
		p {0 ≥⊑ 𝕩 Take m.life ? ⊏Get 1‿spawn_point ; 𝕩}˘ ↩

		{p {p𝕊attr:
			to_attr ← Norm˘ (⊏attr) -⎉1 p Take m.pos
			p + ⟨1‿1, m.vel⟩ FromTo˜ ×⟜0.4 to_attr
		}↩ 𝕩 }˘ attractors

		p {m.vel NormM 𝕩 FromTo m.fric‿m.vel}⊸×↩
		p {𝕩 FromTo m.vel‿m.pos}⊸+↩
	}


	Draw ⇐ {𝕊p:
		poss ← p Take m.pos
		sizes ← ∾˘˜ p Take m.size
		shapes ← poss (⊣≍+)˘ sizes

		life ← p Take m.life
		colors ← 255 ∾˜˘ 255⊸-˘ ⌊|255 × 3⥊˘ ÷˘⟜max_life life

		colors d.Rectangle˘ ⌊shapes
	}
}

attractors ← {
	Get ⇐ {𝕊amount‿w‿h: >{≍˜ •rand.Range¨ w‿h-𝕩}¨ ↕amount}

	Update ⇐ {𝕊⟨attrs, space‿w‿h⟩:
		{space ? attrs ↩ {(attrs)≍˜•rand.Range¨ w‿h}˘ attrs; @}
		(≍⟜0‿0˘· ×⟜0.1 -˜˝˘)⊸+ attrs
	}
	Draw ⇐ { {c.black d.Ellipse ⌊ 𝕩 (⊣≍+) 20‿20}˘ ⊏˘ 𝕩 }
}

# A game object
Obj ← {fncs‿params:{
	fncs←fncs, # Its Get Update and Draw namespace
	data⇐fncs.Get params, # All the data about the object in array form
	Update ⇐ {data↩fncs.Update data ⋈ 𝕩}
	Draw ⇐ {𝕊:fncs.Draw data}
}}

_OnStart ← {System _𝕣 𝕩:
	win.SetSize w‿h

	game_objects ← {
		ps 	⇐ Obj ⟨particle_system, 400‿(mouse.GetPos⟨⟩)⟩
		attrs 	⇐ Obj ⟨attractors, 3‿w‿h⟩
		something ⇐ Obj ⟨{Get⇐{𝕩}, Update⇐{𝕩}, Draw⇐{𝕩}}, @⟩
	}

	states ← {
		# Functions that return the paramaters to update an object
		# Matching is done based on field name
		play ⇐ {
			Ps 	⇐ {𝕊objs: objs.attrs.data‿(mouse.GetPos⟨⟩)}
			Attrs	⇐ {𝕊: (key.IsDown key.space)‿w‿h }
		}
	}

	System ⟨states.play, game_objects⟩
}

Valls ← ⊣ •ns.Get¨ · •ns.Keys ⊢
PerFrame ← {𝕊 state‿objs:

	params ← {𝕏 objs}¨ Valls state
	params {𝕩.Update 𝕨}¨ objs Valls state

	{𝕩.Draw@}¨ Valls objs

	state‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "test"
