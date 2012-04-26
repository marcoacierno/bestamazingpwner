#include <a_samp>
#include <foreach>

#define VERSION 		"1.1.0"

#define ADMIN_REQ       "Devi essere admin RCON per usare questo comando!"

#undef MAX_PLAYERS
#define MAX_PLAYERS 20

#define COLOR_JOIN 				0x61B000AA
#define COLOR_LEFT 				0xD60019AA
#define COLOR_GREY 				0xAFAFAFAA //grigio
#define COLOR_GREEN 			0x33AA33AA //verde
#define COLOR_RED				0xB83131AA //rosso
#define COLOR_YELLOW 			0xFFFF00AA //giallo
#define COLOR_PINK 				0xFF66FFAA //rosa
#define COLOR_BLUE 				0x0000BBAA //blu
#define COLOR_ORANGE 			0xFF9900AA //arancione
#define COLOR_PURPLE 			0x990099AA //viola
#define COLOR_BROWN 			0x663300AA //marrone
#define COLOR_LIGHTBLUE 		0x33CCFFAA //azzurro
#define COLOR_DARKRED 			0x660000AA //rosso scuro
#define COLOR_DARKBLUE 			0x000066AA //blu scuro
#define COLOR_WHITE 			0xFFFFFFAA
#define TD_NERO 				0x00000066
#define WINNER_ROSSO 			0xD0000044
#define WINNER_GREEN 			0x66FF00AA
#define yellow	 				0xFFFF00AA
#define green 					0x33FF33AA
#define red 					0xFF0000AA
#define white 					0xFFFFFFAA
#define pink 					0xCCFF00FF
#define blue 					0x00FFFFAA
#define grey 					0xC0C0C0AA

#define TEAM_A                  1
#define TEAM_B                  2

#define DIALOG_FINAL            0

#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

new Gaming[MAX_PLAYERS];
new GamersIDs[3] = {INVALID_PLAYER_ID, INVALID_PLAYER_ID, INVALID_PLAYER_ID};
new Nickname[MAX_PLAYERS][24];

new pGaming = 0;
new Paused = 0;
new GameRunning;
new DuelsPlayed = 0;
new DuelsToPlay = 2;
new Team[MAX_PLAYERS];
new LastSync[MAX_PLAYERS];
new Scores[3];
new bool:SyncInCorso[MAX_PLAYERS];
new Float:SyncHealth[MAX_PLAYERS];
new Float:SyncArmour[MAX_PLAYERS];
new PlayerSpaawn[MAX_PLAYERS];

new ArenaZone;

#define SPAWN_SKIN      		289
#define TEAM_A_SKIN     		34
#define TEAM_B_SKIN     		58

#define LOBBY_COLOR    	 	  0x44C948AA
#define COLOR_TEAM_A          0x4C8EB1AA
//#define COLOR_TEAM_B          0x67D320AA
#define COLOR_TEAM_B          0x9CB028AA

main()
{
	print("\n----------------------------------");
	print(" Best Amazing Pwner v. "#VERSION);
	print("----------------------------------\n");
}


public OnGameModeInit() {
	SetGameModeText("Best Amazing Pwner");
	UsePlayerPedAnims();
	AddPlayerClass(SPAWN_SKIN,1401.5886,2204.4265,17.6719,140.1902,0,0,0,0,0,0); // normal_spawn
	
	ArenaZone = GangZoneCreate(1300.78125,2097.65625,1406.25,2200.1953125);
	
	SendRconCommand("mapname Lobby");
	return 1;
}

public OnGameModeExit() {
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	SetPlayerPos(playerid, 1411.9674,2180.6179,12.0156);
	SetPlayerFacingAngle(playerid, 35.8087);
	SetPlayerCameraPos(playerid, 1408.5087,2185.8381,12.0156);
	SetPlayerCameraLookAt(playerid, 1411.9674,2180.6179,12.0156);
	return 1;
}

public OnPlayerConnect(playerid) {
	GetPlayerName(playerid, Nickname[playerid], sizeof Nickname);
    Gaming[playerid] = 0;
    SyncInCorso[playerid] = false;
    SetPVarInt(playerid, "spec", -1);
 	new string[128];
	format(string, sizeof string, "\"%s\" è entrato nel server.", Nickname[playerid]);
	SendClientMessageToAll(COLOR_JOIN, string);
	
	SendClientMessage(playerid, COLOR_DARKRED, "*****************************************************");
	SendClientMessage(playerid, green, "Gamemode version: "#VERSION);
	SendClientMessage(playerid, green, "/add - /remove Aggiunge/rimuove un giocatore");
	SendClientMessage(playerid, green, "/start - /pause e /unpause Starta, pausa e spausa");
	SendClientMessage(playerid, green, "/setrounds Setta i rounds da giocare");
	SendClientMessage(playerid, green, "/spec - /sspec Inizia/Ferma lo spec di un giocatore");
//	SendClientMessage(playerid, pink, "http://code.google.com/p/bestamazingpwner/source/browse/gm.pwn Modifica, Migliora, Rilascia. #opensource");
//	SendClientMessage(playerid, pink, "http://tinyurl.com/c9wrb8n Short link.");
	SendClientMessage(playerid, COLOR_DARKRED, "*****************************************************");

    SetPlayerColor(playerid, LOBBY_COLOR);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	new string[128];
    switch(reason)
    {
    	case 0: {
			format(string, sizeof string, "\"%s\" è crashato dal server.", Nickname[playerid]);
		}
    	case 1: {
			format(string, sizeof string, "\"%s\" è uscito dal server.", Nickname[playerid]);
		}
    	case 2: {
			format(string, sizeof string, "\"%s\" è stato kickato/bannato dal server.", Nickname[playerid]);
		}
	}
	SendClientMessageToAll(COLOR_LEFT, string);
	
	if(Gaming[playerid] == 1) {
	    pGaming--;
        GamersIDs[Team[playerid]] = INVALID_PLAYER_ID;
	}
    Gaming[playerid] = 0;
	return 1;
}

public OnPlayerSpawn(playerid) {
	
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	GangZoneShowForPlayer(playerid, ArenaZone, 0x69BC61AA);
	
	if(SyncInCorso[playerid] == false) {
		if( Gaming[playerid] == 1 && DuelsPlayed != 0 && GameRunning && PlayerSpaawn[playerid] == 0) {
			new t_o = TeamOpposto(Team[playerid]);
			SpawnPlayer(GamersIDs[t_o]);
			PlayerSpaawn[playerid] = 1;
		}
	}
	else {
	    if(Gaming[playerid] == 1) {
		    if(Team[playerid] == TEAM_A) {
				SetSpawnInfo(GamersIDs[TEAM_A], GamersIDs[TEAM_A], TEAM_A_SKIN, 1307.3180,2190.0989,11.0234,217.9566, 24, 99999, 25, 99999, 0, 0);
			}
			else {
		    	SetSpawnInfo(GamersIDs[TEAM_B], GamersIDs[TEAM_B], TEAM_B_SKIN, 1389.4598,2107.9426,11.0156,37.8928, 24, 99999, 25, 99999, 0, 0);
			}
		}
		else {
		    SetSpawnInfo(playerid, 0, SPAWN_SKIN, 1401.5886,2204.4265,17.6719,140.1902,0,0,0,0,0,0);
		}
		SetPlayerHealth(playerid, SyncHealth[playerid]);
		SetPlayerArmour(playerid, SyncArmour[playerid]);
		SyncInCorso[playerid] = false;
	}
	
	foreach(Player, i)	{
	    if(GetPVarInt(i, "spec") == -1) continue;
		if(GetPVarInt(i, "spec") == playerid) {
		    PlayerSpectatePlayer(i, playerid);
		}
	}
		
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
	if(GameRunning) {
	    SendDeathMessage(killerid, playerid, reason);
	    new string[128];
	    if(!IsPlayerConnected(killerid)) {
			format(string, sizeof string, "{FF0000} %s è morto.", Nickname[playerid]);
			SendClientMessageToAll(-1, string);
			return 1;
		}
	    if(Gaming[playerid] == 1 && Gaming[killerid] == 1) {
	        DuelsPlayed++;
	        Scores[Team[killerid]]++;
			format(string, sizeof string, "{2DC627}%s{FFFFFF} ha vinto questo duello contro {FF0000}%s {91B028}(%d/%d)", Nickname[killerid], Nickname[playerid], DuelsPlayed, DuelsToPlay);
			SendClientMessageToAll(-1, string);
			PlayerSpaawn[playerid]=0;
			PlayerSpaawn[killerid]=0;
			if(DuelsPlayed>=DuelsToPlay)
			{
			    SendClientMessageToAll(0x20BF3DAA, "Tutti i duels sono stati giocati.");
			    FinalScores();
			    return 1;
			}
			format(string, sizeof string, "mapname %s vs %s (%d - %d)", Nickname[GamersIDs[TEAM_A]], Nickname[GamersIDs[TEAM_B]], Scores[TEAM_A], Scores[TEAM_B]);
			SendRconCommand(string);
			return 1;

	    }
	}
	return 1;
}

public OnPlayerText(playerid, text[]) {
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
	dcmd(add, 3, cmdtext);
	dcmd(remove, 6, cmdtext);
	dcmd(start, 5, cmdtext);
	dcmd(pause, 5, cmdtext);
	dcmd(unpause, 7, cmdtext);
	dcmd(setrounds, 9, cmdtext);
	dcmd(spec, 4, cmdtext);
	dcmd(sspec, 5, cmdtext);
	dcmd(kill, 4, cmdtext);
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys == 160 && GetPVarInt(playerid, "spec") == -1 && (GetPlayerWeapon(playerid) == 0 || GetPlayerWeapon(playerid) == 1) && !IsPlayerInAnyVehicle(playerid)) {
	    if((GetTickCount()-LastSync[playerid])*0.001<2) return SendClientMessage(playerid, red, "Error: You can't flood this command, wait 3 seconds if you want to sync again..");
		new Float:x, Float:y, Float:z, Float:a;
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
		GetPlayerHealth(playerid, SyncHealth[playerid]);
		GetPlayerArmour(playerid, SyncArmour[playerid]);
		SetSpawnInfo(playerid, playerid, GetPlayerSkin(playerid), x, y, z, a, (Gaming[playerid]+GameRunning)==2 ? 24 : 0, 99999, (Gaming[playerid]+GameRunning)==2 ? 25 : 0, 99999, 0, 0);
		SpawnPlayer(playerid);
		LastSync[playerid] = GetTickCount();
		SyncInCorso[playerid] = true;
		SendClientMessage(playerid, green, "Synced!");
		return 1;
	}

	return 1;
}

public OnPlayerUpdate(playerid) {
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
	return 1;
}

/* functions */
stock TeamOpposto(t)
{
	if(t == TEAM_A)
	{
	    return TEAM_B;
	}
	return TEAM_A;
}


stock FinalScores() {
	new str[256];
	
	if(Scores[1] > Scores[2])
	{
	    format(str, sizeof str,  "Congratulazioni a {20BF3D}%s, {FFFFFF}che vince con {C92F21}%d {FFFFFF}duels vinti.\r\n", Nickname[GamersIDs[TEAM_A]], Scores[TEAM_A]);
	}
	else if(Scores[1] < Scores[2])
	{
	    format(str, sizeof str,  "{FFFFFF}Congratulazioni a {20BF3D}%s, {FFFFFF}che vince con {C92F21}%d {FFFFFF}duels vinti.\r\n", Nickname[GamersIDs[TEAM_B]], Scores[TEAM_B]);
	}
	else
	{
	    format(str, sizeof str, "{FFFFFF}Nessun giocatore vince! Pareggio {C92F21}%d {8D99DC}a {FFFFFF}%d\r\n", Scores[TEAM_A], Scores[TEAM_B]);
	}
	
	format(str, sizeof str, "%sDuels vinti\t\t\tNickname\r\n", str);
	
    format(str, sizeof str, "%s%d\t\t\t\t%s\r\n", str, Scores[Team[GamersIDs[TEAM_A]]], Nickname[GamersIDs[TEAM_A]]);
    format(str, sizeof str, "%s%d\t\t\t\t%s\r\n", str, Scores[Team[GamersIDs[TEAM_B]]], Nickname[GamersIDs[TEAM_B]]);

	Scores[TEAM_A] = 0;
	Scores[TEAM_B] = 0;

	Gaming[GamersIDs[TEAM_A]] = 0;
	Gaming[GamersIDs[TEAM_B]] = 0;

	
	Team[GamersIDs[TEAM_A]] = INVALID_PLAYER_ID;
	Team[GamersIDs[TEAM_B]] = INVALID_PLAYER_ID;

	SetSpawnInfo(GamersIDs[TEAM_A], 0, SPAWN_SKIN, 1401.5886,2204.4265,17.6719,140.1902,0,0,0,0,0,0);
	SetSpawnInfo(GamersIDs[TEAM_B], 0, SPAWN_SKIN, 1401.5886,2204.4265,17.6719,140.1902,0,0,0,0,0,0);
	
	GamersIDs[TEAM_A] = INVALID_PLAYER_ID;
	GamersIDs[TEAM_B] = INVALID_PLAYER_ID;
	

	DuelsPlayed = 0;
	GameRunning = 0;
	
	pGaming = 0;
	
	foreach(Player, i)
	{
	    ShowPlayerDialog(i, DIALOG_FINAL, DIALOG_STYLE_LIST, "Duels Final", str, "Chiudi", "");
	    SpawnPlayer(i);
	    SetPlayerWorldBounds(i, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
	    SetPlayerVirtualWorld(i, 0);
	}
	
	for(new x = 0; x < 10; x++) SendDeathMessage(-1,-1,-1);

    SendRconCommand("mapname Lobby");
	return 1;
}

/* Commands */
dcmd_add(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
    if(!strlen(params)) return SendClientMessage(playerid, red, "Usa /add [id]");
	new id = strval(params);
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_RED, "Player non connesso.");
	if(Gaming[id] == 1) return SendClientMessage(playerid, COLOR_RED, "Il player già giocherà, usa /remove [id] per toglierlo.");
	if(pGaming>2) return SendClientMessage(playerid, COLOR_RED, "Ci sono più di due giocatori pronti per giocare..");
    new string[128];

	if(GamersIDs[TEAM_A] == INVALID_PLAYER_ID) {
	    Team[id] = TEAM_A;
	    GamersIDs[TEAM_A] = id;
	}
	else if(GamersIDs[TEAM_B] == INVALID_PLAYER_ID) {
	    Team[id] = TEAM_B;
	    GamersIDs[TEAM_B] = id;
	}
	else {
	    SendClientMessage(playerid, red, "Impossibile trovare un team vuoto (che ci fai qui?)");
	    return 1;
	}

    Gaming[id] = 1;
    pGaming++;
    
	format(string, sizeof string, "L'Admin \"%s\" ha aggiunto \"%s\" come giocatore.", Nickname[playerid], Nickname[id]);
	SendClientMessageToAll(WINNER_GREEN, string);

	return 1;
}
dcmd_remove(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
	if(!strlen(params)) return SendClientMessage(playerid, red, "Usa /remove [id]");
	new id = strval(params);
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_RED, "Player non connesso.");
	if(Gaming[playerid] == 0) return SendClientMessage(playerid, COLOR_RED, "Il player non è in game, usa /add [id] per aggiungerlo.");
	new string[128];

    GamersIDs[Team[id]] = INVALID_PLAYER_ID;
    Team[id] = 0;

    Gaming[id] = 0;
    pGaming--;
    
	format(string, sizeof string, "L'Admin \"%s\" ha rimosso \"%s\" come giocatore.", Nickname[playerid], Nickname[id]);
	SendClientMessageToAll(WINNER_GREEN, string);

	return 1;
}

dcmd_start(playerid, params[])
{
	#pragma unused params
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
	if(GameRunning) return SendClientMessage(playerid, COLOR_RED, "I Duels sono già stati startati..");
	if(pGaming < 2 || pGaming > 2) return SendClientMessage(playerid, red, "Il numero di giocatori settati non è valido.");
 	new string[128];
	format(string, sizeof string, "L'Admin \"%s\" ha startato i duels..", Nickname[playerid]);
	SendClientMessageToAll(WINNER_GREEN, string);

	SetSpawnInfo(GamersIDs[TEAM_A], GamersIDs[TEAM_A], TEAM_A_SKIN, 1307.3180,2190.0989,11.0234,217.9566, 24, 99999, 25, 99999, 0, 0);
    SetPlayerColor(GamersIDs[TEAM_A], COLOR_TEAM_A);

	SetSpawnInfo(GamersIDs[TEAM_B], GamersIDs[TEAM_B], TEAM_B_SKIN, 1389.4598,2107.9426,11.0156,37.8928, 24, 99999, 25, 99999, 0, 0);
    SetPlayerColor(GamersIDs[TEAM_B], COLOR_TEAM_B);
    
    SetPlayerVirtualWorld(GamersIDs[TEAM_A], 2);
    SetPlayerVirtualWorld(GamersIDs[TEAM_B], 2);
    
    SetPlayerWorldBounds(GamersIDs[TEAM_A], 1406.25, 1300.78125, 2200.1953125, 2097.65625);
    SetPlayerWorldBounds(GamersIDs[TEAM_B], 1406.25, 1300.78125, 2200.1953125, 2097.65625);
    
    SpawnPlayer(GamersIDs[TEAM_A]);
    SpawnPlayer(GamersIDs[TEAM_B]);
    
	new str[69];
	format(str, sizeof str, "mapname %s vs %s (%d - %d)", Nickname[GamersIDs[TEAM_A]], Nickname[GamersIDs[TEAM_B]], Scores[TEAM_A], Scores[TEAM_B]);
	SendRconCommand(str);
	
	GameRunning=1;
	return 1;
}

dcmd_pause(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
	if(!GameRunning) return SendClientMessage(playerid, COLOR_RED, "I Duels non sono stati startati..");
	if(Paused) return SendClientMessage(playerid, COLOR_RED, "I Duels sono già in pausa..");
	foreach(Player, i)
	{
	    if(Gaming[i] == 0) continue;
	    TogglePlayerControllable(i, false);
	}
	Paused = 1;
 	new string[128];
	format(string, sizeof string, "L'Admin \"%s\" ha pausato i duels..", Nickname[playerid]);
	SendClientMessageToAll(green, string);
	return 1;
}

dcmd_unpause(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
	if(!GameRunning) return SendClientMessage(playerid, COLOR_RED, "I Duels non sono stati startati..");
	if(!Paused) return SendClientMessage(playerid, COLOR_RED, "I Duels non pausati..");
	foreach(Player, i)
	{
	    if(Gaming[i] == 0) continue;
	    TogglePlayerControllable(i, true);
	}
	Paused = 0;
 	new string[128];
	format(string, sizeof string, "L'Admin \"%s\" ha spausato i duels..", Nickname[playerid]);
	SendClientMessageToAll(green, string);
	return 1;
}

dcmd_setrounds(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ADMIN_REQ);
	if(!strlen(params)) return SendClientMessage(playerid, red, "Usa /setrounds [rounds]");
	new rounds = strval(params);
//	if(rounds < (Scores[TEAM_A]+Scores[TEAM_B])) return SendClientMessage(playerid, red, "Il numero di rounds inserito non è valido..");
	DuelsToPlay = rounds;
 	new string[128];
	format(string, sizeof string, "L'Admin \"%s\" ha settato i rounds da giocare a %d.", Nickname[playerid], DuelsToPlay);
	SendClientMessageToAll(green, string);
	return 1;
}

dcmd_spec(playerid, params[])
{
	if(Gaming[playerid]==1) return SendClientMessage(playerid, red, "Non puoi usare questo comando ora.");
	if(!GameRunning)return SendClientMessage(playerid, red, "Il game non è startato..");
	if(!strlen(params)) return SendClientMessage(playerid, red, "Usa /spec [id]");
	new id = strval(params);
	if(id == playerid) return SendClientMessage(playerid, red, "Non puoi osservare te stesso.");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, red, "Player non connesso.");
	if(Gaming[id]==0) return SendClientMessage(playerid, red, "Player non in game.");
	TogglePlayerSpectating(playerid, 1);
	PlayerSpectatePlayer(playerid, id);
	SetPlayerVirtualWorld(playerid, 2);
	SendClientMessage(playerid, green, "Spec iniziato.");
    SetPVarInt(playerid, "spec", id);
	return 1;
}

dcmd_sspec(playerid, params[])
{
	#pragma unused params
	if(GetPVarInt(playerid, "spec")==-1) return SendClientMessage(playerid, red, "Non stai osservando nessuno.");
	TogglePlayerSpectating(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SendClientMessage(playerid, green, "Spec finito.");
	SetPVarInt(playerid, "spec", -1);
	return 1;
}

dcmd_kill(playerid, params[])
{
	#pragma unused params
	if(!Gaming[playerid]&&GameRunning) return SendClientMessage(playerid, red, "Non puoi usare questo comando ora.");
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

/*IsPlayerInArea(playerid, Float:minx, Float:maxx, Float:miny, Float:maxy)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if (x > minx && x < maxx && y > miny && y < maxy) return 1;
    return 0;
}*/



