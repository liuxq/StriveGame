require "Kbe/Interface/GameObject"

KBEngineLua.NPC = {
};

KBEngineLua.NPC = KBEngineLua.GameObject:New(KBEngineLua.NPC);--继承

function KBEngineLua.NPC:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end
