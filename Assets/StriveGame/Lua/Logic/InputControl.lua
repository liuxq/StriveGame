InputControl = {
	CameraTrans = nil,
	AvatarTrans = nil,
};
local this = InputControl;


function InputControl.Init(avatar )
	this.CameraTrans = UnityEngine.Camera.main.transform;
	this.AvatarTrans = avatar.renderObj.transform;
    this.headNameCanvasTrans = avatar.renderObj.transform:Find("Canvas").transform;
	this.animator = avatar.renderObj:GetComponent("Animator");
end

function InputControl.OnEnable( )
	if EasyJoystick.On_JoystickMove then
		EasyJoystick.On_JoystickMove = EasyJoystick.On_JoystickMove + InputControl.OnJoystickMove;
	else
		EasyJoystick.On_JoystickMove = InputControl.OnJoystickMove;
	end

    if EasyJoystick.On_JoystickMoveEnd then
        EasyJoystick.On_JoystickMoveEnd = EasyJoystick.On_JoystickMoveEnd + InputControl.OnJoystickMoveEnd;
    else
        EasyJoystick.On_JoystickMoveEnd = InputControl.OnJoystickMoveEnd;
    end
end

function InputControl.OnDisable( )
	if EasyJoystick.On_JoystickMove then
		EasyJoystick.On_JoystickMove = EasyJoystick.On_JoystickMove - InputControl.OnJoystickMove;
	end

    if EasyJoystick.On_JoystickMoveEnd then
        EasyJoystick.On_JoystickMoveEnd = EasyJoystick.On_JoystickMoveEnd - InputControl.OnJoystickMoveEnd;
    end
end

function InputControl.OnJoystickMove( move )

    SkillControl.Stop();
	local joyPositionX = move.joystickAxis.x;
    local joyPositionY = move.joystickAxis.y;

    if (move.joystickName == "GameJoystick") then
        if (joyPositionY ~= 0 or joyPositionX ~= 0) then
            --设置角色的朝向（朝向当前坐标+摇杆偏移量）
            local r = Quaternion.Euler(0, this.CameraTrans.eulerAngles.y, 0);
            local dir = r * Vector3.New(joyPositionX, 0, joyPositionY);

            local rotation = this.headNameCanvasTrans.rotation;--不让头顶名字旋转
            this.AvatarTrans:LookAt(Vector3.New(this.AvatarTrans.position.x + dir.x, this.AvatarTrans.position.y, this.AvatarTrans.position.z + dir.z));
            
            --移动玩家的位置（按朝向位置移动）
            this.AvatarTrans:Translate(Vector3.forward * Time.deltaTime * 5);

            this.headNameCanvasTrans.rotation = rotation;
            --移动摄像机
            CameraFollow.FollowUpdate();
            --播放奔跑动画
            this.animator.speed = 2.0;
            this.animator:SetFloat("Speed", 1.0);
        end
    end
end

function InputControl.OnJoystickMoveEnd( move )
    if (move.joystickName == "GameJoystick") then
        --播放休闲动画
        this.animator.speed = 1.0;
        this.animator:SetFloat("Speed", 0.0);
    end
end