require "Common/define"

PlayerHeadCtrl = {};
local this = PlayerHeadCtrl;

local PlayerHead;
local transform;
local gameObject;

--构建函数--
function PlayerHeadCtrl.New()
	logWarn("PlayerHeadCtrl.New--->>");
	return this;
end

function PlayerHeadCtrl.Awake()
	logWarn("PlayerHeadCtrl.Awake--->>");
	panelMgr:CreatePanel('PlayerHead', this.OnCreate);

	--Event.AddListener("onPlayerHeadResult", this.onPlayerHeadResult);
end

--启动事件--
function PlayerHeadCtrl.OnCreate(obj)
	gameObject = obj;
	gameObject.transform.position = Vector3.New(87.5, 385, 0);
	PlayerHead = gameObject:GetComponent('LuaBehaviour');
	--PlayerHead:AddClick(PlayerHeadPanel.btnPlayerHead, this.OnPlayerHead);
	--PlayerHead:AddClick(PlayerHeadPanel.btnCancel, this.OnCancel);
	logWarn("Start lua--->>"..gameObject.name);

	this.target = KBEngineLua.player();
	this.UpdateTargetUI();
end


function  PlayerHeadCtrl.SetHPMax(v)
    PlayerHeadPanel.sliderHp.maxValue = v;
    PlayerHeadPanel.textHpDetail.text = PlayerHeadPanel.sliderHp.value .. "/" .. PlayerHeadPanel.sliderHp.maxValue;

end

function  PlayerHeadCtrl.SetHP(v)
    PlayerHeadPanel.sliderHp.value = v;
    PlayerHeadPanel.textHpDetail.text = PlayerHeadPanel.sliderHp.value .. "/" .. PlayerHeadPanel.sliderHp.maxValue;
end

function  PlayerHeadCtrl.SetName(v)
    PlayerHeadPanel.textTargetName.text = v;
end

function  PlayerHeadCtrl.Deactivate()
    gameObject:SetActive(false);
end

function  PlayerHeadCtrl.Activate()
    gameObject:SetActive(true);
end

function PlayerHeadCtrl.UpdateTargetUI()
    this.Activate();
    this.SetHPMax(this.target.HP_Max);
    this.SetHP(this.target.HP);
    this.SetName(this.target.name);
end

--关闭事件--
function PlayerHeadCtrl.Close()
	--panelMgr:ClosePanel(CtrlNames.CreateAvatar);
	destroy(gameObject);
end