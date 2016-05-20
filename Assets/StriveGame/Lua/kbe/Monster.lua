require "KbePlugins/Entity"

KBEngineLua.Monster = {
};

KBEngineLua.Monster = KBEngineLua.Entity:New(KBEngineLua.Monster);--继承

function KBEngineLua.Monster:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end
