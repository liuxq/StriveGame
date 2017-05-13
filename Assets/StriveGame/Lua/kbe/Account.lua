require "Kbe/Interface/GameObject"

KBEngineLua.Account = {
	avatars = {},
};

KBEngineLua.Account = KBEngineLua.GameObject:New(KBEngineLua.Account);--继承

function KBEngineLua.Account:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end

function KBEngineLua.Account:__init__( )
	Event.Brocast("onLoginSuccessfully", true)
    self:baseCall({"reqAvatarList"});
end

function KBEngineLua.Account:reqCreateAvatar(name, roleType)
    local role = 1;
    if (roleType == "战士") then
        role = 1;
    elseif (roleType == "法师") then
        role = 2;
    end
    self:baseCall({ "reqCreateAvatar", name, role });
end

function KBEngineLua.Account:reqRemoveAvatar(name)
    log("Account::reqRemoveAvatar: name=" .. name);
    self:baseCall({"reqRemoveAvatar", name});
end

function KBEngineLua.Account:reqSelectAvatarGame(dbid)
    log("Account::reqSelectAvatarGame: dbid=" .. tostring(dbid));
    self:baseCall({"selectAvatarGame", dbid});
end


--------------回调-------------------------------------------
function KBEngineLua.Account:onReqAvatarList( infos )
    self.avatars = {};

    local listinfos = infos["values"];

    log("Account::onReqAvatarList: avatarsize=" .. #listinfos);
    
    for i, info in ipairs(listinfos) do
        log("Account::onReqAvatarList: name" .. i .. "=" .. info["name"]);
        self.avatars[info["dbid"]] = info;
    end
    
    Event.Brocast("onReqAvatarList", self.avatars);

end

function KBEngineLua.Account:onCreateAvatarResult(retcode, info)
    if (retcode == 0) then
        self.avatars[info["dbid"]] = info;
        log("Account::onCreateAvatarResult: name=" .. info["name"]);
    else
        log("Account::onCreateAvatarResult: retcode=" .. retcode);
        if (retcode == 3) then
            log("角色数量不能超过三个！");
        end
    end

    Event.Brocast("onCreateAvatarResult", retcode, self.avatars);
end

function KBEngineLua.Account:onRemoveAvatar(dbid)
    log("Account::onRemoveAvatar: dbid=" .. tostring(dbid));


    for k,v in pairs(self.avatars) do
        if(k == dbid) then
            self.avatars[k] = nil;
        end
    end
    -- ui event
    Event.Brocast("onRemoveAvatar", dbid, self.avatars);
end