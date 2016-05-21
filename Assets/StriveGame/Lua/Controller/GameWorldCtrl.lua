require "Common/define"

GameWorldCtrl = {};
local this = GameWorldCtrl;

local GameWorld;
local transform;
local gameObject;

--构建函数--
function GameWorldCtrl.New()
	logWarn("GameWorldCtrl.New--->>");
	return this;
end

function GameWorldCtrl.Awake()
	logWarn("GameWorldCtrl.Awake--->>");
	panelMgr:CreatePanel('GameWorld', this.OnCreate);
end

--启动事件--
function GameWorldCtrl.OnCreate(obj)
	gameObject = obj;

	GameWorld = gameObject:GetComponent('LuaBehaviour');
	--GameWorld:AddClick(GameWorldPanel.btnGameWorld, this.OnGameWorld);
	GameWorld:AddClick(GameWorldPanel.btnRelive, this.OnRelive);

	logWarn("Start lua--->>"..gameObject.name);
	Event.AddListener("OnDie", this.OnDie);

	local p = KBEngineLua.player();
	if p ~= nil then
		this.OnDie(p.state);
	end

end

--复活--
function GameWorldCtrl.OnRelive(go)

	local p = KBEngineLua.player();
	if p ~= nil then
		p:relive(1);
	end
end

--关闭事件--
function GameWorldCtrl.Close()
	--panelMgr:ClosePanel(CtrlNames.Login);
	destroy(gameObject);
	Event.RemoveListener("onConnectStatus", this.onConnectStatus);
end

------------事件--
--死亡--
function GameWorldCtrl.OnDie(v)
	if v == 1 then
		GameWorldPanel.PanelDie:SetActive(true);
	else
		GameWorldPanel.PanelDie:SetActive(false);
	end
end