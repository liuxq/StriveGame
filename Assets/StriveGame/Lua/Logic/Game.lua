Event = require 'events'
require "Dbg"
require "KBEngine"

require "Kbe/Account"
require "Kbe/Avatar"
require "Kbe/Gate"
require "Kbe/Monster"
require "Kbe/NPC"
require "Kbe/DroppedItem"


require "Common/functions"
require "Controller/LoginCtrl"
require "Logic/CtrlManager"
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

    CtrlManager.Init();
    local ctrl = CtrlManager.GetCtrl(CtrlNames.Login);
    if ctrl ~= nil then
        ctrl:Awake();
    end
    World.init();
end
