
SkillControl = {};

local this = SkillControl;

function SkillControl.Init(player)
	if player == nil then
		return;
	end

	this.hasDes = false;
	this.transform = player.renderObj.transform;
	this.animator = player.renderObj:GetComponent("Animator");

end
function SkillControl.Update()
	--更新技能的冷却时间
	for i, sk in ipairs(SkillBox.skills) do
		sk:updateTimer(Time.deltaTime);
    end

    --自动追击
    if (this.hasDes) then    
        if (Vector3.Distance(this.transform.position, this.moveDes.position) < this.minLen) then        
            this.hasDes = false;
            this.animator.speed = 1.0;
            this.animator:SetFloat("Speed", 0.0);
            GameWorldCtrl.AttackSkill(this.skillId);
        else        
            this.transform:LookAt(this.moveDes);
            this.transform:Translate(Vector3.forward * Time.deltaTime * 5);
            --移动摄像机
            CameraFollow.FollowUpdate();
            --播放奔跑动画
            this.animator.speed = 2.0;
            this.animator:SetFloat("Speed", 1.0);
        end
    end
end

function SkillControl.Stop()
	this.hasDes = false;
end

function SkillControl.MoveTo(des, minLen, skillId)
    this.hasDes = true;
    this.moveDes = des;
    this.minLen = minLen;
    this.skillId = skillId;
end