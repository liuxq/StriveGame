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
	this.sb_vertical = transform:FindChild("Scroll View/Scrollbar Vertical"):GetComponent("Scrollbar");
	this.input_content = transform:FindChild("InputField_content"):GetComponent("InputField");
	this.btnResetView = transform:FindChild("Button_resetView").gameObject;
	this.btnSkill1 = transform:FindChild("Button_skill1").gameObject;
	this.btnSkill2 = transform:FindChild("Button_skill2").gameObject;
	this.btnSkill3 = transform:FindChild("Button_skill3").gameObject;
	this.btnTabTarget = transform:FindChild("Button_tabTarget").gameObject;
	
end

--单击事件--
function GameWorldPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

