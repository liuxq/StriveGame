require "Common/define"

SelectAvatarCtrl = {};
local this = SelectAvatarCtrl;

local selectAvatar;
local transform;
local gameObject;

--构建函数--
function SelectAvatarCtrl.New()
	logWarn("SelectAvatarCtrl.New--->>");
	Event.AddListener("onRemoveAvatar", this.onRemoveAvatar);
	return this;
end

function SelectAvatarCtrl.Awake()
	logWarn("SelectAvatarCtrl.Awake--->>");
	panelMgr:CreatePanel('SelectAvatar', this.OnCreate);
end

--启动事件--
function SelectAvatarCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;

	selectAvatar = transform:GetComponent('LuaBehaviour');
	logWarn("Start lua--->>"..gameObject.name);

	selectAvatar:AddClick(SelectAvatarPanel.btnCreateAvatar, this.OnReqCreateAvatar);
	selectAvatar:AddClick(SelectAvatarPanel.btnRemoveAvatar, this.OnReqRemoveAvatar);
	selectAvatar:AddClick(SelectAvatarPanel.btnEnterGame, this.OnReqEnterGame);
	--resMgr:LoadPrefab('prompt', { 'PromptItem' }, this.InitPanel);

	--新建好了之后进行控件操作
	this.UpdateAvatarList();
	
end

function SelectAvatarCtrl.SetAvatars( avatarList )
	this.avatars = avatarList;
end
function SelectAvatarCtrl.UpdateAvatarList()

	local i = 1;
	for k,v in pairs(this.avatars) do
		SelectAvatarPanel.btnAvatar[i].transform:FindChild('Label'):GetComponent('Text').text = v["name"];
		i = i + 1;
	end
    for j=i,3 do
    	SelectAvatarPanel.btnAvatar[j].transform:FindChild('Label'):GetComponent('Text').text = "空";
    end
end

function  SelectAvatarCtrl.OnReqCreateAvatar(go)
    --打开创建角色界面
    local ctrl = CtrlManager.GetCtrl(CtrlNames.CreateAvatar);
    if ctrl ~= nil then
        ctrl.Awake();
    end

    --关闭当前界面
    this.Close();
end

--删除角色--
function SelectAvatarCtrl.OnReqRemoveAvatar(go)
	local name = "";
	for i=1,3 do
		if SelectAvatarPanel.btnAvatar[i].transform:GetComponent('Toggle').isOn == true then
			name = SelectAvatarPanel.btnAvatar[i].transform:FindChild('Label'):GetComponent('Text').text;
		end
	end

	local p = KBEngineLua.player();
	if p ~= nil then
		p:reqRemoveAvatar(name);
	end
end

function SelectAvatarCtrl.OnReqEnterGame(go)
   	local name, dbid;
   	local p = KBEngineLua.player();
	if p ~= nil then
		for i=1,3 do
			if SelectAvatarPanel.btnAvatar[i].transform:GetComponent('Toggle').isOn == true then
				name = SelectAvatarPanel.btnAvatar[i].transform:FindChild('Label'):GetComponent('Text').text;
				break;
			end
		end
		for key, value in pairs(this.avatars) do
			if value["name"] == name then
				dbid = key;
			end
		end
		p:reqSelectAvatarGame(dbid);
	end
end

--------------------数据发过来的事件-----------------------------


function SelectAvatarCtrl.onRemoveAvatar( dbid, dic )
	this.avatars = dic;
	this.UpdateAvatarList();
end



--关闭事件--
function SelectAvatarCtrl.Close()
	--panelMgr:ClosePanel(CtrlNames.SelectAvatar);
	destroy(gameObject);
end