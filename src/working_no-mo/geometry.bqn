⟨raymath, color, window, draw, rayffi, k⇐key⟩←r←•Import "../../raylib.bqn"
⟨IsDown⟩←k

w‿h ← size ← 0‿0

_setup ← {𝕨𝔽_𝕣𝕩:
	meshes ← rayffi.LoadModelFromMesh¨ ⟨
		rayffi.GenMeshPlane 10‿10‿3‿3
		rayffi.GenMeshCube 2‿4‿2
	⟩
	rayffi.SetConfigFlags window.configFlags.fullscreen_mode
	font ← r.font.LoadBQN 50
	w‿h ↩ size ↩ window.GetSize @

	pos ← 0‿0‿¯6 raymath.MP˜ raymath.MatrixRotateX 20
	camera ← ⟨ 0‿0‿¯6, 0‿0‿0,  0‿1‿0, 60,  0⟩

	meshes‿font 𝔽 camera
	rayffi.UnloadModel¨ meshes
}

last ← 0‿0
sensitivity ← 6
PerFrame ← {meshes‿font𝕊camera:
	x‿y ← mouse ← r.mouse.GetPos @
	scroll ← r.mouse.WheelMoved @
	dx‿dy ← mouse - last
	last ↩ mouse
	md ← rayffi.IsMouseButtonDown r.mouse.button.left # mouse down

	RotateX ← {𝕩 raymath.MP˜ raymath.MatrixRotateY md∧(dx÷w),×sensitivity }
	RotateY ← {𝕩 raymath.MP˜ raymath.MatrixRotateX md∧((-dy)÷h)×sensitivity }

	MoveCamera ← (RotateX RotateY) ⌾ ⊑

	{𝕤
		rayffi.BeginMode3D camera
		(rayffi.DrawModel⟨0‿0‿0, 1, color.white⟩∾˜<)¨ meshes
      	rayffi.DrawGrid 10‿1

		rayffi.EndMode3D⟨⟩
		rayffi.DrawFPS 10‿10

	} draw._withCanvas_ color.black @

	MoveCamera camera
}

Game ← PerFrame •_While_ (¬window.ShouldClose) _setup
Game window._openAs "raylib [shaders] example - basic lighting"
