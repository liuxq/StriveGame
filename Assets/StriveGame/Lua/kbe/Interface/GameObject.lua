require "Entity"

KBEngineLua.GameObject = {
	gameEntity = nil,
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

function KBEngineLua.GameObject:set_direction(old)
	-- self.direction.x = self.direction.x * 360 / (Mathf.PI * 2);
	-- self.direction.y = self.direction.y * 360 / (Mathf.PI * 2);
	-- self.direction.z = self.direction.z * 360 / (Mathf.PI * 2);
	if(self.inWorld) then
		Event.Brocast("set_direction", self);
	end
end

function KBEngineLua.GameObject:set_name(old)
	local v = self.name;
	Event.Brocast("set_name", self, v);
end

function KBEngineLua.GameObject:set_state(old)
	local v = self.state;
	Event.Brocast("set_state", self, v);
end

function KBEngineLua.GameObject:set_HP(old)
	local v = self.HP;
	Event.Brocast("set_HP", self, v);
end

function KBEngineLua.GameObject:set_HP_Max(old)
	local v = self.HP_Max;
	Event.Brocast("set_HP_Max", self, v);
end

function KBEngineLua.GameObject:recvDamage(attackerID, skillID, damageType, damage)
--Dbg.DEBUG_MSG(className + "::recvDamage: attackerID=" + attackerID + ", skillID=" + skillID + ", damageType=" + damageType + ", damage=" + damage);
			
	local entity = KBEngineLua.findEntity(attackerID);
	Event.Brocast("recvDamage", self, entity, skillID, damageType, damage);
end