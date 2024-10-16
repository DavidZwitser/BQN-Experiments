⟨c⇐color, win⇐window, d⇐draw, key, StartClock⟩ ← r ← •Import "../../rayed-bqn/rayed.bqn"

_OnStart ← {System _𝕣 𝕩:
  win.SetSize gs × ns
  System⟨⟩
}

ns ← 20‿20
gs ← 50‿50

body ← ⌽[0‿0, 1‿0, 2‿0]
dir ← 1‿0

mainClock ← StartClock @
gameClock ← StartClock @

PerFrame ← {𝕊:
  mainClock.Tick⟨⟩
  {c.black d.Rectangle 𝕩×ns (⊣≍+) ns} ˘ body

  {mainClock.frame > gameClock.frame × 15 ?
    gameClock.Tick⟨⟩

    body ((⊏body)+dir)⊸» ↩
  ;@}

} d._withCanvas_ c.linen

Game ← PerFrame •_While_(¬win.ShouldClose) _OnStart
Game win._openAs "snake"
