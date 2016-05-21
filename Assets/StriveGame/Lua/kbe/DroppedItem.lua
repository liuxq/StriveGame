require "Kbe/Interface/GameObject"

KBEngineLua.DroppedItem = {
};

KBEngineLua.DroppedItem = KBEngineLua.GameObject:New(KBEngineLua.DroppedItem);--继承

function KBEngineLua.DroppedItem:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end
