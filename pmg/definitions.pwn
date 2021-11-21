#define MAX_PMG_GROUPS MAX_PLAYERS
#define MAX_PMG_NAME 25
#define MAX_PMG_MESSAGE 256
#define MAX_PMG_OPEN_INVITES MAX_PLAYERS
#define MAX_PMG_MEMBER_GROUPS 12
#define MAX_PMG_RANK_NAME 24
#define MAX_PMG_RANKS 4

enum pmgData {
    pmgid,
    pmgname[MAX_PMG_NAME],
    pmg_owner_name[MAX_PLAYER_NAME]
}

enum pmgMemberData {
    pmg_member_id,
    pmg_member_name[MAX_PLAYER_NAME],
    pmg_member_pmgid,
    pmg_member_rankid
}

enum pmgRankData {
    pmg_rank_id, 
    pmg_rank_name[MAX_PMG_RANK_NAME]
}


new pmgInfo[MAX_PMG_GROUPS][pmgData];
new pmgMemberInfo[MAX_PLAYERS][MAX_PMG_GROUPS][pmgMemberData];
new pmgRankInfo[MAX_PMG_GROUPS][MAX_PMG_RANKS][pmgRankData];

new primaryPMG[MAX_PLAYERS];
new bool:pmgInvite[MAX_PLAYERS][MAX_PLAYERS];

new usage[128] = "Usage: /pmg <create|say|invite|leave|join|manage|select|delete>";