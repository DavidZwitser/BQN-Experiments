⟨c⇐color,win⇐window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed-bqn/rayed.bqn"
rayffi←•Import "../../rayed-bqn/ffi/raylib.bqn"

Dist ← +´⌾(×˜)-
frame ← time ← 1
deltatime ← 1
center ← w‿h ← size ← 0‿0
Lfo ← {𝕊 step‿size:
	×⟜size •math.Sin ×⟜time ×⟜step π÷2
}
Rand ← {
	𝕊range: (≠range)≡1 ?
		•rand.Range range;

	𝕊range‿count:
		•rand.Range¨ count⥊range;

	𝕊range‿count‿offset:
		+⟜offset •rand.Range¨ count⥊range;

	𝕊range‿count‿offset‿res:
		+⟜offset ÷⟜res •rand.Range¨ count⥊(range × res)
}

colors ← ⟨
 	c.moccasin, c.darkred, c.orange, c.aqua
⟩

# particle system
Ps ← {𝕊 amount:
	masks ← composition ← {
		all ⇐ p‿v‿f‿l‿s‿c ⇐ ↕6
		comp ⇐ p‿p‿v‿v‿f‿l‿s‿c‿c‿c‿c
		Match ← comp=⊢

		pos   ⇐ p Match↩
		vel   ⇐ v Match↩
		fric  ⇐ f Match↩
		life  ⇐ l Match↩
		size  ⇐ s Match↩
		color ⇐ c Match↩
		full  ⇐ 1¨comp
	}

	# fill masked
	FM ← {m𝕊v: ×⟜m (⊑⍒m)⊸⌽ (≠m)⥊v}
	# get masked
	GM ← {m𝕊l: l×m}
	# get specific value
	GV ← {m𝕊l: ⊑(¬m)⊔l}
	# transport values from one part to another (size polymorphically)
	FromTo ← {from‿to𝕊l: to FM (from GV l)}
	Rotate ← { from‿to𝕊l:
		(from -○(⊑⍒) to) ⌽ l
	}

	# masks.pos‿masks.size FromTo 4‿324‿34‿4‿7653‿756‿3‿75‿23‿54‿99

	spawn_point ← center
	max_life 	← 400

	NewParticle ← {𝕊:
		FMR ← FM⟜Rand
		+´ ⟨masks.pos   FMR (20‿20)‿2‿spawn_point
			masks.vel   FMR {𝕩‿2‿(÷⟜2-𝕩)}15
			masks.fric  FMR 0.02‿1‿0.98‿10000
			masks.life  FMR max_life‿1‿0‿100
			masks.size  FMR 4
			masks.color FM ((Rand≠) ⊑ ⊢) colors⟩
	}

	Update ⇐ {𝕊:
		# LFO spawnpoint
		spawn_point ↩ center + (⌊Lfo 0.1‿(w÷2))‿(⌊Lfo 0.3‿(h÷2))

		# Respawn on dead
		particles {(0< +´ masks.life GM 𝕩) ≢ 0 ? 𝕩 ; NewParticle @ }˘ ↩

		# Fade out
		particles {((¬masks.color)⊸×˘𝕩) + ⌊ ×⟜255 ÷⟜max_life masks.life‿masks.color⊸FromTo˘ 𝕩} ↩

		# Updating lifetime
		particles {((¬masks.life)⊸×˘𝕩) + masks.life⊸GM˘ -⟜deltatime 𝕩} ↩

		# Updating their velocities
		particles {((¬masks.vel)⊸×˘𝕩) + 𝕩× masks.fric‿masks.vel⊸FromTo˘ 𝕩} ↩

		# Updating their positions
		particles {𝕩⊸+ masks.vel‿masks.pos⊸ FromTo˘ 𝕩} ↩
	}

	Render ⇐ {𝕊:
		{ 𝕊particle:
			color ← masks.color GV particle
			pos   ← masks.pos   GV particle
			size  ← masks.size 	GV particle

			color d.Rectangle ⌊ (pos (- ≍ +) 4‿4÷2)
		}˘ particles
	}

	Show ⇐ {𝕊: •Show particles }

	particles ← NewParticle˘ amount⥊1
	attractor ← (w÷2)‿(h÷2)
}

_OnStart ← {Game _𝕣 𝕩:
  	font ← r.font.LoadBQN 100
	Resize @

	particle_system ← Ps 5000

	Game font‿particle_system
}

Resize ← {𝕊: w‿h ↩ size ↩ win.GetSize@, center ↩ size÷2 }


PerFrame ← {𝕊font‿particle_system :
	frame +↩ 1, time +↩ deltatime ← rayffi.GetFrameTime ⟨⟩
	(⊢ ◶ @‿Resize) rayffi.IsWindowResized ⟨⟩

	particle_system.Update @
	particle_system.Render @

	rayffi.DrawFPS 10‿10

	font‿particle_system
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬win.ShouldClose) _OnStart
Game win._openAs "test"
