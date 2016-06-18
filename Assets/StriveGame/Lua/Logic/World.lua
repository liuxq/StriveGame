require "Logic/CameraFollow"
require "Logic/InputControl"
require "Logic/Character"
require "Logic/SelectControl"
require "Logic/SkillControl"
require "Controller/GameWorldCtrl"
require "Controller/MessageBoxCtrl"

World = {};
World = {
};

function World.init()
	Event.AddListener("onAvatarEnterWorld", World.onAvatarEnterWorld);
	Event.AddListener("onEnterWorld", World.onEnterWorld);
	Event.AddListener("onLeaveWorld", World.onLeaveWorld);
	Event.AddListener("addSpaceGeometryMapping", World.addSpaceGeometryMapping);

	Event.AddListener("set_position", World.set_position);
	Event.AddListener("set_direction", World.set_direction);
	Event.AddListener("set_name", World.set_name);
    Event.AddListener("set_state", World.set_state);
    Event.AddListener("set_HP", World.set_HP);
    Event.AddListener("set_HP_Max", World.set_HP_Max);
    Event.AddListener("updatePosition", World.updatePosition);
	Event.AddListener("recvDamage", World.recvDamage)
end

function World.onAvatarEnterWorld( avatar )
	if not avatar:isPlayer() then
		return;
	end


	resMgr:LoadPrefab('Model', { 'player' }, function(objs)
		local go = newObject(objs[0]);
		avatar.renderObj = go;
		go.transform.position = avatar.position;
		--go.transform.direction = avatar.direction;
		CameraFollow.target = go.transform;
		CameraFollow.ResetView();
		CameraFollow.FollowUpdate();

		InputControl.Init(avatar);
		InputControl.OnEnable();
		
		--初始化对象
		World.InitEntity(avatar);

		local joystick = find("Joystick").transform:Find("GameJoystick");
		if joystick then
			joystick.gameObject:SetActive(true);
		end

		--初始化角色技能控制
		SkillControl.Init(avatar);
	end);
	
	if(0 == GameWorldCtrl.hasAwake) then
        GameWorldCtrl.Awake();
	end
	PlayerHeadCtrl.Awake();
	TargetHeadCtrl.Awake();
	
	SelectAvatarCtrl.Close();

	UpdateBeat:Add(SelectControl.Update);
	UpdateBeat:Add(SkillControl.Update);
	
end

function World.onEnterWorld( entity )
	if entity:isPlayer() then 
		return;
	end

	if entity.className == "Gate" then
		resMgr:LoadPrefab('Model', { 'Gate' }, function(objs)
			entity.renderObj = newObject(objs[0]);
			entity.renderObj.transform.position = entity.position;
			World.InitEntity(entity);
		end);
	elseif entity.className == "Monster" then
		resMgr:LoadPrefab('Model', { 'player' }, function(objs)
			entity.renderObj = newObject(objs[0]);
			entity.renderObj.transform.position = entity.position;
			World.InitEntity(entity);
		end);
	elseif entity.className == "DroppedItem" then
		resMgr:LoadPrefab('Model', { 'droppedItem' }, function(objs)
			entity.renderObj = newObject(objs[0]);
			entity.renderObj.transform.position = entity.position;
			World.InitEntity(entity);
		end);
	elseif entity.className == "Avatar" then
		resMgr:LoadPrefab('Model', { 'player' }, function(objs)
			entity.renderObj = newObject(objs[0]);
			entity.renderObj.transform.position = entity.position;
			World.InitEntity(entity);
		end);
	elseif entity.className == "NPC" then
		resMgr:LoadPrefab('Model', { 'player' }, function(objs)
			entity.renderObj = newObject(objs[0]);
			entity.renderObj.transform.position = entity.position;
			World.InitEntity(entity);
		end);
	end

end

function World.InitEntity( entity )
	if entity.className == "Gate" or entity.className == "DroppedItem" then
		entity.gameEntity = GameEntity:New();
	else
		entity.gameEntity = Character:New();
	end
	entity.gameEntity:Init(entity);		

	if entity.name then
		World.set_name( entity , entity.name )
	end
end

function World.onLeaveWorld(entity)
	if entity.gameEntity ~= nil then
		entity.gameEntity:Destroy();
	end
	if entity.renderObj ~= nil then
		destroy(entity.renderObj);
		entity.renderObj = nil;
	end
end

function World.addSpaceGeometryMapping( path )
	resMgr:LoadPrefab('Terrain', { 'Terrain' }, function(objs)
		newObject(objs[0]);
	end);
end

function World.set_position( entity )
	entity.gameEntity:SetPosition(entity.position);
end

function World.set_direction( entity )
	entity.gameEntity.m_destDirection = Vector3.New(entity.direction.y, entity.direction.z, entity.direction.x);
end

function World.set_name( entity , v)
	if entity.gameEntity then
		entity.gameEntity:SetName(v);
	end
end

function World.set_HP( entity , v)
    if entity:isPlayer() then
        GameWorldCtrl.Set_HP(v);
    end
end

function World.set_HP_Max( entity , v)
--    print("rensiwei Set_HP_Max"..v)
    if entity:isPlayer() then--当前选择的角色
        GameWorldCtrl.Set_HP_Max(v);
    end
end

function World.set_state( entity , v)
	if entity.gameEntity then
		entity.gameEntity:OnState(v);
	end
	if entity:isPlayer() then
		GameWorldCtrl.OnDie(v);
	end
end

function World.set_HP( entity , v)
	if entity.renderObj ~= nil then
		if PlayerHeadCtrl.target == entity then
			PlayerHeadCtrl.UpdateTargetUI();
		end
		if TargetHeadCtrl.target == entity then
			TargetHeadCtrl.UpdateTargetUI();
		end
	end
end

function World.set_HP_Max( entity , v)
	if entity.renderObj ~= nil then
		if PlayerHeadCtrl.target == entity then
			PlayerHeadCtrl.UpdateTargetUI();
		end
		if TargetHeadCtrl.target == entity then
			TargetHeadCtrl.UpdateTargetUI();
		end
	end
end

function World.updatePosition( entity )
	entity.gameEntity.m_destPosition = entity.position;
end

function World.recvDamage( receiver, attacker, skillID, damageType, damage )
	local sk = SkillBox.Get(skillID);
    if (sk ~= nil) then
        local renderObj = attacker.renderObj;
        renderObj:GetComponent("Animator"):Play("Punch");

        if attacker:isPlayer() then   
        	local dir = receiver.position - attacker.position; 
            renderObj.transform:LookAt(Vector3.New(renderObj.transform.position.x + dir.x, renderObj.transform.position.y, renderObj.transform.position.z + dir.z));
        end

        --显示技能效果
        sk:displaySkill(attacker, receiver);
    end
--    print("rensiwei a nil enity ： receiver"..receiver.."KBEngineLua.Avatar.id:"..KBEngineLua.Avatar.id1);
--    local entity = KBEngineLua.findEntity(receiver);
--    if(entity == nil) then 
--        print("rensiwei a nil enity ： receiver"..receiver.."KBEngineLua.Avatar.id:"..KBEngineLua.Avatar.id);
--	end
--    if(receiver == KBEngineLua.Avatar.id) then--受伤的是主角
--        receiver.character:recvDamage( receiver, attacker, skillID, damageType, damage );
--    else
--        print("rensiwei a nil enity00000");
--    end
    receiver.gameEntity:recvDamage( receiver, attacker, skillID, damageType, damage );
    log("damage:"..damage);
end