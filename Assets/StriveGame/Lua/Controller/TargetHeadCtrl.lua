require "Common/define"

TargetHeadCtrl = {};
local this = TargetHeadCtrl;

local TargetHead;
local transform;
local gameObject;

--构建函数--
function TargetHeadCtrl.New()
	logWarn("TargetHeadCtrl.New--->>");
	return this;
end

function TargetHeadCtrl.Awake()
	logWarn("TargetHeadCtrl.Awake--->>");
	panelMgr:CreatePanel('TargetHead', this.OnCreate);

end

--启动事件--
function TargetHeadCtrl.OnCreate(obj)
	gameObject = obj;
	gameObject.transform.position = Vector3.New(87.5, 337, 0);
	TargetHead = gameObject:GetComponent('LuaBehaviour');

	this.Deactivate();

	logWarn("Start lua--->>"..gameObject.name);
end

function  TargetHeadCtrl.SetHPMax(v)
    TargetHeadPanel.sliderHp.maxValue = v;
end

function  TargetHeadCtrl.SetHP(v)
    TargetHeadPanel.sliderHp.value = v;
end

function  TargetHeadCtrl.SetName(v)
    TargetHeadPanel.textTargetName.text = v;
end

function  TargetHeadCtrl.Deactivate()
    gameObject:SetActive(false);
end

function  TargetHeadCtrl.Activate()
    gameObject:SetActive(true);
end

function TargetHeadCtrl.UpdateTargetUI()
    this.Activate();
    this.SetHPMax(this.target.HP_Max);
    this.SetHP(this.target.HP);
    this.SetName(this.target.name);
end

--关闭事件--
function TargetHeadCtrl.Close()
	destroy(gameObject);
end