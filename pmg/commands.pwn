CMD:pmg(playerid, params[])
{
    new arg[24], arg1[256]; 
    if(sscanf(params, "s[24]S()", arg, arg1)) 
        return SendClientMessage(playerid, -1, usage);
    if(!strcmp(arg, "create"))
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
            mysql_tquery(dbhandle, query, "PMGCreate", "ds", playerid, arg1);
            format(str, sizeof(str), "You have succesfully created a private messaging group called: '%s'", arg1);
            SendPMGMessage(playerid, str);
        }
        else 
        {            
            return SendErrorMessage(playerid, "You have already created a private messaging group.");
        }
    }
    else if(!strcmp(arg, "say"))
    {
        if(primaryPMG[playerid] < 0)
            return SendErrorMessage(playerid, "You do not have any private messaging groups selected.");
        if(strlen(arg1) > 0)
        {
            new selid, rid, str[MAX_PMG_MESSAGE];
            selid = primaryPMG[playerid];
            rid = pmgMemberInfo[playerid][selid][pmg_member_rankid];
            format(str, sizeof(str), "{FFFF00}PMG: (%s) %s(%d): %s", pmgRankInfo[selid][rid][pmg_rank_name], PlayerName(playerid), playerid, arg1);
            //format(str, sizeof(str), "PMG [] %s(%d): %s", PlayerName(playerid), playerid, arg1);
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
    }
    else if(!strcmp(arg, "invite"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg invite <id>");
        PMGInvite(playerid, id);
    }
    else if(!strcmp(arg, "join"))
    {
        new id, str[128];
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg join <id>");
        {
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
        }
    }
    else if(!strcmp(arg, "select"))
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
    } 
    else if(!strcmp(arg, "leave"))
    {
        new id, str[128];
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg leave <group id>");
        
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
    }
    else if(!strcmp(arg, "delete"))
    {
        new id, str[128];
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg delete <group id>");
        
        if(pmgInfo[id][pmg_owner_name] == pmgMemberInfo[playerid][id][pmg_member_name])
        {
            format(str, sizeof(str), "You have deleted '%s'!", pmgInfo[id][pmgname]);
            SendPMGMessage(playerid, str);
            DeletePMG(playerid, id);
        }
        else
        {
            SendErrorMessage(playerid, "You are not the owner of this group!");
        }
    }
    else if(!strcmp(arg, "manage"))
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
                            if(!IsPMGNameValid(_inputtext))
                                return SendErrorMessage(playerid, "Your PMG name may only contain numbers and letters!");
                            strcopy(pmgInfo[gid][pmgname], _inputtext);
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
                                            SetPMGMemberInfo(targetid, gid, trank);
                                            format(str, sizeof(str), "User '%s' now has the rank '%s'", PlayerName(targetid), pmgRankInfo[gid][pmgMemberInfo[targetid][gid][pmg_member_rankid]][pmg_rank_name]);
                                            SendPMGMessage(playerid, str);
                                            format(str, sizeof(str), "%s(%d) has set your rank to {FFFF00}%s{FFFFff} in {FFFF00}%s", PlayerName(playerid), playerid, pmgRankInfo[gid][trank][pmg_rank_name], pmgInfo[gid][pmgname], PlayerName(targetid));
                                            SendPMGMessage(targetid, str);
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
    }
    else
    {
        SendClientMessage(playerid, -1, usage);
    }       
    return 1;
}

CMD:pmginfo(playerid, params[])
{
    new id, str[128], sid;
    if(sscanf(params, "d", id)) 
        return SendClientMessage(playerid, -1, "Usage: /pmginfo <id>");
    sid = primaryPMG[id];
    format(str, sizeof(str), "PMG RANK NAME: %s, PMG ID: %d", pmgRankInfo[sid][pmgMemberInfo[id][sid][pmg_member_rankid]][pmg_rank_name], sid);
    SendClientMessage(playerid, -1, str);
    return 1;
}


CMD:clearchat(playerid, params[])
{
	for(new i; i < 60; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}
	return 1;
}