⟨c⇐color, win⇐window, d⇐draw, rf⇐raylib, m⇐mouse, key⟩←r← •Import "../../rayed-bqn/rayed.bqn"

node_size ← 50
gw‿gh←gs← ÷⟜node_size sw‿sh←size← ∾˜1200
win.SetSize size

_OnStart ← {System _𝕣 𝕩:
	System @
}

shapes ← ⟨
	[1‿1‿1‿1]

	[1‿0
	 1‿0
	 1‿1]

	[1‿0
	 1‿1
	 0‿1]

	[1‿1‿1
	 0‿1‿0]

	[1‿1
	 1‿1]
⟩

Block ← {𝕊:
	shape ← shapes ⊑˜ •rand.Range ≠shapes
	width ← ≠shape
	x ← width + •rand.Range gw-2 × width
	y←0

	Update ⇐ {𝕊 tick:
		y +↩ tick
		{ x (0⊸⌈(node_size×gw-width)⊸⌊)∘+↩ 𝕩×node_size }¨ {𝕩 ⊑ 1‿¯1}¨ /key.IsPressed¨ key.right‿key.left
		{key.IsPressed key.space ? shape ⌽∘⍉↩ ;@}
	}
	Draw ⇐ {𝕊:
		{c.gray d.Rectangle (node_size×x‿y+𝕩) (⊣≍+) 0.9×node_size }¨ ↕∘≢⊸(-⟜1⊸×○⥊) shape
	}
}

clock ← r.StartClock@
game_clock ← 0
fall ← Block@
PerFrame ← {𝕊:
	clock.Tick@

	game_clock +↩ tick ← (clock.Time@) > 0.3×game_clock
	fall.Update tick

	fall.Draw@
} d._withCanvas_ c.white

System ← PerFrame•_While_(¬r.window.ShouldClose) _OnStart
System r.window._openAs "example"
