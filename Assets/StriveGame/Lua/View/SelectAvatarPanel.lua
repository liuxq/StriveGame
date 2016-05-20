local transform;
local gameObject;

SelectAvatarPanel = {};
local this = SelectAvatarPanel;

--启动事件--
function SelectAvatarPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function SelectAvatarPanel.InitPanel()
	this.btnCreateAvatar = transform:FindChild("Button_CreateAvatar").gameObject;
	this.btnRemoveAvatar = transform:FindChild('Button_RemoveAvatar').gameObject;
	this.btnEnterGame = transform:FindChild('Button_EnterGame').gameObject;
	this.btnAvatar = {};
	this.btnAvatar[1] = transform:FindChild('Avatars/Toggle0').gameObject;
	this.btnAvatar[2] = transform:FindChild('Avatars/Toggle1').gameObject;
	this.btnAvatar[3] = transform:FindChild('Avatars/Toggle2').gameObject;
end

--单击事件--
function SelectAvatarPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end