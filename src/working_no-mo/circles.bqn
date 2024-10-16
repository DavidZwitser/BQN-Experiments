⟨c⇐color,win⇐window,d⇐draw,m⇐mouse, texture⟩←r←•Import "../../raylib.bqn"

# Dist ← √+´·⋆⟜2-
# Dist ← {√+´(𝕨-𝕩)⋆2}
Dist ← +´⌾(×˜)-
frame ← 10
time ← 0

colors ← ⟨
 c.moccasin, c.lightred, c.orange
⟩

size ← 0‿0
scale ← 2
field ← 0
_OnStart ← {𝕨 Func _𝕣 𝕩:
  	font ← r.font.LoadBQN 100

	w‿h ← size ↩ ⌊(win.GetSize @) ÷ scale
	field ↩ > {⟨⌊w|𝕩, ⌊𝕩÷w⟩} w‿h⥊↕w×h

	img ← (size∾4) ⥊255

	{𝕊tex:
		tex‿font Func img‿1
	} texture._WithImage img
}

Lfo ← {𝕊 step‿size: (((•math.Sin ((10÷⌊10×time × π÷2) × step)) × size) + 1) ÷ 2}

PerFrame ← {tex‿font𝕊img‿wheel:
	w‿h ← size
	sw‿sh ← ⌊size ÷ scale
	time +↩ r.rayffi.GetFrameTime @
	wheel +↩ r.mouse.WheelMoved @

	frame +↩ 1

	Mask_func ← {
		x← ⌊ ×⟜ (wheel×0.005) (÷⟜scale r.mouse.GetPos@) Dist 𝕨‿𝕩
		y← ⌊ ×⟜ (wheel×0.007) (×⟜(w×0.01) ÷⟜scale -r.mouse.GetPos@) Dist 𝕨‿𝕩
		y×x
	}

	color_mask ← Mask_func˝ field


	color_mask ↩ (≠colors) | color_mask
	img ↩ > colors ⊏˜ color_mask

  	c.white‿tex‿scale‿0 d.Texture 1‿1
  	r.rayffi.UpdateTexture tex⋈⥊img
  	c.white‿font‿30  d.Text 20‿20⋈•Repr∘win.fps.Get⊸∾" FPS"

	img‿wheel
} d._withCanvas_ c.black

Game ← PerFrame •_While_(¬win.ShouldClose)_OnStart
Game win._openAs "test"
