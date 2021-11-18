#include "pmg/commands.pwn"

stock CreatePMG(playerid, const gname[])
{
    format(pmgInfo[playerid][pmgname], MAX_PMG_NAME, "%s", gname);
    pmgInfo[playerid][pmgid] = playerid;
    return 1;
}

stock SetMemberInfo(playerid, id)
{
    selectedPMG[playerid] = id;
    pmgMemberInfo[playerid][id][pmg_member_id] = playerid;
    pmgMemberInfo[playerid][id][pmg_member_pmgid] = pmgInfo[id][pmgid];
}