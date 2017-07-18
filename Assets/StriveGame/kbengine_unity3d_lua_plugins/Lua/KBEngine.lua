
KBEngineLua = {}
local this = KBEngineLua;

require "LuaUtil"
require "DataType"
require "Message"
require "Bundle"
require "Mailbox"
require "Entity"
require "PersistentInfos"



-----------------可配置信息---------------
KBEngineLua.ip = "127.0.0.1";
KBEngineLua.port = "20013";
-- Mobile(Phone, Pad)	= 1,
-- Windows Application program	= 2,
-- Linux Application program = 3,	
-- Mac Application program	= 4,	
-- Web，HTML5，Flash		= 5,
-- bots			= 6,
-- Mini-Client			= 7,
KBEngineLua.clientType = 1;
KBEngineLua.isOnInitCallPropertysSetMethods = true;
KBEngineLua.useAliasEntityID = true;
-----------------end-------------------------


KBEngineLua.MAILBOX_TYPE_CELL = 0;
KBEngineLua.MAILBOX_TYPE_BASE = 1;
KBEngineLua.KBE_FLT_MAX	= 3.402823466e+38;

------debug级别
Dbg.debugLevel = DEBUGLEVEL.DEBUG;

----- player的相关信息
-- 当前玩家的实体id与实体类别
KBEngineLua.entity_uuid = nil;
KBEngineLua.entity_id = 0;
KBEngineLua.entity_type = "";

KBEngineLua.controlledEntities = {};

KBEngineLua.entityServerPos = Vector3.New(0.0, 0.0, 0.0);

KBEngineLua.syncPlayer = true;

-- 空间的信息
KBEngineLua.spacedata = {};
KBEngineLua.spaceID = 0;
KBEngineLua.spaceResPath = "";
KBEngineLua.isLoadedGeometry = false;

-- 账号信息
KBEngineLua.username = "kbengine";
KBEngineLua.password = "123456";

-- 网络信息
KBEngineLua.currserver = "";
KBEngineLua.currstate = "";

-- 服务端分配的baseapp地址
KBEngineLua.baseappIP = "";
KBEngineLua.baseappPort = nil;

KBEngineLua._serverdatas = {};
KBEngineLua._clientdatas = {};

-- 通信协议加密，blowfish协议--没用过~
KBEngineLua._encryptedKey = "";

-- 服务端与客户端的版本号以及协议MD5
KBEngineLua.clientVersion = "0.9.12";
KBEngineLua.clientScriptVersion = "0.1.0";
KBEngineLua.serverVersion = "";
KBEngineLua.serverScriptVersion = "";
KBEngineLua.serverProtocolMD5 = "";
KBEngineLua.serverEntitydefMD5 = "";

-- 各种存储结构
KBEngineLua.moduledefs = {};
KBEngineLua.serverErrs = {};
KBEngineLua.entities = {};
KBEngineLua.entityIDAliasIDList = {};
KBEngineLua.bufferedCreateEntityMessage = {};

-- 持久化
KBEngineLua._persistentInfos = nil;

-- 是否正在加载本地消息协议
KBEngineLua.loadingLocalMessages_ = false;
-- 各种协议是否已经导入了
KBEngineLua.loginappMessageImported_ = false;
KBEngineLua.baseappMessageImported_ = false;
KBEngineLua.entitydefImported_ = false;
KBEngineLua.isImportServerErrorsDescr_ = false;

-- 控制网络间隔
KBEngineLua._lastTickTime = os.clock();
KBEngineLua._lastTickCBTime = os.clock();
KBEngineLua._lastUpdateToServerTime = os.clock();

--网络接口
KBEngineLua._networkInterface = nil;


KBEngineLua.GetArgs = function()
	return this.clientVersion, this.clientScriptVersion, this.ip, this.port;
end

KBEngineLua.int82angle = function(angle, half)
	local halfv = 128;
	if(half == true) then
		halfv = 254;
	end
	
	halfv = angle * (Mathf.PI / halfv);
	return halfv;
end

KBEngineLua.InitEngine = function()
	this._networkInterface = KBEngine.NetworkInterface.New();
	KBEngineLua.Message.bindFixedMessage();
	this._persistentInfos = KBEngineLua.PersistentInfos:New(UnityEngine.Application.persistentDataPath);
	FixedUpdateBeat:Add(this.process, this);
end

KBEngineLua.Destroy = function()
	log("KBEngine::destroy()");  	
	this.reset();
	this.resetMessages();
end

KBEngineLua.player = function()
	return KBEngineLua.entities[KBEngineLua.entity_id];
end

KBEngineLua.findEntity = function(entityID)
	return KBEngineLua.entities[entityID];
end

KBEngineLua.resetMessages = function()
    this.loadingLocalMessages_ = false;
	this.loginappMessageImported_ = false;
	this.baseappMessageImported_ = false;
	this.entitydefImported_ = false;
	this.isImportServerErrorsDescr_ = false;
	this.serverErrs = {};
	this.Message.clear();
	this.moduledefs = {};
	this.entities = {};

	log("KBEngine::resetMessages()");
end

KBEngineLua.importMessagesFromMemoryStream = function(loginapp_clientMessages, baseapp_clientMessages,  entitydefMessages, serverErrorsDescr)

	this.resetMessages();
	
	this.loadingLocalMessages_ = true;
	local stream = KBEngine.MemoryStream.New();
	stream:append(loginapp_clientMessages, 0, loginapp_clientMessages.Length);
	this.currserver = "loginapp";
	this.onImportClientMessages(stream);

	stream = KBEngine.MemoryStream.New();
	stream:append(baseapp_clientMessages, 0, baseapp_clientMessages.Length);
	this.currserver = "baseapp";
	this.onImportClientMessages(stream);
	this.currserver = "loginapp";

	stream = KBEngine.MemoryStream.New();
	stream:append(serverErrorsDescr, 0, serverErrorsDescr.Length);
	this.onImportServerErrorsDescr(stream);
		
	stream = KBEngine.MemoryStream.New();
	stream:append(entitydefMessages, 0, entitydefMessages.Length);
	this.onImportClientEntityDef(stream);

	this.loadingLocalMessages_ = false;
	this.loginappMessageImported_ = true;
	this.baseappMessageImported_ = true;
	this.entitydefImported_ = true;
	this.isImportServerErrorsDescr_ = true;

	this.currserver = "";
	log("KBEngine::importMessagesFromMemoryStream(): is successfully!");
	return true;
end

KBEngineLua.createDataTypeFromStreams = function(stream, canprint)
	local aliassize = stream:readUint16();
	log("KBEngineApp::createDataTypeFromStreams: importAlias(size=" .. aliassize .. ")!");
	
	while(aliassize > 0)
    do  
		aliassize = aliassize -1;
		KBEngineLua.createDataTypeFromStream(stream, canprint);
	end
	
	for k, datatype in pairs(KBEngineLua.datatypes) do
		if(KBEngineLua.datatypes[k] ~= nil) then
			KBEngineLua.datatypes[k]:bind();
		end
	end
end
KBEngineLua.createDataTypeFromStream = function(stream, canprint)
	local utype = stream:readUint16();
	local name = stream:readString();
	local valname = stream:readString();
	
	-- 有一些匿名类型，我们需要提供一个唯一名称放到datatypes中
	-- 如：
	-- <onRemoveAvatar>
	-- 	<Arg>	ARRAY <of> INT8 </of>		</Arg>
	-- </onRemoveAvatar>				
	
	if(string.len(valname) == 0) then
		valname = "nil_" .. utype;
	end
		
	if(canprint) then
		log("KBEngineApp::Client_onImportClientEntityDef: importAlias(" .. name .. ":" .. valname .. ")!");
	end
	
	if(name == "FIXED_DICT") then
		local datatype = KBEngineLua.DATATYPE_FIXED_DICT:New();
		local keysize = stream:readUint8();
		datatype.implementedBy = stream:readString();
			
		while(keysize > 0)
        do
			keysize = keysize -1;
			local keyname = stream:readString();
			local keyutype = stream:readUint16();
			table.insert(datatype.dictKeys, keyname);
			datatype.dicttype[keyname] = keyutype;
		end
		
		KBEngineLua.datatypes[valname] = datatype;
	elseif(name == "ARRAY") then
		local uitemtype = stream:readUint16();
		local datatype = KBEngineLua.DATATYPE_ARRAY:New();
		datatype._type = uitemtype;
		KBEngineLua.datatypes[valname] = datatype;
	else
		KBEngineLua.datatypes[valname] = KBEngineLua.datatypes[name];
	end

	KBEngineLua.datatypes[utype] = KBEngineLua.datatypes[valname];
	
	-- 将用户自定义的类型补充到映射表中
	KBEngineLua.datatype2id[valname] = utype;
end

KBEngineLua.Client_onImportClientEntityDef = function(stream)
	local datas = stream:getbuffer();
	this.onImportClientEntityDef(stream);
	if(this._persistentInfos ~= nil) then
		this._persistentInfos:onImportClientEntityDef(datas);
	end
end

KBEngineLua.onImportClientEntityDef = function(stream)
	KBEngineLua.createDataTypeFromStreams(stream, false);

	while(stream:length() > 0)
	do
		local scriptmodule_name = stream:readString();
		local scriptUtype = stream:readUint16();
		local propertysize = stream:readUint16();
		local methodsize = stream:readUint16();
		local base_methodsize = stream:readUint16();
		local cell_methodsize = stream:readUint16();
		
		log("KBEngineApp::Client_onImportClientEntityDef: import(" .. scriptmodule_name .. "), propertys(" .. propertysize .. "), " ..
				"clientMethods(" .. methodsize .. "), baseMethods(" .. base_methodsize .. "), cellMethods(" .. cell_methodsize .. ")~");
		
		KBEngineLua.moduledefs[scriptmodule_name] = {};
		local currModuleDefs = KBEngineLua.moduledefs[scriptmodule_name];
		currModuleDefs["name"] = scriptmodule_name;
		currModuleDefs["propertys"] = {};
		currModuleDefs["methods"] = {};
		currModuleDefs["base_methods"] = {};
		currModuleDefs["cell_methods"] = {};
		KBEngineLua.moduledefs[scriptUtype] = currModuleDefs;
		
		local self_propertys = currModuleDefs["propertys"];
		local self_methods = currModuleDefs["methods"];
		local self_base_methods = currModuleDefs["base_methods"];
		local self_cell_methods= currModuleDefs["cell_methods"];
		
		local Class = KBEngineLua[scriptmodule_name];

		while(propertysize > 0)
		do
			propertysize = propertysize - 1;
			
			local properUtype = stream:readUint16();
			local properFlags = stream:readUint32();
			local aliasID = stream:readInt16();
			local name = stream:readString();
			local defaultValStr = stream:readString();
			local utype = KBEngineLua.datatypes[stream:readUint16()];
			local setmethod = nil;--函数
			if(Class ~= nil) then
				setmethod = Class["set_" .. name];
			end
			
			local savedata = {properUtype, aliasID, name, defaultValStr, utype, setmethod, properFlags};
			self_propertys[name] = savedata;
			
			if(aliasID >= 0) then
				self_propertys[aliasID] = savedata;
				currModuleDefs["usePropertyDescrAlias"] = true;
			else
				self_propertys[properUtype] = savedata;
				currModuleDefs["usePropertyDescrAlias"] = false;
			end
			
			log("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), property(" .. name .. "/" .. properUtype .. ").");
		end
		while(methodsize > 0)
		do
			methodsize = methodsize - 1;
			
			local methodUtype = stream:readUint16();
			local aliasID = stream:readInt16();
			local name = stream:readString();
			local argssize = stream:readUint8();
			local args = {};
			
			while(argssize > 0)
			do
				argssize = argssize - 1;
				table.insert(args,KBEngineLua.datatypes[stream:readUint16()]);
			end
			
			local savedata = {methodUtype, aliasID, name, args};
			self_methods[name] = savedata;
			
			if(aliasID >= 0) then
				self_methods[aliasID] = savedata;
				currModuleDefs["useMethodDescrAlias"] = true;
			else
				self_methods[methodUtype] = savedata;
				currModuleDefs["useMethodDescrAlias"] = false;
			end
			
			log("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), method(" .. name .. ").");
		end

		while(base_methodsize > 0)
		do
			base_methodsize = base_methodsize - 1;
			
			local methodUtype = stream:readUint16();
			local aliasID = stream:readInt16();
			local name = stream:readString();
			local argssize = stream:readUint8();
			local args = {};
			
			while(argssize > 0)
            do
				argssize = argssize - 1;
				table.insert(args,KBEngineLua.datatypes[stream:readUint16()]);
			end
			
			self_base_methods[name] = {methodUtype, aliasID, name, args};
			log("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), base_method(" .. name .. ").");
		end
		
		while(cell_methodsize > 0)
		do
			cell_methodsize = cell_methodsize - 1;
			
			local methodUtype = stream:readUint16();
			local aliasID = stream:readInt16();
			local name = stream:readString();
			local argssize = stream:readUint8();
			local args = {};
			
			while(argssize > 0)
			do
				argssize = argssize -1;
				table.insert(args,KBEngineLua.datatypes[stream:readUint16()]);
			end
			
			self_cell_methods[name] = {methodUtype, aliasID, name, args};
			log("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), cell_method(" .. name .. ").");
		end
		
		defmethod = KBEngineLua[scriptmodule_name];
		if defmethod == nil then
			log("KBEngineApp::Client_onImportClientEntityDef: module(" .. scriptmodule_name .. ") not found~");
		end
		
		for k, value in pairs(currModuleDefs.propertys) do
			local infos = value;
			local properUtype = infos[1];
			local aliasID = infos[2];
			local name = infos[3];
			local defaultValStr = infos[4];
			local utype = infos[5];

			if(defmethod ~= nil) then
				defmethod[name] = utype:parseDefaultValStr(defaultValStr);
            end
		end

		for k, value in pairs(currModuleDefs.methods) do
			local infos = value;
			local properUtype = infos[1];
			local aliasID = infos[2];
			local name = infos[3];
			local args = infos[4];
			
			if(defmethod ~= nil and defmethod[name] == nil) then
				log(scriptmodule_name .. ":: method(" .. name .. ") no implement~");
			end
		end
	end
	this.onImportEntityDefCompleted();
end

KBEngineLua.Client_onImportClientMessages = function( stream )
	local datas = stream:getbuffer();
	this.onImportClientMessages (stream);
	
	if(this._persistentInfos ~= nil) then
		this._persistentInfos:onImportClientMessages(this.currserver, datas);
	end
end

KBEngineLua.onImportClientMessages = function( stream )
	local msgcount = stream:readUint16();
	
	log("KBEngineApp::onImportClientMessages: start(" .. msgcount .. ") ...!");
	
	while(msgcount > 0)
	do
		msgcount = msgcount - 1;
		
		local msgid = stream:readUint16();
		local msglen = stream:readInt16();

		local msgname = stream:readString();
		local argtype = stream:readInt8();
		local argsize = stream:readUint8();
		local argstypes = {};
		
		for i = 1, argsize, 1 do
			table.insert(argstypes, stream:readUint8());
		end
		
		local handler = nil;
		local isClientMethod = string.find(msgname, "Client_") ~= nil;
		if isClientMethod then
			handler = KBEngineLua[msgname];
			if handler == nil then
				log("KBEngineApp::onImportClientMessages[" .. KBEngineLua.currserver .. "]: interface(" .. msgname .. "/" .. msgid .. ") no implement!");
			else
				log("KBEngineApp::onImportClientMessages: import(" .. msgname .. ") successfully!");
			end
		end
	
		if string.len(msgname) > 0 then
			KBEngineLua.messages[msgname] = KBEngineLua.Message:New(msgid, msgname, msglen, argtype, argstypes, handler);
			
			if isClientMethod then
				KBEngineLua.clientMessages[msgid] = KBEngineLua.messages[msgname];
			else
				KBEngineLua.messages[KBEngineLua.currserver][msgid] = KBEngineLua.messages[msgname];
			end
		else
			KBEngineLua.messages[KBEngineLua.currserver][msgid] = KBEngineLua.Message:New(msgid, msgname, msglen, argtype, argstypes, handler);
		end
	end

	KBEngineLua.onImportClientMessagesCompleted();
end

KBEngineLua.Client_onImportServerErrorsDescr = function(stream)
	local datas = stream:getbuffer();
	this.onImportServerErrorsDescr(stream);
	
	if(this._persistentInfos ~= nil) then
		this._persistentInfos:onImportServerErrorsDescr(datas);
	end
end

KBEngineLua.onImportServerErrorsDescr = function(stream)
	local size = stream:readUint16();
	while size > 0
	do
		size = size - 1;
		
		local e = {};
		e.id = stream:readUint16();
		e.name = KBELuaUtil.ByteToUtf8(stream:readBlob());
		e.descr = KBELuaUtil.ByteToUtf8(stream:readBlob());
		
		this.serverErrs[e.id] = e;
		--log("Client_onImportServerErrorsDescr: id=" + e.id + ", name=" + e.name + ", descr=" + e.descr);
	end
end
	-- 从二进制流导入消息协议完毕了
KBEngineLua.onImportClientMessagesCompleted = function()
	log("KBEngine::onImportClientMessagesCompleted: successfully! currserver=" .. 
		this.currserver .. ", currstate=" .. this.currstate);

	if(this.currserver == "loginapp") then
		if(not this.isImportServerErrorsDescr_ and not this.loadingLocalMessages_) then
			log("KBEngine::onImportClientMessagesCompleted(): send importServerErrorsDescr!");
			this.isImportServerErrorsDescr_ = true;
			local bundle = KBEngineLua.Bundle:New();
			bundle:newMessage(KBEngineLua.messages["Loginapp_importServerErrorsDescr"]);
			bundle:send();
		end
		
		if(this.currstate == "login") then
			this.login_loginapp(false);
		elseif(this.currstate == "autoimport") then
		elseif(this.currstate == "resetpassword") then
			this.resetpassword_loginapp(false);
		elseif(this.currstate == "createAccount") then
			this.createAccount_loginapp(false);
		end

		this.loginappMessageImported_ = true;
	else
		this.baseappMessageImported_ = true;
		
		if(not this.entitydefImported_ and not this.loadingLocalMessages_) then
			log("KBEngine::onImportClientMessagesCompleted: send importEntityDef(" .. (this.entitydefImported_ and "true" or "false")  .. ") ...");
			local bundle = KBEngineLua.Bundle:New();
			bundle:newMessage(KBEngineLua.messages["Baseapp_importClientEntityDef"]);
			bundle:send();
			--Event.fireOut("Baseapp_importClientEntityDef", new object[]{});
		else
			this.onImportEntityDefCompleted();
		end
	end
end
KBEngineLua.onImportEntityDefCompleted = function()
	log("KBEngine::onImportEntityDefCompleted: successfully!");
	this.entitydefImported_ = true;
	
	if(not this.loadingLocalMessages_) then
		this.login_baseapp(false);
	end
end
KBEngineLua.Client_onCreatedProxies = function(rndUUID, eid, entityType)

	log("KBEngineApp::Client_onCreatedProxies: eid(" .. eid .. "), entityType(" .. entityType .. ")!");
	
	this.entity_uuid = rndUUID;
	this.entity_id = eid;
	this.entity_type = entityType;

	local entity = KBEngineLua.entities[eid];
	
	if(entity == nil) then		
		local runclass = KBEngineLua[entityType];
		if(runclass == nil) then
			log("KBEngine::Client_onCreatedProxies: not found module(" .. entityType .. ")!");
			return;
		end
		
		local entity = runclass:New();
		entity.id = eid;
		entity.className = entityType;
		
		entity.base = KBEngineLua.Mailbox:New();
		entity.base.id = eid;
		entity.base.className = entityType;
		entity.base.type = KBEngineLua.MAILBOX_TYPE_BASE;
		
		KBEngineLua.entities[eid] = entity;
		
		local entityMessage = KBEngineLua.bufferedCreateEntityMessage[eid];
		if(entityMessage ~= nil) then
			KBEngineLua.Client_onUpdatePropertys(entityMessage);
			KBEngineLua.bufferedCreateEntityMessage[eid] = nil;
		end
			
		entity:__init__();
		entity.inited = true;
		
		if(KBEngineLua.isOnInitCallPropertysSetMethods) then
			entity:callPropertysSetMethods();
		end
	else
		local entityMessage = KBEngineLua.bufferedCreateEntityMessage[eid];
		if(entityMessage ~= nil) then
			KBEngineLua.Client_onUpdatePropertys(entityMessage);
			KBEngineLua.bufferedCreateEntityMessage[eid] = nil;
		end
	end
end

KBEngineLua.getAoiEntityIDFromStream = function(stream)
	if not this.useAliasEntityID then
		return stream:readInt32();
	end

	local id = 0;
	if(#KBEngineLua.entityIDAliasIDList > 255)then
		id = stream:readInt32();
	else
		local aliasID = stream:readUint8();

		-- -- 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
		-- -- 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
		-- -- 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。
		if(#KBEngineLua.entityIDAliasIDList <= aliasID) then
			return 0;
		end

		id = KBEngineLua.entityIDAliasIDList[aliasID+1];
	end

	return id;
end
	
KBEngineLua.onUpdatePropertys_ = function(eid, stream)

	local entity = KBEngineLua.entities[eid];
	
	if(entity == nil) then
		local entityMessage = KBEngineLua.bufferedCreateEntityMessage[eid];
		if(entityMessage ~= nil) then
			log("KBEngineApp::Client_onUpdatePropertys: entity(" .. eid .. ") not found!");
			return;
		end
		
		local stream1 = KBEngine.MemoryStream.New();
		stream1:copy(stream);
		stream1.rpos = stream1.rpos - 4;--让出一个id

		KBEngineLua.bufferedCreateEntityMessage[eid] = stream1;
		return;
	end
	
	local currModule = KBEngineLua.moduledefs[entity.className];
	local pdatas = currModule.propertys;
	while(stream:length() > 0) do
		local utype = 0;
		if(currModule.usePropertyDescrAlias) then
			utype = stream:readUint8();
		else
			utype = stream:readUint16();
        end

		local propertydata = pdatas[utype];
		local setmethod = propertydata[6];
		local flags = propertydata[7];
		local val = propertydata[5]:createFromStream(stream);
		local oldval = entity[propertydata[3]];
		
		--log("KBEngineApp::Client_onUpdatePropertys: " .. entity.className .. "(id=" .. eid  .. " " .. propertydata[3]);
		
		entity[propertydata[3]] = val;
		if(setmethod ~= nil) then

			-- base类属性或者进入世界后cell类属性会触发set_*方法
			if(flags == 0x00000020 or flags == 0x00000040) then
				if(entity.inited) then
					setmethod(entity, oldval);
				end
			else
				if(entity.inWorld) then
					setmethod(entity, oldval);
				end
			end
		end
	end
end

KBEngineLua.Client_onUpdatePropertysOptimized = function(stream)
	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	KBEngineLua.onUpdatePropertys_(eid, stream);
end

KBEngineLua.Client_onUpdatePropertys = function(stream)
	local eid = stream:readInt32();
	KBEngineLua.onUpdatePropertys_(eid, stream);
end

KBEngineLua.onRemoteMethodCall_ = function(eid, stream)
	local entity = KBEngineLua.entities[eid];
	
	if(entity == nil) then
		log("KBEngineApp::Client_onRemoteMethodCall: entity(" .. eid .. ") not found!");
		return;
	end
	
	local methodUtype = 0;
	if(KBEngineLua.moduledefs[entity.className].useMethodDescrAlias) then
		methodUtype = stream:readUint8();
	else
		methodUtype = stream:readUint16();
	end
	
	local methoddata = KBEngineLua.moduledefs[entity.className].methods[methodUtype];
	local args = {};
	local argsdata = methoddata[4];
	for i=1, #argsdata do
		table.insert(args, argsdata[i]:createFromStream(stream));
	end
	
	if(entity[methoddata[3]] ~= nil) then
		entity[methoddata[3]](entity, unpack(args));
	else
		log("KBEngineApp::Client_onRemoteMethodCall: entity(" .. eid .. ") not found method(" .. methoddata[2] .. ")!");
	end
end

KBEngineLua.Client_onRemoteMethodCallOptimized = function(stream)
	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	KBEngineLua.onRemoteMethodCall_(eid, stream);
end

KBEngineLua.Client_onRemoteMethodCall = function(stream)
	local eid = stream:readInt32();
	KBEngineLua.onRemoteMethodCall_(eid, stream);
end

KBEngineLua.Client_onEntityEnterWorld = function(stream)
	local eid = stream:readInt32();
	if(KBEngineLua.entity_id > 0 and eid ~= KBEngineLua.entity_id) then
		table.insert(KBEngineLua.entityIDAliasIDList, eid);
	end
	
	local entityType;
	if(#KBEngineLua.moduledefs > 255) then
		entityType = stream:readUint16();
	else
		entityType = stream:readUint8();
	end
	
	local isOnGround = 1;
	
	if(stream:length() > 0) then
		isOnGround = stream:readInt8();
	end
	
	entityType = KBEngineLua.moduledefs[entityType].name;
	log("KBEngineApp::Client_onEntityEnterWorld: " .. entityType .. "(" .. eid .. "), spaceID(" .. KBEngineLua.spaceID .. "), isOnGround(" .. isOnGround .. ")!");
	
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		
		entityMessage = KBEngineLua.bufferedCreateEntityMessage[eid];
		if(entityMessage == nil) then
			log("KBEngineApp::Client_onEntityEnterWorld: entity(" .. eid .. ") not found!");
			return;
		end
		
		local runclass = KBEngineLua[entityType];
		if(runclass == nil)  then
			return;
		end
		
		local entity = runclass:New();
		entity.id = eid;
		entity.className = entityType;

		entity.cell = KBEngineLua.Mailbox:New();
		entity.cell.id = eid;
		entity.cell.className = entityType;
		entity.cell.type = KBEngineLua.MAILBOX_TYPE_CELL;
		
		KBEngineLua.entities[eid] = entity;
		
		KBEngineLua.Client_onUpdatePropertys(entityMessage);
		KBEngineLua.bufferedCreateEntityMessage[eid] = nil;
		
		entity.isOnGround = isOnGround > 0;
		entity:__init__();
		entity.inited = true;
		entity.inWorld = true;
		entity:enterWorld();
		
		if(KBEngineLua.isOnInitCallPropertysSetMethods) then
			entity:callPropertysSetMethods();
		end
		
		entity:set_direction(entity.direction);
		entity:set_position(entity.position);
	else
		if(not entity.inWorld) then
			entity.cell = KBEngineLua.Mailbox:New();
			entity.cell.id = eid;
			entity.cell.className = entityType;
			entity.cell.type = KBEngineLua.MAILBOX_TYPE_CELL;

			-- 安全起见， 这里清空一下
			-- 如果服务端上使用giveClientTo切换控制权
			-- 之前的实体已经进入世界， 切换后的实体也进入世界， 这里可能会残留之前那个实体进入世界的信息
			KBEngineLua.entityIDAliasIDList = {};
			KBEngineLua.entities = {}
			KBEngineLua.entities[entity.id] = entity;

			entity:set_direction(entity.direction);
			entity:set_position(entity.position);

			KBEngineLua.entityServerPos.x = entity.position.x;
			KBEngineLua.entityServerPos.y = entity.position.y;
			KBEngineLua.entityServerPos.z = entity.position.z;
			
			entity.isOnGround = isOnGround > 0;
			entity.inWorld = true;
			entity:enterWorld();
			
			if(KBEngineLua.isOnInitCallPropertysSetMethods) then
				entity:callPropertysSetMethods();
			end
		end
	end
end

KBEngineLua.Client_onEntityLeaveWorldOptimized = function(stream)
	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	KBEngineLua.Client_onEntityLeaveWorld(eid);
end

KBEngineLua.Client_onEntityLeaveWorld = function(eid)
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onEntityLeaveWorld: entity(" .. eid .. ") not found!");
		return;
	end
	
	if(entity.inWorld) then
		entity:leaveWorld();
	end

	if(this.entity_id == eid) then
		this.clearSpace(false);
		entity.cell = nil;
	else
		table.removeItem(this.controlledEntities, entity, false);
		--if(_controlledEntities.Remove(entity))
		--	Event.fireOut("onLoseControlledEntity", new object[]{entity});
		this.entities[eid] = nil;
		entity:onDestroy();
		table.removeItem(this.entityIDAliasIDList, eid, false);
	end
end

KBEngineLua.Client_onEntityDestroyed = function(eid)
	log("KBEngineApp::Client_onEntityDestroyed: entity(" .. eid .. ")!");
	
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onEntityDestroyed: entity(" .. eid .. ") not found!");
		return;
	end

	if(entity.inWorld) then
		if(KBEngineLua.entity_id == eid) then
			KBEngineLua.clearSpace(false);
		end
		entity:leaveWorld();
	end

	table.removeItem(this.controlledEntities, entity, false);
	--if(_controlledEntities.Remove(entity))
	--	Event.fireOut("onLoseControlledEntity", new object[]{entity});
		
	KBEngineLua.entities[eid] = nil;
	entity.onDestroy();

end

KBEngineLua.Client_onEntityEnterSpace = function(stream)

	local eid = stream:readInt32();
	KBEngineLua.spaceID = stream:readUint32();
	local isOnGround = true;
	
	if(stream:length() > 0) then
		isOnGround = stream:readInt8();
	end
	
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onEntityEnterSpace: entity(" .. eid .. ") not found!");
		return;
	end
	
	KBEngineLua.entityServerPos.x = entity.position.x;
	KBEngineLua.entityServerPos.y = entity.position.y;
	KBEngineLua.entityServerPos.z = entity.position.z;
	entity:enterSpace();
end

--服务端通知当前玩家离开了space
KBEngineLua.Client_onEntityLeaveSpace = function(eid)
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onEntityLeaveSpace: entity(" .. eid .. ") not found!");
		return;
	end
	
	KBEngineLua.clearSpace(false);
	entity:leaveSpace();
end

--账号创建返回结果
KBEngineLua.Client_onCreateAccountResult = function(stream)

	local retcode = stream:readUint16();
	local datas = stream:readBlob();
	
	Event.Brocast("onCreateAccountResult", retcode, datas);

	if(retcode ~= 0) then
		log("KBEngineApp::Client_onCreateAccountResult: " .. KBEngineLua.username .. " create is failed! code=" .. KBEngineLua.serverErrs[retcode].name .. "!");
		return;
	end

	
	log("KBEngineApp::Client_onCreateAccountResult: " .. KBEngineLua.username .. " create is successfully!");
end


--	告诉客户端：你当前负责（或取消）控制谁的位移同步
KBEngineLua.Client_onControlEntity = function(eid, isControlled)

	local entity = this.entities[eid];

	if (entity == nil) then
		log("KBEngine::Client_onControlEntity: entity(" .. eid .. ") not found!");
		return;
	end

	local isCont = isControlled ~= 0;
	if (isCont) then
		-- 如果被控制者是玩家自己，那表示玩家自己被其它人控制了
		-- 所以玩家自己不应该进入这个被控制列表
		if (this.player().id ~= entity.id) then
			table.insert(this.controlledEntities, entity);
		end
	else
		table.removeItem(this.controlledEntities, entity, false);
	end
	
	entity.isControlled = isCont;
	
	entity.onControlled(isCont);
	--Event.fireOut("onControlled", new object[]{entity, isCont});
end

KBEngineLua.updatePlayerToServer = function()

	if not this.syncPlayer or this.spaceID == 0 then 
		return;
	end

	local now = os.clock();

	local span = now - this._lastUpdateToServerTime; 
	if(span < 0.05) then
		return;
	end

	local player = KBEngineLua.player();
	
	if(player == nil or player.inWorld == false or KBEngineLua.spaceID == 0 or player.isControlled) then
		return;
    end

    this._lastUpdateToServerTime = now - (span - 0.05);

    --log(player.position.x .. " " .. player.position.y);
	if(Vector3.Distance(player._entityLastLocalPos, player.position) > 0.001 or Vector3.Distance(player._entityLastLocalDir, player.direction) > 0.001) then
	
		-- 记录玩家最后一次上报位置时自身当前的位置
		player._entityLastLocalPos.x = player.position.x;
		player._entityLastLocalPos.y = player.position.y;
		player._entityLastLocalPos.z = player.position.z;
		player._entityLastLocalDir.x = player.direction.x;
		player._entityLastLocalDir.y = player.direction.y;
		player._entityLastLocalDir.z = player.direction.z;	
						
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Baseapp_onUpdateDataFromClient"]);
		bundle:writeFloat(player.position.x);
		bundle:writeFloat(player.position.y);
		bundle:writeFloat(player.position.z);
		bundle:writeFloat(player.direction.x);
		bundle:writeFloat(player.direction.y);
		bundle:writeFloat(player.direction.z);
		bundle:writeUint8((player.isOnGround and 1) or 0);
		bundle:writeUint32(this.spaceID);
		bundle:send();
	end

	-- 开始同步所有被控制了的entity的位置
	for i, e in ipairs(this.controlledEntities) do
		local entity = this.controlledEntities[i];
		position = entity.position;
		direction = entity.direction;

		posHasChanged = Vector3.Distance(entity._entityLastLocalPos, position) > 0.001;
		dirHasChanged = Vector3.Distance(entity._entityLastLocalDir, direction) > 0.001;

		if (posHasChanged or dirHasChanged) then
			entity._entityLastLocalPos = position;
			entity._entityLastLocalDir = direction;

			local bundle = KBEngineLua.Bundle:New();
			bundle:newMessage(Message.messages["Baseapp_onUpdateDataFromClientForControlledEntity"]);
			bundle:writeInt32(entity.id);
			bundle:writeFloat(position.x);
			bundle:writeFloat(position.y);
			bundle:writeFloat(position.z);

			--double x = ((double)direction.x / 360 * (System.Math.PI * 2));
			--double y = ((double)direction.y / 360 * (System.Math.PI * 2));
			--double z = ((double)direction.z / 360 * (System.Math.PI * 2));
		
			-- 根据弧度转角度公式会出现负数
			-- unity会自动转化到0~360度之间，这里需要做一个还原
			--if(x - System.Math.PI > 0.0)
			--	x -= System.Math.PI * 2;

			--if(y - System.Math.PI > 0.0)
			--	y -= System.Math.PI * 2;
			
			--if(z - System.Math.PI > 0.0)
			--	z -= System.Math.PI * 2;
			
			bundle:writeFloat(direction.x);
			bundle:writeFloat(direction.y);
			bundle:writeFloat(direction.z);
			bundle:writeUint8((entity.isOnGround and 1) or 0);
			bundle:writeUint32(this.spaceID);
			bundle:send();
		end
	end
end

KBEngineLua.addSpaceGeometryMapping = function(spaceID, respath)

	log("KBEngineApp::addSpaceGeometryMapping: spaceID(" .. spaceID .. "), respath(" .. respath .. ")!");
	
	KBEngineLua.spaceID = spaceID;
	KBEngineLua.spaceResPath = respath;
	Event.Brocast("addSpaceGeometryMapping", respath);
end

KBEngineLua.clearSpace = function(isAll)
	KBEngineLua.entityIDAliasIDList = {};
	KBEngineLua.spacedata = {};
	KBEngineLua.clearEntities(isAll);
	KBEngineLua.isLoadedGeometry = false;
	KBEngineLua.spaceID = 0;
end

KBEngineLua.clearEntities = function(isAll)

	this.controlledEntities = {};

	if(not isAll) then
		local entity = KBEngineLua.player();
		for eid, e in pairs(KBEngineLua.entities) do
		 
			if(eid ~= entity.id) then
				if(KBEngineLua.entities[eid].inWorld) then
			    	KBEngineLua.entities[eid]:leaveWorld();
			    end
			    
			    KBEngineLua.entities[eid]:onDestroy();
			end
		end  
			
		KBEngineLua.entities = {}
		KBEngineLua.entities[entity.id] = entity;
	else
		for eid, e in pairs(KBEngineLua.entities) do
			if(KBEngineLua.entities[eid].inWorld) then
		    	KBEngineLua.entities[eid]:leaveWorld();
		    end
		    
		    KBEngineLua.entities[eid]:onDestroy();
		end  
			
		KBEngineLua.entities = {};
	end
end

KBEngineLua.Client_initSpaceData = function(stream)

	KBEngineLua.clearSpace(false);
	
	KBEngineLua.spaceID = stream:readInt32();
	while(stream:length() > 0) do
		local key = stream:readString();
		local value = stream:readString();
		KBEngineLua.Client_setSpaceData(KBEngineLua.spaceID, key, value);
	end
	
	log("KBEngineApp::Client_initSpaceData: spaceID(" .. KBEngineLua.spaceID .. "), datas(" .. KBEngineLua.spacedata["_mapping"] .. ")!");
end

KBEngineLua.Client_setSpaceData = function(spaceID, key, value)

	log("KBEngineApp::Client_setSpaceData: spaceID(" .. spaceID .. "), key(" .. key .. "), value(" .. value .. ")!");
	
	KBEngineLua.spacedata[key] = value;
	
	if(key == "_mapping") then
		KBEngineLua.addSpaceGeometryMapping(spaceID, value);
    end
	
	--KBEngine.Event.fire("onSetSpaceData", spaceID, key, value);
end

KBEngineLua.Client_delSpaceData = function(spaceID, key)

	log("KBEngineApp::Client_delSpaceData: spaceID(" .. spaceID .. "), key(" .. key .. ")!");
	
	KBEngineLua.spacedata[key] = nil;
	KBEngine.Event.fire("onDelSpaceData", spaceID, key);
end

KBEngineLua.Client_getSpaceData = function(spaceID, key)
	return KBEngineLua.spacedata[key];
end

KBEngineLua.Client_onUpdateBasePos = function(x, y, z)

	this.entityServerPos.x = x;
	this.entityServerPos.y = y;
	this.entityServerPos.z = z;

	local entity = this.player();
	if (entity ~= nil and entity.isControlled) then
		entity.position.x = _entityServerPos.x;
		entity.position.y = _entityServerPos.y;
		entity.position.z = _entityServerPos.z;
		Event.Brocast("updatePosition", entity);
		entity.onUpdateVolatileData();
	end
end

KBEngineLua.Client_onUpdateBasePosXZ = function(x, z)

	KBEngineLua.entityServerPos.x = x;
	KBEngineLua.entityServerPos.z = z;

	local entity = this.player();
	if (entity ~= nil and entity.isControlled) then
		entity.position.x = _entityServerPos.x;
		entity.position.z = _entityServerPos.z;
		Event.Brocast("updatePosition", entity);
		entity.onUpdateVolatileData();
	end
end

KBEngineLua.Client_onUpdateBaseDir = function(stream)
	local x = stream:readFloat();
	local y = stream:readFloat();
	local z = stream:readFloat();

	local entity = this.player();
	if (entity ~= nil and entity.isControlled) then
		entity.direction.x = x;
		entity.direction.y = y;
		entity.direction.z = z;
		Event.Brocast("set_direction", entity);
		entity.onUpdateVolatileData();
	end
end

KBEngineLua.Client_onUpdateData = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onUpdateData: entity(" .. eid .. ") not found!");
		return;
	end
end

KBEngineLua.Client_onSetEntityPosAndDir = function(stream)

	local eid = stream:readInt32();
	local entity = KBEngineLua.entities[eid];
	if(entity == nil) then
		log("KBEngineApp::Client_onSetEntityPosAndDir: entity(" .. eid .. ") not found!");
		return;
	end
	
	entity.position.x = stream:readFloat();
	entity.position.y = stream:readFloat();
	entity.position.z = stream:readFloat();
	entity.direction.x = stream:readFloat();
	entity.direction.y = stream:readFloat();
	entity.direction.z = stream:readFloat();
	
	-- 记录玩家最后一次上报位置时自身当前的位置
	entity._entityLastLocalPos.x = entity.position.x;
	entity._entityLastLocalPos.y = entity.position.y;
	entity._entityLastLocalPos.z = entity.position.z;
	entity._entityLastLocalDir.x = entity.direction.x;
	entity._entityLastLocalDir.y = entity.direction.y;
	entity._entityLastLocalDir.z = entity.direction.z;	
			
	entity:set_direction(entity.direction);
	entity:set_position(entity.position);
end

KBEngineLua.Client_onUpdateData_ypr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local y = stream:readInt8();
	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, y, p, r, -1);
end

KBEngineLua.Client_onUpdateData_yp = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local y = stream:readInt8();
	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, y, p, KBEngineLua.KBE_FLT_MAX, -1);
end

KBEngineLua.Client_onUpdateData_yr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local y = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, y, KBEngineLua.KBE_FLT_MAX, r, -1);
end

KBEngineLua.Client_onUpdateData_pr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, p, r, -1);
end

KBEngineLua.Client_onUpdateData_y = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local y = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, -1);
end

KBEngineLua.Client_onUpdateData_p = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, p, KBEngineLua.KBE_FLT_MAX, -1);
end

KBEngineLua.Client_onUpdateData_r = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, r, -1);
end

KBEngineLua.Client_onUpdateData_xz = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, 1);
end

KBEngineLua.Client_onUpdateData_xz_ypr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local y = stream:readInt8();
	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, y, p, r, 1);
end

KBEngineLua.Client_onUpdateData_xz_yp = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local y = stream:readInt8();
	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, y, p, KBEngineLua.KBE_FLT_MAX, 1);
end

KBEngineLua.Client_onUpdateData_xz_yr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local y = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, y, KBEngineLua.KBE_FLT_MAX, r, 1);
end

KBEngineLua.Client_onUpdateData_xz_pr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, KBEngineLua.KBE_FLT_MAX, p, r, 1);
end

KBEngineLua.Client_onUpdateData_xz_y = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local y = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, 1);
end

KBEngineLua.Client_onUpdateData_xz_p = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, KBEngineLua.KBE_FLT_MAX, p, KBEngineLua.KBE_FLT_MAX, 1);
end

KBEngineLua.Client_onUpdateData_xz_r = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();

	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, KBEngineLua.KBE_FLT_MAX, xz.y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, r, 1);
end

KBEngineLua.Client_onUpdateData_xyz = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, 0);
end

KBEngineLua.Client_onUpdateData_xyz_ypr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local yaw = stream:readInt8();
	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, yaw, p, r, 0);
end

KBEngineLua.Client_onUpdateData_xyz_yp = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local yaw = stream:readInt8();
	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, yaw, p, KBEngineLua.KBE_FLT_MAX, 0);
end

KBEngineLua.Client_onUpdateData_xyz_yr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local yaw = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, yaw, KBEngineLua.KBE_FLT_MAX, r, 0);
end

KBEngineLua.Client_onUpdateData_xyz_pr = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local p = stream:readInt8();
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, KBEngineLua.KBE_FLT_MAX, p, r, 0);
end

KBEngineLua.Client_onUpdateData_xyz_y = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local yaw = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, yaw, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, 0);
end

KBEngineLua.Client_onUpdateData_xyz_p = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local p = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, KBEngineLua.KBE_FLT_MAX, p, KBEngineLua.KBE_FLT_MAX, 0);
end

KBEngineLua.Client_onUpdateData_xyz_r = function(stream)

	local eid = KBEngineLua.getAoiEntityIDFromStream(stream);
	
	local xz = stream:readPackXZ();
	local y = stream:readPackY();
	
	local r = stream:readInt8();
	
	KBEngineLua._updateVolatileData(eid, xz.x, y, xz.y, KBEngineLua.KBE_FLT_MAX, KBEngineLua.KBE_FLT_MAX, r, 0);
end

KBEngineLua._updateVolatileData = function(entityID, x, y, z, yaw, pitch, roll, isOnGround)

	local entity = KBEngineLua.entities[entityID];
	if(entity == nil) then
		-- 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
		-- 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
		-- 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。			
		log("KBEngineApp::_updateVolatileData: entity(" .. entityID .. ") not found!");
		return;
	end
	
	-- 小于0不设置
	if(isOnGround >= 0) then
		entity.isOnGround = (isOnGround > 0);
	end
	
	local changeDirection = false;
	
	if(roll ~= KBEngineLua.KBE_FLT_MAX) then
		changeDirection = true;
		entity.direction.x = KBEngineLua.int82angle(roll, false);
	end

	if(pitch ~= KBEngineLua.KBE_FLT_MAX) then
		changeDirection = true;
		entity.direction.y = KBEngineLua.int82angle(pitch, false);
	end
	
	if(yaw ~= KBEngineLua.KBE_FLT_MAX) then
		changeDirection = true;
		entity.direction.z = KBEngineLua.int82angle(yaw, false);
	end
	
	local done = false;
	if(changeDirection == true) then
		Event.Brocast("set_direction", entity);		
		done = true;
	end
	
	local positionChanged = x ~= KBEngineLua.KBE_FLT_MAX or y ~= KBEngineLua.KBE_FLT_MAX or z ~= KBEngineLua.KBE_FLT_MAX;
	if (x == KBEngineLua.KBE_FLT_MAX) then x = 0.0; end
	if (y == KBEngineLua.KBE_FLT_MAX) then y = 0.0; end
	if (z == KBEngineLua.KBE_FLT_MAX) then z = 0.0; end
            
	if(positionChanged) then
		entity.position.x = x + KBEngineLua.entityServerPos.x;
		entity.position.y = y + KBEngineLua.entityServerPos.y;
		entity.position.z = z + KBEngineLua.entityServerPos.z;
		
		done = true;
		Event.Brocast("updatePosition", entity);
	end
	
	if(done) then
		entity.onUpdateVolatileData();		
    end
end

KBEngineLua.login = function( username, password, data )
	KBEngineLua.username = username;
	KBEngineLua.password = password;
    KBEngineLua._clientdatas = data;
	
	KBEngineLua.login_loginapp(true);
end

--登录到服务端(loginapp), 登录成功后还必须登录到网关(baseapp)登录流程才算完毕
KBEngineLua.login_loginapp = function( noconnect )
	if noconnect then
		this.reset();
		this._networkInterface:connectTo(this.ip, this.port, this.onConnectTo_loginapp_callback, nil);
	else
		log("KBEngine::login_loginapp(): send login! username=" .. this.username);
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_login"]);
		bundle:writeInt8(this.clientType);
		bundle:writeBlob(KBELuaUtil.Utf8ToByte(this._clientdatas));
		bundle:writeString(this.username);
		bundle:writeString(this.password);
		bundle:send();
	end
end

KBEngineLua.onConnectTo_loginapp_callback = function( ip, port, success, userData)
	this._lastTickCBTime = os.clock();
	if not success then
		log("KBEngine::login_loginapp(): connect ".. ip.. ":"..port.." is error!");  
		return;
	end
			
	this.currserver = "loginapp";
	this.currstate = "login";
			
	log("KBEngine::login_loginapp(): connect ".. ip.. ":"..port.." success!"); 

	this.hello();	
end

KBEngineLua.onLogin_loginapp = function()
	this._lastTickCBTime = os.clock();
	if not this.loginappMessageImported_ then
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_importClientMessages"]);
		bundle:send();
		log("KBEngine::onLogin_loginapp: send importClientMessages ...");
	else
		this.onImportClientMessagesCompleted();
	end
end

-----登录到服务端，登录到网关(baseapp)
KBEngineLua.login_baseapp = function(noconnect)
	if(noconnect) then
		--Event.fireOut("onLoginBaseapp", new object[]{});
		this._networkInterface:reset();
		this._networkInterface = KBEngine.NetworkInterface.New();
		this._networkInterface:connectTo(this.baseappIP, this.baseappPort, this.onConnectTo_baseapp_callback, nil);
	else
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Baseapp_loginBaseapp"]);
		bundle:writeString(this.username);
		bundle:writeString(this.password);
		bundle:send();
	end
end

KBEngineLua.onConnectTo_baseapp_callback = function(ip, port, success, userData)
	this._lastTickCBTime = os.clock();
	if not success then
		log("KBEngine::login_baseapp(): connect "..ip..":"..port.." is error!");
		return;
	end
	
	this.currserver = "baseapp";
	this.currstate = "";
	
	log("KBEngine::login_baseapp(): connect "..ip..":"..port.." is successfully!");

	this.hello();
end

KBEngineLua.onLogin_baseapp = function()
	this._lastTickCBTime = os.clock();
	if not this.baseappMessageImported_ then
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Baseapp_importClientMessages"]);
		bundle:send();
		log("KBEngine::onLogin_baseapp: send importClientMessages ...");
		--Event.fireOut("Baseapp_importClientMessages", new object[]{});
	else
		this.onImportClientMessagesCompleted();
	end
end

KBEngineLua.hello = function()

	local bundle = KBEngineLua.Bundle:New();

	if KBEngineLua.currserver == "loginapp" then
		bundle:newMessage(KBEngineLua.messages["Loginapp_hello"]);
	else
		bundle:newMessage(KBEngineLua.messages["Baseapp_hello"]);
	end

	bundle:writeString(KBEngineLua.clientVersion);
	bundle:writeString(KBEngineLua.clientScriptVersion);
	bundle:writeBlob(KBELuaUtil.Utf8ToByte(KBEngineLua._encryptedKey));
	bundle:send();
end

KBEngineLua.Client_onHelloCB = function( stream )
	this.serverVersion = stream:readString();
	this.serverScriptVersion = stream:readString();
	this.serverProtocolMD5 = stream:readString();
	this.serverEntitydefMD5 = stream:readString();
	local ctype = stream:readInt32();
	
	log("KBEngine::Client_onHelloCB: verInfo(" .. KBEngineLua.serverVersion 
		.. "), scriptVersion(".. KBEngineLua.serverScriptVersion .. "), srvProtocolMD5(".. KBEngineLua.serverProtocolMD5 
		.. "), srvEntitydefMD5(".. KBEngineLua.serverEntitydefMD5 .. "), + ctype(" .. ctype .. ")!");
	
	this.onServerDigest();
	
	if this.currserver == "baseapp" then
		this.onLogin_baseapp();
	else
		this.onLogin_loginapp();
	end
end

KBEngineLua.onServerDigest = function()
	if this._persistentInfos ~= nil then
		this._persistentInfos:onServerDigest(this.currserver, this.serverProtocolMD5, this.serverEntitydefMD5);
	end
end



	--登录loginapp失败了
KBEngineLua.Client_onLoginFailed = function(stream)
	local failedcode = stream:readUint16();
	this._serverdatas = stream:readBlob();
	log("KBEngine::Client_onLoginFailed: failedcode(" .. failedcode .. "), datas(" .. this._serverdatas.Length .. ")!");
	Event.Brocast("onLoginFailed", failedcode);
end

KBEngineLua.Client_onLoginSuccessfully = function(stream)
	local accountName = stream:readString();
	this.username = accountName;
	this.baseappIP = stream:readString();
	this.baseappPort = stream:readUint16();

	this._serverdatas = stream:readBlob();
	
	log("KBEngine::Client_onLoginSuccessfully: accountName(" .. accountName .. "), addr(" .. 
			this.baseappIP .. ":" .. this.baseappPort .. "), datas(" .. this._serverdatas.Length .. ")!");
	
	this.login_baseapp(true);
end




KBEngineLua.reset = function()
	--KBEngine.Event.clearFiredEvents();
	KBEngineLua.clearEntities(true);

	this.currserver = "";
	this.currstate = "";
	this._serverdatas = {};
	this.serverVersion = "";
	this.serverScriptVersion = "";
	
	this.entity_uuid = 0;
	this.entity_id = 0;
	this.entity_type = "";

    this.spaceID = 0;
    this.spaceResPath = "";
    this.isLoadedGeometry = false;
	
	this.bufferedCreateEntityMessage = {};

	this._networkInterface:reset();
	this._networkInterface = KBEngine.NetworkInterface.New();

	this._lastTickTime = os.clock();
	this._lastTickCBTime = os.clock();
	this._lastUpdateToServerTime = os.clock();

	this.spacedata = {};
	this.entityIDAliasIDList = {};
	
end


KBEngineLua.onOpenLoginapp_resetpassword = function()
	log("KBEngine::onOpenLoginapp_resetpassword: successfully!");
	this.currserver = "loginapp";
	this.currstate = "resetpassword";
	this._lastTickCBTime = os.clock();
	
	if(not this.loginappMessageImported_) then
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_importClientMessages"]);
		bundle:send();
		log("KBEngine::onOpenLoginapp_resetpassword: send importClientMessages ...");
	else
		this.onImportClientMessagesCompleted();
	end
end


	--重置密码, 通过loginapp
KBEngineLua.resetPassword = function(username)
	this.username = username;
	this.resetpassword_loginapp(true);
end


	--重置密码, 通过loginapp
KBEngineLua.resetpassword_loginapp = function(noconnect)
	if(noconnect) then
		this.reset();
		this._networkInterface:connectTo(this.ip, this.port, this.onConnectTo_resetpassword_callback, nil);
	else
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_reqAccountResetPassword"]);
		bundle:writeString(this.username);
		bundle:send();
	end
end

KBEngineLua.onConnectTo_resetpassword_callback = function(ip, port, success, userData)
	this._lastTickCBTime = os.clock();

	if(not success) then
		log("KBEngine::resetpassword_loginapp(): connect "..ip..":"..port.." is error!");
		return;
	end
	
	log("KBEngine::resetpassword_loginapp(): connect "..ip..":"..port.." is success!"); 
	this.onOpenLoginapp_resetpassword();
end

KBEngineLua.Client_onReqAccountResetPasswordCB = function(failcode)
	if(failcode ~= 0) then
		log("KBEngine::Client_onReqAccountResetPasswordCB: " .. this.username .. " is failed! code=" .. failcode .. "!");
		return;
	end
	log("KBEngine::Client_onReqAccountResetPasswordCB: " .. this.username .. " is successfully!");
end

	--绑定Email，通过baseapp

KBEngineLua.bindAccountEmail = function(emailAddress)
	local bundle = KBEngineLua.Bundle:New();
	bundle:newMessage(KBEngineLua.messages["Baseapp_reqAccountBindEmail"]);
	bundle:writeInt32(this.entity_id);
	bundle:writeString(this.password);
	bundle:writeString(emailAddress);
	bundle:send();
end

KBEngineLua.Client_onReqAccountBindEmailCB = function(failcode)
	if(failcode ~= 0) then
		log("KBEngine::Client_onReqAccountBindEmailCB: " .. this.username .. " is failed! code=" .. failcode .. "!");
		return;
	end

	log("KBEngine::Client_onReqAccountBindEmailCB: " .. this.username .. " is successfully!");
end

----设置新密码，通过baseapp， 必须玩家登录在线操作所以是baseapp。

KBEngineLua.newPassword = function(old_password, new_password)
	local bundle = KBEngineLua.Bundle:New();
	bundle:newMessage(KBEngineLua.messages["Baseapp_reqAccountNewPassword"]);
	bundle:writeInt32(this.entity_id);
	bundle:writeString(old_password);
	bundle:writeString(new_password);
	bundle:send();
end

KBEngineLua.Client_onReqAccountNewPasswordCB = function(failcode)
	if(failcode ~= 0) then
		log("KBEngine::Client_onReqAccountNewPasswordCB: " .. this.username .. " is failed! code=" .. failcode .. "!");
		return;
	end

	log("KBEngine::Client_onReqAccountNewPasswordCB: " .. this.username .. " is successfully!");
end

KBEngineLua.createAccount = function(username, password, data)
	this.username = username;
	this.password = password;
    this._clientdatas = data;
	
	this.createAccount_loginapp(true);
end


	--创建账号，通过loginapp

KBEngineLua.createAccount_loginapp = function(noconnect)
	if(noconnect) then
		this.reset();
		this._networkInterface:connectTo(this.ip, this.port, this.onConnectTo_createAccount_callback, nil);
	else
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_reqCreateAccount"]);
		bundle:writeString(this.username);
		bundle:writeString(this.password);
		bundle:writeBlob(KBELuaUtil.Utf8ToByte(this._clientdatas));
		bundle:send();
	end
end

KBEngineLua.onOpenLoginapp_createAccount = function()
	log("KBEngine::onOpenLoginapp_createAccount: successfully!");
	this.currserver = "loginapp";
	this.currstate = "createAccount";
	this._lastTickCBTime = os.clock();
	
	if( not this.loginappMessageImported_) then
		local bundle = KBEngineLua.Bundle:New();
		bundle:newMessage(KBEngineLua.messages["Loginapp_importClientMessages"]);
		bundle:send();
		log("KBEngine::onOpenLoginapp_createAccount: send importClientMessages ...");
	else
		this.onImportClientMessagesCompleted();
	end
end

KBEngineLua.onConnectTo_createAccount_callback = function(ip, port, success, userData)
	this._lastTickCBTime = os.clock();

	if( not success) then
		log("KBEngine::createAccount_loginapp(): connect "..ip..":"..port.." is error!");
		return;
	end
	
	log("KBEngine::createAccount_loginapp(): connect "..ip..":"..port.." is success!"); 
	this.onOpenLoginapp_createAccount();
end


--	引擎版本不匹配

KBEngineLua.Client_onVersionNotMatch = function(stream)
	this.serverVersion = stream:readString();
	
	log("Client_onVersionNotMatch: verInfo=" .. this.clientVersion .. "(server: " .. this.serverVersion .. ")");
	--Event.fireAll("onVersionNotMatch", new object[]{clientVersion, serverVersion});
	
	if(this._persistentInfos ~= nil) then
		this._persistentInfos:onVersionNotMatch(this.clientVersion, this.serverVersion);
	end
end

--	脚本版本不匹配

KBEngineLua.Client_onScriptVersionNotMatch = function(stream)
	this.serverScriptVersion = stream:readString();
	
	log("Client_onScriptVersionNotMatch: verInfo=" .. this.clientScriptVersion .. "(server: " .. this.serverScriptVersion .. ")");
	--Event.fireAll("onScriptVersionNotMatch", new object[]{clientScriptVersion, this.serverScriptVersion});
	
	if(_persistentInfos ~= nil) then
		_persistentInfos.onScriptVersionNotMatch(this.clientScriptVersion, this.serverScriptVersion);
	end
end

--	被服务端踢出

KBEngineLua.Client_onKicked = function(failedcode)
	log("Client_onKicked: failedcode=" .. failedcode);
	--Event.fireAll("onKicked", new object[]{failedcodeend);
end

--	重登录到网关(baseapp)
--	一些移动类应用容易掉线，可以使用该功能快速的重新与服务端建立通信

KBEngineLua.reLoginBaseapp = function()
	--Event.fireAll("onReloginBaseapp", new object[]{end);
	this._networkInterface:connectTo(this.baseappIP, this.baseappPort, this.onReConnectTo_baseapp_callback, nil);
end

KBEngineLua.onReConnectTo_baseapp_callback = function(ip, port, success, userData)

	if not success then
		log("KBEngine::reLoginBaseapp(): connect "..ip..":"..port.." is error!");
		return;
	end
	
	log("KBEngine::relogin_baseapp(): connect "..ip..":"..port.." is successfully!");

	local bundle = KBEngineLua.Bundle:New();
	bundle:newMessage(KBEngineLua.messages["Baseapp_reLoginBaseapp"]);
	bundle:writeString(this.username);
	bundle:writeString(this.password);
	bundle:writeUint64(this.entity_uuid);
	bundle:writeInt32(this.entity_id);
	bundle:send();

	this._lastTickCBTime = os.clock();
end

	--登录baseapp失败了
KBEngineLua.Client_onLoginBaseappFailed = function(failedcode)
	log("KBEngine::Client_onLoginBaseappFailed: failedcode(" .. failedcode .. ")!");
	--Event.fireAll("onLoginBaseappFailed", new object[]{failedcode});
end

	--重登录baseapp失败了
KBEngineLua.Client_onReloginBaseappFailed = function(failedcode)
	log("KBEngine::Client_onReloginBaseappFailed: failedcode(" .. failedcode .. ")!");
	--Event.fireAll("onReloginBaseappFailed", new object[]{failedcodeend);
end

	--登录baseapp成功了
KBEngineLua.Client_onReloginBaseappSuccessfully = function(stream)
	this.entity_uuid = stream:readUint64();
	log("KBEngine::Client_onReloginBaseappSuccessfully: name(" .. this.username .. ")!");
	--Event.fireAll("onReloginBaseappSuccessfully", new object[]{end);
end


KBEngineLua.sendTick = function()
	if(not this._networkInterface:valid()) then
		return;
	end

	if(not this.loginappMessageImported_ and not this.baseappMessageImported_) then
		return;
	end
	
	local span = os.clock() - this._lastTickTime; 
	
	-- 更新玩家的位置与朝向到服务端
	this.updatePlayerToServer();
	
	if(span > 15) then
		span = this._lastTickCBTime - this._lastTickTime;

		-- 如果心跳回调接收时间小于心跳发送时间，说明没有收到回调
		-- 此时应该通知客户端掉线了
		if(span < 0) then
			log("sendTick: Receive appTick timeout!");
			this._networkInterface:close();
			return;
		end

		local Loginapp_onClientActiveTickMsg = KBEngineLua.messages["Loginapp_onClientActiveTick"];
		local Baseapp_onClientActiveTickMsg = KBEngineLua.messages["Baseapp_onClientActiveTick"];
		
		if(this.currserver == "loginapp") then
			if(Loginapp_onClientActiveTickMsg ~= nil) then
				local bundle = KBEngineLua.Bundle:New();
				bundle:newMessage(Loginapp_onClientActiveTickMsg);
				bundle:send();
			end
		else
			if(Baseapp_onClientActiveTickMsg ~= nil) then
				local bundle = KBEngineLua.Bundle:New();
				bundle:newMessage(Baseapp_onClientActiveTickMsg);
				bundle:send();
			end
		end
		
		this._lastTickTime = os.clock();
	end
end


--
--	服务器心跳回调
--		
KBEngineLua.Client_onAppActiveTickCB = function()
	this._lastTickCBTime = os.clock();
end

	---插件的主循环处理函数

KBEngineLua.process = function()
	-- 处理网络
	this._networkInterface:process();
	
	-- 向服务端发送心跳以及同步角色信息到服务端
    this.sendTick();
end