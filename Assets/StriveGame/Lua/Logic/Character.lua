require "Logic/GameEntity"

Character = {
};

Character = GameEntity:New(Character);--继承

function Character:New( me )
 	me = me or {};
 	setmetatable(me, self);
 	self.__index = self;
 	return me;
end

function Character:Init( entity )
	self.entity = entity;
	self:StartUpdate();
	self.headName = entity.renderObj.transform:Find("Canvas/Text"):GetComponent("Text");
	self.headNameCanvasTrans = entity.renderObj.transform:Find("Canvas").transform;
	self.animator = entity.renderObj.transform:GetComponent("Animator");
	self.cameraTransform = UnityEngine.Camera.main.transform;
end

function Character:OnState( v )
	--状态
	if v == 1 then
		self.animator:Play("Dead");
	else
		self.animator:Play("Idle");
	end
end

function Character:Update()
	if self.headNameCanvasTrans then
		self.headNameCanvasTrans.rotation = self.cameraTransform.rotation;
	end

	if self.entity:isPlayer() then
		return;
	end

	--更新位置和方向
	local flag = false;
	if self.m_destDirection then
		if not self.m_eulerAngles then
			self:SetEulerAngles( self.m_destDirection );
		end

		if Vector3.Distance(self.m_eulerAngles, self.m_destDirection) > 0.0004 then
			self:SetEulerAngles( self.m_destDirection );
			flag = true;
		end
	end

	if self.m_destPosition then
		if not self.m_position then
			self:SetPosition(self.m_destPosition);
		end

		local dist = Vector3.Distance(self.m_position, self.m_destPosition)
		if dist > 0.01 then
			--self:SetPosition(Vector3.Lerp(self.m_position, self.m_destPosition, 1));--100 * UnityEngine.Time.deltaTime));
			self:SetPosition(self.m_destPosition);
			flag = true;
		end
	end

	if flag then
        self.animator.speed = 2.0;
        self.animator:SetFloat("Speed", 1.0);
    else
        self.animator.speed = 1.0;
        self.animator:SetFloat("Speed", 0.0);
   	end

end

function Character:FixedUpdate()
	if not self.entity then
		return;
	end
	if self.entity:isPlayer() then
		local go = self.entity.renderObj;
		Event.Brocast("updatePlayer", self.entity, go.transform.position.x,
	            go.transform.position.y, go.transform.position.z, go.transform.rotation.eulerAngles.y);   
	end
end
