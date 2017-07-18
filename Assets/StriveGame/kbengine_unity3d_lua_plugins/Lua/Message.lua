--消息
KBEngineLua.messages = {};
KBEngineLua.messages["loginapp"] = {};
KBEngineLua.messages["baseapp"] = {};
KBEngineLua.clientMessages = {};


KBEngineLua.Message = {}


function KBEngineLua.Message:New( id, name, length, argstype, argtypes, handler )
	local me =  {};
	setmetatable(me, self);
	self.__index = self;

	me.id = id;
	me.name = name;
	me.msglen = length;
	me.argsType = argstype;

	-- 绑定执行
	me.args = {};
	for i = 1, #argtypes, 1 do
		table.insert( me.args, KBEngineLua.datatypes[argtypes[i]] );
	end

	me.handler = handler;

    return me;
end

	
function KBEngineLua.Message:createFromStream(msgstream)
	if #self.args <= 0 then
		return msgstream;
	end
	
	local result = {};
	for i = 1, #self.args, 1 do
		table.insert( result, self.args[i]:createFromStream(msgstream) );
	end
	
	return result;
end
	
function KBEngineLua.Message:handleMessage(msgstream)
	if self.handler == nil then
		log("KBEngine.Message::handleMessage: interface(" .. self.name .. "/" .. self.id .. ") no implement!");
		return;
	end

	if #self.args <= 0 then
		if self.argsType < 0 then
			self.handler(msgstream);
		else
			self.handler();
		end
	else
		self.handler(unpack(self:createFromStream(msgstream)));
	end
end

function KBEngineLua.Message.clear()
	KBEngineLua.messages = {};
	KBEngineLua.messages["loginapp"] = {};
	KBEngineLua.messages["baseapp"] = {};
	KBEngineLua.clientMessages = {};

	KBEngineLua.Message.bindFixedMessage();
end

function KBEngineLua.Message.bindFixedMessage()
				-- 提前约定一些固定的协议
			-- 这样可以在没有从服务端导入协议之前就能与服务端进行握手等交互。
	KBEngineLua.messages["Loginapp_importClientMessages"] = KBEngineLua.Message:New(5, "importClientMessages", 0, 0, {}, nil);
	KBEngineLua.messages["Loginapp_hello"] = KBEngineLua.Message:New(4, "hello", -1, -1, {}, nil);
	KBEngineLua.messages["Baseapp_importClientMessages"] = KBEngineLua.Message:New(207, "importClientMessages", 0, 0, {}, nil);
	KBEngineLua.messages["Baseapp_importClientEntityDef"] = KBEngineLua.Message:New(208, "importClientMessages", 0, 0, {}, nil);
	KBEngineLua.messages["Baseapp_hello"] = KBEngineLua.Message:New(200, "hello", -1, -1, {}, nil);

	------client--------------
	KBEngineLua.messages["Client_onHelloCB"] = KBEngineLua.Message:New(521, "Client_onHelloCB", -1, -1, {}, 
		KBEngineLua["Client_onHelloCB"]);
	KBEngineLua.clientMessages[KBEngineLua.messages["Client_onHelloCB"].id] = KBEngineLua.messages["Client_onHelloCB"];

	KBEngineLua.messages["Client_onScriptVersionNotMatch"] = KBEngineLua.Message:New(522, "Client_onScriptVersionNotMatch", -1, -1, {}, 
		KBEngineLua["Client_onScriptVersionNotMatch"]);
	KBEngineLua.clientMessages[KBEngineLua.messages["Client_onScriptVersionNotMatch"].id] = KBEngineLua.messages["Client_onScriptVersionNotMatch"];

	KBEngineLua.messages["Client_onVersionNotMatch"] = KBEngineLua.Message:New(523, "Client_onVersionNotMatch", -1, -1, {}, 
		KBEngineLua["Client_onVersionNotMatch"]);
	KBEngineLua.clientMessages[KBEngineLua.messages["Client_onVersionNotMatch"].id] = KBEngineLua.messages["Client_onVersionNotMatch"];

	KBEngineLua.messages["Client_onImportClientMessages"] = KBEngineLua.Message:New(518, "Client_onImportClientMessages", -1, -1, {}, 
		KBEngineLua["Client_onImportClientMessages"]);
	KBEngineLua.clientMessages[KBEngineLua.messages["Client_onImportClientMessages"].id] = KBEngineLua.messages["Client_onImportClientMessages"];
	
end






KBEngineLua.READ_STATE_MSGID = 0;
-- 消息的长度65535以内
KBEngineLua.READ_STATE_MSGLEN = 1;
-- 当上面的消息长度都无法到达要求时使用扩展长度
-- uint32
KBEngineLua.READ_STATE_MSGLEN_EX = 2;
-- 消息的内容
KBEngineLua.READ_STATE_BODY = 3;

KBEngineLua.MessageReader = {
	msgid = 0,
	msglen = 0,
	expectSize = 2,
	state = KBEngineLua.READ_STATE_MSGID,
	stream = KBEngine.MemoryStream.New(),
};
local reader = KBEngineLua.MessageReader;


function KBEngineLua.MessageReader.process(datas, offset, length)
	local totallen = offset;
	while(length > 0 and reader.expectSize > 0)
	do
		if(reader.state == KBEngineLua.READ_STATE_MSGID) then
			if(length >= reader.expectSize) then
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, reader.expectSize);
				totallen = totallen + reader.expectSize;
				reader.stream.wpos = reader.stream.wpos + reader.expectSize;
				length = length - reader.expectSize;
				reader.msgid = reader.stream:readUint16();
				reader.stream:clear();
				
				local msg = KBEngineLua.clientMessages[reader.msgid];

				if(msg.msglen == -1) then
					reader.state = KBEngineLua.READ_STATE_MSGLEN;
					reader.expectSize = 2;
				elseif(msg.msglen == 0) then
					-- 如果是0个参数的消息，那么没有后续内容可读了，处理本条消息并且直接跳到下一条消息
					msg:handleMessage(stream);
					reader.state = KBEngineLua.READ_STATE_MSGID;
					reader.expectSize = 2;
				else		
					reader.expectSize = msg.msglen;
					reader.state = KBEngineLua.READ_STATE_BODY;
				end
			else
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, length);
				reader.stream.wpos = reader.stream.wpos + length;
				reader.expectSize = reader.expectSize - length;
				break;
			end
		elseif(reader.state == KBEngineLua.READ_STATE_MSGLEN) then
			if(length >= reader.expectSize) then
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, reader.expectSize);
				totallen = totallen + reader.expectSize;
				reader.stream.wpos = reader.stream.wpos + reader.expectSize;
				length = length - reader.expectSize;
				
				reader.msglen = reader.stream:readUint16();
				reader.stream:clear();
				
				-- 长度扩展
				if(reader.msglen >= 65535) then
					reader.state = KBEngineLua.READ_STATE_MSGLEN_EX;
					reader.expectSize = 4;
				else
					reader.state = KBEngineLua.READ_STATE_BODY;
					reader.expectSize = reader.msglen;
				end
			else
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, length);
				reader.stream.wpos = reader.stream.wpos + length;
				reader.expectSize = reader.expectSize - length;
				break;
			end
		elseif(reader.state == KBEngineLua.READ_STATE_MSGLEN_EX) then
			if(length >= reader.expectSize) then
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, reader.expectSize);
				totallen = totallen + reader.expectSize;
				reader.stream.wpos = reader.stream.wpos + reader.expectSize;
				length = length - reader.expectSize;
				
				reader.expectSize = reader.stream:readUint32();
				reader.stream:clear();
				
				reader.state = KBEngineLua.READ_STATE_BODY;
			else
				KBELuaUtil.ArrayCopy(datas, totallen, reader.stream:data(), reader.stream.wpos, length);
				reader.stream.wpos = reader.stream.wpos + length;
				reader.expectSize = reader.expectSize - length;
				break;
			end
		elseif(reader.state == KBEngineLua.READ_STATE_BODY) then
			if(length >= reader.expectSize) then
				reader.stream:append(datas, totallen, reader.expectSize);
				totallen = totallen + reader.expectSize;
				length = length - reader.expectSize;

				local msg = KBEngineLua.clientMessages[reader.msgid];

				msg:handleMessage(reader.stream);

				reader.stream:clear();
				
				reader.state = KBEngineLua.READ_STATE_MSGID;
				reader.expectSize = 2;
			else
				reader.stream:append (datas, totallen, length);
				reader.expectSize = reader.expectSize - length;
				break;
			end
		end
	end
end