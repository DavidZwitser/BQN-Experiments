⟨win⇐window, d⇐draw⟩←r←•Import "../../rayed-bqn/rayed.bqn"

win.SetSize size←800‿800
scale ← 10
grid ← ⌊size÷scale
Sow ← {𝕨⌾((•rand.Range¨≢𝕩)⊑⊢)𝕩}

a ← 0⊸Sow⍟20 grid⥊1
b ← ¬a

d1 ← 1
d2 ← 0.5
f ← 0.035
k ← 0.058

diffusion_grid ← [
	0.05‿0.2‿0.05
	0.2‿ ¯1 ‿0.2
	0.05‿0.2‿0.05
]

PerFrame ← {𝕊:
	[a, b] ↩ |1‿2⍉>˘ {ga𝕊gb:
		a ← 1⊑1⊏a ⋄ b ← 1⊑1⊏b
		⟨+⟜(f×1-a) -⟜(a×b×b) +´+˝ d1 × ga + diffusion_grid
		 +⟜(f+k×b) +⟜(a×b×b) +´+˝ d2 × gb + diffusion_grid⟩
	}¨´ { 𝕩⊸{3‿3⊸↑ (𝕩+1)⊸⌽ 𝕨 }¨ ↕≢𝕩}¨ a‿b

	↕∘≢⊸({x‿y𝕊a‿b: (|⌊0⊸⌈255⊸⌊⟨a×255, b×255, 0, 255⟩) d.Rectangle |⌊(x‿y×scale) (⊣≍+) ∾˜ scale}¨) a∾¨b
} d._withCanvas_ (4⥊255)

System ← PerFrame•_While_(¬r.window.ShouldClose)
System r.window._openAs "example"
