--	持久化引擎协议，在检测到协议版本发生改变时会清理协议

KBEngineLua.PersistentInfos = {}

function KBEngineLua.PersistentInfos:New( path )
	local me =  {};
	setmetatable(me, self);
	self.__index = self;

	me._persistentDataPath = path;
	me._digest = "";

	me._isGood = me:loadAll();

    return me;
end
	
function KBEngineLua.PersistentInfos:isGood()
	return self._isGood;
end

function KBEngineLua.PersistentInfos:_getSuffixBase()
    local clientVersion, clientScriptVersion, ip, port = KBEngineLua.GetArgs();
	return clientVersion .. "." .. clientScriptVersion .. "." .. ip .. "." .. port;
end

function KBEngineLua.PersistentInfos:_getSuffix()
	return self._digest .. "." .. self:_getSuffixBase();
end

function KBEngineLua.PersistentInfos:loadAll()
	
	local kbengine_digest = KBELuaUtil.loadFile (self._persistentDataPath, "kbengine.digest." .. self:_getSuffixBase(), false);
	if(kbengine_digest.Length <= 0) then
		self:clearMessageFiles();
		return false;
	end

	

	self._digest = KBELuaUtil.bytesToString(kbengine_digest);
	
	local loginapp_onImportClientMessages = KBELuaUtil.loadFile(self._persistentDataPath, "loginapp_clientMessages." .. self:_getSuffix(), false);

	local baseapp_onImportClientMessages = KBELuaUtil.loadFile(self._persistentDataPath, "baseapp_clientMessages." .. self:_getSuffix(), false);

	local onImportServerErrorsDescr = KBELuaUtil.loadFile(self._persistentDataPath, "serverErrorsDescr." .. self:_getSuffix(), false);

	local onImportClientEntityDef = KBELuaUtil.loadFile(self._persistentDataPath, "clientEntityDef." .. self:_getSuffix(), false);

	if(loginapp_onImportClientMessages.Length > 0 and baseapp_onImportClientMessages.Length > 0) then
        local re = KBEngineLua.importMessagesFromMemoryStream(loginapp_onImportClientMessages, baseapp_onImportClientMessages, onImportClientEntityDef, onImportServerErrorsDescr);

        if (not re) then
            self:clearMessageFiles();
            return false;
        end
		
	end
	
	return true;
end

function KBEngineLua.PersistentInfos:onImportClientMessages(currserver, stream)
	if(currserver == "loginapp") then
		KBELuaUtil.createFile (self._persistentDataPath, "loginapp_clientMessages." .. self:_getSuffix(), stream);
	else
		KBELuaUtil.createFile (self._persistentDataPath, "baseapp_clientMessages." .. self:_getSuffix(), stream);
	end
end

function KBEngineLua.PersistentInfos:onImportServerErrorsDescr(stream)
	KBELuaUtil.createFile (self._persistentDataPath, "serverErrorsDescr." .. self:_getSuffix(), stream);
end

function KBEngineLua.PersistentInfos:onImportClientEntityDef(stream)
	KBELuaUtil.createFile (self._persistentDataPath, "clientEntityDef." .. self:_getSuffix(), stream);
end

function KBEngineLua.PersistentInfos:onVersionNotMatch(verInfo, serVerInfo)
	self:clearMessageFiles();
end

function KBEngineLua.PersistentInfos:onScriptVersionNotMatch(verInfo, serVerInfo)
	self:clearMessageFiles();
end

function KBEngineLua.PersistentInfos:onServerDigest(currserver, serverProtocolMD5, serverEntitydefMD5)
	-- 我们不需要检查网关的协议， 因为登录loginapp时如果协议有问题已经删除了旧的协议
	if(currserver == "baseapp") then
		return;
	end
	
	if(self._digest ~= serverProtocolMD5 .. serverEntitydefMD5) then
		self._digest = serverProtocolMD5 .. serverEntitydefMD5;

		self:clearMessageFiles();
	else
		return;
	end
	
	if(KBELuaUtil.loadFile(self._persistentDataPath, "kbengine.digest." .. self:_getSuffixBase(), false).Length) then
		KBELuaUtil.createFile(self._persistentDataPath, "kbengine.digest." .. self:_getSuffixBase(), KBELuaUtil.stringToBytes(serverProtocolMD5 .. serverEntitydefMD5));
	end
end
	
function KBEngineLua.PersistentInfos:clearMessageFiles()
	KBELuaUtil.deleteFile(self._persistentDataPath, "kbengine.digest." .. self:_getSuffixBase());
	KBELuaUtil.deleteFile(self._persistentDataPath, "loginapp_clientMessages." .. self:_getSuffix());
	KBELuaUtil.deleteFile(self._persistentDataPath, "baseapp_clientMessages." .. self:_getSuffix());
	KBELuaUtil.deleteFile(self._persistentDataPath, "serverErrorsDescr." .. self:_getSuffix());
	KBELuaUtil.deleteFile(self._persistentDataPath, "clientEntityDef." .. self:_getSuffix());

    KBEngineLua.resetMessages();
end
