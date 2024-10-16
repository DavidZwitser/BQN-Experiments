
⟨c⇐color, win⇐window, d⇐draw, m⇐mouse, key, raymath⟩←r←•Import "../../rayed-bqn/rayed.bqn"
rayffi←•Import "../../rayed-bqn/ffi/raylib.bqn"

Dist ← +´⌾(×˜)- 		# Credits to Brian E
Norm ← ÷⟜(0⊸=⊸++´⌾(×˜)) # Credits to Brian E
frame ← time ← dt ← deltatime ← 1
center ← w‿h ← size ← 0‿0


Lfo ← {𝕊 step‿size:
	×⟜size •math.Sin ×⟜time ×⟜step π÷2
}
RR←•rand.Range
Rand ← {
	𝕊range: (≠range)≡1 ? 				RR¨ ≠⊸⥊range;
	𝕊range‿offset: 	+⟜offset   		RR¨ ≠⊸⥊range;
	𝕊range‿offset‿res: +⟜offset ÷⟜res 	RR¨ ≠⊸⥊(range × res)
}

# particle system
PS ← {𝕊 amount:
	m ← masks ← {
		p‿v‿f‿l‿s‿c ⇐ options ← ↕6
		comp ← p‿p‿v‿v‿f‿l‿s‿c
		[pos, vel, fric, life, size, char] ⇐ options =⌜ comp
	}

	# fill masked - m←mask, v←value(s)
	FM ← {m𝕊v: ×⟜m⎉1 (-·⊑⍒m)⊸⌽ (≠m)⥊⎉1 v}
	# get values - m←mask, l←particle list or table
	GV ← {m𝕊l: >⥊1↑⎉1 (¬m)⊸⊔⎉1 l}

	# transport values from one position to another
	# from←from_mask, to←to_mask, F←{to-masked_to_vals𝕊to-masked_from_vals}, t←particles_table
	_FromTo ← {from‿to F _𝕣 t:
		base ← (¬to)⊸×˘ t
		orig ← to⊸×˘ t

		{(+´from) ≡ (+´to) ?
			base + orig⊸F (to -○(⊑⍋) from)⌽˘ from⊸×˘ t
		;
			base + orig⊸F to FM from GV t
		}
	}

	max_life 	← 500
	chars  		← "+-×÷⋆√⌊⌈∧∨¬|≤<≥>=≠≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!𝔽𝔾𝕊𝕗𝕘𝕤˙˜˘¨⌜⁼`∘○⊸⟜⌾⊘◶⎊⎉⚇⍟←⇐↩.;:?•𝕣𝕨𝕩𝕎𝕏⋄,{}⟨⟩()[]‿·¯π∞@#​"
	indexes 	← ⟨51,                                               7,     11,        13,          10,        5,  1,1⟩
	char_colors ← ⟨57‿165‿72, 148‿65‿139, 153‿136‿24, 204‿205‿203, 156‿125‿193, 167‿50‿39, 63‿153‿171, 63‿61‿170⟩
	# Very wastefull I know
	indexed_colors ← indexes/char_colors

	NewParticle ← {𝕊:
		FMR ← FM⟜Rand
		+´ ⟨masks.pos   FMR (200‿200)‿spawn_point
			masks.vel   FMR {(𝕩‿𝕩)‿(÷⟜2-𝕩)‿100}2
			masks.fric  FMR {𝕩‿(1-𝕩)‿10000}0.01
			masks.life  FMR max_life‿0‿1000
			masks.size  FMR 15‿3
			masks.size  FMR 15‿3
			masks.char  FMR ⌊ ≠chars
		⟩
	}

	spawn_point ← center
	Update ⇐ {𝕊 attractors:
		# Oscillate spawnpoint
		spawn_point ↩ center + ⌊ LFO¨ 0.2‿0.3 ∾¨ ÷⟜2 center

		# Respawn on dead
		particles {(0< +´ m.life × 𝕩) ≢ 0 ? 𝕩 ; NewParticle ⟨⟩ }˘ ↩

		# Updating lifetime
		particles -⟜(m.life × deltatime)˘ ↩

		# Handling attraction
		Attr ← {vels𝕊pos: pos (m.vel⊸GV) ↩
			vels - m.vel⊸FM˘ +˝ {𝕊attr:

				to_attr ← -⟜attr˘ pos
				strength ← 800000 ÷ ⋆⟜2 pos Dist˘ to_attr

				(Norm˘ to_attr) ×˘ strength
			}˘ attractors
		}
		particles { m.pos‿m.vel Attr _FromTo 𝕩} ↩

		# Updating their velocities
		particles {m.fric‿m.vel ×⟜dt∘× _FromTo 𝕩} ↩

		# Updating their positions
		particles {m.vel‿m.pos  ×⟜dt∘+ _FromTo 𝕩} ↩
	}

	Resize ⇐ {𝕊:⟨⟩}
	Show ⇐ {𝕊: •Show particles}

	Render ⇐ {𝕊font:

		texts  ← ⊑⟜chars˘ m.char GV particles
		colors ← ⊑⟜indexed_colors˘ m.char GV particles
		# Add the alpha row based on life
		colors {𝕩 ∾˘⌊| ×⟜255 ÷⟜max_life m.life GV particles}↩

		poss   ← m.pos GV particles
		sizes  ← 3× m.size GV particles
		fonts  ← (≢sizes)⥊⋈font

		Fishie ← ⍉·><˘¨
		args ← Fishie ⟨colors, fonts, sizes,  poss, texts⟩

		# Some rather peculilar deconstructing needs to be done. It's to fishy for me to understand
		{𝕊c‿f‿s‿p‿t: f‿s ↩⊑¨ f‿s, c‿f‿s d.Text p‿t}˘ args
	}

	particles ← NewParticle˘ amount⥊1
}

# Attractors
Attrs ← {𝕊amount:
	move_area ← 3000
	Poss ← {𝕊amount: {(center+move_area÷4) - ⌊ •rand.Range¨ ÷⟜2 move_area × 1‿1 × ⊑𝕩}˘ amount⥊1 }

	attractors ⇐ target_poss ⇐ Poss amount
	Mouse ⇐ {𝕊pos: attractors (⌊Pos˘)↩ }
	ChangeTargets ⇐ {𝕊: target_poss (Poss≠)↩}
	Resize ⇐ {𝕊: ChangeTargets ⟨⟩ }
	Update ⇐ {𝕊: attractors +↩ ×⟜dt ×⟜0.05 target_poss-attractors }

	size ← 20
	Render ⇐ {𝕊: {c.beige d.Ellipse ⌊ (𝕩 (- ≍ +) 2⥊size÷2)}˘ attractors}
}

Resize ← {𝕊 font‿particles‿attractors:
	w‿h ↩ size ↩ win.GetSize⟨⟩, center ↩ size÷2
	particles.Resize ⟨⟩
	attractors.Resize ⟨⟩
}
Run ← {𝕊 font‿particles‿attractors:
	# attractors.Mouse +⟜1 m.GetPos ⟨⟩
	attractors.Update ⟨⟩
	particles.Update attractors.attractors
	attractors.Render ⟨⟩
	particles.Render font
}

_OnStart ← {System _𝕣 𝕩:
	particles ← Ps 500
	attractors ← Attrs 2
	font ← r.font.LoadBQN 50

	Resize font‿particles‿attractors

	System font‿particles‿attractors
}

PerFrame ← {𝕊font‿particles‿attractors : model ← font‿particles‿attractors
	frame +↩ 1, time +↩ dt ← deltatime ← rayffi.GetFrameTime ⟨⟩
	{ rayffi.IsWindowResized ⟨⟩ ? Resize model ; @}
	{ key.IsPressed key.space ? attractors.ChangeTargets ⟨⟩ ; @}

	Run model

	# rayffi.DrawFPS 10‿10
	model
} d._withCanvas_ c.white

# r.rayffi.SetTraceLogLevel r.traceLogLevel.warning
System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "test"
