local transform;
local gameObject;

TargetHeadPanel = {};
local this = TargetHeadPanel;

--启动事件--
function TargetHeadPanel.Awake(obj)

	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function TargetHeadPanel.InitPanel()
	this.sliderHp = transform:FindChild("Slider_targetHP"):GetComponent("Slider");
	this.textTargetName = transform:FindChild("Text_targetName"):GetComponent("Text");	
end

--单击事件--
function TargetHeadPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

