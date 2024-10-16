⟨c⇐color, win⇐window, d⇐draw, key, mouse, StartClock⟩←r←•Import "../../rayed-bqn/rayed.bqn"

Lag ← {actual←𝕩, {@: actual; 𝕊goal: actual ↩ actual + 0.1 × goal - actual}}

# Obj ← {old𝕊new:
# 	foo ⇐ {⟨foo⟩:foo; old.foo}new
# 	bar ⇐ {⟨bar⟩:bar; old.bar}new

# }
# inst ← @ Obj {foo⇐5, bar⇐3}
# •Show inst.foo
# inst ↩ inst Obj {foo⇐2}
# inst.foo

ball_fncs ← {
	Update ⇐ {𝕊⟨me, ⟨jump⟩⟩:
		size 		⇐ me.size + me.growth
		velocity 	⇐ jump◶⟨⊢, -me.jump_speed⟩ me.velocity + me.weight
		y 			⇐ me.y + velocity
		⟨x, weight, jump_speed, growth⟩⇐me
	}
	Draw ⇐ {𝕊⟨size, x, y⟩: c.black d.Ellipse ⌊ x‿y (-≍+) ∾˜size}
}
timer_fncs ← {
	ChangeText ⇐ {𝕊⟨me, new_text⟩:
		text		⇐ new_text
		⟨count_down, font_size, length, pos, font, t⟩⇐me
	}
	Update ⇐ {𝕊⟨me, new_text‿new_font_size⟩:
		font_size	⇐ me.Font_size new_font_size
		⟨length, pos, font, t, text, count_down⟩⇐me
	}
	Draw ⇐ {𝕊me:
		font_size ← me.Font_size 5
		text ← me.text ∾ •Fmt me.count_down◶⟨⊢, {me.length-𝕩}⟩ ⌊me.t.Time @
		pos ← me.pos-(0.25×font_size×≠text)‿(÷⟜2 font_size)
		c.black‿me.font‿font_size d.Text pos‿text
	}
}

_OnStart ← {System _𝕣 𝕩:
	win_size ← 800‿800
	win.SetSize win_size
	font ← r.font.LoadBQN 200

	# Initialise and create all the game objects
	game_objects ← {
		ball ⇐ {⟨Update, Draw⟩ ⇐ ball_fncs
			Apply ⇐ {data↩𝕩}
			data ⇐ {
				size 		⇐ 30
				x 			⇐ ÷⟜2⊑win_size
				y			⇐ ×⟜0.8⊑⌽win_size
				velocity 	⇐ ¯10
				weight 		⇐ 0.4
				jump_speed 	⇐ 12
				growth  	⇐ 0.2
			}
		}

		timer ⇐ {⟨Update, Draw⟩ ⇐ timer_fncs
			Apply ⇐ {data↩𝕩}
			data ⇐ {
				t 			⇐ r.StartClock @
				length 		⇐ 3
				font_size 	⇐ Lag 120
				pos 		⇐ (÷⟜2 win_size) - (0.1 × 60)‿0
				font 		⇐ font
				text 		⇐ @
				count_down	⇐ 1
			}
		}
	}

	states ← {
		start ⇐ {
			Update ⇐ {𝕊first_frame‿⟨timer⟩:{
				timer ⇐ timer.Update timer.data‿⟨"Starting in ", 60⟩
			}}
			NewState ⇐ {𝕊⟨timer⟩: ((timer.data.t.Time@) > timer.data.length)◶⟨states.start, states.play⟩@ }
		}
		play ⇐ {
			Update ⇐ {𝕊first_frame‿⟨ball, timer⟩:{
				ball ⇐ ball.Update ball.data‿⟨key.IsPressed key.space⟩
				timer ⇐ timer.Update timer.data‿⟨"", 40⟩
			}}
			NewState ⇐ {𝕊⟨ball⟩:
				collider ← ball.data.y (-∾+) ball.data.size
				({top‿bottom: (top < 0) ∨ bottom > ⊑⌽win_size} collider)◶⟨ states.play, states.game_over⟩@
			}
		}
		game_over ⇐ {
			Update ⇐ {𝕊first_frame‿⟨ball, timer⟩:{
				ball ⇐ ball.Update ball.data‿⟨0⟩
				timer ⇐ timer.Update timer.data‿⟨"Game Over", 40⟩
			}}
			NewState ⇐ {𝕊:states.game_over}
		}
	}

	System ⟨⟨{⇐}, states.start⟩, game_objects⟩
}

Valls ← ⊣ •ns.Get¨ · •ns.Keys ⊢
PerFrame ← {𝕊 ⟨last_state, state⟩‿objs:

	fresh_objs ← state.Update (last_state≢state)‿objs
	fresh_vals ← Valls fresh_objs
	fresh_vals {𝕩.Apply 𝕨}¨ objs Valls fresh_objs

	{𝕩.Draw 𝕩.data}¨ Valls objs

	last_state ↩ state
	state ↩ state.NewState objs

	⟨last_state, state⟩‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
