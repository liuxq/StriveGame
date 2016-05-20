local transform;
local gameObject;

LoginPanel = {};
local this = LoginPanel;

--启动事件--
function LoginPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function LoginPanel.InitPanel()
	this.btnLogin = transform:FindChild("Button_login").gameObject;
	this.btnRegister = transform:FindChild("Button_register").gameObject;
	this.inputUsername = transform:FindChild("InputField_username").gameObject;
	this.inputPassword = transform:FindChild("InputField_password").gameObject;
	this.textStatus = transform:FindChild("Text_status").gameObject;
end

--单击事件--
function LoginPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

