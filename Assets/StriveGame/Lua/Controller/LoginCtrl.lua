require "Common/define"

LoginCtrl = {};
local this = LoginCtrl;

local login;
local transform;
local gameObject;

--构建函数--
function LoginCtrl.New()
	logWarn("LoginCtrl.New--->>");
	return this;
end

function LoginCtrl.Awake()
	logWarn("LoginCtrl.Awake--->>");
	panelMgr:CreatePanel('Login', this.OnCreate);
end

--启动事件--
function LoginCtrl.OnCreate(obj)
	gameObject = obj;

	login = gameObject:GetComponent('LuaBehaviour');
	login:AddClick(LoginPanel.btnLogin, this.OnLogin);
	login:AddClick(LoginPanel.btnRegister, this.OnRegister);

	logWarn("Start lua--->>"..gameObject.name);

	Event.AddListener("onConnectionState", this.onConnectionState);
	Event.AddListener("onLoginSuccessfully", this.onLoginSuccessfully);
	Event.AddListener("onLoginFailed", this.onLoginFailed);
	Event.AddListener("onCreateAccountResult", this.onCreateAccountResult);
	Event.AddListener("onReqAvatarList", this.onReqAvatarList);

end

--登录--
function LoginCtrl.OnLogin(go)
	local username = LoginPanel.inputUsername:GetComponent('InputField').text;
	local pw = LoginPanel.inputPassword:GetComponent('InputField').text;
	KBEngineLua.login(username, pw, "lxq");
end
--注册--
function LoginCtrl.OnRegister(go)
	local username = LoginPanel.inputUsername:GetComponent('InputField').text;
	local pw = LoginPanel.inputPassword:GetComponent('InputField').text;
	KBEngineLua.createAccount(username, pw, "lxqregister");
end

--关闭事件--
function LoginCtrl.Close()
	--panelMgr:ClosePanel(CtrlNames.Login);
	destroy(gameObject);
	Event.RemoveListener("onConnectionState", this.onConnectionState);
	Event.RemoveListener("onLoginSuccessfully", this.onLoginSuccessfully);
	Event.RemoveListener("onLoginFailed", this.onLoginFailed);
	Event.RemoveListener("onCreateAccountResult", this.onCreateAccountResult);
	Event.RemoveListener("onReqAvatarList", this.onReqAvatarList);
end

------------------回调--------------
function LoginCtrl.onReqAvatarList( avatarList )
	-- 关闭登录界面
	this.Close();
	--新建选择角色界面
    local ctrl = CtrlManager.GetCtrl(CtrlNames.SelectAvatar);
    if ctrl ~= nil then
    	ctrl.SetAvatars(avatarList);
        ctrl.Awake();
    end
end
function LoginCtrl.onConnectionState( isSuccess )
	if isSuccess == true then
		LoginPanel.textStatus:GetComponent('Text').text = "连接成功，正在登陆";
	else
		LoginPanel.textStatus:GetComponent('Text').text = "连接错误";
	end
end

function  LoginCtrl.onCreateAccountResult( errorCode, data )
	if errorCode ~= 0 then
		LoginPanel.textStatus:GetComponent('Text').text = "账号注册错误"..errorCode;
	else
		LoginPanel.textStatus:GetComponent('Text').text = "注册账号成功! 请点击登录进入游戏";
	end
end

function LoginCtrl.onLoginFailed( errorCode )
	LoginPanel.textStatus:GetComponent('Text').text = "登录失败"..errorCode;
end

function LoginCtrl.onLoginSuccessfully( isSuccess )
  	LoginPanel.textStatus:GetComponent('Text').text = "登录成功";
end