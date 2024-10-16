⟨c⇐color, win⇐window, d⇐draw, key⟩←r←•Import "../../rayed-bqn/rayed.bqn"

block ← {
	Fall ⇐ {⟨gravity, fric⟩𝕊[pos, vel]: [pos + vel, (1-fric) × vel + 0‿gravity]}
	Bounce ⇐ {⟨bbox, fric⟩𝕊[pos, vel]: [pos, {∨´0>bbox-pos}◶⟨vel, (1-fric)×vel×¯1⟩ @]}

	Draw ⇐ {𝕊[pos, vel]: c.black d.Rectangle pos (-≍+) 50‿50}
}

_OnStart ← {System _𝕣 𝕩:
	c ← {
		w‿h ⇐ win_size 	⇐ 800‿800
		font 		⇐ r.font.LoadBQN 200
		gravity 	⇐ 1.5
		friction 	⇐ 0.01
	}
	win.SetSize c.win_size

	# Initialise and create all the game objects
	game_objects ← {
		player ⇐ {
			⟨Draw⟩ 	⇐ block
			Get 	⇐ {𝕊: [(÷⟜2 c.h)‿0, 0‿1.6]}
			Apply 	⇐ {data↩𝕩}
			data	⇐ Get@
		}
		start_time ⇐ {
			Get 	⇐ {𝕊: •MonoTime@}
			Apply 	⇐ {data↩𝕩}
			data 	⇐ Get@
		}
	}

	states ← {
		play ⇐ {
			Update ⇐ {𝕊⟨player⟩:{
				player ⇐ ⟨c.win_size×0.8, c.friction⟩ block.Bounce ⟨c.gravity, c.friction⟩ block.Fall player.data
			}}
			Draw ⇐ {𝕊objs: ⟨objs.player⟩}
			NewState ⇐ {𝕊⟨player, start_time⟩: (3 < start_time.data -˜ •MonoTime@)◶⟨states.play, states.reset⟩ @ }
		}
		reset ⇐ {
			Update ⇐ {𝕊⟨player, start_time⟩: {player⇐player.Get@, start_time⇐start_time.Get@}}
			Draw 	⇐ {𝕊: ⟨⟩}
			NewState ⇐ {𝕊: states.play}
		}
	}

	System ⟨⟨{⇐}, states.play⟩, game_objects⟩
}

Vals ← ⊣ •ns.Get¨ · •ns.Keys ⊢
PerFrame ← {𝕊 ⟨last_state, state⟩‿objs:

	fresh_objs ← state.Update objs
	v ← Vals fresh_objs
	v {𝕩.Apply 𝕨}¨ objs Vals fresh_objs

	{𝕩.Draw 𝕩.data}¨ state.Draw objs

	last_state ↩ state
	state ↩ state.NewState objs

	⟨last_state, state⟩‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
