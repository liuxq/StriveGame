local transform;
local gameObject;

PlayerHeadPanel = {};
local this = PlayerHeadPanel;

--启动事件--
function PlayerHeadPanel.Awake(obj)

	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function PlayerHeadPanel.InitPanel()
	this.sliderHp = transform:FindChild("Slider_targetHP"):GetComponent("Slider");
	this.textTargetName = transform:FindChild("Text_targetName"):GetComponent("Text");
	this.textHpDetail = transform:FindChild("Text_hp"):GetComponent("Text");
end

--单击事件--
function PlayerHeadPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

