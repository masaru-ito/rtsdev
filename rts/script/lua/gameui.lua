--[[
	Customized functions for controlling what happens for a particular loaded level.
	These classes should define any  of

	init(level)
	start(level)
	update(level, dt)
	shutdown(level)
	render(level)
]]--

local Util = require 'core/appkit/lua/util'
local SimpleProject = require 'core/appkit/lua/simple_project'

Project.GameUI = Project.GameUI or {}
local GameUI = Project.GameUI
GameUI.custom_listener = GameUI.custom_listener or nil

local start_time = 0
--GameUIの呼び出し
function GameUI.start()
	if stingray.Window then
		stingray.Window.set_show_cursor(true)
	end

	if scaleform then
	    scaleform.Stingray.load_project_and_scene("s2d_projects/ui.s2d/ui")
		--scaleform.Stingray.load_project("test_mainmenu.s2dproj", "s2d_projects/test_mainmenu")
		scaleform.Stage.set_view_scale_mode(1)
		--Register menu button mouse listener
		local custom_listener = GameUI.custom_listener
		custom_listener = scaleform.EventListener.create(custom_listener, GameUI.on_custom_event)
		GameUI.custom_listener = custom_listener
		scaleform.EventListener.connect(custom_listener, scaleform.EventTypes.Custom)
		local loading = scaleform.Actor.load("GameUI.s2dscene")	--GameUI用のシーンをロード
	    -- Remove the main menu scene
        scaleform.Stage.remove_scene_by_index(1)
        -- Add the loading scene
        scaleform.Stage.add_scene(loading)
	end

	local level = SimpleProject.level
	start_time = stingray.World.time(SimpleProject.world)
	-- make sure camera is at correct location
	local camera_unit = SimpleProject.camera_unit
	local camera = stingray.Unit.camera(camera_unit, 1)
	stingray.Unit.set_local_pose(camera_unit, 1, stingray.Matrix4x4.identity())
	stingray.Camera.set_local_pose(camera, camera_unit, stingray.Matrix4x4.identity())

	Appkit.manage_level_object(level, GameUI, nil)
end
--GameUIのリリース
function GameUI.shutdown(object)
	if scaleform then
		scaleform.EventListener.disconnect(GameUI.custom_listener)
		scaleform.Stingray.unload_project()
	end

	GameUI.evt_listener_handle = nil
	Appkit.unmanage_level_object(SimpleProject.level, GameUI, nil)
	if stingray.Window then
		stingray.Window.set_show_cursor(false)
	end
end

GameUI.action = nil
function GameUI.on_custom_event(evt)
	if evt.name == "pause_game" then
		--ゲームをポーズするためにactionの文字列を変更
		GameUI.action = "pause"
	end
end

--更新処理で呼ばれる
local function perform_action()
	-- Load empty level
	if GameUI.action == "pause" then
		--ゲームのタイムを止める処理を記述予定
		--今はメインメニューに戻る処理とする
		GameUI.shutdown()
		SimpleProject.change_level(Project.level_names.mainmenu)    --testmapに遷移
	-- Exit the program
	end
	GameUI.action = nil
end

-- [[Main Menu custom functionality]]--
function GameUI.update(object, dt)
	if GameUI.action == nil  then
		local time = stingray.World.time(SimpleProject.world)
		local p = stingray.Application.platform()
		if time - start_time > 1 then
		--[[	if Appkit.Util.is_pc() then
				if stingray.Keyboard.pressed(stingray.Keyboard.button_id("1")) then
					GameUI.action = "start"
				elseif stingray.Keyboard.pressed(stingray.Keyboard.button_id("esc")) then
					GameUI.action = "exit"
				end
			elseif p == stingray.Application.XB1 or p == stingray.Application.PS4 then 
				if stingray.Pad1.pressed(stingray.Pad1.button_id(Appkit.Util.plat(nil, "a", nil, "cross"))) then
    				GameUI.action = "start"
    			elseif stingray.Pad1.pressed(stingray.Pad1.button_id(Appkit.Util.plat(nil, "b", nil, "circle"))) then
    				GameUI.action = "exit"
    			end 
    		end
    		]]--
		end
	end
	perform_action()
end

return GameUI