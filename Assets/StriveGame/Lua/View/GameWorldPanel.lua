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
    this.textContent = transform:FindChild("Scroll View/Viewport/trans_content").gameObject;	
    this.textPos = transform:FindChild("Text_pos").gameObject;
    this.sb_vertical = transform:FindChild("Scroll View/Scrollbar Vertical"):GetComponent("Scrollbar");
    this.input_content = transform:FindChild("InputField_content"):GetComponent("InputField");
    this.Panel_PlayerHead = transform:FindChild("Panel_PalyerHead").gameObject;
    this.btnResetView = transform:FindChild("Button_resetView").gameObject;
--    local name_text = GameWorldPanel.Panel_PlayerHead:FindChild("Text_PlayerName");

end

--单击事件--
function GameWorldPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

