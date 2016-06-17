require "Common/define"

MessageBoxCtrl = {};
local this = MessageBoxCtrl;

local MessageBox;
local transform;
local gameObject;

--构建函数--
function MessageBoxCtrl.New()
	logWarn("MessageBoxCtrl.New--->>");
	return this;
end

function MessageBoxCtrl.Awake()
    local canvas = find("Canvas");
    if (canvas.transform:Find("MessageBoxPanel") ~= nil) then 
        this.Show();
        print("MessageBoxPanel have been created!");
        return;
    end
    logWarn("MessageBoxCtrl.Awake--->>");
	panelMgr:CreatePanel('MessageBox', this.OnCreate);
end

--启动事件--
function MessageBoxCtrl.OnCreate(obj)
	gameObject = obj;

    MessageBox = gameObject:GetComponent('LuaBehaviour');
    MessageBox:AddClick(MessageBoxPanel.btnOK, this.OnOK);
    MessageBox:AddClick(MessageBoxPanel.btnCancle, this.OnCancle);

	logWarn("Start lua--->>"..gameObject.name);

    MessageBoxPanel.txtTitle:GetComponent('Text').text = "title";
    MessageBoxPanel.txtContent:GetComponent('Text').text = "content";
end


function MessageBoxCtrl.OnOK(go)
    if (MessageBoxPanel.onClick ~= nil) then
        MessageBoxPanel.onClick();
	end
    this.Hide();
end

function MessageBoxCtrl.OnCancle(go)
    this.Hide();
end

function MessageBoxCtrl.Hide()
    local panel_MsgBox = find("MessageBoxPanel");
    if panel_MsgBox ~= nil then
        panel_MsgBox:SetActive(false);
	end
end

function MessageBoxCtrl.Show()
    local canvas = find("Canvas");
    local panel_MsgBox = canvas.transform:Find("MessageBoxPanel").gameObject;
    if panel_MsgBox ~= nil then
        panel_MsgBox:SetActive(true);
    end;
end

function MessageBoxCtrl.SetInfo(strTitle, strContent,onClick)
    MessageBoxPanel.txtTitle:GetComponent('Text').text = strTitle;
    MessageBoxPanel.txtContent:GetComponent('Text').text = strContent;
    MessageBoxPanel.onClick = onClick;
end
