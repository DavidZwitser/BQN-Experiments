⟨c⇐color,win⇐window,d⇐draw,m⇐mouse, raymath⟩←r← •Import "../../rayed-bqn/rayed.bqn"
rayffi ← •Import "../../rayed-bqn/raylib.bqn"

# Dist ← √+´·⋆⟜2-
# Dist ← {√+´(𝕨-𝕩)⋆2}
Dist ← +´⌾(×˜)-
L ← +´⌾(×˜)
time ← 0

colors ← ⟨
 c.moccasin, c.lightred, c.orange
⟩

size ← w‿h ← 0‿0
scale ← 20
field ← 0
_OnStart ← {𝕨 Func _𝕣 𝕩:
  	font ← r.font.LoadBQN 100

	w‿h ↩ size ↩ ⌊(win.GetSize @) ÷ scale
	field ↩ > {⟨⌊w|𝕩, ⌊𝕩÷w⟩} w‿h⥊↕w×h

	img ← (size∾4) ⥊255

	{𝕊tex:
		tex‿font Func img‿¯2
	} r.texture._WithImage img
}

Lfo ← {𝕊 step‿size: (((•math.Sin ((10÷⌊10×time × π÷2) × step)) × size) + 1) ÷ 2}
Sphere ← {p𝕊r: -⟜r L p }
Box ← {p𝕊s:
	q ← -⟜s | p
	+⟜(L(q⌈0.0)) ⌊⟜0.0 ⌈´q
}
SDF ← {p𝕊r:
	b ← (p+(1‿0‿1)) Box 1‿1‿1
	s ← p Sphere r
	s
}

hit_threshold ← 0.05
max_distance ← 100

March ← {pos𝕊dir:
	total_distance ← 0
	hit ← 0
	{𝕊:
		curr_pos ← pos + dir × total_distance
		dist ← curr_pos SDF 1

		{ dist < hit_threshold ?
			hit ↩ 1
			dist
		; total_distance > max_distance ?
			0
		;
			total_distance +↩ dist
			1
		}

	}•_While_{𝕩 ≡ 1} 1

	# hit

}

last ← 0‿0
sensitivity ← 1
camera_pos ← 0‿0‿¯4

PerFrame ← {tex‿font𝕊img‿wheel:
	x‿y ← mouse ← m.GetPos @
	mx‿my ← -⟜1 ×⟜2 ÷⟜(size×scale) m.GetPos @
	time +↩ rayffi.GetFrameTime @
	wheel +↩ ×⟜0.1 m.WheelMoved @

	dx‿dy ← mouse - last
	last ↩ mouse
	md ← rayffi.IsMouseButtonDown m.button.left

	RotateX ← {𝕩 raymath.MP˜ raymath.MatrixRotateY md∧(dx÷w)×sensitivity }
	RotateY ← {𝕩 raymath.MP˜ raymath.MatrixRotateX md∧((-dy)÷h)×sensitivity }
	camera_pos ↩ RotateY RotateX camera_pos

	Mask_func ← {
		u‿v ← -⟜1 ×⟜2 ÷⟜size 𝕨‿𝕩
		camera_pos March (÷⟜4 +⟜u‿v‿0 -camera_pos)
	}

	color_mask ← Mask_func¨˝ field

	# color_mask ↩ (≠colors) | color_mask
	# img ↩ > colors ⊏˜ color_mask

	img ↩> {⌊c.orange × ((-𝕩)×20)}¨ color_mask

  	c.white‿tex‿scale‿0 d.Texture 1‿1
  	rayffi.UpdateTexture tex⋈⥊img
  	# c.white‿font‿30  d.Text 20‿20⋈•Repr∘win.fps.Get⊸∾" FPS"

	img‿wheel
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬win.ShouldClose)_OnStart
Game win._openAs "test"
