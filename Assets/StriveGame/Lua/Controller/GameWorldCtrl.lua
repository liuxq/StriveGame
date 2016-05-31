require "Common/define"

GameWorldCtrl = {};
local this = GameWorldCtrl;

local GameWorld;
local transform;
local gameObject;

--构建函数--
function GameWorldCtrl.New()
	logWarn("GameWorldCtrl.New--->>");
	return this;
end

function GameWorldCtrl.Awake()
	logWarn("GameWorldCtrl.Awake--->>");
	panelMgr:CreatePanel('GameWorld', this.OnCreate);
end

--启动事件--
function GameWorldCtrl.OnCreate(obj)
	gameObject = obj;

	GameWorld = gameObject:GetComponent('LuaBehaviour');
	--GameWorld:AddClick(GameWorldPanel.btnGameWorld, this.OnGameWorld);
	GameWorld:AddClick(GameWorldPanel.btnRelive, this.OnRelive);
	GameWorld:AddClick(GameWorldPanel.btnClose, this.OnClose);
	GameWorld:AddClick(GameWorldPanel.btnSend, this.OnSendMessage);
	GameWorld:AddClick(GameWorldPanel.btnResetView, this.OnResetView);
	GameWorld:AddClick(GameWorldPanel.btnSkill1, this.OnAttackSkill1);
	GameWorld:AddClick(GameWorldPanel.btnSkill2, this.OnAttackSkill2);
	GameWorld:AddClick(GameWorldPanel.btnSkill3, this.OnAttackSkill3);

	logWarn("Start lua--->>"..gameObject.name);

	Event.AddListener("OnDie", this.OnDie);
	Event.AddListener("ReceiveChatMessage", this.ReceiveChatMessage);

	--做一些初始化工作
	local p = KBEngineLua.player();
	if p ~= nil then
		this.OnDie(p.state);
	end
	this.SetSkillButton();
end

--复活--
function GameWorldCtrl.OnRelive(go)

	local p = KBEngineLua.player();
	if p ~= nil then
		p:relive(1);
	end
end

--关闭游戏--
function GameWorldCtrl.OnClose(go)
	UnityEngine.Application.Quit();
end

--发送聊天
function GameWorldCtrl.OnSendMessage(go)
	local p = KBEngineLua.player();
	if p ~= nil and string.len(GameWorldPanel.input_content.text) > 0 then
		Event.Brocast("sendChatMessage", p, GameWorldPanel.input_content.text);
	end
end

--重置视角
function GameWorldCtrl.OnResetView(go)
	CameraFollow:ResetView();
end

--关闭事件--
function GameWorldCtrl.Close()
	--panelMgr:ClosePanel(CtrlNames.Login);
	destroy(gameObject);
	Event.RemoveListener("onConnectStatus", this.onConnectStatus);
end

--设置技能按钮--
function GameWorldCtrl.SetSkillButton()
	if #SkillBox.skills == 3 then
		GameWorldPanel.btnSkill1.transform:FindChild("Text"):GetComponent("Text").text = SkillBox.skills[1].name;
		GameWorldPanel.btnSkill2.transform:FindChild("Text"):GetComponent("Text").text = SkillBox.skills[2].name;
		GameWorldPanel.btnSkill3.transform:FindChild("Text"):GetComponent("Text").text = SkillBox.skills[3].name;
	end
end

function GameWorldCtrl.AttackSkill(skillID )
	local player = KBEngineLua.player();
    
    if (player == nil) then
        return;
    end

    -- UI_Target ui_target = World.instance.getUITarget();
    -- if (ui_target != null && ui_target.GE_target != null)
    -- {
    --     string name = ui_target.GE_target.name;
    --     Int32 entityId = Utility.getPostInt(name);

    --     if (avatar != null)
    --     {
    --         int errorCode = avatar.useTargetSkill(skillId, entityId);
    --         if (errorCode == 1)
    --         {
    --             UI_ErrorHint._instance.errorShow("目标太远");
    --             //逼近目标
    --             UnityEngine.GameObject renderEntity = (UnityEngine.GameObject)entity.renderObj;
    --             renderEntity.GetComponent<MoveController>().moveTo(ui_target.GE_target.transform, SkillBox.inst.get(skillId).canUseDistMax-1, skillId);
    --         }
    --         if (errorCode == 2)
    --         {
    --             UI_ErrorHint._instance.errorShow("技能冷却");
    --         }
    --         if (errorCode == 3)
    --         {
    --             UI_ErrorHint._instance.errorShow("目标已死亡");
    --         }
    --     }
    -- }
end

function GameWorldCtrl.OnAttackSkill1( )
	this.AttackSkill(SkillBox.skills[1].id);
end
function GameWorldCtrl.OnAttackSkill2( )
	this.AttackSkill(SkillBox.skills[2].id);
end
function GameWorldCtrl.OnAttackSkill3( )
	this.AttackSkill(SkillBox.skills[3].id);
end

------------事件--
--死亡--
function GameWorldCtrl.OnDie(v)
	if v == 1 then
		GameWorldPanel.PanelDie:SetActive(true);
	else
		GameWorldPanel.PanelDie:SetActive(false);
	end
end

--接受信息
function GameWorldCtrl.ReceiveChatMessage(msg)
	local text = GameWorldPanel.textContent:GetComponent("Text");

	if (string.len(text.text) > 0) then
        text.text = text.text .. "\n" .. msg;
    else
        text.text = text.text .. msg;
    end

    if (text.preferredHeight + 30 > 67) then
        GameWorldPanel.textContent:GetComponent("RectTransform").sizeDelta = Vector2.New(0, text.preferredHeight);
    end

    GameWorldPanel.sb_vertical.value = 0;
    GameWorldPanel.input_content.text = "";
end


