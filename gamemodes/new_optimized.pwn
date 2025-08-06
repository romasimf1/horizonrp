#include "modules/grove.inc"

// =================== [ Инклуды ] ===================
#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <streamer>
#include <foreach>

// =================== [ MySQL БД ] ===================
#define MySQL_Host "127.0.0.1"
#define MySQL_User "root"
#define MySQL_Base "new"
#define MySQL_Pass ""

// =================== [ Диалоги ] ===================
#define SPD ShowPlayerDialog
#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll

#define DSL DIALOG_STYLE_LIST
#define DSI DIALOG_STYLE_INPUT
#define DSM DIALOG_STYLE_MSGBOX
#define DSP DIALOG_STYLE_PASSWORD

// Диалоги
enum {
    DIALOG_REGISTER = 1,
    DIALOG_PASS_CHECK,
    DIALOG_EMAIL,
    DIALOG_REFERAL,
    DIALOG_NATIONS,
    DIALOG_AGE,
    DIALOG_SEX,
    DIALOG_LOGIN
}

// =================== [ Цвета ] ===================
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x008000FF
#define COLOR_BLUE 0x00BFFFFF
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_ORANGE 0xDF8600FF
#define COLOR_GREY 0x999999FF
#define COLOR_PURPLE 0x800080FF
#define COLOR_BROWN 0xA52A2AFF
#define COLOR_LIGHTRED 0xFF463CFF

// =================== [ Константы ] ===================
#define MAX_SKIN_MALE 14
#define MAX_SKIN_FEMALE 14
#define MIN_PASSWORD_LEN 6
#define MAX_PASSWORD_LEN 32
#define MIN_EMAIL_LEN 6
#define MAX_EMAIL_LEN 46
#define MIN_AGE 14
#define MAX_AGE 99
#define LOGIN_TIME_LIMIT 35
#define MAX_LOGIN_ATTEMPTS 3
#define UPDATE_INTERVAL 5000

// =================== [ Дефайны ] ===================
#define Freeze(%0,%1) TogglePlayerControllable(%0, %1)
#define Pkick(%0) SetTimerEx("TimeKick", 80, false, "i", %0)

#if !defined isnull
#define isnull(%0) ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif

// =================== [ Переменные Grove Street ] ===================
new GroveWarehouse = 0;
new bool:GroveWarehouseLocked = false;

// =================== [ Форварды ] ===================
forward PlayerCheck(playerid);
forward PlayerLogin(playerid);
forward CheckReferal(playerid, name[]);
forward CheckReferal_2(playerid);
forward CheckLogin(playerid);
forward TimeKick(playerid);
forward UpdatePlayer(playerid);
forward FastSpawn(playerid);

// =================== [ Переменные ] ===================
new MySQL:dbHandle;
new number_skin[MAX_PLAYERS char];
new number_pass[MAX_PLAYERS char];
new Text:select_skin[MAX_PLAYERS][11];
new update_timer[MAX_PLAYERS];
new login_timer[MAX_PLAYERS];
new bool:login_check[MAX_PLAYERS char];

// =================== [ Энум игрока ] ===================
enum PlayerData {
    pID,
    pName[MAX_PLAYER_NAME + 1],
    pPass[MAX_PASSWORD_LEN + 1],
    pEmail[MAX_EMAIL_LEN + 1],
    pReferal[MAX_PLAYER_NAME + 1],
    pDateReg[11],
    pNations,
    pAge,
    pSex,
    pSkin,
    pMoney,
    pLevel,
    pFaction,
    pRank,
    pMaterials
}
new pInfo[MAX_PLAYERS][PlayerData];

// =================== [ Массивы скинов ] ===================
new const MaleSkins[] = {32, 78, 79, 133, 134, 135, 136, 137, 138, 142, 143, 144, 146, 147};
new const FemaleSkins[] = {63, 64, 65, 88, 89, 90, 91, 92, 93, 129, 130, 131, 145, 148};

new const NationsList[][] = {
    "Американская", "Китайская", "Итальянская", "Мексиканская",
    "Русская", "Украинская", "Филиппинская", "Японская"
};

// =================== [ Коллбэки сервера ] ===================
public OnGameModeInit() {
    SetGameModeText("HorizonRP v2.0");
    ConnectMySQL();
    AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
    ShowNameTags(true);
    SetNameTagDrawDistance(20.0);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);
    
    CreateRegistrationInterior();
    print("[LOAD] HorizonRP успешно загружен!");
    return 1;
}

public OnGameModeExit() {
    mysql_close(dbHandle);
    print("[UNLOAD] HorizonRP выгружен!");
    return 1;
}

public OnPlayerConnect(playerid) {
    GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
    
    // Проверяем существование аккаунта
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), 
        "SELECT `ID` FROM `users` WHERE `Name` = '%e' LIMIT 1", 
        pInfo[playerid][pName]
    );
    mysql_tquery(dbHandle, query, "PlayerCheck", "d", playerid);
    
    ClearPlayerData(playerid);
    CreatePlayerTextDraws(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    SavePlayerData(playerid);
    KillPlayerTimers(playerid);
    DestroyPlayerTextDraws(playerid);
    ClearPlayerData(playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(login_check{playerid}) {
        SetPlayerSpawnLocation(playerid);
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    return 1;
}

public OnPlayerText(playerid, text[]) {
    if(!login_check{playerid}) {
        SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
        return 0;
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    return 0;
}

public OnPlayerRequestSpawn(playerid) {
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if(clickedid == Text:INVALID_TEXT_DRAW && number_skin{playerid} > 0) {
        SelectTextDraw(playerid, COLOR_BROWN);
        return 1;
    }
    
    // Обработка смены скинов
    if(clickedid == select_skin[playerid][9]) { // Кнопка ">"
        ChangeSkin(playerid, 1);
    }
    else if(clickedid == select_skin[playerid][8]) { // Кнопка "<"
        ChangeSkin(playerid, -1);
    }
    else if(clickedid == select_skin[playerid][10]) { // Кнопка подтверждения
        ConfirmSkinSelection(playerid);
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new len = strlen(inputtext);
    new val = strval(inputtext);
    
    switch(dialogid) {
        case DIALOG_REGISTER: {
            if(!response) {
                SCM(playerid, COLOR_RED, "Введите /quit для выхода");
                Pkick(playerid);
                return 1;
            }
            
            if(!ValidatePassword(inputtext, len)) {
                ShowRegister(playerid);
                return 1;
            }
            
            strmid(pInfo[playerid][pPass], inputtext, 0, len, MAX_PASSWORD_LEN + 1);
            ShowPassCheck(playerid);
        }
        
        case DIALOG_PASS_CHECK: {
            if(!strcmp(pInfo[playerid][pPass], inputtext)) {
                ShowEmail(playerid);
            } else {
                SCM(playerid, COLOR_LIGHTRED, "Неверный пароль.");
                Pkick(playerid);
            }
        }
        
        case DIALOG_EMAIL: {
            if(!response) {
                ShowPassCheck(playerid);
                return 1;
            }
            
            if(!ValidateEmail(inputtext, len)) {
                ShowEmail(playerid);
                return 1;
            }
            
            strmid(pInfo[playerid][pEmail], inputtext, 0, len, MAX_EMAIL_LEN + 1);
            ShowReferal(playerid);
        }
        
        case DIALOG_REFERAL: {
            if(!response) {
                ShowNations(playerid);
                return 1;
            }
            
            if(isnull(inputtext)) {
                ShowReferal(playerid);
                SCM(playerid, COLOR_GREY, "Вы ничего не ввели.");
                return 1;
            }
            
            CheckReferalExists(playerid, inputtext);
        }
        
        case DIALOG_NATIONS: {
            if(!response) {
                ShowReferal(playerid);
                return 1;
            }
            
            pInfo[playerid][pNations] = listitem + 1;
            ShowAge(playerid);
        }
        
        case DIALOG_AGE: {
            if(!response) {
                ShowNations(playerid);
                return 1;
            }
            
            if(!ValidateAge(val)) {
                ShowAge(playerid);
                return 1;
            }
            
            pInfo[playerid][pAge] = val;
            ShowSex(playerid);
        }
        
        case DIALOG_SEX: {
            pInfo[playerid][pSex] = response ? 1 : 2;
            StartSkinSelection(playerid);
        }
        
        case DIALOG_LOGIN: {
            if(!response) {
                SCM(playerid, COLOR_RED, "Введите /quit для выхода");
                Pkick(playerid);
                return 1;
            }
            
            if(isnull(inputtext)) {
                ShowLogin(playerid);
                SCM(playerid, COLOR_GREY, "Вы ничего не ввели.");
                return 1;
            }
            
            AttemptLogin(playerid, inputtext);
        }
    }
    return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
    if(!login_check{playerid}) {
        SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
        return 0;
    }
    return 1;
}

// =================== [ Колбэки MySQL ] ===================
public PlayerCheck(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    new rows = cache_num_rows();
    
    if(rows) {
        pInfo[playerid][pID] = cache_get_value_int(0, "ID");
        login_timer[playerid] = SetTimerEx("CheckLogin", LOGIN_TIME_LIMIT * 1000, false, "i", playerid);
        ShowLogin(playerid);
    } else {
        ShowRegister(playerid);
    }
    return 1;
}

public PlayerLogin(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    new rows = cache_num_rows();
    
    if(rows) {
        LoadPlayerData(playerid);
        login_check{playerid} = true;
        
        SetTimerEx("FastSpawn", 100, false, "i", playerid);
        update_timer[playerid] = SetTimerEx("UpdatePlayer", UPDATE_INTERVAL, true, "i", playerid);
        KillTimer(login_timer[playerid]);
        
        CheckReferalBonus(playerid);
        
        new message[64];
        format(message, sizeof(message), "Добро пожаловать, %s!", pInfo[playerid][pName]);
        SCM(playerid, COLOR_GREEN, message);
    } else {
        HandleFailedLogin(playerid);
    }
    return 1;
}

public CheckReferal(playerid, name[]) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    new rows = cache_num_rows();
    
    if(!rows) {
        ShowReferal(playerid);
        SCM(playerid, COLOR_GREY, "Аккаунт не найден.");
        return 1;
    }
    
    strmid(pInfo[playerid][pReferal], name, 0, strlen(name), MAX_PLAYER_NAME + 1);
    ShowNations(playerid);
    return 1;
}

public CheckReferal_2(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    new rows = cache_num_rows();
    
    if(rows) {
        pInfo[playerid][pMoney] += 100000;
        SavePlayerField(playerid, "Money", pInfo[playerid][pMoney]);
        SCM(playerid, COLOR_YELLOW, "Вы получаете $100,000 за приглашенного игрока!");
        
        new query[128];
        mysql_format(dbHandle, query, sizeof(query), 
            "DELETE FROM `referal` WHERE `Name` = '%e' LIMIT 1", 
            pInfo[playerid][pName]
        );
        mysql_tquery(dbHandle, query);
    }
    return 1;
}

public CheckLogin(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    SCM(playerid, COLOR_RED, "Время на авторизацию вышло. Введите /quit");
    Pkick(playerid);
    return 1;
}

public TimeKick(playerid) {
    if(IsPlayerConnected(playerid)) {
        Kick(playerid);
    }
    return 1;
}

public UpdatePlayer(playerid) {
    if(!IsPlayerConnected(playerid) || !login_check{playerid}) return 1;
    
    // Проверка денег на анти-чит
    if(pInfo[playerid][pMoney] != GetPlayerMoney(playerid)) {
        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
    }
    
    // Периодическое сохранение
    SavePlayerField(playerid, "Money", pInfo[playerid][pMoney]);
    return 1;
}

public FastSpawn(playerid) {
    if(IsPlayerConnected(playerid)) {
        SpawnPlayer(playerid);
    }
    return 1;
}

// =================== [ Функции диалогов ] ===================
stock ShowLogin(playerid) {
    new string[512];
    format(string, sizeof(string),
        "{FFFFFF}[Добро пожаловать на HorizonRP]\n\n\
        Логин: {%06x}%s{FFFFFF}\n\
        Пинг: {%06x}%d{FFFFFF}\n\
        Аккаунт: {FF0000}занят{FFFFFF}\n\n\
        {999999}У вас есть %d секунд для ввода пароля{FFFFFF}\n\
        Введите свой пароль:",
        COLOR_BROWN >>> 8, pInfo[playerid][pName],
        COLOR_BROWN >>> 8, GetPlayerPing(playerid),
        LOGIN_TIME_LIMIT
    );
    SPD(playerid, DIALOG_LOGIN, DSP, "Авторизация", string, "Войти", "Выйти");
}

stock ShowRegister(playerid) {
    new string[512];
    format(string, sizeof(string),
        "{FFFFFF}[Добро пожаловать на HorizonRP]\n\n\
        Логин: {%06x}%s{FFFFFF}\n\
        Пинг: {%06x}%d{FFFFFF}\n\
        Аккаунт: {008000}свободен{FFFFFF}\n\n\
        Придумайте свой пароль (%d-%d символов):",
        COLOR_BROWN >>> 8, pInfo[playerid][pName],
        COLOR_BROWN >>> 8, GetPlayerPing(playerid),
        MIN_PASSWORD_LEN, MAX_PASSWORD_LEN
    );
    SPD(playerid, DIALOG_REGISTER, DSI, "Регистрация", string, "Далее", "Выйти");
}

stock ShowPassCheck(playerid) {
    SPD(playerid, DIALOG_PASS_CHECK, DSP, "Подтверждение пароля",
        "{FFFFFF}Подтвердите свой {A52A2A}пароль{FFFFFF}\n\
        чтобы продолжить {A52A2A}регистрацию{FFFFFF}:",
        "Далее", "Назад");
}

stock ShowEmail(playerid) {
    new string[512];
    format(string, sizeof(string),
        "{FFFFFF}Укажите правильно свою {A52A2A}электронную почту{FFFFFF}\n\
        В случае взлома или потери аккаунта\n\
        вы сможете восстановить свой {A52A2A}аккаунт{FFFFFF}:\n\n\
        {DF8600}Требования:{FFFFFF}\n\
        • Длина: %d-%d символов\n\
        • Должна содержать @ и точку\n\
        • Только латинские символы и цифры",
        MIN_EMAIL_LEN, MAX_EMAIL_LEN
    );
    SPD(playerid, DIALOG_EMAIL, DSI, "Электронная почта", string, "Далее", "Назад");
}

stock ShowReferal(playerid) {
    SPD(playerid, DIALOG_REFERAL, DSI, "Реферал",
        "{FFFFFF}Введите {A52A2A}ник игрока{FFFFFF}, пригласившего\n\
        вас на сервер:\n\n\
        {DF8600}Награды для реферала:{FFFFFF}\n\
        • При достижении вами 6-го уровня:\n\
        • Получит {DF8600}$120,000\n\
        • Получит {A52A2A}VIP статус{FFFFFF} на {DF8600}7 дней\n\
        • Получит {A52A2A}донат{FFFFFF} на {DF8600}250 рублей",
        "Далее", "Пропустить");
}

stock ShowNations(playerid) {
    new nations_str[256];
    for(new i = 0; i < sizeof(NationsList); i++) {
        if(i > 0) strcat(nations_str, "\n");
        strcat(nations_str, NationsList[i]);
    }
    SPD(playerid, DIALOG_NATIONS, DSL, "Национальность", nations_str, "Выбрать", "Назад");
}

stock ShowAge(playerid) {
    new string[256];
    format(string, sizeof(string),
        "{FFFFFF}Введите возраст вашего {A52A2A}персонажа{FFFFFF}:\n\n\
        {DF8600}Требования:{FFFFFF}\n\
        • Возраст от %d до %d лет\n\
        • Только цифры",
        MIN_AGE, MAX_AGE
    );
    SPD(playerid, DIALOG_AGE, DSI, "Возраст", string, "Далее", "Назад");
}

stock ShowSex(playerid) {
    SPD(playerid, DIALOG_SEX, DSM, "Пол персонажа",
        "{FFFFFF}Выберите {A52A2A}пол{FFFFFF} вашего\n\
        персонажа, за которого вы будете играть:",
        "Мужской", "Женский");
}

// =================== [ Функции валидации ] ===================
stock bool:ValidatePassword(const password[], len) {
    if(len < MIN_PASSWORD_LEN || len > MAX_PASSWORD_LEN) {
        SCM(playerid, COLOR_GREY, "Неверная длина пароля.");
        return false;
    }
    
    if(CheckRusText(password, len)) {
        SCM(playerid, COLOR_GREY, "Смените раскладку клавиатуры.");
        return false;
    }
    
    return true;
}

stock bool:ValidateEmail(const email[], len) {
    if(len < MIN_EMAIL_LEN || len > MAX_EMAIL_LEN) {
        SCM(playerid, COLOR_GREY, "Неверная длина электронной почты.");
        return false;
    }
    
    if(strfind(email, "@", false) == -1 || strfind(email, ".", false) == -1) {
        SCM(playerid, COLOR_GREY, "Неверный формат электронной почты.");
        return false;
    }
    
    if(CheckRusText(email, len)) {
        SCM(playerid, COLOR_GREY, "Смените раскладку клавиатуры.");
        return false;
    }
    
    return true;
}

stock bool:ValidateAge(age) {
    if(age < MIN_AGE || age > MAX_AGE) {
        SCM(playerid, COLOR_GREY, "Неверный возраст персонажа.");
        return false;
    }
    return true;
}

stock bool:CheckRusText(const string[], size = sizeof(string)) {
    for(new i = 0; i < size; i++) {
        switch(string[i]) {
            case 'А'..'я', 'Ё', 'ё': return true;
        }
    }
    return false;
}

// =================== [ Функции игрока ] ===================
stock ClearPlayerData(playerid) {
    number_skin{playerid} = 0;
    number_pass{playerid} = 0;
    login_check{playerid} = false;
    
    // Очистка данных игрока
    pInfo[playerid][pID] = 0;
    pInfo[playerid][pMoney] = 0;
    pInfo[playerid][pLevel] = 1;
    pInfo[playerid][pFaction] = 0;
    pInfo[playerid][pRank] = 0;
    pInfo[playerid][pMaterials] = 0;
}

stock KillPlayerTimers(playerid) {
    KillTimer(update_timer[playerid]);
    KillTimer(login_timer[playerid]);
}

stock SetPlayerSpawnLocation(playerid) {
    SetPlayerScore(playerid, pInfo[playerid][pLevel]);
    SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
    SetPlayerPos(playerid, 1154.3717, -1769.2594, 16.5938);
    SetPlayerFacingAngle(playerid, 0.0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);
    GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
}

stock LoadPlayerData(playerid) {
    cache_get_value_name(0, "Pass", pInfo[playerid][pPass], MAX_PASSWORD_LEN + 1);
    cache_get_value_name(0, "Email", pInfo[playerid][pEmail], MAX_EMAIL_LEN + 1);
    cache_get_value_name(0, "Referal", pInfo[playerid][pReferal], MAX_PLAYER_NAME + 1);
    cache_get_value_name(0, "Date Reg", pInfo[playerid][pDateReg], 11);
    
    pInfo[playerid][pNations] = cache_get_value_name_int(0, "Nations");
    pInfo[playerid][pAge] = cache_get_value_name_int(0, "Age");
    pInfo[playerid][pSex] = cache_get_value_name_int(0, "Sex");
    pInfo[playerid][pSkin] = cache_get_value_name_int(0, "Skin");
    pInfo[playerid][pMoney] = cache_get_value_name_int(0, "Money");
    pInfo[playerid][pLevel] = cache_get_value_name_int(0, "Level");
}

stock SavePlayerData(playerid) {
    if(!login_check{playerid} || pInfo[playerid][pID] == 0) return;
    
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `users` SET `Money` = %d, `Level` = %d WHERE `ID` = %d",
        pInfo[playerid][pMoney], pInfo[playerid][pLevel], pInfo[playerid][pID]
    );
    mysql_tquery(dbHandle, query);
}

stock SavePlayerField(playerid, const field[], value) {
    if(!login_check{playerid} || pInfo[playerid][pID] == 0) return;
    
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `users` SET `%s` = %d WHERE `ID` = %d",
        field, value, pInfo[playerid][pID]
    );
    mysql_tquery(dbHandle, query);
}

stock CheckReferalExists(playerid, const name[]) {
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT `ID` FROM `users` WHERE `Name` = '%e' LIMIT 1",
        name
    );
    mysql_tquery(dbHandle, query, "CheckReferal", "ds", playerid, name);
}

stock CheckReferalBonus(playerid) {
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `referal` WHERE `Name` = '%e' LIMIT 1",
        pInfo[playerid][pName]
    );
    mysql_tquery(dbHandle, query, "CheckReferal_2", "d", playerid);
}

stock AttemptLogin(playerid, const password[]) {
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `users` WHERE `ID` = %d AND `Pass` = '%e' LIMIT 1",
        pInfo[playerid][pID], password
    );
    mysql_tquery(dbHandle, query, "PlayerLogin", "d", playerid);
}

stock HandleFailedLogin(playerid) {
    number_pass{playerid}++;
    
    if(number_pass{playerid} >= MAX_LOGIN_ATTEMPTS) {
        Pkick(playerid);
        SCM(playerid, COLOR_RED, "Попытки на ввод пароля закончены. Введите /quit");
        return;
    }
    
    new message[64];
    format(message, sizeof(message), "Неверный пароль. Осталось попыток: %d", 
        MAX_LOGIN_ATTEMPTS - number_pass{playerid});
    SCM(playerid, COLOR_LIGHTRED, message);
    ShowLogin(playerid);
}

// =================== [ Функции скинов ] ===================
stock StartSkinSelection(playerid) {
    SpawnPlayer(playerid);
    
    if(pInfo[playerid][pSex] == 1) {
        SetPlayerSkin(playerid, MaleSkins[0]);
        number_skin{playerid} = 1;
    } else {
        SetPlayerSkin(playerid, FemaleSkins[0]);
        number_skin{playerid} = 1;
    }
    
    for(new i = 0; i < 11; i++) {
        TextDrawShowForPlayer(playerid, select_skin[playerid][i]);
    }
    
    SelectTextDraw(playerid, COLOR_BROWN);
    SetPlayerVirtualWorld(playerid, playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerPos(playerid, 248.6302, 33.8265, 1007.3272);
    SetPlayerFacingAngle(playerid, 35.4503);
    SetPlayerCameraPos(playerid, 245.2390, 36.4504, 1008.5635);
    SetPlayerCameraLookAt(playerid, 248.6302, 33.8265, 1007.3272);
    Freeze(playerid, false);
}

stock ChangeSkin(playerid, direction) {
    number_skin{playerid} += direction;
    
    if(pInfo[playerid][pSex] == 1) {
        if(number_skin{playerid} > MAX_SKIN_MALE) number_skin{playerid} = 1;
        else if(number_skin{playerid} < 1) number_skin{playerid} = MAX_SKIN_MALE;
        
        SetPlayerSkin(playerid, MaleSkins[number_skin{playerid} - 1]);
    } else {
        if(number_skin{playerid} > MAX_SKIN_FEMALE) number_skin{playerid} = 1;
        else if(number_skin{playerid} < 1) number_skin{playerid} = MAX_SKIN_FEMALE;
        
        SetPlayerSkin(playerid, FemaleSkins[number_skin{playerid} - 1]);
    }
}

stock ConfirmSkinSelection(playerid) {
    if(pInfo[playerid][pSex] == 1) {
        pInfo[playerid][pSkin] = MaleSkins[number_skin{playerid} - 1];
    } else {
        pInfo[playerid][pSkin] = FemaleSkins[number_skin{playerid} - 1];
    }
    
    for(new i = 0; i < 11; i++) {
        TextDrawHideForPlayer(playerid, select_skin[playerid][i]);
    }
    
    CancelSelectTextDraw(playerid);
    CompleteRegistration(playerid);
}

stock CompleteRegistration(playerid) {
    // Получаем текущую дату
    new year, month, day;
    getdate(year, month, day);
    format(pInfo[playerid][pDateReg], 11, "%02d.%02d.%d", day, month, year);
    
    // Создаем аккаунт в базе данных
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `users` (`Name`, `Pass`, `Email`, `Referal`, `Date Reg`, `Nations`, `Age`, `Sex`, `Skin`, `Money`, `Level`) \
        VALUES ('%e', '%e', '%e', '%e', '%e', %d, %d, %d, %d, 5000, 1)",
        pInfo[playerid][pName], pInfo[playerid][pPass], pInfo[playerid][pEmail],
        pInfo[playerid][pReferal], pInfo[playerid][pDateReg], pInfo[playerid][pNations],
        pInfo[playerid][pAge], pInfo[playerid][pSex], pInfo[playerid][pSkin]
    );
    mysql_tquery(dbHandle, query, "OnPlayerRegister", "d", playerid);
}

// =================== [ Функции интерьера ] ===================
stock CreateRegistrationInterior() {
    // Создание интерьера для регистрации
    new map_world = -1, map_int = -1;
    
    CreateDynamicObject(19377, 247.991806, 34.998001, 1006.241271, 0.0, 90.0, 0.0, map_world, map_int, -1, 300.0, 300.0);
    CreateDynamicObject(19450, 243.570098, 34.971900, 1007.989501, 0.0, 0.0, 0.0, map_world, map_int, -1, 300.0, 300.0);
    CreateDynamicObject(19450, 248.470397, 30.245599, 1007.989501, 0.0, 0.0, 90.0, map_world, map_int, -1, 300.0, 300.0);
    CreateDynamicObject(19450, 248.424942, 39.656631, 1007.989501, 0.0, 0.0, 90.0, map_world, map_int, -1, 300.0, 300.0);
    CreateDynamicObject(19450, 253.155105, 40.396900, 1005.764526, 0.0, 0.0, 0.0, map_world, map_int, -1, 300.0, 300.0);
    CreateDynamicObject(19450, 253.155105, 30.765899, 1007.989501, 0.0, 0.0, 0.0, map_world, map_int, -1, 300.0, 300.0);
}

stock CreatePlayerTextDraws(playerid) {
    // Создание TextDraw'ов для выбора скина
    select_skin[playerid][0] = TextDrawCreate(535.177124, 334.000000, "usebox");
    TextDrawLetterSize(select_skin[playerid][0], 0.000000, 8.044445);
    TextDrawTextSize(select_skin[playerid][0], 426.696929, 0.000000);
    TextDrawAlignment(select_skin[playerid][0], 1);
    TextDrawColor(select_skin[playerid][0], 0);
    TextDrawUseBox(select_skin[playerid][0], true);
    TextDrawBoxColor(select_skin[playerid][0], 102);
    TextDrawSetShadow(select_skin[playerid][0], 0);
    TextDrawSetOutline(select_skin[playerid][0], 0);
    TextDrawFont(select_skin[playerid][0], 0);

    select_skin[playerid][8] = TextDrawCreate(458.682708, 348.833282, "<");
    TextDrawLetterSize(select_skin[playerid][8], 0.946163, 2.708333);
    TextDrawTextSize(select_skin[playerid][8], 18.935607, 19.916625);
    TextDrawAlignment(select_skin[playerid][8], 2);
    TextDrawColor(select_skin[playerid][8], -1);
    TextDrawSetShadow(select_skin[playerid][8], 0);
    TextDrawSetOutline(select_skin[playerid][8], 2);
    TextDrawBackgroundColor(select_skin[playerid][8], 51);
    TextDrawFont(select_skin[playerid][8], 1);
    TextDrawSetProportional(select_skin[playerid][8], 1);
    TextDrawSetSelectable(select_skin[playerid][8], true);

    select_skin[playerid][9] = TextDrawCreate(510.283172, 349.249938, ">");
    TextDrawLetterSize(select_skin[playerid][9], 0.946163, 2.708333);
    TextDrawTextSize(select_skin[playerid][9], 18.935607, 19.916625);
    TextDrawAlignment(select_skin[playerid][9], 2);
    TextDrawColor(select_skin[playerid][9], -1);
    TextDrawSetShadow(select_skin[playerid][9], 0);
    TextDrawSetOutline(select_skin[playerid][9], 2);
    TextDrawBackgroundColor(select_skin[playerid][9], 51);
    TextDrawFont(select_skin[playerid][9], 1);
    TextDrawSetProportional(select_skin[playerid][9], 1);
    TextDrawSetSelectable(select_skin[playerid][9], true);

    select_skin[playerid][10] = TextDrawCreate(485.045806, 381.750061, "Выбрать");
    TextDrawLetterSize(select_skin[playerid][10], 0.683324, 2.743333);
    TextDrawTextSize(select_skin[playerid][10], 18.935607, 28.916625);
    TextDrawAlignment(select_skin[playerid][10], 2);
    TextDrawColor(select_skin[playerid][10], -1);
    TextDrawSetShadow(select_skin[playerid][10], 0);
    TextDrawSetOutline(select_skin[playerid][10], 2);
    TextDrawBackgroundColor(select_skin[playerid][10], 51);
    TextDrawFont(select_skin[playerid][10], 1);
    TextDrawSetProportional(select_skin[playerid][10], 1);
    TextDrawSetSelectable(select_skin[playerid][10], true);
}

stock DestroyPlayerTextDraws(playerid) {
    for(new i = 0; i < 11; i++) {
        if(select_skin[playerid][i] != Text:INVALID_TEXT_DRAW) {
            TextDrawDestroy(select_skin[playerid][i]);
            select_skin[playerid][i] = Text:INVALID_TEXT_DRAW;
        }
    }
}

// =================== [ MySQL ] ===================
stock ConnectMySQL() {
    dbHandle = mysql_connect(MySQL_Host, MySQL_User, MySQL_Base, MySQL_Pass);
    
    if(mysql_errno(dbHandle) != 0) {
        print("[ERROR] Ошибка подключения к MySQL!");
        return 0;
    }
    
    mysql_set_charset("utf8", dbHandle);
    print("[MySQL] Подключение к базе данных установлено!");
    return 1;
}

// =================== [ Команды администратора ] ===================
CMD:gmx(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return SCM(playerid, COLOR_RED, "У вас нет прав!");
    
    SCMTA(COLOR_RED, "Сервер перезагружается...");
    SetTimer("RestartServer", 2000, false);
    return 1;
}

forward RestartServer();
public RestartServer() {
    SendRconCommand("gmx");
}

CMD:setmoney(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return SCM(playerid, COLOR_RED, "У вас нет прав!");
    
    new targetid, amount;
    if(sscanf(params, "dd", targetid, amount)) return SCM(playerid, COLOR_GREY, "Использование: /setmoney [ID] [сумма]");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Игрок не в сети!");
    
    pInfo[targetid][pMoney] = amount;
    ResetPlayerMoney(targetid);
    GivePlayerMoney(targetid, amount);
    SavePlayerField(targetid, "Money", amount);
    
    new message[128];
    format(message, sizeof(message), "Администратор %s установил вам $%d", pInfo[playerid][pName], amount);
    SCM(targetid, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы установили игроку %s сумму $%d", pInfo[targetid][pName], amount);
    SCM(playerid, COLOR_GREEN, message);
    return 1;
}

// =================== [ Основная функция ] ===================
main() {
    print("HorizonRP v2.0 - Оптимизированная версия");
}