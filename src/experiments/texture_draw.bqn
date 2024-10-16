⟨c⇐color, win⇐window, draw, key, mouse⟩←r←•Import "../../rayed-bqn/raylib.bqn"

_OnStart ← {System _𝕣 𝕩: System@}

PerFrame←{𝕤
  img←100‿100‿4⥊c.white

  {
    c.white‿𝕩‿4‿0 draw.Texture 0‿0
  } r.texture._WithImage img

} draw._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
