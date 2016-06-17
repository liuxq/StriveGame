
CtrlNames = {
	Login = "LoginCtrl",
	SelectAvatar = "SelectAvatarCtrl",
	CreateAvatar = "CreateAvatarCtrl",
    GameWorld = "GameWorldCtrl",
	MsgBox = "MessageBoxCtrl",
}

PanelNames = {
	"LoginPanel",	
	"SelectAvatarPanel",
	"CreateAvatarPanel",
    "GameWorldPanel",
    "MessageBoxPanel",
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}
--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;

resMgr = LuaHelper.GetResManager();
panelMgr = LuaHelper.GetPanelManager();
soundMgr = LuaHelper.GetSoundManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;
KBEEvent = KBEngine.Event;