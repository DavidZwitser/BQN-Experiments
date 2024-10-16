# Todo:
# give information on when this updates (timestamp of last import?)
# also give info for when import failed
# (idea, have hotTest.bqn import "global" values that hotreload.bqn mutates)

mainFilename ← "astroids.bqn"
lastMain ← main ← •Import mainFilename
mainText ← •file.Bytes mainFilename
closed ← 0
lastUpdate ← •Monotime@

•rand.Random 5

Revert ← {𝕤
  main ↩ lastmain
}


WasNotClosed ← {
  closed ∨ ↩ main.Close 𝕩
  ¬closed
}

# how many iterations till next check
iter ← 20

{𝕨𝔽_𝕣𝕩: 𝕩}
{𝕨𝔽_𝕣𝕏: }
{𝕤: }

{𝕊input:
  {𝕤
    main @⊸•Import⎊⊣↩ mainFilename # catches syntax bugs
    mainText ↩ 𝕩
  }⍟(mainText⊸≢)•file.Bytes mainFilename
  out ← main.PerFrame⍟WasNotClosed⍟iter⎊Revert input
  lastMain ↩ main
  out
} •_While_ (WasNotClosed⎊Revert) main._start @
