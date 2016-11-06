CameraFollow = {
    -- The target we are following
    target = nil,
    -- The distance in the x-z plane to the target
    distance = 15.0,
    -- the height we want the camera to be above the target
    height = 8.0,
    -- How much we 
    heightDamping = 2.0,
    rotationDamping = 0.5,

    rotate = 0.5,
    transform = nil;
};

local this = CameraFollow;

function CameraFollow.ResetView( )
    -- Early out if we don't have a target
    if (this.target == nil) then
        return;
    end

    this.transform = UnityEngine.Camera.main.transform;
    -- Calculate the current rotation angles
    local wantedRotationAngle = this.target.eulerAngles.y;
    local wantedHeight = this.target.position.y + this.height;

    local currentHeight = this.transform.position.y;
    currentHeight = wantedHeight;
    -- Damp the height
    --currentHeight = Mathf.Lerp(currentHeight, wantedHeight, this.heightDamping * UnityEngine.Time.deltaTime);

    -- Convert the angle into a rotation
    local currentRotation = Quaternion.Euler(0, wantedRotationAngle, 0);
    --Quaternion r = Quaternion.Euler(0, rotate, 0);
    --local currentRotation = 1;

    -- Set the position of the camera on the x-z plane to:
    -- distance meters behind the this.target
    this.transform.position = this.target.position;

    this.transform.position = this.transform.position - currentRotation * Vector3.forward * this.distance;

    -- Set the height of the camera
    this.transform.position = Vector3.New(this.transform.position.x, currentHeight, this.transform.position.z);

    -- Always look at the this.target
    this.transform:LookAt(this.target);
    -- UnityEngine.Camera.main.active = true;
end

function CameraFollow.FollowUpdate()
    -- Early out if we don't have a target
    if (not this.target) then
        return;
    end

    -- Calculate the current rotation angles
    local wantedRotationAngle = this.target.eulerAngles.y;
    local wantedHeight = this.target.position.y + this.height;

    local currentRotationAngle = this.transform.eulerAngles.y;
    local currentHeight = this.transform.position.y;

    local deltaAngle = wantedRotationAngle - currentRotationAngle;
    if (deltaAngle > 180.0) then deltaAngle = deltaAngle - 360;
    elseif (deltaAngle < -180.0) then deltaAngle = deltaAngle + 360; end

    if (deltaAngle > 90) then deltaAngle = 180 - deltaAngle; end
    if (deltaAngle < -90) then deltaAngle = -180 - deltaAngle; end

    -- Damp the rotation around the y-axis
    currentRotationAngle = Mathf.LerpAngle(currentRotationAngle, currentRotationAngle+deltaAngle, this.rotationDamping * Time.deltaTime);

    -- Damp the height
    currentHeight = Mathf.Lerp(currentHeight, wantedHeight, this.heightDamping * UnityEngine.Time.deltaTime);

    -- Convert the angle into a rotation
    local currentRotation = Quaternion.Euler(0, currentRotationAngle, 0);
    --Quaternion r = Quaternion.Euler(0, rotate, 0);
    --local currentRotation = 1;

    -- Set the position of the camera on the x-z plane to:
    -- distance meters behind the this.target
    this.transform.position = this.target.position;

    this.transform.position = this.transform.position - currentRotation * Vector3.forward * this.distance;

    -- Set the height of the camera
    this.transform.position = Vector3.New(this.transform.position.x,currentHeight,this.transform.position.z);

    -- Always look at the this.target
    this.transform:LookAt(this.target);
end