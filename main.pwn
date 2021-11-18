//#define YSI_NO_HEAP_MALLOC
//#define CGEN_MEMORY 22640
//#pragma compat 1
//#pragma dynamic 1000000
#include <a_samp> 
#include <sscanf2>
#include <YSI_Visual/y_commands>
#include <YSI_Visual/y_dialog>
#include <YSI_Coding/y_inline>

#include "pmg/definitions.pwn"
#include "pmg/functions.pwn"

main()
{
	print("\n----------------------------------");
	print("EPIC SERFER !");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("Testing");
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    AddPlayerClass(166,1969.5961,-1443.9052,13.5318,49.6607,0,0,0,0,0,0);
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746); 
	return 1; 
}


public OnPlayerConnect(playerid)
{
	selectedPMG[playerid] = -1;
	pmgMemberInfo[playerid][playerid][pmg_member_id] = -1;
	pmgMemberInfo[playerid][playerid][pmg_member_pmgid] = -1;
	return 1;
}

stock IsAlphaNumeric(const string[]) {
	for(new x; x < strlen(string); x++) {
		if( (string[x] > 47 && string[x] < 58) ||  (string[x] > 64 && string[x] < 91) || (string[x] > 96 && string[x] < 123)) {
			continue;
		}
		else
		{
			return 0;
		}
	}
	return 1;
}

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

CMD:clearchat(playerid, params[])
{
	for(new i; i < 60; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}
	return 1;
}




