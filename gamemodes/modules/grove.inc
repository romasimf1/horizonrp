// =================== [ Grove Street Gang Module ] ===================
#define GROVE_ID 1

// Ранги Grove Street (от младшего к старшему)
new const GroveRanks[][] = {
    "Печенька",    // 1
    "Пончик",      // 2
    "Сэндвич",     // 3
    "Круассан",    // 4
    "Пицца",       // 5
    "Мороженка",   // 6
    "Чизкейк",     // 7
    "Капкейк",     // 8
    "Торт",        // 9
    "Король"       // 10
};

// =================== [ Команды лидера ] ===================
CMD:makeleader(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return SCM(playerid, COLOR_RED, "У вас нет прав!");
    
    new target, frac;
    if(sscanf(params, "dd", target, frac)) return SCM(playerid, COLOR_GREY, "Использование: /makeleader [ID] [фракция]");
    if(!IsPlayerConnected(target)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    if(frac < 1 || frac > 10) return SCM(playerid, COLOR_RED, "Неверный ID фракции (1-10)!");
    
    pInfo[target][pFaction] = frac;
    pInfo[target][pRank] = 10;
    
    new message[128];
    format(message, sizeof(message), "Администратор %s назначил вас лидером фракции %d", pInfo[playerid][pName], frac);
    SCM(target, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы назначили игрока %s лидером фракции %d", pInfo[target][pName], frac);
    SCM(playerid, COLOR_GREEN, message);
    return 1;
}

// =================== [ Команды Grove Street ] ===================
CMD:invite(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(pInfo[playerid][pRank] < 9) return SCM(playerid, COLOR_RED, "У вас недостаточно прав! (нужен 9+ ранг)");
    
    new target;
    if(sscanf(params, "d", target)) return SCM(playerid, COLOR_GREY, "Использование: /invite [ID]");
    if(!IsPlayerConnected(target)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    if(pInfo[target][pFaction] != 0) return SCM(playerid, COLOR_RED, "Игрок уже состоит в организации!");
    
    pInfo[target][pFaction] = GROVE_ID;
    pInfo[target][pRank] = 1;
    
    new message[128];
    format(message, sizeof(message), "%s пригласил вас в банду Grove Street! Ваш ранг: %s", 
        pInfo[playerid][pName], GroveRanks[0]);
    SCM(target, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы пригласили игрока %s в Grove Street", pInfo[target][pName]);
    SCM(playerid, COLOR_GREEN, message);
    
    // Уведомление всей банды
    format(message, sizeof(message), "[GROVE] %s пригласил в банду нового участника: %s", 
        pInfo[playerid][pName], pInfo[target][pName]);
    SendGroveMessage(message, COLOR_BLUE);
    return 1;
}

CMD:uninvite(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(pInfo[playerid][pRank] < 9) return SCM(playerid, COLOR_RED, "У вас недостаточно прав! (нужен 9+ ранг)");
    
    new target;
    if(sscanf(params, "d", target)) return SCM(playerid, COLOR_GREY, "Использование: /uninvite [ID]");
    if(!IsPlayerConnected(target)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    if(pInfo[target][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Игрок не состоит в Grove Street!");
    if(pInfo[target][pRank] >= pInfo[playerid][pRank]) return SCM(playerid, COLOR_RED, "Вы не можете исключить этого игрока!");
    
    pInfo[target][pFaction] = 0;
    pInfo[target][pRank] = 0;
    
    new message[128];
    format(message, sizeof(message), "%s исключил вас из банды Grove Street!", pInfo[playerid][pName]);
    SCM(target, COLOR_RED, message);
    
    format(message, sizeof(message), "Вы исключили игрока %s из Grove Street", pInfo[target][pName]);
    SCM(playerid, COLOR_GREEN, message);
    
    // Уведомление всей банды
    format(message, sizeof(message), "[GROVE] %s исключил из банды: %s", 
        pInfo[playerid][pName], pInfo[target][pName]);
    SendGroveMessage(message, COLOR_RED);
    return 1;
}

CMD:giverank(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(pInfo[playerid][pRank] < 10) return SCM(playerid, COLOR_RED, "У вас недостаточно прав! (только лидер)");
    
    new target, rank;
    if(sscanf(params, "dd", target, rank)) return SCM(playerid, COLOR_GREY, "Использование: /giverank [ID] [ранг 1-9]");
    if(!IsPlayerConnected(target)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    if(pInfo[target][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Игрок не состоит в Grove Street!");
    if(rank < 1 || rank > 9) return SCM(playerid, COLOR_RED, "Неверный ранг! (1-9)");
    
    new old_rank = pInfo[target][pRank];
    pInfo[target][pRank] = rank;
    
    new message[128];
    if(rank > old_rank) {
        format(message, sizeof(message), "Лидер %s повысил вас до ранга %s (%d)!", 
            pInfo[playerid][pName], GroveRanks[rank-1], rank);
        SCM(target, COLOR_GREEN, message);
    } else {
        format(message, sizeof(message), "Лидер %s понизил вас до ранга %s (%d)!", 
            pInfo[playerid][pName], GroveRanks[rank-1], rank);
        SCM(target, COLOR_ORANGE, message);
    }
    
    format(message, sizeof(message), "Вы изменили ранг игрока %s на %s (%d)", 
        pInfo[target][pName], GroveRanks[rank-1], rank);
    SCM(playerid, COLOR_GREEN, message);
    return 1;
}

// =================== [ Склад ] ===================
CMD:warehouse(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    
    new string[256];
    format(string, sizeof(string), 
        "{FFFFFF}=== {00FF00}Склад Grove Street{FFFFFF} ===\n\n\
        Материалов на складе: {FFFF00}%d{FFFFFF}\n\
        Ваши материалы: {FFFF00}%d{FFFFFF}\n\
        Статус склада: %s{FFFFFF}\n\n\
        Команды:\n\
        • /takemats [количество] - взять материалы\n\
        • /putmats [количество] - положить материалы\n\
        • /warelock - заблокировать/разблокировать (лидер)",
        GroveWarehouse, pInfo[playerid][pMaterials],
        GroveWarehouseLocked ? "{FF0000}Заблокирован" : "{00FF00}Открыт"
    );
    SPD(playerid, 999, DSM, "Склад Grove Street", string, "Закрыть", "");
    return 1;
}

CMD:warelock(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(pInfo[playerid][pRank] < 10) return SCM(playerid, COLOR_RED, "У вас недостаточно прав! (только лидер)");
    
    GroveWarehouseLocked = !GroveWarehouseLocked;
    
    new message[128];
    format(message, sizeof(message), "Лидер %s %s склад банды", 
        pInfo[playerid][pName], GroveWarehouseLocked ? "заблокировал" : "разблокировал");
    SendGroveMessage(message, COLOR_ORANGE);
    return 1;
}

CMD:takemats(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(GroveWarehouseLocked) return SCM(playerid, COLOR_RED, "Склад заблокирован!");
    
    new amount;
    if(sscanf(params, "d", amount)) return SCM(playerid, COLOR_GREY, "Использование: /takemats [количество]");
    if(amount < 1 || amount > 1000) return SCM(playerid, COLOR_RED, "Неверное количество! (1-1000)");
    if(GroveWarehouse < amount) return SCM(playerid, COLOR_RED, "На складе недостаточно материалов!");
    
    GroveWarehouse -= amount;
    pInfo[playerid][pMaterials] += amount;
    
    new message[128];
    format(message, sizeof(message), "Вы взяли %d материалов со склада. У вас: %d", 
        amount, pInfo[playerid][pMaterials]);
    SCM(playerid, COLOR_GREEN, message);
    
    // Лог для банды
    format(message, sizeof(message), "[СКЛАД] %s взял %d материалов (осталось: %d)", 
        pInfo[playerid][pName], amount, GroveWarehouse);
    SendGroveMessage(message, COLOR_YELLOW);
    return 1;
}

CMD:putmats(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(GroveWarehouseLocked) return SCM(playerid, COLOR_RED, "Склад заблокирован!");
    
    new amount;
    if(sscanf(params, "d", amount)) return SCM(playerid, COLOR_GREY, "Использование: /putmats [количество]");
    if(amount < 1 || amount > 1000) return SCM(playerid, COLOR_RED, "Неверное количество! (1-1000)");
    if(pInfo[playerid][pMaterials] < amount) return SCM(playerid, COLOR_RED, "У вас недостаточно материалов!");
    
    pInfo[playerid][pMaterials] -= amount;
    GroveWarehouse += amount;
    
    new message[128];
    format(message, sizeof(message), "Вы положили %d материалов на склад. У вас: %d", 
        amount, pInfo[playerid][pMaterials]);
    SCM(playerid, COLOR_GREEN, message);
    
    // Лог для банды
    format(message, sizeof(message), "[СКЛАД] %s пополнил склад на %d материалов (всего: %d)", 
        pInfo[playerid][pName], amount, GroveWarehouse);
    SendGroveMessage(message, COLOR_YELLOW);
    return 1;
}

// =================== [ Оружие ] ===================
CMD:givegun(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(pInfo[playerid][pRank] < 5) return SCM(playerid, COLOR_RED, "У вас недостаточно прав! (нужен 5+ ранг)");
    
    new target, weapon, ammo;
    if(sscanf(params, "ddd", target, weapon, ammo)) return SCM(playerid, COLOR_GREY, "Использование: /givegun [ID] [оружие] [патроны]");
    if(!IsPlayerConnected(target)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    if(pInfo[target][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Игрок не состоит в Grove Street!");
    if(weapon < 1 || weapon > 46) return SCM(playerid, COLOR_RED, "Неверный ID оружия! (1-46)");
    if(ammo < 1 || ammo > 500) return SCM(playerid, COLOR_RED, "Неверное количество патронов! (1-500)");
    
    new cost = ammo; // 1 материал = 1 патрон
    if(pInfo[playerid][pMaterials] < cost) return SCM(playerid, COLOR_RED, "У вас недостаточно материалов!");
    
    pInfo[playerid][pMaterials] -= cost;
    GivePlayerWeapon(target, weapon, ammo);
    
    new message[128];
    new weapon_name[32];
    GetWeaponName(weapon, weapon_name, sizeof(weapon_name));
    
    format(message, sizeof(message), "%s выдал вам %s с %d патронами", 
        pInfo[playerid][pName], weapon_name, ammo);
    SCM(target, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы выдали игроку %s %s с %d патронами (потрачено %d материалов)", 
        pInfo[target][pName], weapon_name, ammo, cost);
    SCM(playerid, COLOR_GREEN, message);
    return 1;
}

// =================== [ Радио ] ===================
CMD:r(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    if(isnull(params)) return SCM(playerid, COLOR_GREY, "Использование: /r [сообщение]");
    
    new message[144];
    format(message, sizeof(message), "[RADIO] %s %s: %s", 
        GroveRanks[pInfo[playerid][pRank]-1], pInfo[playerid][pName], params);
    SendGroveMessage(message, COLOR_BLUE);
    return 1;
}

CMD:f(playerid, params[]) {
    return cmd_r(playerid, params);
}

// =================== [ Информация ] ===================
CMD:members(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    
    new count = 0, members_list[512];
    strcat(members_list, "{FFFFFF}=== {00FF00}Участники Grove Street{FFFFFF} ===\n\n");
    
    foreach(new i : Player) {
        if(pInfo[i][pFaction] == GROVE_ID) {
            new temp[64];
            format(temp, sizeof(temp), "%s %s (ID: %d)\n", 
                GroveRanks[pInfo[i][pRank]-1], pInfo[i][pName], i);
            strcat(members_list, temp);
            count++;
        }
    }
    
    if(count == 0) {
        strcat(members_list, "{FF0000}В данный момент нет участников онлайн");
    } else {
        new temp[32];
        format(temp, sizeof(temp), "\n{FFFF00}Всего онлайн: %d", count);
        strcat(members_list, temp);
    }
    
    SPD(playerid, 998, DSM, "Участники банды", members_list, "Закрыть", "");
    return 1;
}

CMD:myrank(playerid, params[]) {
    if(pInfo[playerid][pFaction] != GROVE_ID) return SCM(playerid, COLOR_RED, "Вы не состоите в Grove Street!");
    
    new message[128];
    format(message, sizeof(message), "Ваш ранг в Grove Street: %s (%d/10)", 
        GroveRanks[pInfo[playerid][pRank]-1], pInfo[playerid][pRank]);
    SCM(playerid, COLOR_GREEN, message);
    return 1;
}

// =================== [ Вспомогательные функции ] ===================
stock SendGroveMessage(const message[], color) {
    foreach(new i : Player) {
        if(pInfo[i][pFaction] == GROVE_ID) {
            SCM(i, color, message);
        }
    }
}

stock GetOnlineGroveMembers() {
    new count = 0;
    foreach(new i : Player) {
        if(pInfo[i][pFaction] == GROVE_ID) {
            count++;
        }
    }
    return count;
}

stock bool:IsGroveLeader(playerid) {
    return (pInfo[playerid][pFaction] == GROVE_ID && pInfo[playerid][pRank] == 10);
}

stock bool:IsGroveMember(playerid) {
    return (pInfo[playerid][pFaction] == GROVE_ID && pInfo[playerid][pRank] > 0);
}

