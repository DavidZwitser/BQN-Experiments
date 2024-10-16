⟨c⇐color, win⇐window, d⇐draw, m⇐mouse, key⟩← r ← •Import "../../rayed-bqn/rayed.bqn"

Norm ← ÷⟜(0⊸=⊸++´⌾(×˜)) # Credits to Brian E

Take ← {v𝕊m: (Size m)↑⎉1 (Pos m)↓⎉1 v}
Pos ← ⊑/
Size ← +´
FromTo ← {v𝕊mf‿mt: mt⊸×⎉1 (≠mt)⊸⥊⎉1 v Take mf }
NormM ← ¬⊸(+⎉1)

# Particle system
ps ← {
	max_life ← 5
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

	# Attract ⇐ {attractors𝕊p: [pos + vel, (1-fric) × vel + 0‿gravity]}
	Die 	⇐ {𝕊p: (m.life × 0.1)⊸-˘ p }
	Spawn 	⇐ {⟨sp⟩𝕊p: p (0⊸≥·⊑⊢)◶⟨⊣, ⊏Get 1‿sp⟩˘ p Take m.life }
	Move 	⇐ {𝕊p: p + p FromTo m.vel‿m.pos}
	Fric 	⇐ {𝕊p: p × m.vel NormM p FromTo m.fric‿m.vel }
	Attract ⇐ {attrs𝕊p:
		{𝕊attr:
			to_attr ← Norm˘ (⊏attr) - ⎉1 p Take m.pos
			p + ⟨1‿1, m.vel⟩ FromTo˜ ×⟜0.4 to_attr
		}˘ attrs
	}

	Draw ⇐ {𝕊p:
		poss ← p Take m.pos
		sizes ← ∾˜˘ p Take m.size
		shapes ← poss (⊣≍+)˘ sizes

		life ← p Take m.life
		colors ← 255 ∾˜˘ 255⊸-˘ ⌊|255 × 3⥊˘ ÷˘⟜max_life life

		colors d.Rectangle˘ ⌊shapes
	}
}

attrs ← {
	NewPos ⇐ {𝕊:@}

	Draw ⇐ {𝕊:@}
}

_OnStart ← {System _𝕣 𝕩:
	c ← {
		w‿h ⇐ win_size 	⇐ 800‿800
		gravity 	⇐ 1.5
		friction 	⇐ 0.01
	}
	win.SetSize c.win_size

	# Initialise and create all the game objects
	game_objects ← {
		system ⇐ {
			Get 	⇐ {𝕊: ps.Get 200‿(c.win_size÷2)}
			Draw	⇐ ps.Draw
			Apply 	⇐ {data↩𝕩}
			data 	⇐ Get@
		}
		attractors ⇐ {
			Get 	⇐ {𝕊: >{≍˜ •rand.Range¨ c.w‿c.h-𝕩}¨ ↕5}
			Draw 	⇐ attrs.Draw
			Apply 	⇐ {data↩𝕩}
			data 	⇐ Get@
		}
	}

	states ← {
		play ⇐ {
			Update ⇐ {𝕊⟨system, attractors⟩:{⇐
				system ⇐ (⊏˘ attractors.data) ps.Attract ps.Fric ps.Move system.data
			}}
			Draw ⇐ {𝕊objs: ⟨objs.system, objs.attractors⟩}
			NewState ⇐ {𝕊: states.play }
		}
	}

	System ⟨⟨{⇐}, states.play⟩, game_objects⟩
}

Vals ← ⊣ •ns.Get¨ · •ns.Keys ⊢
PerFrame ← {𝕊 ⟨last_state, state⟩‿objs:

	fresh_objs ← state.Update objs
	v ← Vals fresh_objs
	v {𝕩.Apply 𝕨}¨ objs Vals fresh_objs

	{𝕩.Draw 𝕩.data}¨ state.Draw objs

	last_state ↩ state
	state ↩ state.NewState objs

	⟨last_state, state⟩‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
