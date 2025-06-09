#define GROVE_ID 1

new const GroveRanks[][] = {
    "\xCF\xE5\xF7\xE5\xED\xFC\xEA\xE0", // 1
    "\xCF\xEE\xED\xF7\xE8\xEA", // 2
    "\xD1\xFD\xED\xE4\xE2\xE8\xF7", // 3
    "\xCA\xF0\xF3\xE0\xF1\xF1\xE0\xED", // 4
    "\xCF\xE8\xF6\xF6\xE0", // 5
    "\xCC\xEE\xF0\xEE\xE6\xE5\xED\xEA\xE0", // 6
    "\xD7\xE8\xE7\xEA\xE5\xE9\xEA", // 7
    "\xCA\xE0\xEF\xEA\xE5\xE9\xEA", // 8
    "\xD2\xEE\xF0\xF2", // 9
    "\xCA\xEE\xF0\xEE\xEB\xFC" //10
};

CMD:makeleader(playerid, params[])
{
    new target, frac;
    if(sscanf(params, "dd", target, frac)) return SCM(playerid, -1, "Usage: /makeleader [player] [fraction]");
    if(!IsPlayerConnected(target)) return SCM(playerid, Color_Red, "Player not online");
    pInfo[target][pFaction] = frac;
    pInfo[target][pRank] = 10;
    SCM(target, Color_Green, "You are now the leader");
    return 1;
}

CMD:invite(playerid, params[])
{
    new target;
    if(sscanf(params, "d", target)) return SCM(playerid, -1, "Usage: /invite [player]");
    if(pInfo[playerid][pFaction] != GROVE_ID || pInfo[playerid][pRank] < 9) return 1;
    pInfo[target][pFaction] = GROVE_ID;
    pInfo[target][pRank] = 1;
    SCM(target, Color_Green, "You are invited to Grove Street");
    return 1;
}

CMD:warehouse(playerid, params[])
{
    if(pInfo[playerid][pFaction] != GROVE_ID) return 1;
    new str[64];
    format(str, sizeof str, "Materials on warehouse: %d", GroveWarehouse);
    SCM(playerid, Color_Green, str);
    format(str, sizeof str, "Your materials: %d", pInfo[playerid][pMaterials]);
    SCM(playerid, Color_Green, str);
    return 1;
}

CMD:warelock(playerid, params[])
{
    if(pInfo[playerid][pFaction] != GROVE_ID || pInfo[playerid][pRank] < 10) return 1;
    GroveWarehouseLocked = !GroveWarehouseLocked;
    SCM(playerid, Color_Orange, GroveWarehouseLocked ? "Warehouse locked" : "Warehouse unlocked");
    return 1;
}

CMD:takemats(playerid, params[])
{
    new amount;
    if(sscanf(params, "d", amount)) return SCM(playerid, -1, "Usage: /takemats [amount]");
    if(pInfo[playerid][pFaction] != GROVE_ID) return 1;
    if(GroveWarehouseLocked) return SCM(playerid, Color_Red, "Warehouse closed");
    if(GroveWarehouse < amount) return SCM(playerid, Color_Red, "Not enough materials on warehouse");
    GroveWarehouse -= amount;
    pInfo[playerid][pMaterials] += amount;
    return 1;
}

CMD:putmats(playerid, params[])
{
    new amount;
    if(sscanf(params, "d", amount)) return SCM(playerid, -1, "Usage: /putmats [amount]");
    if(pInfo[playerid][pFaction] != GROVE_ID) return 1;
    if(GroveWarehouseLocked) return SCM(playerid, Color_Red, "Warehouse closed");
    if(pInfo[playerid][pMaterials] < amount) return SCM(playerid, Color_Red, "Not enough materials");
    pInfo[playerid][pMaterials] -= amount;
    GroveWarehouse += amount;
    return 1;
}

CMD:givegun(playerid, params[])
{
    new gun, ammo;
    if(sscanf(params, "dd", gun, ammo)) return SCM(playerid, -1, "Usage: /givegun [weapon] [ammo]");
    if(pInfo[playerid][pFaction] != GROVE_ID) return 1;
    if(pInfo[playerid][pMaterials] < ammo) return SCM(playerid, Color_Red, "Not enough materials");
    pInfo[playerid][pMaterials] -= ammo;
    GivePlayerWeapon(playerid, gun, ammo);
    return 1;
}

CMD:r(playerid, params[])
{
    if(pInfo[playerid][pFaction] != GROVE_ID) return 0;
    if(isnull(params)) return 1;
    new msg[128], name[MAX_PLAYER_NAME+1];
    GetPlayerName(playerid, name, sizeof name);
    format(msg, sizeof msg, "{00BFFFF}[%s %s] %s", GroveRanks[pInfo[playerid][pRank]-1], name, params);
    foreach(new i : Player) if(pInfo[i][pFaction] == GROVE_ID) SCM(i, Color_Blue, msg);
    return 1;
}
CMD:f(playerid, params[]) return callcmd::r(playerid, params);

