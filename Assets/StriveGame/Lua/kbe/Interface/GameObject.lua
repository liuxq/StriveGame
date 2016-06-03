require "KbePlugins/Entity"

KBEngineLua.GameObject = {
};

KBEngineLua.GameObject = KBEngineLua.Entity:New(KBEngineLua.GameObject);--继承

function KBEngineLua.GameObject:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end

function KBEngineLua.GameObject:set_position( old )
	if(self:isPlayer()) then
		KBEngineLua.entityServerPos.x = self.position.x;
		KBEngineLua.entityServerPos.y = self.position.y;
		KBEngineLua.entityServerPos.z = self.position.z;
	end
end

function KBEngineLua.Entity:set_direction(old)
	--log(self.className .. "::set_direction: " .. old.x ..old.y ..old.z);  	
	self.direction.x = self.direction.x * 360 / (Mathf.PI * 2);
	self.direction.y = self.direction.y * 360 / (Mathf.PI * 2);
	self.direction.z = self.direction.z * 360 / (Mathf.PI * 2);
	--log(className + "::set_direction: " + old + " => " + v); 
	-- if(inWorld)
	-- 	Event.fireOut("set_direction", new object[]{this});
end

function KBEngineLua.Entity:set_name(old)
	local v = self.name;
	Event.Brocast("set_name", self, v);
end

function KBEngineLua.Entity:set_state(old)
	local v = self.state;
	Event.Brocast("set_state", self, v);
end

function KBEngineLua.Entity:set_HP(old)
	local v = self.HP;
	Event.Brocast("set_HP", self, v);
end

function KBEngineLua.Entity:set_HP_Max(old)
	local v = self.HP_Max;
	Event.Brocast("set_HP_Max", self, v);
end

function KBEngineLua.Entity:recvDamage(attackerID, skillID, damageType, damage)
--Dbg.DEBUG_MSG(className + "::recvDamage: attackerID=" + attackerID + ", skillID=" + skillID + ", damageType=" + damageType + ", damage=" + damage);
			
	local entity = KBEngineLua.findEntity(attackerID);
	Event.Brocast("recvDamage", self, entity, skillID, damageType, damage);
end