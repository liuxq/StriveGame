require "Kbe/Interface/GameObject"

KBEngineLua.Gate = {
};

KBEngineLua.Gate = KBEngineLua.GameObject:New(KBEngineLua.Gate);--继承

function KBEngineLua.Gate:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end
