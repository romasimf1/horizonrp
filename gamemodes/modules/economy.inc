// =================== [ Economy System Module ] ===================
// HorizonRP v2.0 - Экономическая система
// Включает: работы, банки, переводы денег, мэрию

#if !defined _INC_economy
#define _INC_economy

// =================== [ Диалоги экономики ] ===================
#define DIALOG_JOB_LIST 1000
#define DIALOG_JOB_INFO 1001
#define DIALOG_JOB_APPLY 1002
#define DIALOG_WORK_MENU 1003
#define DIALOG_BANK_MAIN 1004
#define DIALOG_BANK_TRANSFER 1005
#define DIALOG_BANK_WITHDRAW 1006
#define DIALOG_BANK_DEPOSIT 1007
#define DIALOG_ATM_PIN 1008
#define DIALOG_ATM_MENU 1009
#define DIALOG_CREATE_ACCOUNT 1010
#define DIALOG_SET_PIN 1011

// =================== [ Константы ] ===================
#define MAX_JOBS 50
#define MAX_ATM_LOCATIONS 100
#define MAX_CITY_OFFICES 20
#define WORK_COOLDOWN 300 // 5 минут между работами
#define PAYCHECK_INTERVAL 3600 // 1 час в секундах
#define BANK_TRANSFER_FEE 100 // Комиссия за перевод
#define ATM_WITHDRAW_FEE 50 // Комиссия банкомата

// =================== [ Енумы ] ===================
enum JobData {
    jobID,
    jobName[64],
    jobDescription[256],
    jobMinLevel,
    jobMaxLevel,
    jobBaseSalary,
    jobBonusPerLevel,
    jobRequiredSkin,
    Float:jobLocationX,
    Float:jobLocationY,
    Float:jobLocationZ,
    bool:jobActive
}

enum ATMData {
    atmID,
    atmType, // 1-ATM, 2-Bank
    atmName[64],
    Float:atmX,
    Float:atmY,
    Float:atmZ,
    atmInterior,
    atmVirtualWorld,
    bool:atmActive
}

enum CityOfficeData {
    officeID,
    officeType, // 1-City Hall, 2-Job Center, 3-Licensing
    officeName[64],
    Float:officeX,
    Float:officeY,
    Float:officeZ,
    officeInterior,
    officeVirtualWorld,
    bool:officeActive
}

enum PlayerWorkData {
    workJobID,
    workJobLevel,
    workExperience,
    workTotalEarned,
    workLastWork,
    workInProgress,
    workStartTime
}

// =================== [ Переменные ] ===================
new Jobs[MAX_JOBS][JobData];
new ATMLocations[MAX_ATM_LOCATIONS][ATMData];
new CityOffices[MAX_CITY_OFFICES][CityOfficeData];
new PlayerWork[MAX_PLAYERS][PlayerWorkData];

new totalJobs = 0;
new totalATMs = 0;
new totalOffices = 0;

// Пикапы и объекты
new jobPickups[MAX_JOBS];
new atmPickups[MAX_ATM_LOCATIONS];
new officePickups[MAX_CITY_OFFICES];

// =================== [ Форварды ] ===================
forward LoadJobs();
forward LoadATMLocations();
forward LoadCityOffices();
forward OnJobsLoaded();
forward OnATMsLoaded();
forward OnOfficesLoaded();
forward OnJobLoaded(playerid);
forward OnBankAccountCreated(playerid);
forward OnATMPinCheck(playerid);
forward OnMoneyTransfer(playerid);
forward CheckPlayerPaycheck(playerid);
forward GivePlayerPaycheck(playerid);
forward ProcessWork(playerid);

// =================== [ Функции инициализации ] ===================
stock InitializeEconomySystem() {
    print("[ECONOMY] Загрузка экономической системы...");
    
    LoadJobs();
    LoadATMLocations();
    LoadCityOffices();
    
    // Таймер для проверки зарплат
    SetTimer("CheckPlayerPaycheck", PAYCHECK_INTERVAL * 1000, true);
    
    print("[ECONOMY] Экономическая система загружена!");
    return 1;
}

stock LoadJobs() {
    new query[256];
    format(query, sizeof(query), "SELECT * FROM `jobs` WHERE `IsActive` = 1 ORDER BY `MinLevel` ASC");
    mysql_tquery(dbHandle, query, "OnJobsLoaded");
    return 1;
}

stock LoadATMLocations() {
    new query[256];
    format(query, sizeof(query), "SELECT * FROM `atm_locations` WHERE `IsActive` = 1");
    mysql_tquery(dbHandle, query, "OnATMsLoaded");
    return 1;
}

stock LoadCityOffices() {
    new query[256];
    format(query, sizeof(query), "SELECT * FROM `city_offices` WHERE `IsActive` = 1");
    mysql_tquery(dbHandle, query, "OnOfficesLoaded");
    return 1;
}

// =================== [ Колбэки загрузки ] ===================
public OnJobsLoaded() {
    new rows = cache_num_rows();
    totalJobs = 0;
    
    for(new i = 0; i < rows && i < MAX_JOBS; i++) {
        Jobs[i][jobID] = cache_get_value_int(i, "ID");
        cache_get_value_name(i, "Name", Jobs[i][jobName], 64);
        cache_get_value_name(i, "Description", Jobs[i][jobDescription], 256);
        Jobs[i][jobMinLevel] = cache_get_value_int(i, "MinLevel");
        Jobs[i][jobMaxLevel] = cache_get_value_int(i, "MaxLevel");
        Jobs[i][jobBaseSalary] = cache_get_value_int(i, "BaseSalary");
        Jobs[i][jobBonusPerLevel] = cache_get_value_int(i, "BonusPerLevel");
        Jobs[i][jobRequiredSkin] = cache_get_value_int(i, "RequiredSkin");
        Jobs[i][jobLocationX] = cache_get_value_float(i, "WorkLocationX");
        Jobs[i][jobLocationY] = cache_get_value_float(i, "WorkLocationY");
        Jobs[i][jobLocationZ] = cache_get_value_float(i, "WorkLocationZ");
        Jobs[i][jobActive] = true;
        
        // Создаем пикап для работы
        jobPickups[i] = CreateDynamicPickup(1239, 1, Jobs[i][jobLocationX], Jobs[i][jobLocationY], Jobs[i][jobLocationZ]);
        
        totalJobs++;
    }
    
    printf("[ECONOMY] Загружено %d работ", totalJobs);
    return 1;
}

public OnATMsLoaded() {
    new rows = cache_num_rows();
    totalATMs = 0;
    
    for(new i = 0; i < rows && i < MAX_ATM_LOCATIONS; i++) {
        ATMLocations[i][atmID] = cache_get_value_int(i, "ID");
        ATMLocations[i][atmType] = cache_get_value_int(i, "Type");
        cache_get_value_name(i, "Name", ATMLocations[i][atmName], 64);
        ATMLocations[i][atmX] = cache_get_value_float(i, "PosX");
        ATMLocations[i][atmY] = cache_get_value_float(i, "PosY");
        ATMLocations[i][atmZ] = cache_get_value_float(i, "PosZ");
        ATMLocations[i][atmInterior] = cache_get_value_int(i, "Interior");
        ATMLocations[i][atmVirtualWorld] = cache_get_value_int(i, "VirtualWorld");
        ATMLocations[i][atmActive] = true;
        
        // Создаем пикап
        new pickupModel = (ATMLocations[i][atmType] == 2) ? 1274 : 1274; // Банк или банкомат
        atmPickups[i] = CreateDynamicPickup(pickupModel, 1, ATMLocations[i][atmX], ATMLocations[i][atmY], ATMLocations[i][atmZ]);
        
        totalATMs++;
    }
    
    printf("[ECONOMY] Загружено %d банков и банкоматов", totalATMs);
    return 1;
}

public OnOfficesLoaded() {
    new rows = cache_num_rows();
    totalOffices = 0;
    
    for(new i = 0; i < rows && i < MAX_CITY_OFFICES; i++) {
        CityOffices[i][officeID] = cache_get_value_int(i, "ID");
        CityOffices[i][officeType] = cache_get_value_int(i, "Type");
        cache_get_value_name(i, "Name", CityOffices[i][officeName], 64);
        CityOffices[i][officeX] = cache_get_value_float(i, "PosX");
        CityOffices[i][officeY] = cache_get_value_float(i, "PosY");
        CityOffices[i][officeZ] = cache_get_value_float(i, "PosZ");
        CityOffices[i][officeInterior] = cache_get_value_int(i, "Interior");
        CityOffices[i][officeVirtualWorld] = cache_get_value_int(i, "VirtualWorld");
        CityOffices[i][officeActive] = true;
        
        // Создаем пикап
        officePickups[i] = CreateDynamicPickup(1239, 1, CityOffices[i][officeX], CityOffices[i][officeY], CityOffices[i][officeZ]);
        
        totalOffices++;
    }
    
    printf("[ECONOMY] Загружено %d офисов", totalOffices);
    return 1;
}

// =================== [ Функции работы ] ===================
stock ShowJobsList(playerid) {
    new string[2048], temp[256];
    strcat(string, "Работа\tМин. ур.\tЗарплата\tОписание\n");
    
    for(new i = 0; i < totalJobs; i++) {
        if(!Jobs[i][jobActive]) continue;
        
        new canApply = (pInfo[playerid][pLevel] >= Jobs[i][jobMinLevel]);
        new salary = Jobs[i][jobBaseSalary] + (Jobs[i][jobBonusPerLevel] * pInfo[playerid][pLevel]);
        
        format(temp, sizeof(temp), "%s%s\t%d ур.\t$%d\t%s\n",
            canApply ? "{FFFFFF}" : "{999999}",
            Jobs[i][jobName],
            Jobs[i][jobMinLevel],
            salary,
            Jobs[i][jobDescription]
        );
        strcat(string, temp);
    }
    
    SPD(playerid, DIALOG_JOB_LIST, DSL, "Список доступных работ", string, "Выбрать", "Закрыть");
    return 1;
}

stock ShowJobInfo(playerid, jobIndex) {
    if(jobIndex < 0 || jobIndex >= totalJobs) return 0;
    
    new string[512];
    new salary = Jobs[jobIndex][jobBaseSalary] + (Jobs[jobIndex][jobBonusPerLevel] * pInfo[playerid][pLevel]);
    new canApply = (pInfo[playerid][pLevel] >= Jobs[jobIndex][jobMinLevel]);
    
    format(string, sizeof(string),
        "{FFFFFF}Работа: {FFFF00}%s{FFFFFF}\n\n\
        Описание: %s\n\n\
        Минимальный уровень: {FFFF00}%d{FFFFFF}\n\
        Максимальный уровень: {FFFF00}%d{FFFFFF}\n\
        Зарплата за работу: {00FF00}$%d{FFFFFF}\n\
        Бонус за уровень: {00FF00}+$%d{FFFFFF}\n\n\
        %s",
        Jobs[jobIndex][jobName],
        Jobs[jobIndex][jobDescription],
        Jobs[jobIndex][jobMinLevel],
        Jobs[jobIndex][jobMaxLevel],
        salary,
        Jobs[jobIndex][jobBonusPerLevel],
        canApply ? "{00FF00}Вы можете устроиться на эту работу!" : "{FF0000}Недостаточно уровня для этой работы!"
    );
    
    SPD(playerid, DIALOG_JOB_APPLY, DSM, Jobs[jobIndex][jobName], string, 
        canApply ? "Устроиться" : "Закрыть", "Назад");
        
    PlayerWork[playerid][workJobID] = jobIndex;
    return 1;
}

stock ApplyForJob(playerid, jobIndex) {
    if(jobIndex < 0 || jobIndex >= totalJobs) return 0;
    if(pInfo[playerid][pLevel] < Jobs[jobIndex][jobMinLevel]) {
        SCM(playerid, COLOR_RED, "У вас недостаточно уровня для этой работы!");
        return 0;
    }
    
    if(pInfo[playerid][pCurrentJob] != 0) {
        SCM(playerid, COLOR_RED, "Сначала уволитесь с текущей работы! Используйте /quitjob");
        return 0;
    }
    
    // Сохраняем в базу данных
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `player_jobs` (`UserID`, `JobID`, `JobLevel`, `Experience`) VALUES (%d, %d, 1, 0) \
        ON DUPLICATE KEY UPDATE `IsActive` = 1",
        pInfo[playerid][pID], Jobs[jobIndex][jobID]
    );
    mysql_tquery(dbHandle, query);
    
    // Обновляем данные игрока
    pInfo[playerid][pCurrentJob] = Jobs[jobIndex][jobID];
    pInfo[playerid][pJobLevel] = 1;
    pInfo[playerid][pJobExperience] = 0;
    
    PlayerWork[playerid][workJobID] = jobIndex;
    PlayerWork[playerid][workJobLevel] = 1;
    PlayerWork[playerid][workExperience] = 0;
    
    new message[128];
    format(message, sizeof(message), "Поздравляем! Вы устроились на работу: %s", Jobs[jobIndex][jobName]);
    SCM(playerid, COLOR_GREEN, message);
    
    return 1;
}

stock StartWork(playerid) {
    if(pInfo[playerid][pCurrentJob] == 0) {
        SCM(playerid, COLOR_RED, "У вас нет работы! Обратитесь в центр трудоустройства.");
        return 0;
    }
    
    if(PlayerWork[playerid][workInProgress]) {
        SCM(playerid, COLOR_RED, "Вы уже работаете!");
        return 0;
    }
    
    new currentTime = gettime();
    if(currentTime - PlayerWork[playerid][workLastWork] < WORK_COOLDOWN) {
        new remaining = WORK_COOLDOWN - (currentTime - PlayerWork[playerid][workLastWork]);
        new message[64];
        format(message, sizeof(message), "Подождите %d секунд до следующей работы.", remaining);
        SCM(playerid, COLOR_GREY, message);
        return 0;
    }
    
    // Находим работу по ID
    new jobIndex = -1;
    for(new i = 0; i < totalJobs; i++) {
        if(Jobs[i][jobID] == pInfo[playerid][pCurrentJob]) {
            jobIndex = i;
            break;
        }
    }
    
    if(jobIndex == -1) {
        SCM(playerid, COLOR_RED, "Ошибка: работа не найдена!");
        return 0;
    }
    
    // Проверяем расстояние до рабочего места
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, Jobs[jobIndex][jobLocationX], 
        Jobs[jobIndex][jobLocationY], Jobs[jobIndex][jobLocationZ])) {
        SCM(playerid, COLOR_RED, "Вы должны находиться на рабочем месте!");
        return 0;
    }
    
    // Устанавливаем скин если требуется
    if(Jobs[jobIndex][jobRequiredSkin] != 0) {
        SetPlayerSkin(playerid, Jobs[jobIndex][jobRequiredSkin]);
    }
    
    PlayerWork[playerid][workInProgress] = true;
    PlayerWork[playerid][workStartTime] = currentTime;
    
    SCM(playerid, COLOR_GREEN, "Вы начали работать! Используйте /stopwork чтобы закончить.");
    
    // Запускаем таймер работы
    SetTimerEx("ProcessWork", 30000, false, "i", playerid); // 30 секунд
    
    return 1;
}

public ProcessWork(playerid) {
    if(!IsPlayerConnected(playerid) || !PlayerWork[playerid][workInProgress]) {
        return 1;
    }
    
    new jobIndex = PlayerWork[playerid][workJobID];
    if(jobIndex < 0 || jobIndex >= totalJobs) return 1;
    
    // Рассчитываем зарплату
    new salary = Jobs[jobIndex][jobBaseSalary] + (Jobs[jobIndex][jobBonusPerLevel] * pInfo[playerid][pLevel]);
    
    // Добавляем опыт и деньги
    new expGain = 10 + random(20);
    PlayerWork[playerid][workExperience] += expGain;
    PlayerWork[playerid][workTotalEarned] += salary;
    PlayerWork[playerid][workLastWork] = gettime();
    PlayerWork[playerid][workInProgress] = false;
    
    pInfo[playerid][pMoney] += salary;
    pInfo[playerid][pJobExperience] += expGain;
    pInfo[playerid][pTotalEarned] += salary;
    
    // Проверяем повышение уровня работы
    new requiredExp = PlayerWork[playerid][workJobLevel] * 100;
    if(PlayerWork[playerid][workExperience] >= requiredExp && 
       PlayerWork[playerid][workJobLevel] < Jobs[jobIndex][jobMaxLevel]) {
        PlayerWork[playerid][workJobLevel]++;
        pInfo[playerid][pJobLevel]++;
        
        new message[128];
        format(message, sizeof(message), "Поздравляем! Вы повысились до %d уровня в работе %s!",
            PlayerWork[playerid][workJobLevel], Jobs[jobIndex][jobName]);
        SCM(playerid, COLOR_YELLOW, message);
    }
    
    // Сохраняем в базу
    SavePlayerJobData(playerid);
    
    new message[128];
    format(message, sizeof(message), "Работа завершена! Вы заработали $%d и получили %d опыта.",
        salary, expGain);
    SCM(playerid, COLOR_GREEN, message);
    
    GivePlayerMoney(playerid, salary);
    
    return 1;
}

// =================== [ Банковская система ] ===================
stock ShowBankMenu(playerid) {
    if(!HasBankAccount(playerid)) {
        ShowCreateBankAccount(playerid);
        return 1;
    }
    
    new string[512];
    format(string, sizeof(string),
        "{FFFFFF}Добро пожаловать в Los Santos Bank!\n\n\
        Номер счета: {FFFF00}%s{FFFFFF}\n\
        Баланс: {00FF00}$%d{FFFFFF}\n\n\
        Выберите операцию:",
        pInfo[playerid][pBankAccount],
        GetPlayerBankBalance(playerid)
    );
    
    SPD(playerid, DIALOG_BANK_MAIN, DSL, "Los Santos Bank", 
        "Пополнить счет\nСнять деньги\nПеревести деньги\nИстория операций\nЗакрыть",
        "Выбрать", "Выйти");
    return 1;
}

stock ShowCreateBankAccount(playerid) {
    new string[512];
    format(string, sizeof(string),
        "{FFFFFF}У вас нет банковского счета!\n\n\
        Банковский счет позволяет:\n\
        • Безопасно хранить деньги\n\
        • Переводить деньги другим игрокам\n\
        • Получать проценты на остаток\n\
        • Пользоваться банкоматами\n\n\
        Стоимость открытия счета: {00FF00}$1000{FFFFFF}\n\
        У вас есть: {FFFF00}$%d{FFFFFF}",
        pInfo[playerid][pMoney]
    );
    
    SPD(playerid, DIALOG_CREATE_ACCOUNT, DSM, "Открытие банковского счета", string,
        "Открыть", "Отмена");
    return 1;
}

stock CreateBankAccount(playerid) {
    if(pInfo[playerid][pMoney] < 1000) {
        SCM(playerid, COLOR_RED, "У вас недостаточно денег для открытия счета! Нужно $1000.");
        return 0;
    }
    
    if(HasBankAccount(playerid)) {
        SCM(playerid, COLOR_RED, "У вас уже есть банковский счет!");
        return 0;
    }
    
    // Генерируем номер счета
    new accountNumber[17];
    format(accountNumber, sizeof(accountNumber), "%04d%04d%04d%04d", 
        random(9999), random(9999), random(9999), random(9999));
    
    SPD(playerid, DIALOG_SET_PIN, DSI, "Установка PIN-кода",
        "{FFFFFF}Установите 4-значный PIN-код для вашего счета:\n\n\
        {FFFF00}PIN-код нужен для безопасности ваших операций.{FFFFFF}",
        "Установить", "Отмена");
        
    format(pInfo[playerid][pBankAccount], 17, "%s", accountNumber);
    return 1;
}

stock bool:HasBankAccount(playerid) {
    return (strlen(pInfo[playerid][pBankAccount]) > 0);
}

stock GetPlayerBankBalance(playerid) {
    if(!HasBankAccount(playerid)) return 0;
    
    new query[256], balance = 0;
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT `Balance` FROM `bank_accounts` WHERE `UserID` = %d",
        pInfo[playerid][pID]);
        
    new Cache:result = mysql_query(dbHandle, query);
    if(cache_num_rows()) {
        balance = cache_get_value_int(0, "Balance");
    }
    cache_delete(result);
    
    return balance;
}

// =================== [ Команды ] ===================
CMD:work(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    StartWork(playerid);
    return 1;
}

CMD:stopwork(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    if(!PlayerWork[playerid][workInProgress]) {
        SCM(playerid, COLOR_RED, "Вы не работаете!");
        return 1;
    }
    
    PlayerWork[playerid][workInProgress] = false;
    SCM(playerid, COLOR_YELLOW, "Вы прекратили работу.");
    return 1;
}

CMD:jobs(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    ShowJobsList(playerid);
    return 1;
}

CMD:quitjob(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    if(pInfo[playerid][pCurrentJob] == 0) {
        SCM(playerid, COLOR_RED, "У вас нет работы!");
        return 1;
    }
    
    // Сбрасываем работу
    pInfo[playerid][pCurrentJob] = 0;
    pInfo[playerid][pJobLevel] = 0;
    pInfo[playerid][pJobExperience] = 0;
    
    PlayerWork[playerid][workJobID] = -1;
    PlayerWork[playerid][workInProgress] = false;
    
    SCM(playerid, COLOR_YELLOW, "Вы уволились с работы.");
    return 1;
}

CMD:bank(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    // Проверяем, находится ли игрок рядом с банком
    new nearBank = false;
    for(new i = 0; i < totalATMs; i++) {
        if(ATMLocations[i][atmType] == 2 && ATMLocations[i][atmActive]) {
            if(IsPlayerInRangeOfPoint(playerid, 3.0, ATMLocations[i][atmX], 
                ATMLocations[i][atmY], ATMLocations[i][atmZ])) {
                nearBank = true;
                break;
            }
        }
    }
    
    if(!nearBank) {
        SCM(playerid, COLOR_RED, "Вы должны находиться рядом с банком!");
        return 1;
    }
    
    ShowBankMenu(playerid);
    return 1;
}

CMD:atm(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    // Проверяем, находится ли игрок рядом с банкоматом
    new nearATM = false;
    for(new i = 0; i < totalATMs; i++) {
        if(ATMLocations[i][atmActive]) {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, ATMLocations[i][atmX], 
                ATMLocations[i][atmY], ATMLocations[i][atmZ])) {
                nearATM = true;
                break;
            }
        }
    }
    
    if(!nearATM) {
        SCM(playerid, COLOR_RED, "Вы должны находиться рядом с банкоматом!");
        return 1;
    }
    
    if(!HasBankAccount(playerid)) {
        SCM(playerid, COLOR_RED, "У вас нет банковского счета! Обратитесь в банк.");
        return 1;
    }
    
    SPD(playerid, DIALOG_ATM_PIN, DSP, "Банкомат - Введите PIN",
        "{FFFFFF}Введите ваш 4-значный PIN-код:", "Войти", "Отмена");
    return 1;
}

// =================== [ Обработка диалогов ] ===================
stock OnEconomyDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_JOB_LIST: {
            if(!response) return 1;
            if(listitem < 0 || listitem >= totalJobs) return 1;
            
            ShowJobInfo(playerid, listitem);
        }
        
        case DIALOG_JOB_APPLY: {
            if(!response) {
                ShowJobsList(playerid);
                return 1;
            }
            
            ApplyForJob(playerid, PlayerWork[playerid][workJobID]);
        }
        
        case DIALOG_CREATE_ACCOUNT: {
            if(!response) return 1;
            
            CreateBankAccount(playerid);
        }
        
        case DIALOG_SET_PIN: {
            if(!response) return 1;
            
            if(strlen(inputtext) != 4 || !IsNumeric(inputtext)) {
                SCM(playerid, COLOR_RED, "PIN-код должен состоять из 4 цифр!");
                SPD(playerid, DIALOG_SET_PIN, DSI, "Установка PIN-кода",
                    "{FFFFFF}Установите 4-значный PIN-код для вашего счета:",
                    "Установить", "Отмена");
                return 1;
            }
            
            // Создаем счет в базе данных
            new query[512];
            mysql_format(dbHandle, query, sizeof(query),
                "INSERT INTO `bank_accounts` (`UserID`, `AccountNumber`, `Balance`, `PIN`) VALUES (%d, '%e', 0, '%e')",
                pInfo[playerid][pID], pInfo[playerid][pBankAccount], inputtext);
            mysql_tquery(dbHandle, query, "OnBankAccountCreated", "d", playerid);
            
            pInfo[playerid][pMoney] -= 1000;
            GivePlayerMoney(playerid, -1000);
            
            SCM(playerid, COLOR_GREEN, "Банковский счет успешно создан! Снято $1000 за обслуживание.");
        }
        
                 case DIALOG_BANK_MAIN: {
            if(!response) return 1;
            
            switch(listitem) {
                case 0: { // Пополнить
                    new string[256];
                    format(string, sizeof(string), 
                        "{FFFFFF}Введите сумму для пополнения счета:\n\n\
                        {FFFF00}У вас в кармане: $%d{FFFFFF}",
                        pInfo[playerid][pMoney]);
                    SPD(playerid, DIALOG_BANK_DEPOSIT, DSI, "Пополнение счета", string, "Пополнить", "Назад");
                }
                case 1: { // Снять
                    new string[256];
                    format(string, sizeof(string),
                        "{FFFFFF}Введите сумму для снятия:\n\n\
                        {FFFF00}На счету: $%d{FFFFFF}",
                        GetPlayerBankBalance(playerid));
                    SPD(playerid, DIALOG_BANK_WITHDRAW, DSI, "Снятие денег", string, "Снять", "Назад");
                }
                case 2: { // Перевести
                    new string[256];
                    format(string, sizeof(string),
                        "{FFFFFF}Введите ID игрока и сумму через пробел:\n\
                        Пример: 5 1000\n\n\
                        {FFFF00}Комиссия: $%d{FFFFFF}",
                        BANK_TRANSFER_FEE);
                    SPD(playerid, DIALOG_BANK_TRANSFER, DSI, "Перевод денег", string, "Перевести", "Назад");
                }
            }
        }
        
        case DIALOG_BANK_DEPOSIT: {
            if(!response) {
                ShowBankMenu(playerid);
                return 1;
            }
            
            new amount = strval(inputtext);
            if(amount <= 0) {
                SCM(playerid, COLOR_RED, "Введите корректную сумму!");
                return 1;
            }
            
            if(amount > pInfo[playerid][pMoney]) {
                SCM(playerid, COLOR_RED, "У вас недостаточно денег!");
                return 1;
            }
            
            // Переводим деньги на счет
            new query[256];
            mysql_format(dbHandle, query, sizeof(query),
                "UPDATE `bank_accounts` SET `Balance` = `Balance` + %d WHERE `UserID` = %d",
                amount, pInfo[playerid][pID]);
            mysql_tquery(dbHandle, query);
            
            // Записываем транзакцию
            mysql_format(dbHandle, query, sizeof(query),
                "INSERT INTO `bank_transactions` (`ToAccountID`, `Amount`, `TransactionType`, `Description`) \
                SELECT `ID`, %d, 'deposit', 'Пополнение счета через банк' FROM `bank_accounts` WHERE `UserID` = %d",
                amount, pInfo[playerid][pID]);
            mysql_tquery(dbHandle, query);
            
            pInfo[playerid][pMoney] -= amount;
            GivePlayerMoney(playerid, -amount);
            
            new message[128];
            format(message, sizeof(message), "Вы пополнили счет на $%d", amount);
            SCM(playerid, COLOR_GREEN, message);
            
            ShowBankMenu(playerid);
        }
        
        case DIALOG_BANK_WITHDRAW: {
            if(!response) {
                ShowBankMenu(playerid);
                return 1;
            }
            
            new amount = strval(inputtext);
            if(amount <= 0) {
                SCM(playerid, COLOR_RED, "Введите корректную сумму!");
                return 1;
            }
            
            new balance = GetPlayerBankBalance(playerid);
            if(amount > balance) {
                SCM(playerid, COLOR_RED, "На счету недостаточно средств!");
                return 1;
            }
            
            // Снимаем деньги со счета
            new query[256];
            mysql_format(dbHandle, query, sizeof(query),
                "UPDATE `bank_accounts` SET `Balance` = `Balance` - %d WHERE `UserID` = %d",
                amount, pInfo[playerid][pID]);
            mysql_tquery(dbHandle, query);
            
            // Записываем транзакцию
            mysql_format(dbHandle, query, sizeof(query),
                "INSERT INTO `bank_transactions` (`FromAccountID`, `Amount`, `TransactionType`, `Description`) \
                SELECT `ID`, %d, 'withdraw', 'Снятие денег через банк' FROM `bank_accounts` WHERE `UserID` = %d",
                amount, pInfo[playerid][pID]);
            mysql_tquery(dbHandle, query);
            
            pInfo[playerid][pMoney] += amount;
            GivePlayerMoney(playerid, amount);
            
            new message[128];
            format(message, sizeof(message), "Вы сняли со счета $%d", amount);
            SCM(playerid, COLOR_GREEN, message);
            
            ShowBankMenu(playerid);
        }
        
        case DIALOG_BANK_TRANSFER: {
            if(!response) {
                ShowBankMenu(playerid);
                return 1;
            }
            
            new targetid, amount;
            if(sscanf(inputtext, "dd", targetid, amount)) {
                SCM(playerid, COLOR_RED, "Использование: ID сумма (например: 5 1000)");
                return 1;
            }
            
            if(amount <= 0) {
                SCM(playerid, COLOR_RED, "Введите корректную сумму!");
                return 1;
            }
            
            if(!IsPlayerConnected(targetid)) {
                SCM(playerid, COLOR_RED, "Игрок не в сети!");
                return 1;
            }
            
            if(targetid == playerid) {
                SCM(playerid, COLOR_RED, "Нельзя переводить деньги самому себе!");
                return 1;
            }
            
            if(!HasBankAccount(targetid)) {
                SCM(playerid, COLOR_RED, "У получателя нет банковского счета!");
                return 1;
            }
            
            new balance = GetPlayerBankBalance(playerid);
            new totalAmount = amount + BANK_TRANSFER_FEE;
            
            if(totalAmount > balance) {
                new message[128];
                format(message, sizeof(message), "Недостаточно средств! Нужно $%d (включая комиссию $%d)", 
                    totalAmount, BANK_TRANSFER_FEE);
                SCM(playerid, COLOR_RED, message);
                return 1;
            }
            
            // Выполняем перевод
            ProcessMoneyTransfer(playerid, targetid, amount);
            ShowBankMenu(playerid);
        }
        
        case DIALOG_ATM_PIN: {
            if(!response) return 1;
            
            if(strlen(inputtext) != 4 || !IsNumeric(inputtext)) {
                SCM(playerid, COLOR_RED, "PIN-код должен состоять из 4 цифр!");
                return 1;
            }
            
            // Проверяем PIN в базе данных
            new query[256];
            mysql_format(dbHandle, query, sizeof(query),
                "SELECT `Balance` FROM `bank_accounts` WHERE `UserID` = %d AND `PIN` = '%e'",
                pInfo[playerid][pID], inputtext);
            mysql_tquery(dbHandle, query, "OnATMPinCheck", "d", playerid);
        }
        
        case DIALOG_ATM_MENU: {
            if(!response) return 1;
            
            switch(listitem) {
                case 0: { // Баланс
                    new message[128];
                    format(message, sizeof(message), "Ваш баланс: $%d", GetPlayerBankBalance(playerid));
                    SCM(playerid, COLOR_GREEN, message);
                }
                case 1: { // Снять деньги
                    new string[256];
                    format(string, sizeof(string),
                        "{FFFFFF}Введите сумму для снятия:\n\n\
                        {FFFF00}На счету: $%d{FFFFFF}\n\
                        {FFFF00}Комиссия: $%d{FFFFFF}",
                        GetPlayerBankBalance(playerid), ATM_WITHDRAW_FEE);
                    SPD(playerid, DIALOG_BANK_WITHDRAW, DSI, "Банкомат - Снятие", string, "Снять", "Назад");
                }
            }
        }
    }
    return 1;
}

// =================== [ Вспомогательные функции ] ===================
stock SavePlayerJobData(playerid) {
    if(!login_check{playerid} || pInfo[playerid][pID] == 0) return;
    
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `users` SET `CurrentJob` = %d, `JobLevel` = %d, `JobExperience` = %d, `TotalEarned` = %d WHERE `ID` = %d",
        pInfo[playerid][pCurrentJob], pInfo[playerid][pJobLevel], 
        pInfo[playerid][pJobExperience], pInfo[playerid][pTotalEarned], pInfo[playerid][pID]);
    mysql_tquery(dbHandle, query);
}

stock IsNumeric(const string[]) {
    new length = strlen(string);
    if(length == 0) return false;
    
    for(new i = 0; i < length; i++) {
        if(string[i] < '0' || string[i] > '9') return false;
    }
    return true;
}

public CheckPlayerPaycheck(playerid) {
    // Эта функция вызывается каждый час для всех игроков
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(!IsPlayerConnected(i) || !login_check{i}) continue;
        if(pInfo[i][pCurrentJob] == 0) continue;
        
        GivePlayerPaycheck(i);
    }
    return 1;
}

public GivePlayerPaycheck(playerid) {
    if(pInfo[playerid][pCurrentJob] == 0) return 0;
    
    // Находим работу
    new jobIndex = -1;
    for(new i = 0; i < totalJobs; i++) {
        if(Jobs[i][jobID] == pInfo[playerid][pCurrentJob]) {
            jobIndex = i;
            break;
        }
    }
    
    if(jobIndex == -1) return 0;
    
    new paycheck = (Jobs[jobIndex][jobBaseSalary] / 4) + (Jobs[jobIndex][jobBonusPerLevel] * pInfo[playerid][pJobLevel] / 4);
    
    pInfo[playerid][pMoney] += paycheck;
    pInfo[playerid][pPayCheck] += paycheck;
    pInfo[playerid][pTotalEarned] += paycheck;
    
    GivePlayerMoney(playerid, paycheck);
    
    new message[128];
    format(message, sizeof(message), "Зарплата: вы получили $%d за работу %s", paycheck, Jobs[jobIndex][jobName]);
    SCM(playerid, COLOR_GREEN, message);
    
    return 1;
}

// =================== [ Дополнительные функции ] ===================
stock ProcessMoneyTransfer(playerid, targetid, amount) {
    // Снимаем деньги с отправителя
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `bank_accounts` SET `Balance` = `Balance` - %d WHERE `UserID` = %d",
        amount + BANK_TRANSFER_FEE, pInfo[playerid][pID]);
    mysql_tquery(dbHandle, query);
    
    // Добавляем деньги получателю
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `bank_accounts` SET `Balance` = `Balance` + %d WHERE `UserID` = %d",
        amount, pInfo[targetid][pID]);
    mysql_tquery(dbHandle, query);
    
    // Записываем транзакции
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `bank_transactions` (`FromAccountID`, `ToAccountID`, `Amount`, `TransactionType`, `Description`, `Fee`) \
        SELECT f.ID, t.ID, %d, 'transfer', 'Перевод между игроками', %d \
        FROM `bank_accounts` f, `bank_accounts` t \
        WHERE f.UserID = %d AND t.UserID = %d",
        amount, BANK_TRANSFER_FEE, pInfo[playerid][pID], pInfo[targetid][pID]);
    mysql_tquery(dbHandle, query);
    
    // Уведомления
    new message[128];
    format(message, sizeof(message), "Вы перевели $%d игроку %s (комиссия $%d)", 
        amount, pInfo[targetid][pName], BANK_TRANSFER_FEE);
    SCM(playerid, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы получили банковский перевод $%d от %s", 
        amount, pInfo[playerid][pName]);
    SCM(targetid, COLOR_GREEN, message);
    
    return 1;
}

public OnATMPinCheck(playerid) {
    new rows = cache_num_rows();
    
    if(!rows) {
        SCM(playerid, COLOR_RED, "Неверный PIN-код!");
        return 1;
    }
    
    // PIN верный, показываем меню банкомата
    SPD(playerid, DIALOG_ATM_MENU, DSL, "Банкомат", 
        "Проверить баланс\nСнять деньги\nВыйти", "Выбрать", "Отмена");
    return 1;
}

public OnBankAccountCreated(playerid) {
    SCM(playerid, COLOR_GREEN, "Банковский счет успешно создан!");
    return 1;
}

// =================== [ Дополнительные команды ] ===================
CMD:pay(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    new targetid, amount;
    if(sscanf(params, "dd", targetid, amount)) {
        SCM(playerid, COLOR_GREY, "Использование: /pay [ID] [сумма]");
        return 1;
    }
    
    if(amount <= 0) {
        SCM(playerid, COLOR_RED, "Введите корректную сумму!");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid)) {
        SCM(playerid, COLOR_RED, "Игрок не в сети!");
        return 1;
    }
    
    if(targetid == playerid) {
        SCM(playerid, COLOR_RED, "Нельзя переводить деньги самому себе!");
        return 1;
    }
    
    if(amount > pInfo[playerid][pMoney]) {
        SCM(playerid, COLOR_RED, "У вас недостаточно денег!");
        return 1;
    }
    
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid, x1, y1, z1);
    GetPlayerPos(targetid, x2, y2, z2);
    
    if(GetDistanceBetweenPoints(x1, y1, z1, x2, y2, z2) > 5.0) {
        SCM(playerid, COLOR_RED, "Вы должны находиться рядом с игроком!");
        return 1;
    }
    
    // Передаем наличные
    pInfo[playerid][pMoney] -= amount;
    pInfo[targetid][pMoney] += amount;
    
    GivePlayerMoney(playerid, -amount);
    GivePlayerMoney(targetid, amount);
    
    new message[128];
    format(message, sizeof(message), "Вы передали $%d игроку %s", amount, pInfo[targetid][pName]);
    SCM(playerid, COLOR_GREEN, message);
    
    format(message, sizeof(message), "Вы получили $%d от игрока %s", amount, pInfo[playerid][pName]);
    SCM(targetid, COLOR_GREEN, message);
    
    return 1;
}

CMD:stats(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    new string[1024];
    new jobName[64] = "Безработный";
    
    // Получаем название работы
    if(pInfo[playerid][pCurrentJob] != 0) {
        for(new i = 0; i < totalJobs; i++) {
            if(Jobs[i][jobID] == pInfo[playerid][pCurrentJob]) {
                format(jobName, sizeof(jobName), "%s", Jobs[i][jobName]);
                break;
            }
        }
    }
    
    format(string, sizeof(string),
        "{FFFFFF}======== {FFFF00}Статистика игрока{FFFFFF} ========\n\
        Имя: {FFFF00}%s{FFFFFF}\n\
        Уровень: {FFFF00}%d{FFFFFF}\n\
        Деньги в кармане: {00FF00}$%d{FFFFFF}\n\
        Банковский счет: {FFFF00}%s{FFFFFF}\n\
        Баланс банка: {00FF00}$%d{FFFFFF}\n\
        Работа: {FFFF00}%s{FFFFFF}\n\
        Уровень работы: {FFFF00}%d{FFFFFF}\n\
        Опыт работы: {FFFF00}%d{FFFFFF}\n\
        Всего заработано: {00FF00}$%d{FFFFFF}\n\
        Фракция: {FFFF00}%s{FFFFFF}",
        pInfo[playerid][pName],
        pInfo[playerid][pLevel],
        pInfo[playerid][pMoney],
        HasBankAccount(playerid) ? pInfo[playerid][pBankAccount] : "Нет",
        GetPlayerBankBalance(playerid),
        jobName,
        pInfo[playerid][pJobLevel],
        pInfo[playerid][pJobExperience],
        pInfo[playerid][pTotalEarned],
        pInfo[playerid][pFaction] ? "Есть" : "Нет"
    );
    
    SPD(playerid, -1, DSM, "Статистика", string, "Закрыть", "");
    return 1;
}

CMD:findatm(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid, playerX, playerY, playerZ);
    
    new closest = -1;
    new Float:closestDistance = 999999.0;
    
    for(new i = 0; i < totalATMs; i++) {
        if(!ATMLocations[i][atmActive]) continue;
        
        new Float:distance = GetDistanceBetweenPoints(playerX, playerY, playerZ,
            ATMLocations[i][atmX], ATMLocations[i][atmY], ATMLocations[i][atmZ]);
            
        if(distance < closestDistance) {
            closestDistance = distance;
            closest = i;
        }
    }
    
    if(closest != -1) {
        SetPlayerCheckpoint(playerid, ATMLocations[closest][atmX], 
            ATMLocations[closest][atmY], ATMLocations[closest][atmZ], 3.0);
            
        new message[128];
        format(message, sizeof(message), "Ближайший %s отмечен на карте (%.1fm)", 
            ATMLocations[closest][atmType] == 2 ? "банк" : "банкомат", closestDistance);
        SCM(playerid, COLOR_GREEN, message);
    } else {
        SCM(playerid, COLOR_RED, "Банкоматы не найдены!");
    }
    
    return 1;
}

CMD:findjob(playerid, params[]) {
    if(!login_check{playerid}) return SCM(playerid, COLOR_GREY, "Вы не авторизованы.");
    
    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid, playerX, playerY, playerZ);
    
    new closest = -1;
    new Float:closestDistance = 999999.0;
    
    for(new i = 0; i < totalJobs; i++) {
        if(!Jobs[i][jobActive]) continue;
        
        new Float:distance = GetDistanceBetweenPoints(playerX, playerY, playerZ,
            Jobs[i][jobLocationX], Jobs[i][jobLocationY], Jobs[i][jobLocationZ]);
            
        if(distance < closestDistance) {
            closestDistance = distance;
            closest = i;
        }
    }
    
    if(closest != -1) {
        SetPlayerCheckpoint(playerid, Jobs[closest][jobLocationX], 
            Jobs[closest][jobLocationY], Jobs[closest][jobLocationZ], 5.0);
            
        new message[128];
        format(message, sizeof(message), "Ближайшая работа '%s' отмечена на карте (%.1fm)", 
            Jobs[closest][jobName], closestDistance);
        SCM(playerid, COLOR_GREEN, message);
    } else {
        SCM(playerid, COLOR_RED, "Работы не найдены!");
    }
    
    return 1;
}

// Вспомогательная функция для расстояния между точками

stock Float:GetDistanceBetweenPoints(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2) {
    return Float:sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)) + ((z2-z1)*(z2-z1)));
}

#endif