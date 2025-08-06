#include "modules/grove.inc"
// == == == == [ Èíêëóäû ] == == == ==
#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <streamer>
#include <foreach>
// == == == == [ MySQL ÁÄ ] == == == ==
#define MySQL_Host "127.0.0.1"
#define MySQL_User "root"
#define MySQL_Base "new"
#define MySQL_Pass ""
// == == == == [ Äèàëîãè ] == == == ==
#define SPD ShowPlayerDialog
#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define DSL DIALOG_STYLE_LIST
#define DSI DIALOG_STYLE_INPUT
#define DSM DIALOG_STYLE_MSGBOX
#define DSP DIALOG_STYLE_PASSWORD
// == == == == [ Öâåòà ] == == == ==
#define Color_Brown 0xA52A2AFF
#define Color_Blue 0x00BFFFFF
#define Color_Crimson 0xDC143CFF
#define Color_Chocolate 0xD2691EFF
#define Color_FireBrick 0xB22222FF
#define Color_Grey 0x999999FF
#define Color_Green 0x008000FF
#define Color_LimeGreen 0x00FF00FF
#define Color_Maroon 0x800000FF
#define Color_Orange 0xDF8600FF
#define Color_OrangeRed 0xFF4500FF
#define Color_Purple 0x800080FF
#define Color_Red 0xFF0000FF
#define Color_White 0xFFFFFFFF
#define Color_Yellow 0xFFFF00FF
#define Color_LightRed 0xFF463CFF
// == == == == [ Äåôàéíû ] == == == ==
#define Freeze(%0,%1) TogglePlayerControllable(%0, %1)
#define Pkick(%0) SetTimerEx("TimeKick", 80, false, "i", %0)
#if !defined isnull
#define isnull(%0) ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif
new GroveWarehouse = 0,
    bool:GroveWarehouseLocked = false;
        pFaction,
        pRank,
        pMaterials
// == == == == [ Ôîðâðàäû ] == == == ==
forward PlayerCheck(playerid);
forward PlayerLogin(playerid);
forward CheckReferal(playerid, name[]);
forward CheckReferal_2(playerid);
forward CheckLogin(playerid);
forward TimeKick(playerid);
forward UpdateTime(playerid);
forward GetID(playerid);
forward FastSpawn(playerid);
// == == == == [ Ïåðåìåííûå ] == == == ==
new dbHandle,
    number_skin[MAX_PLAYERS char],
    number_pass[MAX_PLAYERS char],
    
    Text: select_skin[MAX_PLAYERS][11],
    update_timer[MAX_PLAYERS],
    login_timer[MAX_PLAYERS],
    
    bool: login_check[MAX_PLAYERS char];
// == == == == [ Èíôîðìàöèÿ Èãðîêà ] == == == ==
enum player
{
	pID,
	pName[MAX_PLAYER_NAME+1],
	pPass[32+1],
	pEmail[46+1],
	pReferal[MAX_PLAYER_NAME+1],
	pDateReg[10+1],
	pNations,
	pAge,
	pSex,
	pSkin,
	pMoney,
	pLevel
}
new pInfo[MAX_PLAYERS][player];
// == == == == [ Ïàáëèêè ] == == == ==
public OnGameModeInit()
{
	SetGameModeText("Role Play");
	ConnectMySQL();
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
	ShowNameTags(true);
	SetNameTagDrawDistance(20.0);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	
	// == == == [ Èíòåðüåð Ðåãèñòðàöèè/Àâòîðèçàöèè ] == == ==
	new tmpobjid, map_world = -1, map_int = -1;
	tmpobjid = CreateDynamicObject(19377, 247.991806, 34.998001, 1006.241271, 0.000000, 90.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-80-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19450, 243.570098, 34.971900, 1007.989501, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(19450, 248.470397, 30.245599, 1007.989501, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(19450, 248.424942, 39.656631, 1007.989501, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 39.667198, 1008.629821, 0.000000, 180.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(19450, 253.155105, 40.396900, 1005.764526, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(19450, 253.155105, 30.765899, 1007.989501, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.192398, 37.713199, 1010.343811, 0.000000, 180.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 37.470199, 1010.343811, 0.000000, 180.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.192398, 35.525199, 1008.629821, 0.000000, 180.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 36.585201, 1009.670776, 0.000000, 180.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.192398, 38.607200, 1009.670776, 0.000000, 180.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 37.591201, 1008.687805, -90.000000, 90.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.192398, 38.417198, 1007.451782, 90.000000, 90.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.192398, 36.183200, 1007.451782, 90.000000, 90.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 39.851200, 1009.787780, -90.000000, 90.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 253.168395, 35.334201, 1009.787780, -90.000000, 90.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18835, "mickytextures", "whiteforletters", 0x00000000);
	tmpobjid = CreateDynamicObject(19431, 245.793411, 30.620260, 1007.989501, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3945, "bistro_alpha", "creme128", 0x00000000);
	tmpobjid = CreateDynamicObject(19878, 246.076507, 30.526100, 1006.757202, 0.000000, 73.100097, 42.840000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 10041, "archybuild10", "whitedecosfe4", 0x00000000);
	tmpobjid = CreateDynamicObject(2123, 250.584747, 32.671661, 1006.878417, 0.000000, 0.000000, 174.420227, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14385, "trailerkb", "tr_floor2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 6060, "shops2_law", "venshade03_law", 0x00000000);
	tmpobjid = CreateDynamicObject(2123, 252.482543, 32.319801, 1006.878417, 0.000000, 0.000000, -7.739998, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14385, "trailerkb", "tr_floor2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 6060, "shops2_law", "venshade03_law", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	tmpobjid = CreateDynamicObject(2123, 251.515731, 33.748291, 1006.878417, 0.000000, 0.000000, 81.359939, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14385, "trailerkb", "tr_floor2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 6060, "shops2_law", "venshade03_law", 0x00000000);
	tmpobjid = CreateDynamicObject(19916, 252.774307, 34.942501, 1006.243591, 0.000000, 0.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 14803, "bdupsnew", "Bdup2_Artex", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 3437, "ballypillar01", "ballywall01_64", 0x00000000);
	tmpobjid = CreateDynamicObject(19431, 252.266998, 35.493801, 1007.989501, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3945, "bistro_alpha", "creme128", 0x00000000);
	tmpobjid = CreateDynamicObject(948, 252.729293, 39.250640, 1006.327209, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 3, 18757, "vcinteriors", "dts_elevator_ceiling", 0x00000000);
	tmpobjid = CreateDynamicObject(948, 252.729293, 35.846599, 1006.327209, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 3, 18757, "vcinteriors", "dts_elevator_ceiling", 0x00000000);
	tmpobjid = CreateDynamicObject(19431, 244.481353, 36.768760, 1007.989501, 0.000000, 0.000000, 121.320022, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 246.476394, 39.693000, 1006.395812, 0.000000, 180.000000, 152.520095, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.146606, 37.085498, 1007.355773, 0.000000, 180.000000, -25.440000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.125595, 37.095500, 1009.588806, 0.000000, 0.000000, -25.440000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(19431, 243.040298, 36.364898, 1007.989501, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 7488, "vegasdwntwn1", "vgnstonewall1_256", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.719696, 38.193298, 1006.263793, 90.000000, 90.000000, 62.459999, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 246.753692, 40.174301, 1006.263793, 90.000000, 90.000000, 62.459999, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.695693, 38.199298, 1009.780822, -89.940002, 89.879997, 62.459999, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 246.719696, 40.173301, 1009.780822, -89.940002, 89.879997, 62.459999, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 246.476394, 39.693000, 1008.626770, 0.000000, 180.000000, 152.520095, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 1677, "wshxrefhse2", "yellowbeige_128", 0x00000000);
	tmpobjid = CreateDynamicObject(948, 243.902862, 36.032028, 1006.328735, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 3, 18757, "vcinteriors", "dts_elevator_ceiling", 0x00000000);
	tmpobjid = CreateDynamicObject(2631, 249.768112, 37.315521, 1006.308471, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 19844, "metalpanels", "metalpanel2", 0x00000000);
	tmpobjid = CreateDynamicObject(2842, 246.801513, 30.390031, 1006.328796, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 4828, "airport3_las", "gnhotelwall02_128", 0x00000000);
	tmpobjid = CreateDynamicObject(2315, 249.071701, 37.363800, 1006.340576, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 19082, "laserpointer4", "laserbeam-4-64x64", 0x00000000);
	tmpobjid = CreateDynamicObject(19934, 251.572692, 35.506801, 1006.328918, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 5040, "shopliquor_las", "lasjmliq1", 0x00000000);
	tmpobjid = CreateDynamicObject(19934, 251.572692, 35.506801, 1008.701904, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 5040, "shopliquor_las", "lasjmliq1", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 251.419799, 35.509799, 1007.898071, 0.000000, 180.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3435, "motel01sign", "vegasmotelsign03_128", 0x00000000);
	tmpobjid = CreateDynamicObject(19934, 245.794998, 31.381900, 1005.835021, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 5040, "shopliquor_las", "lasjmliq1", 0x00000000);
	tmpobjid = CreateDynamicObject(19934, 245.796997, 31.381900, 1009.190979, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 5040, "shopliquor_las", "lasjmliq1", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.802307, 31.545400, 1007.917968, 0.000000, 180.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3435, "motel01sign", "vegasmotelsign03_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1897, 245.778305, 31.545400, 1010.121520, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3435, "motel01sign", "vegasmotelsign03_128", 0x00000000);
	tmpobjid = CreateDynamicObject(1706, 249.312805, 39.018909, 1006.328918, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 19597, "lsbeachside", "wall7-256x256", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18901, "matclothes", "beretblk", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19004, "roundbuilding1", "stonewalltile4", 0x00000000);
	tmpobjid = CreateDynamicObject(19477, 247.338363, 30.848352, 1006.359741, 0.000000, -89.299949, -90.199981, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(tmpobjid, 0, "_______", 140, "Ariel", 85, 0, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19477, 247.338821, 30.978340, 1006.361328, 0.000000, -89.299949, -90.199981, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(tmpobjid, 0, "Welcome", 140, "Ariel", 80, 0, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(1734, 251.378692, 32.527801, 1009.675476, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3615, "beachhut", "asanmonbhut2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14803, "bdupsnew", "Bdup2_Artex", 0x00000000);
	tmpobjid = CreateDynamicObject(19786, 250.752899, 30.328399, 1008.182373, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-40-percent", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 18646, "matcolours", "grey-95-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(2081, 250.266601, 30.275199, 1006.301879, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 18800, "mroadhelix1", "road1-3", 0x00000000);
	tmpobjid = CreateDynamicObject(2030, 251.384567, 32.532619, 1006.726074, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2059, 250.426696, 30.520099, 1006.442810, 0.000000, 0.000000, 37.619998, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1841, 249.316772, 30.276500, 1007.586486, 0.000000, -12.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(9248, 203.829803, 41.609100, 1006.492980, 0.000000, 0.000000, 236.940093, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1536, 246.561019, 30.292381, 1006.267150, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2694, 245.376556, 30.590986, 1006.433898, -0.199999, -0.099999, 83.298019, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19325, 253.168395, 38.892101, 1007.920776, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2462, 243.762207, 30.374200, 1005.009094, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2694, 244.007797, 30.570898, 1006.633605, 0.000000, 0.000000, 91.498001, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1841, 252.196792, 30.276500, 1007.586486, 0.000000, -12.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2396, 245.350097, 30.637460, 1007.853271, 0.000000, 0.000000, 183.980102, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(18951, 244.088287, 30.550710, 1007.240905, -14.819998, -94.260101, -39.900009, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19814, 248.382293, 39.518299, 1006.571716, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19814, 253.055999, 34.390998, 1006.571716, 0.000000, 0.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19814, 249.352905, 30.337999, 1006.571716, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19829, 246.352203, 30.334299, 1007.654418, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11744, 251.373626, 33.096321, 1007.128173, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11744, 251.968246, 32.485088, 1007.128173, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11744, 250.855117, 32.589950, 1007.128173, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(14793, 247.224899, 35.662689, 1009.640686, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19377, 247.991806, 34.998001, 1009.817321, 0.000000, 90.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19603, 246.326904, 39.374000, 1008.375000, 0.000000, 90.000000, 152.459899, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19325, 246.715499, 40.152400, 1007.920776, 0.000000, 0.000000, 152.459899, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19630, 245.839599, 38.417098, 1007.675170, 0.000000, -7.756000, 63.476001, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19630, 245.761398, 38.265499, 1008.572082, 0.000000, 23.166000, 63.476001, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1599, 245.592407, 37.938499, 1007.053588, -9.585000, 16.139999, -26.399999, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1600, 246.124801, 39.089000, 1008.114013, -3.359998, 18.120000, -28.079999, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1604, 245.509902, 37.751300, 1008.252685, -9.852000, -18.719999, -30.479999, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2344, 250.983795, 31.010700, 1006.758972, -7.079998, 0.000000, 34.259998, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(18868, 250.943618, 37.723011, 1006.824279, 0.000000, 0.000000, 209.580093, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11716, 250.860900, 32.786598, 1007.124694, 0.000000, 0.000000, -94.080009, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11716, 251.996322, 32.295970, 1007.124694, 0.000000, 0.000000, 94.080001, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11716, 251.577209, 33.103149, 1007.124816, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11715, 251.187606, 33.079639, 1007.132812, 0.000000, 0.000000, 180.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11715, 250.864395, 32.382801, 1007.130493, 0.000000, 0.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11715, 251.992263, 32.695388, 1007.130920, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19807, 250.452499, 30.644599, 1006.869323, 0.000000, 0.000000, 219.779998, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19819, 250.970397, 32.231281, 1007.202819, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19819, 251.883239, 32.814140, 1007.202819, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19819, 251.100906, 32.960449, 1007.202819, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1664, 251.451995, 32.485900, 1007.292297, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1664, 250.886596, 33.112098, 1006.483703, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1664, 250.986236, 33.115150, 1006.483703, 0.000000, 0.000000, 14.760000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19173, 243.666107, 31.827199, 1008.544128, 0.000000, 0.000000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2265, 252.568099, 33.414398, 1008.203002, 0.000000, 0.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2263, 252.563400, 32.566299, 1007.816406, 0.000000, 0.000000, -90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19318, 243.665893, 34.626098, 1008.591491, 0.000000, -57.180000, 90.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19893, 250.688613, 37.320781, 1006.825195, 0.000000, 0.000000, -146.339904, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2226, 243.993942, 35.340259, 1006.327819, 0.000000, 0.000000, 71.219993, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19611, 244.888809, 36.315910, 1006.322204, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(367, 244.824996, 36.204498, 1007.943420, -8.939998, 17.700000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19421, 248.744903, 37.138938, 1006.413879, -6.400000, 0.000000, -60.659999, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2263, 248.458801, 39.069690, 1008.086914, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2260, 249.921569, 39.058410, 1008.382568, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2261, 251.425765, 39.064884, 1007.637207, 0.000000, 0.000000, 0.000000, map_world, map_int, -1, 300.00, 300.00);
	return true;
}
public OnGameModeExit()
{
	return true;
}
public OnPlayerRequestClass(playerid, classid)
{
	return true;
}
public OnPlayerConnect(playerid)
{
//*********************************ëîãîòèï**************************************
	new Text:Textdraw0;
	new Text:Textdraw1;
	new Text:Textdraw2;
	new Text:Textdraw3;
	new Text:Textdraw4;
	new Text:Textdraw5;


	Textdraw0 = TextDrawCreate(559.058776, 1.166676, "San-Andreas");
	TextDrawLetterSize(Textdraw0, 0.449999, 1.600000);
	TextDrawAlignment(Textdraw0, 1);
	TextDrawColor(Textdraw0, -5963521);
	TextDrawUseBox(Textdraw0, true);
	TextDrawBoxColor(Textdraw0, 0);
	TextDrawSetShadow(Textdraw0, 0);
	TextDrawSetOutline(Textdraw0, 1);
	TextDrawBackgroundColor(Textdraw0, 51);
	TextDrawFont(Textdraw0, 2);
	TextDrawSetProportional(Textdraw0, 1);

	Textdraw1 = TextDrawCreate(557.647033, 15.750000, "LD_POOL:ball");
	TextDrawLetterSize(Textdraw1, 0.000000, 0.000000);
	TextDrawTextSize(Textdraw1, 6.588277, 5.833333);
	TextDrawAlignment(Textdraw1, 1);
	TextDrawColor(Textdraw1, -1);
	TextDrawSetShadow(Textdraw1, 0);
	TextDrawSetOutline(Textdraw1, 0);
	TextDrawFont(Textdraw1, 4);

	Textdraw2 = TextDrawCreate(607.529357, 15.749997, "LD_POOL:ball");
	TextDrawLetterSize(Textdraw2, 0.000000, 0.000000);
	TextDrawTextSize(Textdraw2, 6.117629, 5.833334);
	TextDrawAlignment(Textdraw2, 1);
	TextDrawColor(Textdraw2, -1);
	TextDrawSetShadow(Textdraw2, 0);
	TextDrawSetOutline(Textdraw2, 0);
	TextDrawFont(Textdraw2, 4);

	Textdraw3 = TextDrawCreate(562.352966, 16.333330, "LD_SPAC:white");
	TextDrawLetterSize(Textdraw3, 0.000000, 0.000000);
	TextDrawTextSize(Textdraw3, 47.529342, 4.666667);
	TextDrawAlignment(Textdraw3, 1);
	TextDrawColor(Textdraw3, -1);
	TextDrawSetShadow(Textdraw3, 0);
	TextDrawSetOutline(Textdraw3, 0);
	TextDrawFont(Textdraw3, 4);

	Textdraw4 = TextDrawCreate(559.529602, 23.333349, "ROLE PLAY");
	TextDrawLetterSize(Textdraw4, 0.298940, 1.168332);
	TextDrawAlignment(Textdraw4, 1);
	TextDrawColor(Textdraw4, -1);
	TextDrawSetShadow(Textdraw4, 0);
	TextDrawSetOutline(Textdraw4, 1);
	TextDrawBackgroundColor(Textdraw4, 51);
	TextDrawFont(Textdraw4, 2);
	TextDrawSetProportional(Textdraw4, 1);

	Textdraw5 = TextDrawCreate(43.294170, 429.333404, "action-rp.ru");
	TextDrawLetterSize(Textdraw5, 0.266000, 1.284999);
	TextDrawAlignment(Textdraw5, 1);
	TextDrawColor(Textdraw5, -1);
	TextDrawSetShadow(Textdraw5, 0);
	TextDrawSetOutline(Textdraw5, 1);
	TextDrawBackgroundColor(Textdraw5, 51);
	TextDrawFont(Textdraw5, 2);
	TextDrawSetProportional(Textdraw5, 1);
//******************************************************************************
	GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
 	static fmt_str[] = "SELECT `ID` FROM `users` WHERE `Name` = '%s' LIMIT 1";
	new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)];
	mysql_format(dbHandle, string, sizeof(string), fmt_str, pInfo[playerid][pName]);
	mysql_function_query(dbHandle, string, true, "PlayerCheck", "d", playerid);
	Clear(playerid);
	PlayerTextDraws(playerid);
	return true;
}
public OnPlayerDisconnect(playerid, reason)
{
    KillTimers(playerid);
	return true;
}
public OnPlayerSpawn(playerid)
{
    if(login_check{playerid} == true)
 		SetPlayerSpawn(playerid);
	return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	return true;
}
public OnVehicleSpawn(vehicleid)
{
	return true;
}
public OnVehicleDeath(vehicleid, killerid)
{
	return true;
}
public OnPlayerText(playerid, text[])
{
    if(login_check{playerid} == false)
	{
	    SCM(playerid, Color_Grey, !"Âû íå àâòîðèçîâàíû.");
	    return false;
	}
	return false;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	return false;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return true;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	return true;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return true;
}
public OnPlayerEnterCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveCheckpoint(playerid)
{
	return true;
}
public OnPlayerEnterRaceCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return true;
}
public OnRconCommand(cmd[])
{
	return true;
}
public OnPlayerRequestSpawn(playerid)
{
	return true;
}
public OnObjectMoved(objectid)
{
	return true;
}
public OnPlayerObjectMoved(playerid, objectid)
{
	return true;
}
public OnPlayerPickUpPickup(playerid, pickupid)
{
	return true;
}
public OnVehicleMod(playerid, vehicleid, componentid)
{
	return true;
}
public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return true;
}
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return true;
}
public OnPlayerSelectedMenuRow(playerid, row)
{
	return true;
}
public OnPlayerExitedMenu(playerid)
{
	return true;
}
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return true;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return true;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return true;
}
public OnPlayerUpdate(playerid)
{
	return true;
}
public OnPlayerStreamIn(playerid, forplayerid)
{
	return true;
}
public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}
public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return true;
}
public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return true;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new len = strlen(inputtext),
	    val = strval(inputtext);
	switch(dialogid)
	{
	    case 1:
	    {
	        if(response)
	        {
	            if(!len)
	            {
	                ShowRegister(playerid);
	                return SCM(playerid, Color_Grey, "Âû íè÷åãî íå ââåëè.");
	            }
	            if(!(6 <= len <= 32))
	            {
	                ShowRegister(playerid);
					return SCM(playerid, Color_Grey, !"Íåâåðíàÿ äëèíà ïàðîëÿ.");
	            }
	            if(CheckRusText(inputtext, len+1))
				{
				    ShowRegister(playerid);
				    return SCM(playerid, Color_Grey, !"Ñìåíèòå ðàñêëàäêó êëàâèàòóðû.");
				}
				strmid(pInfo[playerid][pPass], inputtext, 0, len, 32+1);
				ShowPassCheck(playerid);
	        }
	        else
	        {
	            SCM(playerid, Color_FireBrick, !"Ââåäèòå /q[uit]");
	            Pkick(playerid);
	        }
	    }
	    case 2:
	    {
			if(!strcmp(pInfo[playerid][pPass], inputtext)) ShowEmail(playerid);
			else
			{
			    SCM(playerid, Color_LightRed, !"Íåâåðíûé ïàðîëü.");
				return Pkick(playerid);
			}
	    }
	    case 3:
	    {
	        if(response)
	        {
				if(!len)
				{
				    ShowEmail(playerid);
				    return SCM(playerid, Color_Grey, !"Âû íè÷åãî íå ââåëè.");
				}
				if(!(6 <= len <= 46))
				{
				    ShowEmail(playerid);
				    return SCM(playerid, Color_Grey, !"Íåâåðíàÿ äëèíà Ýëåòðîííîé ïî÷òû.");
				}
				if(strfind(inputtext, "@", false) == -1 || strfind(inputtext, ".", false) == -1)
				{
				    ShowEmail(playerid);
				    return SCM(playerid, Color_Grey, !"Íåâåðíûé ôîðìàò Ýëåêòðîííîé ïî÷òû.");
				}
				if(CheckRusText(inputtext, len+1))
				{
				    ShowEmail(playerid);
				    return SCM(playerid, Color_Grey, !"Ñìåíèòå ðàñêëàäêó êëàâèàòóðû.");
				}
				strmid(pInfo[playerid][pEmail], inputtext, 0, len, 46+1);
				ShowReferal(playerid);
	        }
	        else ShowPassCheck(playerid);
	    }
	    case 4:
	    {
	        if(response)
		    {
		        if(isnull(inputtext))
				{
				    ShowReferal(playerid);
				    return SCM(playerid, Color_Grey, !"Âû íè÷åãî íå ââåëè.");
				}
				static fmt_str[] = "SELECT `ID` FROM `users` WHERE `Name` = '%e' LIMIT 1";
				new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)];
				mysql_format(dbHandle, string, sizeof(string), fmt_str, (inputtext));
				mysql_function_query(dbHandle, string, true, "CheckReferal", "de", playerid, inputtext);
		    }
		    else ShowNations(playerid);
	    }
	    case 5:
	    {
	        if(response)
			{
				pInfo[playerid][pNations] = listitem+1;
				ShowAge(playerid);
			}
			else ShowReferal(playerid);
	    }
	    case 6:
	    {
	        if(response)
	        {
	            if(isnull(inputtext))
				{
				    ShowAge(playerid);
				    return SCM(playerid, Color_Grey, !"Âû íè÷åãî íå ââåëè.");
				}
				if(!(1 <= val <= 99))
				{
				    ShowAge(playerid);
				    return SCM(playerid, Color_Grey, !"Íåâåðíàÿ äëèíà âîçðàñòà.");
				}
				pInfo[playerid][pAge] = val;
				ShowSex(playerid);
	        }
	        else ShowNations(playerid);
	    }
	    case 7:
	    {
	        SpawnPlayer(playerid);
		    if(response)
		    {
			    pInfo[playerid][pSex] = 1;
			    SetPlayerSkin(playerid, 32);
			    number_skin{playerid} = 1;
			}
		    else
		    {
			    pInfo[playerid][pSex] = 2;
			    SetPlayerSkin(playerid, 63);
			    number_skin{playerid} = 15;
			}
			for(new i; i != 11; i++) TextDrawShowForPlayer(playerid, select_skin[playerid][i]);
			SelectTextDraw(playerid, 0xA52A2AFF);
	        SetPlayerVirtualWorld(playerid, playerid);
	        SetPlayerInterior(playerid, 0);
	        SetPlayerPos(playerid, 248.6302,33.8265,1007.3272);
			SetPlayerFacingAngle(playerid, 35.4503);
			SetPlayerCameraPos(playerid, 245.2390,36.4504,1008.5635);
			SetPlayerCameraLookAt(playerid, 248.6302,33.8265,1007.3272);
	        Freeze(playerid, 0);
	    }
	    case 8:
	    {
	        if(response)
	        {
	        	if(isnull(inputtext))
				{
	                ShowLogin(playerid);
	                return SCM(playerid, Color_Grey, "Âû íè÷åãî íå ââåëè.");
	            }
				static fmt_str[] = "SELECT * FROM `users` WHERE `ID` = '%d' AND `Pass` = '%e' LIMIT 1";
				new string[sizeof(fmt_str)+37];
				mysql_format(dbHandle, string, sizeof(string), fmt_str, pInfo[playerid][pID], inputtext);
				mysql_function_query(dbHandle, string, true, "PlayerLogin", "d", playerid);
			}
			else
			{
			    SCM(playerid, Color_FireBrick, !"Ââåäèòå /q[uit]");
	            Pkick(playerid);
			}
	    }
	}
	return true;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return true;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(login_check{playerid} == false)
	{
	    SCM(playerid, Color_Grey, !"Âû íå àâòîðèçîâàíû.");
	    return false;
	}
	return true;
}
public OnPlayerClickTextDraw(playerid, Text: clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW && number_skin{playerid} > 0)
	    SelectTextDraw(playerid, 0xA52A2AFF);
	if(clickedid == select_skin[playerid][9])
	{
	    number_skin{playerid} ++;
	    if(pInfo[playerid][pSex] == 1)
  		{
	        if(number_skin{playerid} == 15)
	            number_skin{playerid} = 1;
		}
	    else
	    {
	        if(number_skin{playerid} == 29)
	            number_skin{playerid} = 15;
		}

	    switch(number_skin{playerid})
	    {
	        // == == == [Ìóæñêèå] == == ==
	        case 1: SetPlayerSkin(playerid, 32);
	        case 2: SetPlayerSkin(playerid, 78);
	        case 3: SetPlayerSkin(playerid, 79);
	        case 4: SetPlayerSkin(playerid, 133);
	        case 5: SetPlayerSkin(playerid, 134);
	        case 6: SetPlayerSkin(playerid, 135);
	        case 7: SetPlayerSkin(playerid, 136);
	        case 8: SetPlayerSkin(playerid, 137);
	        case 9: SetPlayerSkin(playerid, 160);
	        case 10: SetPlayerSkin(playerid, 200);
	        case 11: SetPlayerSkin(playerid, 212);
	        case 12: SetPlayerSkin(playerid, 213);
	        case 13: SetPlayerSkin(playerid, 230);
	        case 14: SetPlayerSkin(playerid, 239);
	        // == == == [Æåíñêèå] == == ==
	        case 15: SetPlayerSkin(playerid, 63);
	        case 16: SetPlayerSkin(playerid, 64);
	        case 17: SetPlayerSkin(playerid, 75);
	        case 18: SetPlayerSkin(playerid, 85);
	        case 19: SetPlayerSkin(playerid, 131);
	        case 20: SetPlayerSkin(playerid, 152);
	        case 21: SetPlayerSkin(playerid, 198);
	        case 22: SetPlayerSkin(playerid, 199);
	        case 23: SetPlayerSkin(playerid, 201);
	        case 24: SetPlayerSkin(playerid, 207);
	        case 25: SetPlayerSkin(playerid, 237);
	        case 26: SetPlayerSkin(playerid, 238);
	        case 27: SetPlayerSkin(playerid, 243);
	        case 28: SetPlayerSkin(playerid, 245);
	    }
	}
	if(clickedid == select_skin[playerid][8])
	{
	    number_skin{playerid} --;
	    if(pInfo[playerid][pSex] == 1)
     	{
	        if(number_skin{playerid} == 0)
	            number_skin{playerid} = 14;
		}
	    else
	    {
	        if(number_skin{playerid} == 14)
	            number_skin{playerid} = 28;
		}
	    switch(number_skin{playerid})
	    {
	        // == == == [Ìóæñêèå] == == ==
	        case 1: SetPlayerSkin(playerid, 32);
	        case 2: SetPlayerSkin(playerid, 78);
	        case 3: SetPlayerSkin(playerid, 79);
	        case 4: SetPlayerSkin(playerid, 133);
	        case 5: SetPlayerSkin(playerid, 134);
	        case 6: SetPlayerSkin(playerid, 135);
	        case 7: SetPlayerSkin(playerid, 136);
	        case 8: SetPlayerSkin(playerid, 137);
	        case 9: SetPlayerSkin(playerid, 160);
	        case 10: SetPlayerSkin(playerid, 200);
	        case 11: SetPlayerSkin(playerid, 212);
	        case 12: SetPlayerSkin(playerid, 213);
	        case 13: SetPlayerSkin(playerid, 230);
	        case 14: SetPlayerSkin(playerid, 239);
	        // == == == [Æåíñêèå] == == ==
	        case 15: SetPlayerSkin(playerid, 63);
	        case 16: SetPlayerSkin(playerid, 64);
	        case 17: SetPlayerSkin(playerid, 75);
	        case 18: SetPlayerSkin(playerid, 85);
	        case 19: SetPlayerSkin(playerid, 131);
	        case 20: SetPlayerSkin(playerid, 152);
	        case 21: SetPlayerSkin(playerid, 198);
	        case 22: SetPlayerSkin(playerid, 199);
	        case 23: SetPlayerSkin(playerid, 201);
	        case 24: SetPlayerSkin(playerid, 207);
	        case 25: SetPlayerSkin(playerid, 237);
	        case 26: SetPlayerSkin(playerid, 238);
	        case 27: SetPlayerSkin(playerid, 243);
	        case 28: SetPlayerSkin(playerid, 245);
	    }
	}
	if(clickedid == select_skin[playerid][10])
	{
	    new year_server,
	        month_server,
	        day_server;
		for(new i; i != 11; i++) TextDrawHideForPlayer(playerid, select_skin[playerid][i]);
	    SCM(playerid, Color_White, !"Âû óñïåøíî çàðåãèñòðèðîâàëèñü");
	    login_check{playerid} = true;
	    update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
	    Freeze(playerid, 1);
	    number_skin{playerid} = 0;
	    CancelSelectTextDraw(playerid);
	    // == == == [ Ñîçäàíèå Àêêàóíòà ] == == ==
	    pInfo[playerid][pLevel] = 1;
	    pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
	    
	    getdate(year_server, month_server, day_server);
	    format(pInfo[playerid][pDateReg], 10+1, "%02d/%02d/%02d", day_server, month_server, year_server);
	    // == == == == == == == == == == == == ==
	    static fmt_str[] = "INSERT INTO `users` (`Name`, `Pass`, `Email`, `Referal`,`Date Reg`, `Nations`, `Age`, `Sex`, `Skin`, `Level`) \
		VALUES ('%s', '%s', '%s', '%s', '%s', '%d', '%d', '%d', '%d', '%d')";
		new string[sizeof(fmt_str)+MAX_PLAYER_NAME*2+76];
		mysql_format(dbHandle, string, sizeof(string), fmt_str, pInfo[playerid][pName], pInfo[playerid][pPass], pInfo[playerid][pEmail],
			pInfo[playerid][pReferal], pInfo[playerid][pDateReg], pInfo[playerid][pNations], pInfo[playerid][pAge], pInfo[playerid][pSex],
		pInfo[playerid][pSkin], pInfo[playerid][pLevel]);
		mysql_function_query(dbHandle, string, true, "GetID", "i", playerid);
	    SpawnPlayer(playerid);
	}
	return true;
}
// == == == == [ Ñâîè Ïàáëèêè ] == == == ==
public PlayerCheck(playerid)
{
	new rows,
		fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    login_timer[playerid] = SetTimerEx("CheckLogin", 1000*35, false, "i", playerid);
	    pInfo[playerid][pID] = cache_get_field_content_int(0, "ID");
		ShowLogin(playerid);
	}
	else ShowRegister(playerid);
}
public PlayerLogin(playerid)
{
    new rows,
	    fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    cache_get_field_content(0, "Pass", pInfo[playerid][pPass], dbHandle, 32+1);
	    cache_get_field_content(0, "Email", pInfo[playerid][pEmail], dbHandle, 46+1);
	    cache_get_field_content(0, "Referal", pInfo[playerid][pReferal], dbHandle, MAX_PLAYER_NAME+1);
	    cache_get_field_content(0, "Date Reg", pInfo[playerid][pDateReg], dbHandle, 10+1);
	    pInfo[playerid][pNations] = cache_get_field_content_int(0, "Nations");
	    pInfo[playerid][pAge] = cache_get_field_content_int(0, "Age");
	    pInfo[playerid][pSex] = cache_get_field_content_int(0, "Sex");
	    pInfo[playerid][pSkin] = cache_get_field_content_int(0, "Skin");
	    pInfo[playerid][pMoney] = cache_get_field_content_int(0, "Money");
	    pInfo[playerid][pLevel] = cache_get_field_content_int(0, "Level");
	    //== == == == == == == == == == == == == == == == == == == == == == ==
	    login_check{playerid} = true;
	    SetTimerEx("FastSpawn", 100, false, "i", playerid);
	    update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
	    KillTimer(login_timer[playerid]);
	    static fmt_str[] = "SELECT * FROM `referal` WHERE `Name` = '%s' LIMIT 1";
		new string[sizeof(fmt_str)+MAX_PLAYER_NAME-1];
		mysql_format(dbHandle, string, sizeof(string), fmt_str, pInfo[playerid][pName]);
		mysql_function_query(dbHandle, string, true, "CheckReferal_2", "d", playerid);
	}
	else
	{
	    number_pass{playerid} ++;
	    if(number_pass{playerid} == 3)
	    {
	        Pkick(playerid);
	        return SCM(playerid, Color_FireBrick, !"Ïîïûòêè íà ââîä ïàðîëÿ çàêîí÷åíû. Ââåäèòå /q[uit]");
	    }
	    static const fmt_str[] = "Íåâåðíûé ïàðîëü. Îñòàëîñü ïîïûòîê: %d";
		new string[sizeof(fmt_str)];
		format(string, sizeof(string), fmt_str, 3-number_pass{playerid});
		SCM(playerid, Color_LightRed, string);
	    ShowLogin(playerid);
	}
	return true;
}
public CheckReferal(playerid, name[])
{
    new rows,
	    fields;
	cache_get_data(rows, fields);
	if(!rows)
	{
	    ShowReferal(playerid);
	    return SCM(playerid, Color_Grey, !"Àêêàóíò íå íàéäåí.");
	}
	strmid(pInfo[playerid][pReferal], name, 0, strlen(name), MAX_PLAYER_NAME+1);
	ShowSex(playerid);
	return true;
}
public CheckReferal_2(playerid)
{
    new rows,
	    fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    pInfo[playerid][pMoney] += 100_000;
	    SavePlayer(playerid, "Money", pInfo[playerid][pMoney], "d");
	    SCM(playerid, Color_Yellow, !"Âû ïîëó÷àåòå 100.000$ çà ïðèãëàøåííîãî èãðîêà");
	    static fmt_str[] = "DELETE FROM `referal` WHERE `Name` = '%s' LIMIT 1";
		new string[sizeof(fmt_str)+MAX_PLAYER_NAME-1];
		mysql_format(dbHandle, string, sizeof(string), fmt_str, pInfo[playerid][pName]);
		mysql_function_query(dbHandle, string, true, "", "");
	}
	return true;
}
public CheckLogin(playerid)
{
	SCM(playerid, Color_FireBrick, !"Âðåìÿ íà àâòîðèçàöèþ âûøëî. Ââåäèòå /q[uit]");
	Pkick(playerid);
	return true;
}
public TimeKick(playerid)
{
	Kick(playerid);
	return true;
}
public UpdateTime(playerid)
{
    if(pInfo[playerid][pMoney] != GetPlayerMoney(playerid))
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
	}
	update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
	return true;
}
public GetID(playerid)
{
	pInfo[playerid][pID] = cache_insert_id();
	return true;
}
public FastSpawn(playerid)
{
	SpawnPlayer(playerid);
	return true;
}
// == == == == [ Ñòîêè ] == == == ==
stock ShowLogin(playerid)
{
    static const fmt_str[] = "{FFFFFF}[Äîáðî ïîæàëîâàòü]\n\n\
		Ëîãèí: {A52A2A}[%s]{FFFFFF}\n\
		Ïèíã: {A52A2A}[%d]{FFFFFF}\n\
		Àêêàóíò: {FF0000}[çàíÿò]{FFFFFF}\n\n\
		{999999}Ó âàñ åñòü 35 ñåêóíä, ÷òîáû ââåñòè{FFFFFF}\n\
	Ââåäèòå ñâîé ïàðîëü:";
	new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)+(-2+5)];
	format(string, sizeof(string), fmt_str, pInfo[playerid][pName], GetPlayerPing(playerid));
	SPD(playerid, 8, DSP, "Àâòîðèçàöèÿ", string, ">>", "><");
}
stock ShowRegister(playerid)
{
    static const fmt_str[] = "{FFFFFF}[Äîáðî ïîæàëîâàòü]\n\n\
	Ëîãèí: {A52A2A}[%s]{FFFFFF}\n\
	Ïèíã: {A52A2A}[%d]{FFFFFF}\n\
	Àêêàóíò: {008000}[ñâîáîäåí]{FFFFFF}\n\n\
	Ïðèäóìàéòå ñâîé ïàðîëü:";
	new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)+(-2+5)];
	format(string, sizeof(string), fmt_str, pInfo[playerid][pName], GetPlayerPing(playerid));
	SPD(playerid, 1, DSI, "Ðåãèñòðàöèÿ", string, ">>", "><");
}
stock ShowPassCheck(playerid)
{
	SPD(playerid, 2, DSP, "[Ïîäòâåðæäåíèå ïàðîëÿ]", "{FFFFFF}Ïîäòâåðäèòå Ñâîé {A52A2A}[Ïàðîëü]{FFFFFF}\n\
	×òîáû ïðîäîëæèòü {A52A2A}[Ðåãèòñðàöèþ]{FFFFFF}:", ">>", "><");
}
stock ShowEmail(playerid)
{
	SPD(playerid, 3, DSI, "[Ýëåêòðîííàÿ ïî÷òà]", "{FFFFFF}Óêàæèòå ïðàâèëüíî ñâîþ {A52A2A}[Ýëåêòðîííîþ ïî÷òó]{FFFFFF}\n\
	Â ñëó÷àå âçëîìà èëè ïîòåðè àêêàóíòà{FFFFFF}\n\
	Âû ñìîæèòå âîññòàíîâèòü Ñâîé {A52A2A}[Àêêàóíò]{FFFFFF}:\n\
	{DF8600}[Ïîäñêàçêà]{FFFFFF}:\n\
	\t{008000}[]{FFFFFF}Ýëåêòðîííàÿ ïî÷òà äîëæíà áûòü îò 6-òè äî 46-òè ñìâîëîâ\n\
	\t{008000}[]{FFFFFF}Ýëåêòðîííàÿ ïî÷òà äîëæíà ñîñòîÿòü èç öèôð è ëàòèíñêèõ ñèìâîëîâ", ">>", "<<");
}
stock ShowReferal(playerid)
{
	SPD(playerid, 4, DSI, "[Ðåôåðàë]", "{FFFFFF}Ââåäèòå {A52A2A}[Íèê èãðîêà] {FFFFFF}ïðèãëàñèâøåãî\n\
	Âàñ íà ñåðâåð:\n\
	{DF8600}[Ïîäñêàçêà]{FFFFFF}:\n\n\
	Äîñòèãíóâøè {A52A2A}Âàìè 6-ãî óðîâíÿ{FFFFFF}, ýòîò èãðîê\n\
	\t{008000}[]{FFFFFF}Ïîëó÷èò {DF8600}[120.000$]\n\
	\t{008000}[]{FFFFFF}Ïîëó÷èò {A52A2A}[VIP] - ñòàòóñ {FFFFFF}íà {DF8600}[7 äíåé]\n\
	\t{008000}[]{FFFFFF}Ïîëó÷èò {A52A2A}[Äîíàò] {FFFFFF}â ðàçìåðå {DF8600}[250 ðóáëåé]", "><", ">>");
}
stock ShowNations(playerid)
{
    SPD(playerid, 5, DSL, !"[Íàöèîíàëüíîñòü]", !"Àìåðèêàíñêàÿ\n\
    Êèòàéñêàÿ\n\
	Èòàëüÿíñêàÿ\n\
	Ìåêñèêàíñêàÿ\n\
	Ðóññêèé\n\
	Óêðàèíñêàÿ\n\
	Ôèëèïïèíñêàÿ\n\
	ßïîíñêàÿ", !">>", !"<<");
}
stock ShowAge(playerid)
{
    SPD(playerid, 6, DSI, !"[Âîçðàñò]", !"{FFFFFF}Ââåäèòå âîçðàñò\n\
	Âàøåãî {A52A2A}[Ïåðñîíàæà]{FFFFFF}:\n\
	{DF8600}[Ïîäñêàçêà]{FFFFFF}:\n\n\
	\t{008000}[]{FFFFFF}Âîçðàñò îò 1-ãî äî 99-òè\n\
	\t{008000}[]{FFFFFF}Âîçðàñò äîëæåí ñîñòîÿòü èç öèôð", !">>", !"<<");
}
stock ShowSex(playerid)
{
	SPD(playerid, 7, DSM, !"[Ïîë]", !"{FFFFFF}Âûáåðèòå {A52A2A}[Ïîë] {FFFFFF}Âàøåãî\n\
	ïåðñîíàæà{FFFFFF}\n\
	Çà êîòîðîãî Âû áóäåòå èãðàòü {A52A2A}[Role Play]{FFFFFF}:", !"Ìóæñêîé", !"Æåíñêèé");
}
stock CheckRusText(string[], size = sizeof(string))
{
    for(new i; i < size; i++)
	switch(string[i])
	{
	    case 'À'..'ß', 'à'..'ÿ', ' ': return true;
	}
	return false;
}
stock Clear(playerid)
{
	number_skin{playerid} = 0;
	number_pass{playerid} = 0;
	login_check{playerid} = false;
}
stock KillTimers(playerid)
{
    KillTimer(update_timer[playerid]);
   	KillTimer(login_timer[playerid]);
}
stock SetPlayerSpawn(playerid)
{
    SetPlayerScore(playerid, pInfo[playerid][pLevel]);
	SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
	SetPlayerPos(playerid, 1154.3717, -1769.2594, 16.5938);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	return true;
}
stock SavePlayer(playerid, const field_name[], const set[], const type[])
{
	new string[128+1];
	if(!strcmp(type, "d", true))
	{
	    mysql_format(dbHandle, string, sizeof(string), "UPDATE `users` SET `%s` = '%d' WHERE `ID` = '%d' LIMIT 1",
		field_name, set, pInfo[playerid][pID]);
	}
    else if(!strcmp(type, "s", true))
    {
	    mysql_format(dbHandle, string, sizeof(string), "UPDATE `users` SET `%s` = '%s' WHERE `ID` = '%d' LIMIT 1",
		field_name, set, pInfo[playerid][pID]);
	}
    mysql_function_query(dbHandle, string, false, "", "");
}
stock PlayerTextDraws(playerid)
{
	// == == == [ Âûáîð Ñêèíà ] == == ==
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

	select_skin[playerid][1] = TextDrawCreate(475.674652, 350.333282, "usebox");
	TextDrawLetterSize(select_skin[playerid][1], 0.000000, 2.275923);
	TextDrawTextSize(select_skin[playerid][1], 438.878021, 0.000000);
	TextDrawAlignment(select_skin[playerid][1], 1);
	TextDrawColor(select_skin[playerid][1], 0);
	TextDrawUseBox(select_skin[playerid][1], true);
	TextDrawBoxColor(select_skin[playerid][1], 102);
	TextDrawSetShadow(select_skin[playerid][1], 0);
	TextDrawSetOutline(select_skin[playerid][1], 0);
	TextDrawFont(select_skin[playerid][1], 0);

	select_skin[playerid][2] = TextDrawCreate(525.401245, 351.333251, "usebox");
	TextDrawLetterSize(select_skin[playerid][2], 0.000000, 2.275923);
	TextDrawTextSize(select_skin[playerid][2], 488.542358, 0.000000);
	TextDrawAlignment(select_skin[playerid][2], 1);
	TextDrawColor(select_skin[playerid][2], 0);
	TextDrawUseBox(select_skin[playerid][2], true);
	TextDrawBoxColor(select_skin[playerid][2], 102);
	TextDrawSetShadow(select_skin[playerid][2], 0);
	TextDrawSetOutline(select_skin[playerid][2], 0);
	TextDrawFont(select_skin[playerid][2], 0);

	select_skin[playerid][3] = TextDrawCreate(501.101013, 383.833099, "usebox");
	TextDrawLetterSize(select_skin[playerid][3], 0.000000, 2.229071);
	TextDrawTextSize(select_skin[playerid][3], 464.178894, 0.000000);
	TextDrawAlignment(select_skin[playerid][3], 1);
	TextDrawColor(select_skin[playerid][3], 0);
	TextDrawUseBox(select_skin[playerid][3], true);
	TextDrawBoxColor(select_skin[playerid][3], 102);
	TextDrawSetShadow(select_skin[playerid][3], 0);
	TextDrawSetOutline(select_skin[playerid][3], 0);
	TextDrawFont(select_skin[playerid][3], 0);

	select_skin[playerid][4] = TextDrawCreate(531.771606, 340.083312, "LD_SPAC:white");
	TextDrawLetterSize(select_skin[playerid][4], 0.000000, 0.000000);
	TextDrawTextSize(select_skin[playerid][4], -101.200592, -6.416625);
	TextDrawAlignment(select_skin[playerid][4], 1);
	TextDrawColor(select_skin[playerid][4], -5963521);
	TextDrawSetShadow(select_skin[playerid][4], 0);
	TextDrawSetOutline(select_skin[playerid][4], 0);
	TextDrawFont(select_skin[playerid][4], 4);

	select_skin[playerid][5] = TextDrawCreate(472.800415, 352.749847, "LD_SPAC:white");
	TextDrawLetterSize(select_skin[playerid][5], 0.000000, 0.000000);
	TextDrawTextSize(select_skin[playerid][5], -31.390945, -3.499959);
	TextDrawAlignment(select_skin[playerid][5], 1);
	TextDrawColor(select_skin[playerid][5], -1523963137);
	TextDrawSetShadow(select_skin[playerid][5], 0);
	TextDrawSetOutline(select_skin[playerid][5], 0);
	TextDrawFont(select_skin[playerid][5], 4);

	select_skin[playerid][6] = TextDrawCreate(522.526611, 353.749847, "LD_SPAC:white");
	TextDrawLetterSize(select_skin[playerid][6], 0.000000, 0.000000);
	TextDrawTextSize(select_skin[playerid][6], -31.390945, -3.499959);
	TextDrawAlignment(select_skin[playerid][6], 1);
	TextDrawColor(select_skin[playerid][6], -1523963137);
	TextDrawSetShadow(select_skin[playerid][6], 0);
	TextDrawSetOutline(select_skin[playerid][6], 0);
	TextDrawFont(select_skin[playerid][6], 4);

	select_skin[playerid][7] = TextDrawCreate(498.226470, 385.666503, "LD_SPAC:white");
	TextDrawLetterSize(select_skin[playerid][7], 0.000000, 0.000000);
	TextDrawTextSize(select_skin[playerid][7], -31.390945, -3.499959);
	TextDrawAlignment(select_skin[playerid][7], 1);
	TextDrawColor(select_skin[playerid][7], -1523963137);
	TextDrawSetShadow(select_skin[playerid][7], 0);
	TextDrawSetOutline(select_skin[playerid][7], 0);
	TextDrawFont(select_skin[playerid][7], 4);

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

	select_skin[playerid][10] = TextDrawCreate(485.045806, 381.750061, "><");
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
// == == == == [ Ðàçíîå ] == == == ==
stock ConnectMySQL()
{
	dbHandle =mysql_connect(MySQL_Host, MySQL_User, MySQL_Base, MySQL_Pass);
	switch(mysql_errno())
	{
	    case 0: print("MySQL - connected");
	    default: print("MySQL - disconnect");
	}
	mysql_set_charset("cp1251");
}
main() { }
