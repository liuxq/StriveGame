Event = require 'events'
require "Logic/CtrlManager"
require "Common/functions"
require "Controller/LoginCtrl"
require "Controller/MessageBoxCtrl"
require "KbePlugins/KBEngine"
require "Kbe/Account"
require "Logic/World"



--管理器--
Game = {};
local this = Game;

local game; 
local transform;
local gameObject;
local WWW = UnityEngine.WWW;

function Game.InitViewPanels()
	for i = 1, #PanelNames do
		require ("View/"..tostring(PanelNames[i]))
	end
end

--初始化完成，发送链接服务器信息--
function Game.OnInitOK()
    --注册LuaView--
    this.InitViewPanels();

    MessageBoxCtrl.Awake();
    this.objHUDText = find("HUDText");

    CtrlManager.Init();
    local ctrl = CtrlManager.GetCtrl(CtrlNames.Login);
    if ctrl ~= nil then
        ctrl:Awake();
    end
    World.init();
end
