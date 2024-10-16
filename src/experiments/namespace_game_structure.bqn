⟨c⇐color, win⇐window, d⇐draw, key, mouse⟩←r←•Import "../../rayed-bqn/raylib.bqn"

ball ← {
	# Define the object that holds all the data needed to draw it
	Get ⇐ {𝕊size‿win_size: {
		growing 	⇐ 1
		shape 		⇐ win_size (-≍+)○(÷⟜2) size
	}}
	# Update the data based on paramaters
	Update ⇐ {𝕊⟨⟨shape, growing⟩, ⟨growth_speed, max_size, min_size, win_size, space_pressed⟩⟩:{
		growing 	⇐ ∨´ growing◶⟨min_size⊸>, max_size⊸>⟩ -˝○- shape
		shape 		⇐ shape + (-≍⊢) ∾˜ growing◶⟨-, ⊢⟩ growth_speed
	}}
	# Draw it
	Draw ⇐ {𝕊⟨shape⟩: c.black d.Rectangle shape}
}

# A game object/system
Obj ← {fncs‿params:{
	fncs←fncs, # Its Get Update and Draw namespace
	data⇐fncs.Get params, # All the data about the object
	GetUpdate ⇐ {fncs.Update data ⋈ 𝕩}
	ApplyUpdate ⇐ {data ↩ 𝕩}
	Draw ⇐ {𝕊:fncs.Draw data}
}}

_OnStart ← {System _𝕣 𝕩:
	win_size ← 800‿800
	win.SetSize win_size

	# Initialise and create all the game objecst
	game_objects ← {
		main_character ⇐ Obj moving_square‿⟨300‿300, win_size⟩
	}

	states ← {
		# Functions per state that return the paramaters to update an object
		# Matching is done based on field name, leaving out a name means it shouldn't be updated
		play ⇐ {
			Main_character ⇐ {𝕊objs: ⟨1, 600, 200, win_size⟩}
		}
	}

	System ⟨states.play, game_objects⟩
}

Valls ← ⊣ •ns.Get¨ · •ns.Keys ⊢
PerFrame ← {𝕊 state‿objs:

	params ← {𝕏 objs}¨ state Valls state
	newData ← params {𝕩.GetUpdate 𝕨}¨ objs Valls state
	newData {𝕩.ApplyUpdate 𝕨}¨ objs Valls state

	{𝕩.Draw@}¨ Valls objs

	state‿objs
} d._withCanvas_ c.white

System ← PerFrame •_While_(¬win.ShouldClose) _OnStart
System win._openAs "example"
