require "KbePlugins/Entity"

KBEngineLua.DroppedItem = {
};

KBEngineLua.DroppedItem = KBEngineLua.Entity:New(KBEngineLua.DroppedItem);--继承

function KBEngineLua.DroppedItem:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end
