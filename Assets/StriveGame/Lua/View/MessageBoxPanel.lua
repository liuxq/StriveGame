local transform;
local gameObject;

MessageBoxPanel = {};
local this = MessageBoxPanel;

--启动事件--
function MessageBoxPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function MessageBoxPanel.InitPanel()
	this.btnOK = transform:FindChild("Button_OK").gameObject;
	this.btnCancle = transform:FindChild("Button_Cancle").gameObject;
    this.txtTitle = transform:FindChild("Text_Title").gameObject;
    this.txtContent = transform:FindChild("Text_Content").gameObject;

--    gameObject.active = false;初始化完成以后不显示
    gameObject:SetActive(false);
end

--单击事件--
function MessageBoxPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

function MessageBoxPanel.Tick(go)
    print("rensiwei Tick "..Time.deltaTime);
end