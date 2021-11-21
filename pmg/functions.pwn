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

forward PMGCreation(playerid, gname[]);
public PMGCreation(playerid, gname[])
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

stock SetRanksPMG(gid)
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

stock SetPMGMemberInfo(playerid, gid, rid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgmembers (username, pmgid, rankid) VALUES ('%s', %d, %d)", PlayerName(playerid), gid, rid);
	mysql_tquery(dbhandle, query, "");
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
	}
}

forward LoadPMGMemberData(playerid);
public LoadPMGMemberData(playerid)
{
	new rows, gid;
	cache_get_row_count(rows);
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(i, "pmgid", gid);
		cache_get_value_name(i, "username", pmgMemberInfo[playerid][gid][pmg_member_name]);
		cache_get_value_name_int(i, "pmgid", pmgMemberInfo[playerid][gid][pmg_member_pmgid]);
		cache_get_value_name_int(i, "rankid", pmgMemberInfo[playerid][gid][pmg_member_rankid]);
		if(pmgMemberInfo[playerid][gid][pmg_member_name] == pmgInfo[gid][pmg_owner_name])
			SetPVarInt(playerid, "groupCreated", 1);
	}
	primaryPMG[playerid] = -2;
}

stock RemovePlayerFromPMG(playerid, gid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgmembers WHERE username='%s' AND pmgid='%d'", PlayerName(playerid), gid);
	mysql_tquery(dbhandle, query, "");
    pmgMemberInfo[playerid][gid][pmg_member_pmgid] = -1;
	pmgMemberInfo[playerid][gid][pmg_member_rankid] = -1;
	format(pmgMemberInfo[playerid][gid][pmg_member_name], MAX_PLAYER_NAME, "INVALID MNAME");
	if(primaryPMG[playerid] == gid)
		primaryPMG[playerid] = -1;
	pmgInvite[playerid][gid] = false;
}

stock ResetPMGMemberInfo(playerid)
{
	primaryPMG[playerid] = -1;
	for(new i; i < MAX_PMG_GROUPS; i++)
	{
		format(pmgMemberInfo[playerid][i][pmg_member_name], MAX_PLAYER_NAME, "INVALID MNAME");
    	pmgMemberInfo[playerid][i][pmg_member_pmgid] = -1;
		pmgMemberInfo[playerid][i][pmg_member_rankid] = -1;
	}
}

stock DeletePMG(playerid, groupid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgdata WHERE pmgid=%d", groupid);
	mysql_tquery(dbhandle, query, "");
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgranks WHERE pmgid=%d", groupid);
	mysql_tquery(dbhandle, query, "");
	mysql_format(dbhandle, query, sizeof(query), "DELETE FROM pmgmembers WHERE pmgid=%d", groupid);
	mysql_tquery(dbhandle, query, "");
	RemovePlayerFromPMG(playerid, groupid);
	pmgInfo[groupid][pmgid] = -1;
	format(pmgInfo[groupid][pmgname], MAX_PMG_NAME, "INVALID PNAME");
	format(pmgInfo[groupid][pmg_owner_name], MAX_PLAYER_NAME, "INVALID ONAME");
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

stock PMGCreateCMD(playerid, arg1[])
{
	if(strlen(arg1) == 0)
        return SendClientMessage(playerid, -1, "Usage: /pmg create <name>");

    if(CanPlayerCreatePMG(playerid))
    {
        if(!IsPMGNameValid(arg1))
            return SendErrorMessage(playerid, "Invalid PMG name entered, you may only use letters and numbers.");

        new str[128], query[128];
        SetPVarInt(playerid, "groupCreated", 1);
        mysql_format(dbhandle, query, sizeof(query), "INSERT INTO pmgdata (pmg_name, pmg_owner_name) VALUES ('%s', '%s')", arg1, PlayerName(playerid));
        mysql_tquery(dbhandle, query, "");
        mysql_format(dbhandle, query, sizeof(query), "SELECT * FROM pmgdata WHERE pmg_owner_name='%s'", PlayerName(playerid));
        mysql_tquery(dbhandle, query, "PMGCreation", "ds", playerid, arg1);
        format(str, sizeof(str), "You have succesfully created a private messaging group called: '%s'", arg1);
        SendPMGMessage(playerid, str);
    }
    else 
    {            
        return SendErrorMessage(playerid, "You have already created a private messaging group.");
    }
	return 1;
}

stock PMGInviteCMD(playerid, id)
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

stock PMGJoinCMD(playerid, id)
{
	new str[256];
    if(id == primaryPMG[playerid])
        return SendClientMessage(playerid, -1, "You are already in this group!");
    if(pmgInvite[playerid][id] == true)
    {
        format(str, sizeof(str), "%s(%d) has joined the PMG!", PlayerName(playerid), playerid);
        SendMessageToPMG(id, str);
        primaryPMG[playerid] = id;
        SetPMGMemberInfo(playerid, id, 1);
        pmgInvite[playerid][id] = false;
        SetPVarInt(playerid, "joinedGroup", 1);
        format(str, sizeof(str), "You have joined the group: %s", pmgInfo[id][pmgname]);
        SendPMGMessage(playerid, str);
    }
    if(!GetPVarInt(playerid, "joinedGroup"))
        return SendErrorMessage(playerid, "You either haven't been invited to that group or it doesn't exist!");
    SetPVarInt(playerid, "joinedGroup", 0);
	return 1;
}

stock PMGSayCMD(playerid, arg1[])
{
	if(primaryPMG[playerid] < 0)
	    return SendErrorMessage(playerid, "You do not have any private messaging groups selected.");
	if(strlen(arg1) > 0)
	{
	    new selid, rid, str[MAX_PMG_MESSAGE];
	    selid = primaryPMG[playerid];
	    rid = pmgMemberInfo[playerid][selid][pmg_member_rankid];
	    format(str, sizeof(str), "{FFFF00}PMG: (%s) %s(%d): %s", pmgRankInfo[selid][rid][pmg_rank_name], PlayerName(playerid), playerid, arg1);
	    foreach(new i : Player)
	    {
	        if(primaryPMG[i] == selid)
	            SendClientMessage(i, -1, str);
	    }
	}
	else 
	{            
	    return SendClientMessage(playerid, -1, "Usage: /pmg say <message>");
	}
	return 1;
}

stock PMGSelectCMD(playerid)
{
	if(primaryPMG[playerid] == -1)
        return SendClientMessage(playerid, -1, "{FF0000}ERROR:{FFFFFF} No groups found.");
        
    new goptions[256], pmgoptions[256], str[256], options, groupoptions[MAX_PMG_MEMBER_GROUPS], optionid;
    for(new i; i < MAX_PMG_GROUPS; i++)
    {
        if(pmgMemberInfo[playerid][i][pmg_member_rankid] > 0)
        {
            format(pmgoptions, sizeof(pmgoptions), "(%d) - %s\n", pmgMemberInfo[playerid][i][pmg_member_pmgid], pmgInfo[i][pmgname]);
            strcat(goptions, pmgoptions, sizeof(goptions));
            groupoptions[options] = pmgInfo[i][pmgid];
            options++; 
        }
    }
    inline Response(playerId, dialogid, response, listitem, string:inputtext[])
    {
    #pragma unused playerId, dialogid, inputtext, response, listitem
        if(response)
        {	    
            optionid = groupoptions[listitem];
            format(str, sizeof(str), "Selected '%s' as primary group.", pmgInfo[optionid][pmgname]);
            SendPMGMessage(playerid, str);
            primaryPMG[playerid] = optionid;
            format(str, sizeof(str), "SELECTED ID: %d", primaryPMG[playerid]);
            SendPMGMessage(playerid, str);
        }
    }       
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select a primary PMG:", goptions, "Select", "Cancel"); 
	return 1;
}

stock PMGLeaveCMD(playerid, id)
{
	new str[256];
	if(pmgInfo[id][pmg_owner_name] == pmgMemberInfo[playerid][id][pmg_member_name])
        return SendErrorMessage(playerid, "You cannot leave your own group! Use /pmg delete instead.");

    if(pmgMemberInfo[playerid][id][pmg_member_pmgid] == id)
    {
        RemovePlayerFromPMG(playerid, id);
        format(str, sizeof(str), "You have left %s!", pmgInfo[id][pmgname]);
        SendPMGMessage(playerid, str);
        format(str, sizeof(str), "{00FF00}PMG: {FFFFFF}%s(%d) has left the PMG!", PlayerName(playerid), playerid);
        SendMessageToPMG(id, str);
    }
    else
    {
        SendErrorMessage(playerid, "You are not in this group!");
    }
	return 1;
}

stock PMGDeleteCMD(playerid, id)
{
	new str[64];
    if(pmgInfo[id][pmg_owner_name] == pmgMemberInfo[playerid][id][pmg_member_name])
    {
        if(!GetPVarInt(playerid, "groupCreated"))
            return SendErrorMessage(playerid, "You do not own any group.");
        format(str, sizeof(str), "You have deleted '%s'!", pmgInfo[id][pmgname]);
        SendPMGMessage(playerid, str);
        DeletePMG(playerid, id);
    }
    else
    {
        SendErrorMessage(playerid, "You are not the owner of this group!");
    }
    return 1;
}

stock PMGManageCMD(playerid)
{
	new str[128], ranklist[128], gid = primaryPMG[playerid], rankchosen, uop[MAX_PLAYERS], op, userlist[128], targetid, trank;
    if(pmgMemberInfo[playerid][gid][pmg_member_rankid] < 3)
        return SendErrorMessage(playerid, "You cannot manage this group, select your own group as primary to start managing.");
    inline Response(playerId, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerId, dialogid, inputtext, response, listitem
        if(response)
	    {	    
            if(listitem == 0)
            {
                inline _Response(_playerId, _dialogid, _response, _listitem, string:_inputtext[])
                {
                #pragma unused _playerId, _dialogid, _inputtext, _response, _listitem
                    if(_response)
	                {
						new query[128];
                        if(!IsPMGNameValid(_inputtext))
                            return SendErrorMessage(playerid, "Your PMG name may only contain numbers and letters!");
                        strcopy(pmgInfo[gid][pmgname], _inputtext);
						mysql_format(dbhandle, query, sizeof(query), "UPDATE pmgdata SET pmgname='%s' WHERE pmgid=%d", _inputtext, gid);
                        mysql_tquery(dbhandle, query, "");
                        format(str, sizeof(str), "Succesfully changed PMG name to: %s", pmgInfo[gid][pmgname]);
                        SendPMGMessage(playerid, str);
                    }
                    else
                    {
                        SendErrorMessage(playerid, "You have entered an invalid name! Your name was either too long or too short!");
                    }
                }
                Dialog_ShowCallback(playerid, using inline _Response, DIALOG_STYLE_INPUT, "PMG Manage", "Enter a new group name:", "Confirm", "Cancel"); 
            }
            if(listitem == 1)
            {
                inline Response1(playerId1, dialogid1, response1, listitem1, string:inputtext1[])
                {
                #pragma unused playerId1, dialogid1, inputtext1, response1, listitem1
                    if(response1)
	                {
                        rankchosen = listitem1;
                        rankchosen++;
                        inline Response2(playerId2, dialogid2, response2, listitem2, string:inputtext2[])
                        {
                        #pragma unused playerId2, dialogid2, inputtext2, response2, listitem2
                            if(response2)
	                        {
                                if(listitem2 == 0)
                                {
                                    inline Response3(playerId3, dialogid3, response3, listitem3, string:inputtext3[])
                                    {
                                    #pragma unused playerId3, dialogid3, inputtext3, response3, listitem3
                                        if(response3)
	                                    {
                                            if(0 < strlen(inputtext3) < MAX_PMG_RANK_NAME)
                                            {
                                                new query[128];
                                                strcopy(pmgRankInfo[gid][rankchosen][pmg_rank_name], inputtext3);
                                                format(str, sizeof(str), "Rank name has been changed to: %s", pmgRankInfo[gid][rankchosen][pmg_rank_name]);
                                                SendPMGMessage(playerid, str);
                                                mysql_format(dbhandle, query, sizeof(query), "UPDATE pmgranks SET rankname='%s' WHERE pmgid=%d AND rankid=%d", pmgRankInfo[gid][rankchosen][pmg_rank_name], gid, rankchosen);
                                                mysql_tquery(dbhandle, query, "");
                                            }
                                            else
                                            {
                                                SendErrorMessage(playerid, "Invalid name entered, rank name change cancelled.");
                                            }
                                        }
                                    }
                                    Dialog_ShowCallback(playerid, using inline Response3, DIALOG_STYLE_INPUT, "PMG Manage", "Enter a new name for the specified rank:", "Confirm", "Cancel"); 
                                }
                            }         
                        }           
                        Dialog_ShowCallback(playerid, using inline Response2, DIALOG_STYLE_LIST, "PMG Manage", "Change rank name\n", "Select", "Cancel"); 
                    }
                }
                for(new i; i < MAX_PMG_RANKS; i++)
                {
                    if(i > 0)
                    {
                        format(str, sizeof(str), "%d - %s\n", pmgRankInfo[gid][i][pmg_rank_id], pmgRankInfo[gid][i][pmg_rank_name]);
                        strcat(ranklist, str, sizeof(ranklist));
                    }
                }
                Dialog_ShowCallback(playerid, using inline Response1, DIALOG_STYLE_LIST, "PMG Manage", ranklist, "Select", "Cancel"); 
            }
            if(listitem == 2)
            {
                foreach(new i : Player)
                {
                    if(pmgMemberInfo[i][gid][pmg_member_pmgid] == gid)
                    {
                        format(str, sizeof(str), "(%d) - %s - %s\n", i, PlayerName(i), pmgRankInfo[gid][pmgMemberInfo[i][gid][pmg_member_rankid]][pmg_rank_name]);
                        strcat(userlist, str, sizeof(userlist));
                        uop[op] = i;
                        op++;
                    }
                }
                inline Response4(playerId4, dialogid4, response4, listitem4, string:inputtext4[])
                {
                #pragma unused playerId4, dialogid4, inputtext4, response4, listitem4
                    if(response4)
	                {
                        targetid = uop[listitem4];
                        if(pmgMemberInfo[playerid][gid][pmg_member_name] != pmgInfo[gid][pmg_owner_name])
                        {
                            if(pmgMemberInfo[playerid][gid][pmg_member_rankid] <= pmgMemberInfo[targetid][gid][pmg_member_rankid])
                                return SendErrorMessage(playerid, "You cannot manage this user's rank!");
                        }
                        else if(targetid == playerid)
                            return SendErrorMessage(playerid, "You cannot manage your own rank!");
                        else
                        {
                            inline Response5(playerId5, dialogid5, response5, listitem5, string:inputtext5[])
                            {
                            #pragma unused playerId5, dialogid5, inputtext5, response5, listitem5
                                if(response5)
	                            {
                                    trank = strval(inputtext5);
                                    if(trank == 0)
                                    {
                                        RemovePlayerFromPMG(targetid, gid);
                                        format(str, sizeof(str), "User '%s' has been removed from your group", PlayerName(targetid));
                                        SendPMGMessage(playerid, str);
                                        format(str, sizeof(str), "{FF0000}You have been kicked from the group {FFFFFF}%s{FF0000} by {FFFFFF}%s(%d)", pmgInfo[gid][pmgname], PlayerName(playerid), playerid);
                                        SendPMGMessage(targetid, str);
                                    }
                                    else if(0 < trank < MAX_PMG_RANKS)
                                    {
										new query[128];
										pmgMemberInfo[targetid][gid][pmg_member_rankid] = trank;
                                        format(str, sizeof(str), "User '%s' now has the rank '%s'", PlayerName(targetid), pmgRankInfo[gid][pmgMemberInfo[targetid][gid][pmg_member_rankid]][pmg_rank_name]);
                                        SendPMGMessage(playerid, str);
                                        format(str, sizeof(str), "%s(%d) has set your rank to {FFFF00}%s{FFFFff} in {FFFF00}%s", PlayerName(playerid), playerid, pmgRankInfo[gid][trank][pmg_rank_name], pmgInfo[gid][pmgname], PlayerName(targetid));
                                        SendPMGMessage(targetid, str);
										mysql_format(dbhandle, query, sizeof(query), "UPDATE pmgmembers SET rankid=%d WHERE username='%s'", trank, PlayerName(targetid));
                                        mysql_tquery(dbhandle, query, "");
                                    }
                                    else
                                    {
                                        SendErrorMessage(playerid, "Invalid rank ID entered!");
                                    }
                                }
                            }
                            Dialog_ShowCallback(playerid, using inline Response5, DIALOG_STYLE_INPUT, "PMG Manage", "Enter player's new rank ID (0 = kick):", "Confirm", "Cancel");
                        }
                    }
                }
                Dialog_ShowCallback(playerid, using inline Response4, DIALOG_STYLE_LIST, "PMG Manage", userlist, "Select", "Cancel");
            }       
        }
    }
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "PMG Manage", "Change group name\nModify ranks\nManage users ranks", "Select", "Cancel"); 
	return 1;
}

stock strcopy(dest[], const source[], len = sizeof(dest)) 
{
	dest[0] = '\0';
	return strcat(dest, source, len);
}
