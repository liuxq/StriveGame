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

	--Event.AddListener("onTargetHeadResult", this.onTargetHeadResult);
end

--启动事件--
function TargetHeadCtrl.OnCreate(obj)
	gameObject = obj;
	gameObject.transform.position = Vector3.New(87.5, 128, 0);
	TargetHead = gameObject:GetComponent('LuaBehaviour');
	--TargetHead:AddClick(TargetHeadPanel.btnTargetHead, this.OnTargetHead);
	--TargetHead:AddClick(TargetHeadPanel.btnCancel, this.OnCancel);

	logWarn("Start lua--->>"..gameObject.name);
end


--关闭事件--
function TargetHeadCtrl.Close()
	--KBEEvent.deregisterOut("onConnectStatus", this.onConnectStatus);
	--KBEEvent.deregisterOut("onTargetHeadSuccessfully", this.onCreateAvatarSuccessfully);
    --KBEEvent.deregisterOut("onCreateAvatarFailed", this.onCreateAvatarFailed);

	--panelMgr:ClosePanel(CtrlNames.CreateAvatar);
	destroy(gameObject);
end