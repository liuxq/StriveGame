
CtrlNames = {
	Login = "LoginCtrl",
	SelectAvatar = "SelectAvatarCtrl",
	CreateAvatar = "CreateAvatarCtrl",
	GameWorld = "GameWorldCtrl",
	PlayerHead = "PlayerHeadCtrl",
	TargetHead = "TargetHeadCtrl",
}

PanelNames = {
	"LoginPanel",	
	"SelectAvatarPanel",
	"CreateAvatarPanel",
	"GameWorldPanel",
	"PlayerHeadPanel",
	"TargetHeadPanel",
}


Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;

resMgr = LuaHelper.GetResManager();
panelMgr = LuaHelper.GetPanelManager();
soundMgr = LuaHelper.GetSoundManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;