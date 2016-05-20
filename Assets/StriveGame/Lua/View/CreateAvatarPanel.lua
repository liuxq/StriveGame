local transform;
local gameObject;

CreateAvatarPanel = {};
local this = CreateAvatarPanel;

--启动事件--
function CreateAvatarPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function CreateAvatarPanel.InitPanel()
	this.btnCreateAvatar = transform:FindChild("Button_CreateAvatar").gameObject;
	this.btnCancel = transform:FindChild("Button_Cancel").gameObject;
	this.inputCreateAvatarName = transform:FindChild("InputField_CreateAvatarName").gameObject;
	this.toggleProf = {};
	this.toggleProf[1] = transform:FindChild("Panel_prof/Toggle_1").gameObject;
	this.toggleProf[2] = transform:FindChild("Panel_prof/Toggle_2").gameObject;
	this.textStatus = transform:FindChild("Text_status").gameObject;
end

--单击事件--
function CreateAvatarPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

