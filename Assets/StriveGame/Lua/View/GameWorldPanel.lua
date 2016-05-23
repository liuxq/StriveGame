local transform;
local gameObject;

GameWorldPanel = {};
local this = GameWorldPanel;

--启动事件--
function GameWorldPanel.Awake(obj)

	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function GameWorldPanel.InitPanel()
	this.btnSend = transform:FindChild("Button_send").gameObject;
	this.PanelDie = transform:FindChild("Panel_die").gameObject;
	this.btnRelive = transform:FindChild("Panel_die/Button_relive").gameObject;
	this.btnClose = transform:FindChild("Button_close").gameObject;
end

--单击事件--
function GameWorldPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

