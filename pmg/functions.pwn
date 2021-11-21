#include "pmg/commands.pwn"

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock SendErrorMessage(playerid, const str[])
{
	new errormsg[256], message[256];
	format(message, sizeof(message), "{FF0000}ERROR: {FFFFFF}%s", str);
	strcat(errormsg, message, sizeof(errormsg));
	SendClientMessage(playerid, -1, errormsg);
	return 1;
}

stock SendPMGMessage(playerid, const str[])
{
	new pmgmsg[256], message[256];
	format(message, sizeof(message), "{00FF00}PMG: {FFFFFF}%s", str);
	strcat(pmgmsg, message, sizeof(pmgmsg));
	SendClientMessage(playerid, -1, pmgmsg);
	return 1;
}

stock IsAlphaNumeric(const string[]) 
{
	for(new x; x < strlen(string); x++) 
	{
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

forward PMGCreate(playerid, gname[]);
public PMGCreate(playerid, gname[])
{
	new gid;
	cache_get_value_name_int(0, "pmgid", gid);
	pmgInfo[gid][pmgid] = gid;
    format(pmgInfo[gid][pmgname], MAX_PMG_NAME, gname);
    format(pmgInfo[gid][pmg_owner_name], MAX_PLAYER_NAME, PlayerName(playerid));
	primaryPMG[playerid] = gid;
	SetRanksPMG(gid);
	SetPMGMemberInfo(playerid, gid, 3);
	return 1;
}

forward SetRanksPMG(gid);
public SetRanksPMG(gid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgranks (pmgid, rankid, rankname) VALUES (%d, %d, '%s')", gid, 1, "Member");
	mysql_tquery(dbhandle, query, "");
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgranks (pmgid, rankid, rankname) VALUES (%d, %d, '%s')", gid, 2, "Moderator");
	mysql_tquery(dbhandle, query, "");
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgranks (pmgid, rankid, rankname) VALUES (%d, %d, '%s')", gid, 3, "Leader");
	mysql_tquery(dbhandle, query, "");

	pmgRankInfo[gid][1][pmg_rank_id] = 1;
	format(pmgRankInfo[gid][1][pmg_rank_name], MAX_PMG_RANK_NAME, "Member");

	pmgRankInfo[gid][2][pmg_rank_id] = 2;
	format(pmgRankInfo[gid][2][pmg_rank_name], MAX_PMG_RANK_NAME, "Moderator");

	pmgRankInfo[gid][3][pmg_rank_id] = 3;
	format(pmgRankInfo[gid][3][pmg_rank_name], MAX_PMG_RANK_NAME, "Leader");
}

forward SetPMGMemberInfo(playerid, gid, rid);
public SetPMGMemberInfo(playerid, gid, rid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgmembers (username, pmgid, rankid) VALUES ('%s', %d, %d)", PlayerName(playerid), gid, rid);
	mysql_tquery(dbhandle, query, "");
	pmgMemberInfo[playerid][gid][pmg_member_id] = playerid;
    pmgMemberInfo[playerid][gid][pmg_member_pmgid] = gid;
	pmgMemberInfo[playerid][gid][pmg_member_rankid] = rid;
    format(pmgMemberInfo[playerid][gid][pmg_member_name], MAX_PLAYER_NAME, PlayerName(playerid));
}

forward LoadPMGData();
public LoadPMGData()
{
	new rows, gid;
	cache_get_row_count(rows);
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(i, "pmgid", gid);
		cache_get_value_name_int(i, "pmgid", pmgInfo[gid][pmgid]);
		cache_get_value_name(i, "pmg_name", pmgInfo[gid][pmgname]);
		cache_get_value_name(i, "pmg_owner_name", pmgInfo[gid][pmg_owner_name]);
	}
}

forward LoadPMGRanks();
public LoadPMGRanks()
{
	new rows, gid, rid;
	cache_get_row_count(rows);
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(i, "pmgid", gid);
		cache_get_value_name_int(i, "rankid", rid);
		cache_get_value_name_int(i, "rankid", pmgRankInfo[gid][rid][pmg_rank_id]);
		cache_get_value_name(i, "rankname", pmgRankInfo[gid][rid][pmg_rank_name]);
		printf("pmg id: %d, rank id: %d, rank name: %s", gid, pmgRankInfo[gid][rid][pmg_rank_id], pmgRankInfo[gid][rid][pmg_rank_name]);
	}
}

forward LoadPMGMemberData(playerid);
public LoadPMGMemberData(playerid)
{
	new rows, gid;
	cache_get_row_count(rows);
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(0, "pmgid", gid);
		//cache_get_value_name_int(0, "userid", pmgMemberInfo[playerid][gid][pmg_member_id]);
		cache_get_value_name(0, "username", pmgMemberInfo[playerid][gid][pmg_member_name]);
		cache_get_value_name_int(0, "pmgid", pmgMemberInfo[playerid][gid][pmg_member_pmgid]);
		cache_get_value_name_int(0, "rankid", pmgMemberInfo[playerid][gid][pmg_member_rankid]);
		if(pmgMemberInfo[playerid][gid][pmg_member_name] == pmgInfo[gid][pmg_owner_name])
			SetPVarInt(playerid, "groupCreated", 1);
		printf("username: %s, pmgid: %d, rankid: %d", pmgMemberInfo[playerid][gid][pmg_member_name], pmgMemberInfo[playerid][gid][pmg_member_pmgid], pmgMemberInfo[playerid][gid][pmg_member_rankid]);
	}
	primaryPMG[playerid] = -2;
}

stock RemovePlayerFromPMG(playerid, gid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgmembers WHERE username='%s' AND pmgid='%d'", PlayerName(playerid), gid);
	mysql_tquery(dbhandle, query, "");
	pmgMemberInfo[playerid][gid][pmg_member_id] = -1;
    pmgMemberInfo[playerid][gid][pmg_member_pmgid] = -1;
	pmgMemberInfo[playerid][gid][pmg_member_rankid] = -1;
	format(pmgMemberInfo[playerid][gid][pmg_member_name], MAX_PLAYER_NAME, "INVALID NAME");
	if(primaryPMG[playerid] == gid)
		primaryPMG[playerid] = -1;
	pmgInvite[playerid][gid] = false;
}

stock ResetPMGMemberInfo(playerid)
{
	primaryPMG[playerid] = -1;
	for(new i; i < MAX_PMG_GROUPS; i++)
	{
		format(pmgMemberInfo[playerid][i][pmg_member_name], MAX_PLAYER_NAME, "INVALID NAME");
    	pmgMemberInfo[playerid][i][pmg_member_pmgid] = -1;
		pmgMemberInfo[playerid][i][pmg_member_rankid] = -1;
		pmgMemberInfo[playerid][i][pmg_member_id] = -1;
	}
}

stock DeletePMG(playerid, groupid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgdata WHERE pmgid=%d", groupid);
	mysql_tquery(dbhandle, query, "");
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgranks WHERE pmgid=%d", groupid);
	mysql_tquery(dbhandle, query, "");
	RemovePlayerFromPMG(playerid, groupid);
	pmgInfo[groupid][pmgid] = -1;
	format(pmgInfo[groupid][pmgname], MAX_PMG_NAME, "INVALID NAME");
	format(pmgInfo[groupid][pmg_owner_name], MAX_PLAYER_NAME, "INVALID NAME");
	SetPVarInt(playerid, "groupCreated", 0);
	foreach(new i : Player)
		{
			if(pmgMemberInfo[i][groupid][pmg_member_pmgid] == groupid)
			{
				RemovePlayerFromPMG(i, groupid);
			}
		}
	return 1;
}

stock CanPlayerCreatePMG(playerid)
{
    if(GetPVarInt(playerid, "groupCreated"))
    	return 0;
	return 1;
}

stock IsPMGNameValid(const name[])
{
    if(0 < strlen(name) < MAX_PMG_NAME)
    {
        if(!IsAlphaNumeric(name)) 
            return 0;

        return 1;
    }
	return 0;
}

stock SendMessageToPMG(gid, const msg[])
{
    foreach(new i : Player)
    {
        if(primaryPMG[i] == gid)
        	SendClientMessage(i, -1, msg);
	}
}

stock PMGInvite(playerid, id)
{
	new str[256];
    if(!GetPVarInt(playerid, "groupCreated"))
        return SendClientMessage(playerid, -1, "You do not have a private messaging group! Make one using: /pmg create <name>");
    if(!IsPlayerConnected(id))
        return SendErrorMessage(playerid, "Player is not connected!");
    if(id == playerid)
        return SendErrorMessage(playerid, "You cannot invite yourself!");
    if(primaryPMG[playerid] < 0)
        return SendErrorMessage(playerid, "You do not have a primary group selected!");
    if(pmgInvite[id][primaryPMG[playerid]] == true)
        return SendErrorMessage(playerid, "Player is already invited!");
    if(pmgMemberInfo[id][primaryPMG[playerid]][pmg_member_rankid] > 0)
        return SendErrorMessage(playerid, "Player is already in the group!");
    if(pmgMemberInfo[playerid][primaryPMG[playerid]][pmg_member_rankid] < 2)
        return SendErrorMessage(playerid, "You do not have the permission to invite people to your primary group.");
        
    pmgInvite[id][primaryPMG[playerid]] = true;
    format(str, sizeof(str), "You have invited %s(%d) to your private messaging group!", PlayerName(id), id);
    SendPMGMessage(playerid, str);
    format(str, sizeof(str), "You have been invited to '%s' by %s(%d)", pmgInfo[primaryPMG[playerid]][pmgname], PlayerName(playerid), playerid);
    SendPMGMessage(id, str);
    format(str, sizeof(str), "Use '/pmg join %d' to join that group!", primaryPMG[playerid]);
    SendPMGMessage(id, str);
	return 1;
}

stock strcopy(dest[], const source[], len = sizeof(dest)) 
{
	dest[0] = '\0';
	return strcat(dest, source, len);
}
