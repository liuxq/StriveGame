
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
	caster:cellCall({"useTargetSkill", self.id, target.id});
    self.restCoolTimer = 0;
end

function Skill:displaySkill(caster, target)
    if (self.displayType == 1) then
        resMgr:LoadPrefab('Skill', { self.skillEffect }, function(objs)
			local renderObj = newObject(objs[0]);
			local fly = renderObj:GetComponent("NcEffectFlying");
	        fly.FromPos = Vector3.New(caster.position.x, caster.position.y+1, caster.position.z);
	        fly.ToPos = Vector3.New(target.position.x, target.position.y+1, target.position.z);
	        --fly.Speed = 5.0f;
	        --fly.HWRate = 0;
		end);

        
    elseif (self.displayType == 0) then
        resMgr:LoadPrefab('Skill', { self.skillEffect }, function(objs)
			local renderObj = newObject(objs[0]);
			renderObj.transform.position = Vector3.New(target.position.x, target.position.y+1, target.position.z);
		end);
    end
end