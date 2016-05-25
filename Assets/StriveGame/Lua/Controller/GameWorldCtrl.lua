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
	GameWorld:AddClick(GameWorldPanel.btnClose, this.OnClose);
	GameWorld:AddClick(GameWorldPanel.btnSend, this.OnSendMessage);

	logWarn("Start lua--->>"..gameObject.name);

	Event.AddListener("OnDie", this.OnDie);
	Event.AddListener("ReceiveChatMessage", this.ReceiveChatMessage);

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

--关闭游戏--
function GameWorldCtrl.OnClose(go)
	UnityEngine.Application.Quit();
end

--发送聊天
function GameWorldCtrl.OnSendMessage(go)
	local p = KBEngineLua.player();
	if p ~= nil and string.len(GameWorldPanel.input_content.text) > 0 then
		Event.Brocast("sendChatMessage", p, GameWorldPanel.input_content.text);
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

--接受信息
function GameWorldCtrl.ReceiveChatMessage(msg)
	local text = GameWorldPanel.textContent:GetComponent("Text");

	if (string.len(text.text) > 0) then
        text.text = text.text .. "\n" .. msg;
    else
        text.text = text.text .. msg;
    end

    if (text.preferredHeight + 30 > 67) then
        GameWorldPanel.textContent:GetComponent("RectTransform").sizeDelta = Vector2.New(0, text.preferredHeight);
    end

    GameWorldPanel.sb_vertical.value = 0;
    GameWorldPanel.input_content.text = "";
end
