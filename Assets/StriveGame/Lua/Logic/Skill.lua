
Skill = {
	name = "",
	descr = "",
	id = 0,
	canUseDistMin = 0,
	canUseDistMax = 3,
	coolTime = 0.5,

	-- SkillDisplay_Event_Effect = 0
	-- SkillDisplay_Event_Bullet = 1
	displayType = 1,

	skillEffect = "",
	restCoolTimer = 0,

};

function Skill:New( me )
 	me = me or {};
 	setmetatable(me, self);
 	self.__index = self;
 	return me;
end

--1: 太远， 2：冷却，3：已死亡
function Skill:validCast(caster, target)
	local dist = Vector3.Distance(target.position, caster.position);
    if dist > self.canUseDistMax then
        return 1;
    elseif self.restCoolTimer < self.coolTime then
        return 2;
    elseif caster.state == 1 then
        return 3;
    end
    return 0;
end

function Skill:updateTimer(second)
    self.restCoolTimer = self.restCoolTimer + second;
end
		
function Skill:use(caster, target)
	caster:cellCall("useTargetSkill", self.id, target.id);
    self.restCoolTimer = 0;
end

function Skill:displaySkill(caster, target)   
    if (self.displayType == 1) then   
        resMgr:LoadPrefab('Skill', { SkillBox.dictSkillDisplay[skillEffect] }, function(objs)
			local renderObj = newObject(objs[0]);
			local fly = renderObj:AddComponent("NcEffectFlying");
	        fly.FromPos = caster.position;
	        fly.FromPos.y = 1;
	        fly.ToPos = target.position;
	        fly.ToPos.y = 1;
	        --fly.Speed = 5.0f;
	        --fly.HWRate = 0;
		end);

        
    elseif (self.displayType == 0) then
        local pos = target.position;
        pos.y = 1;
        
        UnityEngine.Object.Instantiate(SkillBox.inst.dictSkillDisplay[skillEffect], pos, Quaternion.identity);

        resMgr:LoadPrefab('Skill', { SkillBox.dictSkillDisplay[skillEffect] }, function(objs)
			local renderObj = newObject(objs[0]);
			renderObj.transform.position = pos;
		end);
    end
end