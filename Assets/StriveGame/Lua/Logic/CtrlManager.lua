require "Common/define"
require "Controller/LoginCtrl"
require "Controller/SelectAvatarCtrl"
require "Controller/CreateAvatarCtrl"
require "Controller/GameWorldCtrl"

CtrlManager = {};
local this = CtrlManager;
local ctrlList = {};	--控制器列表--

function CtrlManager.Init()
	logWarn("CtrlManager.Init----->>>");


	ctrlList[CtrlNames.Login] = LoginCtrl.New();
	ctrlList[CtrlNames.SelectAvatar] = SelectAvatarCtrl.New();
	ctrlList[CtrlNames.CreateAvatar] = CreateAvatarCtrl.New();
	ctrlList[CtrlNames.GameWorld] = GameWorldCtrl.New();
	return this;
end

--添加控制器--
function CtrlManager.AddCtrl(ctrlName, ctrlObj)
	ctrlList[ctrlName] = ctrlObj;
end

--获取控制器--
function CtrlManager.GetCtrl(ctrlName)
	return ctrlList[ctrlName];
end

--移除控制器--
function CtrlManager.RemoveCtrl(ctrlName)
	ctrlList[ctrlName] = nil;
end

--关闭控制器--
function CtrlManager.Close()
	logWarn('CtrlManager.Close---->>>');
end