IncludeScript("vs_library")

// LineupFinder™ - Used to find utility lineups quickly & easily!
// Written by KYSO with assistance from Sam
// @movekyso - youtube.com/kyso

function OnPostSpawn(){
	setup_match()
	reprint_menu()
	VS.GetLocalPlayer()
	delay( "display_menu()", 1 )
	if( !Ent("vs_ref*") ){
		HPlayerEye <- VS.CreateMeasure( HPlayer.GetName(), null, 1 )
		hDraw <- VS.Timer(1, 0.1-FrameTime(), "redraw")
		VS.MakePermanent(hDraw)
		hListener <- VS.CreateEntity("game_ui", null, { spawnflags = 0, fieldofview = -1.0 })
		VS.AddOutput(hListener, "PressedAttack",  "draw")
		VS.AddOutput(hListener, "UnpressedAttack","dummy")
		VS.MakePermanent(hListener)
	}
	EntFireByHandle(hListener, "activate", "", 0, HPlayer)
	EntFireByHandle(hDraw,"disable")
	hListener.DisconnectOutput("PressedAttack","PressedAttack")
}

function display_menu() {
	SendToConsole("alias 1 script toggle_mode()")
	SendToConsole("alias 2 script toggle_drawings()")
	SendToConsole("alias 3 script clear_drawings()")
	SendToConsole("alias 4 script save_location()")
	SendToConsole("alias 5 script load_location()")
	SendToConsole("alias 6 script toggle_preview()")
	SendToConsole("alias 7 script simulate_throw(simTime)")
	SendToConsole("alias 8 script rethrow()")
	SendToConsole("alias 9 script clearsmoke_one()")
	SendToConsole("alias 10 script toggle_xhair()")
	SendToConsole("alias 11 script print_pos()")
	SendToConsole("alias 12 script exit_menu()")

	print("　LineupFinder™ Loaded!\n"
		+"　1 - Toggle Shoot to Draw\n"
		+"　2 - Toggle Drawings\n"
		+"　3 - Clear Drawings\n"
		+"　4 - Save Location\n"
		+"　5 - Load Location\n"
		+"　6 - Toggle Nade Trajectory\n"
		+"　7 - Simulate Nade Throw\n"
		+"　8 - Rethrow Last Nade\n"
		+"　9 - Clear Smokes\n"
		+"　10 - Toggle Crosshair\n"
		+"　11 - Print Saved Position\n"
		+"　12 - Exit Script\n")
}

currentMode <- false
prevMode <- false
simMode <- false
xhairSet <- false
xhairLineup <- false
configSaved <- false
saveLoc <- null
saveAng <- null
simTime <- 5
pos <- 0
start <- Vector(0,0,0)
end <- Vector(0,0,0)
lfTickrate <- VS.GetTickrate()
drawings <- []
drawMode <- 0
locSet <- false
r <- 255
g <- 0
b <- 0

function toggle_mode() {
	if (simMode) simulate_throw(5)
	if (!currentMode) {
		Alert( "Shoot to Draw Enabled" )
		SendToConsole("r_showenvcubemap 1")
		hListener.ConnectOutput("PressedAttack","PressedAttack")
		currentMode = true
	}
	else {
		Alert( "Shoot to Draw Disabled" )
		hListener.DisconnectOutput("PressedAttack","PressedAttack")
		SendToConsole("r_showenvcubemap 0")
		currentMode = false
	}
	reprint_menu()
}

function draw(){
	if (pos == 0){
		pos++
		local tr = VS.TraceDir( HPlayer.EyePosition(), HPlayerEye.GetForwardVector() )
		start = tr.GetPos()
		return
	}
	else{
		pos = 0
		local tr = VS.TraceDir( HPlayer.EyePosition(), HPlayerEye.GetForwardVector() )
		end = tr.GetPos()
		drawings.append(start)
		drawings.append(end)
		
		drawings.append(start + Vector(1,0,0))
		drawings.append(end + Vector(1,0,0))
		
		drawings.append(start + Vector(-1,0,0))
		drawings.append(end + Vector(-1,0,0))
		
		
		EntFireByHandle(hDraw,"enable")
		return
	}
}

function redraw(){
	local i = 0
	while (i < drawings.len() - 1 ){
		local counter = drawings.len() / drawings.len()/3  + 2
		if (r > 0 && g <= 255 && b == 0){
			if (g < 255){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				g += counter
				if (g < 0) g = 0
				if (g > 255) g = 255
			}
			if (g == 255 && r > 0){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				r -= counter
				if (r < 0) r = 0
				if (r > 255) r = 255
			}
		}
		if (g > 0 && r == 0 && b <= 255){
			if (b < 255){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				b += counter
				if (b < 0) b = 0
				if (b > 255) b = 255
			}
			if (b == 255 && g > 0){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				g -= counter
				if (g < 0) g = 0
				if (g > 255)g = 255
			}
		}
		if (r <= 255 && g == 0 && b > 0){
			if (r < 255){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				r += counter
				if (r < 0) r = 0
				if (r > 255)r = 255
			}
			if (r == 255 && b > 0){
				DebugDrawLine(drawings[i], drawings[i+1], r, g, b, true, 0.1)
				b -= counter
				if (b < 0) b = 0
				if (b > 255) b = 255
			}
		}
		i += 2
	}
}


function clear_drawings(){
	SendToConsole("clear_debug_overlays")
	EntFireByHandle(hDraw,"disable")
	drawings <- []
	reprint_menu()
}

function toggle_drawings(){
	if (drawMode == 0){
		EntFireByHandle(hDraw,"disable")
		drawMode++
	}
	else{
		EntFireByHandle(hDraw,"enable")
		drawMode = 0
	}
	reprint_menu()
}

function toggle_preview() {
	if (prevMode) {
		SendToConsole("sv_grenade_trajectory 0")
		prevMode = false
		Alert( "Grenade trajectory disabled" )
	}
	else {
		SendToConsole("sv_grenade_trajectory 1")
		prevMode = true
		Alert( "Grenade trajectory enabled" )
	}
	reprint_menu()
}

function mod_times(sign) {
	if (simTime < 30 && sign == 1){
		simTime++
		Alert("Simulation Duration: " + simTime + " seconds")
	}
	if (simTime > 1 && sign == 2){
		simTime--
		Alert("Simulation Duration: " + simTime + " seconds")
	}
}

function setup_match() {
	SendToConsole(""
		+"sv_cheats 1;bot_kick;script reprint_menu() "
		+"mp_roundtime 60;mp_freezetime 0;mp_respawn_on_death_t 1;mp_buytime 1000000; "
		+"sv_infinite_ammo 1;mp_limitteams 0;mp_autoteambalance 0;mp_buy_anywhere 1;"
		+"mp_autokick 0;ammo_grenade_limit_total 5;sv_grenade_trajectory 0;"
		+"sv_grenade_trajectory_thickness 1;sv_grenade_trajectory_time 5;mp_warmup_end; "
		+"mp_buy_allow_grenades 1;endround;impulse 101; mp_roundtime_defuse 60; god")

	reprint_menu()
}


function save_location() {
	saveLoc = HPlayer.GetOrigin()
	saveAng = HPlayerEye.GetAngles()
	locSet = true
	Alert( "Location saved" )
	reprint_menu()
}

function load_location() {
	if (!locSet){
		Alert("No position saved yet")
		return
	}
	HPlayer.SetOrigin(saveLoc)
	HPlayer.SetAngles(saveAng.x,saveAng.y,0)
	Alert( "Location loaded" )
	reprint_menu()
}

function reprint_menu() {
	SendToConsole("clear")
	SendToConsole("script display_menu()")
}

function toggle_xhair() {
	if (!xhairSet) {
		if (!configSaved){
			SendToConsole("host_writeconfig tempConfig.cfg")
			configSaved = true
			xhairSet = true
		}
	}
	if (!xhairLineup) {
		SendToConsole("cl_crosshairsize 600")
		xhairLineup = true
		Alert( "Enabled long crosshair" )
	}
	else {
		xhairLineup = false
		xhairSet = false
		if (configSaved){
			SendToConsole("exec tempConfig.cfg")
			configSaved = false
		}
		Alert( "Crosshair reset" )
	}
	reprint_menu()
}

function clearsmoke_one(){
	if (!ENT_SCRIPT.IsValid()){
		VS.ForceReload()
        return clearsmoke_one()
	}
	SendToConsole("host_timescale 100")
	delay("clearsmoke_two()", 20)
}

function clearsmoke_two(){
	SendToConsole("host_timescale 1")
	reprint_menu()
}

function exit_menu(){
	if (currentMode) toggle_mode()
	if (xhairSet) toggle_xhair()
	if (simMode) simulate_throw(5)
	EntFireByHandle(hDraw,"disable")
	SendToConsole("alias 1;alias 2;alias 3;alias 4;alias 5;alias 6;alias 7;alias 8;alias 9;alias 10;alias 11; alias 12")
	SendToConsole("alias regular;alias jumpThrow;alias incTime;alias decTime; alias toggleTickrate")
	SendToConsole("clear")
	Alert( "Goodbye!" )
}

function rethrow(){
	SendToConsole("sv_rethrow_last_grenade")
	reprint_menu()
}

function simulate_throw(simTime){
	if (currentMode) toggle_mode()
	SendToConsole("alias regular script sim_type(1)")
	SendToConsole("alias jumpThrow script sim_type(2)")
	SendToConsole("alias incTime script mod_times(1)")
	SendToConsole("alias decTime script mod_times(2)")

	if (!simMode) {
		if (!configSaved){
			SendToConsole("host_writeconfig tempConfig.cfg")
			configSaved = true
		}
		SendToConsole("unbind mouse1; unbind mouse3; unbind mwheelup; unbind mwheeldown; unbind mouse3")
		SendToConsole("bind mouse1 regular")
		SendToConsole("bind mouse2 jumpThrow")
		SendToConsole("bind mwheelup incTime")
		SendToConsole("bind mwheeldown decTime")
		SendToConsole("bind mwheeldown decTime")
		Alert( "M1: Regular | Scroll: Adjust Sim Time | M2: Jump Throw" )
		simMode = true
	}
	else {
		Alert( "Simulate Throws Disabled" );
		SendToConsole("exec tempConfig.cfg");
		configSaved = false
		SendToConsole("bind mouse1 +attack; bind mouse2 +attack2")
		simMode = false
	}
	reprint_menu()
}

function sim_type(type) {
	if (type == 1){
		SendToConsole("cl_sim_grenade_trajectory " + simTime)
	}
	if (type == 2){
		jumpthrow1()
	}
}

function jumpthrow1(){
	if (!ENT_SCRIPT.IsValid()){
		VS.ForceReload()
        return jumpthrow1()
	}
	local delayTime = 0
	if (lfTickrate == 64) delayTime = 0.14
	else delayTime = 0.115
	SendToConsole("+jump")
	delay("jumpthrow2()", delayTime)
}

function jumpthrow2(){
	SendToConsole("cl_sim_grenade_trajectory " + simTime)
	SendToConsole("-jump")
}

function print_pos(){
	if (saveLoc != null && saveAng != null){
		print ("setpos_exact " + saveLoc.x + " " + saveLoc.y + " " + (saveLoc.z + 1) + ";")
		print("setang_exact " + saveAng.x + " " + saveAng.y + " 0")
	}
	else print("No location saved yet")
}

OnPostSpawn()