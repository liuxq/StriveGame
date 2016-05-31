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
	this.sliderHp = transform:FindChild("Slider_targetHP").gameObject;
	this.textTargetName = transform:FindChild("Text_targetName").gameObject;
	this.textHpDetail = transform:FindChild("Text_hp").gameObject;	
end

--单击事件--
function PlayerHeadPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

