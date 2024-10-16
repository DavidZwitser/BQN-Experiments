ps_funcs ← {
	Get ⇐ {⟨⟨2, 6, 3⟩, ⟨343, 02, 2⟩⟩}
	Render ⇐ {𝕊p: •Show p}
}
attr_funcs ← {
	Get ⇐ {3‿20}
}
[x,U,i]
model ← ⟨
	Clock.start @
	⟨ps.Get @⟩‿⟨ps.Get @⟩
	attr.Get @
⟩


Update ← {𝕊 model←⟨clock, ps, attr⟩:
⟨
	clock.Tick @
	ps_funcs.Update ps‿attr
	attr_funcs.Update attr
⟩
}

Render ← {𝕊 ⟨ps‿attr⟩:

}

{Render 𝕩, Update 𝕩} •_While_ {𝕩 ≢ 0} model
