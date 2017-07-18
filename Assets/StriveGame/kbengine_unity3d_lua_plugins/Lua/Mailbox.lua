
KBEngineLua.Mailbox = {}


function KBEngineLua.Mailbox:New()
	local me =  {};
	setmetatable(me, self);
	self.__index = self;

	me.id = 0;
	me.className = "";
	me.type = 0;
	me.networkInterface_ = KBEngineLua._networkInterface;
	me.bundle = nil;

    return me;
end

function KBEngineLua.Mailbox:isBase( )
	return self.type == 1;
end

function KBEngineLua.Mailbox:isCell( )
	return self.type == 0;
end


	----创建新的mail

function KBEngineLua.Mailbox:newMail()

	if(self.bundle == nil) then
		self.bundle = KBEngineLua.Bundle:New();
	end
	
	if(self.type == 0) then
		self.bundle:newMessage(KBEngineLua.messages["Baseapp_onRemoteCallCellMethodFromClient"]);
	else
		self.bundle:newMessage(KBEngineLua.messages["Base_onRemoteMethodCall"]);
	end

	self.bundle:writeInt32(self.id);
	
	return self.bundle;
end


	---向服务端发送这个mail

function KBEngineLua.Mailbox:postMail(inbundle)

	if(inbundle == nil) then
		inbundle = self.bundle;
	end
	
	inbundle:send();
	
	if(inbundle == self.bundle) then
		self.bundle = nil;
	end
end