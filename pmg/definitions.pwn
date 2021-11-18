#define MAX_PMG_GROUPS 75
#define MAX_PMG_NAME 25
#define MAX_PMG_MESSAGE 256
#define MAX_PMG_OPEN_INVITES 16
#define MAX_PMG_RANK_NAME 36
#define MAX_PMG_MEMBER_GROUPS 12

enum _:pmgData {
    pmgid,
    pmgname[MAX_PMG_NAME]
}

enum pmgMemberData {
    pmg_member_id,
    pmg_member_name[MAX_PLAYER_NAME],
    pmg_member_pmgid
}


new pmgInfo[MAX_PMG_GROUPS][pmgData];
new pmgMemberInfo[MAX_PLAYERS][MAX_PMG_GROUPS][pmgMemberData];

new selectedPMG[MAX_PLAYERS];
new bool:pmgInvite[MAX_PLAYERS][MAX_PLAYERS];

new usage[128] = "Usage: /pmg <create|say|invite>";