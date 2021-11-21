#include <a_samp> 
#include <sscanf2>
#include <YSI_Visual/y_commands>
#include <YSI_Visual/y_dialog>
#include <YSI_Coding/y_inline>
#include <a_mysql>

new MySQL:dbhandle;

#include "pmg/definitions.pwn"
#include "pmg/functions.pwn"

#define db_host "localhost"
#define db_user "root"
#define db_pass ""
#define db_db 	"pmgtask"


main()
{
	print("\n----------------------------------");
	print("EPIC SERFER !");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	mysql_log(ALL);
	dbhandle = mysql_connect(db_host, db_user, db_pass, db_db);

	mysql_tquery(dbhandle, "SELECT * FROM pmgdata", "LoadPMGData");
	mysql_tquery(dbhandle, "SELECT * FROM pmgranks", "LoadPMGRanks");

	SetGameModeText("Testing");
    AddPlayerClass(166,1969.5961,-1443.9052,13.5318,49.6607,0,0,0,0,0,0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746); 
	return 1; 
}


public OnPlayerConnect(playerid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "SELECT * FROM pmgmembers WHERE username='%s'", PlayerName(playerid));
	mysql_tquery(dbhandle, query, "LoadPMGMemberData", "d", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	ResetPMGMemberInfo(playerid);
}








