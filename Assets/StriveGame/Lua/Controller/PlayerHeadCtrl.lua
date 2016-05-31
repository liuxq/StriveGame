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
	gameObject.transform.position = Vector3.New(87.5, 176, 0);
	PlayerHead = gameObject:GetComponent('LuaBehaviour');
	--PlayerHead:AddClick(PlayerHeadPanel.btnPlayerHead, this.OnPlayerHead);
	--PlayerHead:AddClick(PlayerHeadPanel.btnCancel, this.OnCancel);

	logWarn("Start lua--->>"..gameObject.name);

end


--关闭事件--
function PlayerHeadCtrl.Close()
	--KBEEvent.deregisterOut("onConnectStatus", this.onConnectStatus);
	--KBEEvent.deregisterOut("onPlayerHeadSuccessfully", this.onCreateAvatarSuccessfully);
    --KBEEvent.deregisterOut("onCreateAvatarFailed", this.onCreateAvatarFailed);

	--panelMgr:ClosePanel(CtrlNames.CreateAvatar);
	destroy(gameObject);
end