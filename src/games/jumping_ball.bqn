⟨c⇐color, win⇐window, d⇐draw, key, mouse⟩←r←•Import "../../rayed-bqn/rayed.bqn"

ball ← {
	Red ⇐ {𝕊data:
		color ⇐ c.red
		⟨const, y, velocity, size⟩⇐data
	}
	Grow ⇐ {𝕊data:
		size 		⇐ data.size + data.const.growth
		⟨const, y, velocity, color⟩⇐data
	}
	Fall ⇐ {𝕊data:{
		velocity 	 ⇐ data.velocity + data.const.weight
		y 			   ⇐ data.y + data.velocity
		⟨const, size, color⟩⇐data
	}}
	Jump ⇐ {⟨jump⟩𝕊data:
		velocity 	⇐ ⊢◶⟨data.velocity, -data.const.jump_speed⟩ jump
		⟨const, y, size, color⟩⇐data
	}

	Collider ⇐ {𝕊data:
		data.y (-∾+) 0.8 × data.size
	}
	Draw ⇐ {𝕊⟨⟨x⟩⇐const, size, y, color⟩: color d.Ellipse ⌊ x‿y (-≍+) ∾˜size}
}

timer_text ← {
	Start ⇐ {𝕊data:
		start_time ⇐ •MonoTime @
		⟨font, pos, text, length, font_size, time⟩⇐data
	}
	Tick ⇐ {𝕊data:
		time ⇐ (•MonoTime@) - data.start_time
		⟨font, pos, text, length, font_size, start_time⟩⇐data
	}
	Draw ⇐ {𝕊⟨font, pos, text, length, font_size, time⟩:
		time 		↩ ⌊time
		text 		↩ text ∾ •Fmt (length≢0)◶⟨time, length-time⟩@
		pos 		↩ pos - (0.25×font_size×≠text)‿(÷⟜2 font_size)
		c.black‿font‿font_size d.Text pos‿text
	}
}

text ← {
	Draw ⇐ {𝕊⟨text, pos, font, font_size⟩:
		pos ↩ pos - (0.25×font_size×≠text)‿(÷⟜2 font_size)
		c.black‿font‿font_size d.Text pos‿text
	}
}

_OnStart ← {System _𝕣 𝕩:
	win_size ← 800‿800
	win.SetSize win_size
	font ← r.font.LoadBQN 200

	# Initialise and create all the game objects
	game_objects ← {
		player ⇐ {
			⟨Draw⟩ ⇐ ball
			Apply ⇐ {data↩𝕩}
			Get ⇐ {𝕊:
				const ⇐ {
					weight 		⇐ 0.4
					jump_speed 	⇐ 12
					x 			⇐ ÷⟜2⊑win_size
					growth  	⇐ 0.15
				}
				color 		⇐ c.black
				velocity 	⇐ ¯12
				size 		⇐ 5
				y			⇐ ×⟜0.7⊑⌽win_size
			}
			data ⇐ Get@
		}

		countdown ⇐ {
			⟨Draw⟩ ⇐ timer_text
			Apply ⇐ {data↩𝕩}
			Get ⇐ {𝕊:
				font ⇐ font
				text ⇐ "Starting in "
				pos ⇐ (÷⟜2 win_size)
				length⇐3
				font_size ⇐ 100
				time ⇐ 0
				start_time ⇐ •MonoTime@
			}
			data ⇐ Get @
		}

		play_timer ⇐ {
			⟨Draw⟩ ⇐ timer_text
			Apply ⇐ {data↩𝕩}
			Get ⇐ {𝕊:
				font⇐font, text⇐"", pos⇐(0.1 × win_size), length⇐0, font_size⇐100
				time ⇐ 0
				start_time ⇐ •MonoTime@
			}
			data ⇐ Get@
		}

		game_over_text ⇐ {
			⟨Draw⟩ ⇐ text
			Apply ⇐ {data↩𝕩}
			Get ⇐ {𝕊:
				font⇐font, text⇐"Game Over", pos⇐(÷⟜2 win_size), font_size⇐140
			}
			data ⇐ Get@
		}

		restart_cooldown ⇐ {
			Get ⇐ {𝕊: ⟨•MonoTime@, •MonoTime@⟩}
			Tick ⇐ {𝕊⟨now, start_time⟩: ⟨•MonoTime@, start_time⟩}
				Done ⇐ {𝕊me: 1.5 <⊑-˝me}
			Apply ⇐ {data↩𝕩}
			data ⇐ Get@
		}
		restart_text ⇐ {
			⟨Draw⟩ ⇐ text
			Apply ⇐ {data↩𝕩}
			Get ⇐ {𝕊:
				font⇐font, text⇐"Space to restart", pos⇐(0‿200 + ÷⟜2 win_size), font_size⇐30
			}
			data ⇐ Get@
		}
	}

	states ← {
		start ⇐ {
			Update ⇐ {fresh𝕊⟨player, countdown⟩:{
				player ⇐ ball.Grow player.data
				countdown ⇐ timer_text.Tick countdown.data
			}}
			Draw ⇐ {𝕊objs: objs.countdown‿objs.player}
			NewState ⇐ {𝕊⟨countdown⟩: ((countdown.data.time) > countdown.data.length)◶⟨states.start, states.play⟩@ }
		}
		play ⇐ {
			Update ⇐ {fresh𝕊⟨player, play_timer⟩:{
				player 	⇐ ⟨key.IsPressed key.space⟩ ball.Jump ball.Grow ball.Fall player.data
				play_timer ⇐ timer_text.Tick ⊢◶⟨play_timer.data, timer_text.Start play_timer.data⟩ fresh
			}}
			Draw ⇐ {𝕊objs: objs.player‿objs.play_timer}
			NewState ⇐ {𝕊⟨player⟩:
				collider ← ball.Collider player.data
				({top‿bottom: (top < 0) ∨ bottom > ⊑⌽win_size} collider)◶⟨states.play, states.game_over⟩@
			}
		}
		game_over ⇐ {
			Update ⇐ {fresh𝕊⟨player, restart_cooldown⟩:{
				player ⇐ ball.Red ball.Fall player.data
				restart_cooldown ⇐ restart_cooldown.Tick ⊢◶⟨restart_cooldown.data, restart_cooldown.Get⟨⟩⟩ fresh
			}}
			Draw ⇐ {𝕊objs:
				restart_cooldown_down ← objs.restart_cooldown.Done objs.restart_cooldown.data
				restart_cooldown_down◶⟨⊢, ∾⟜objs.restart_text⟩ objs.game_over_text‿objs.player
			}
			NewState ⇐ {𝕊objs:
				space_pressed ← key.IsPressed key.space
				cooldown_done ← objs.restart_cooldown.Done objs.restart_cooldown.data
				(space_pressed ∧ cooldown_done)◶⟨states.game_over, states.reset⟩ @
			}
		}
		reset ⇐ {
			Update ⇐ {fresh𝕊⟨player, restart_cooldown, play_timer, countdown⟩:{
				player ⇐ player.Get@
				restart_cooldown ⇐ restart_cooldown.Get@
				play_timer ⇐ play_timer.Get@
				countdown ⇐ countdown.Get@
			}}
			Draw ⇐ {𝕊:⟨⟩}
			NewState ⇐ {𝕊: states.start}
		}
	}

	System ⟨⟨{⇐}, states.start⟩, game_objects⟩
}

Vals ← ⊣ •ns.Get¨ · •ns.Key ⊢
PerFrame ← {𝕊 ⟨last_state, state⟩‿objs:

	fresh_objs ← (last_state≢state) state.Update objs
	fresh_vals ← Vals fresh_objs
	fresh_vals {𝕩.Apply 𝕨}¨ objs Vals fresh_objs

	{𝕩.Draw 𝕩.data}¨ state.Draw objs

	last_state ↩ state
	state ↩ state.NewState objs

	⟨last_state, state⟩‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
