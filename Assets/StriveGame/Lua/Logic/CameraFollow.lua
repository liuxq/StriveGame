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

function CameraFollow:ResetView( )
    -- Early out if we don't have a target
    if (self.target == nil) then
        return;
    end

	self.transform = UnityEngine.Camera.main.transform;
    -- Calculate the current rotation angles
    local wantedRotationAngle = self.target.eulerAngles.y;
    local wantedHeight = self.target.position.y + self.height;

    local currentHeight = self.transform.position.y;
    currentHeight = wantedHeight;
    -- Damp the height
    --currentHeight = Mathf.Lerp(currentHeight, wantedHeight, self.heightDamping * UnityEngine.Time.deltaTime);

    -- Convert the angle into a rotation
    local currentRotation = Quaternion.Euler(0, wantedRotationAngle, 0);
    --Quaternion r = Quaternion.Euler(0, rotate, 0);
    --local currentRotation = 1;

    -- Set the position of the camera on the x-z plane to:
    -- distance meters behind the self.target
    self.transform.position = self.target.position;

    self.transform.position = self.transform.position - currentRotation * Vector3.forward * self.distance;

    -- Set the height of the camera
    self.transform.position = Vector3.New(self.transform.position.x, currentHeight, self.transform.position.z);

    -- Always look at the self.target
    self.transform:LookAt(self.target);
    UnityEngine.Camera.main.active = true;
end

function CameraFollow:FollowUpdate()
    -- Early out if we don't have a target
    if (not self.target) then
        return;
    end

    -- Calculate the current rotation angles
    local wantedRotationAngle = self.target.eulerAngles.y;
    local wantedHeight = self.target.position.y + self.height;

    local currentRotationAngle = self.transform.eulerAngles.y;
    local currentHeight = self.transform.position.y;

    local deltaAngle = wantedRotationAngle - currentRotationAngle;
    if (deltaAngle > 180.0) then deltaAngle = deltaAngle - 360;
    elseif (deltaAngle < -180.0) then deltaAngle = deltaAngle + 360; end

    if (deltaAngle > 90) then deltaAngle = 180 - deltaAngle; end
    if (deltaAngle < -90) then deltaAngle = -180 - deltaAngle; end

    -- Damp the rotation around the y-axis
    currentRotationAngle = Mathf.LerpAngle(currentRotationAngle, currentRotationAngle+deltaAngle, self.rotationDamping * Time.deltaTime);

    -- Damp the height
    currentHeight = Mathf.Lerp(currentHeight, wantedHeight, self.heightDamping * UnityEngine.Time.deltaTime);

    -- Convert the angle into a rotation
    local currentRotation = Quaternion.Euler(0, currentRotationAngle, 0);
    --Quaternion r = Quaternion.Euler(0, rotate, 0);
    --local currentRotation = 1;

    -- Set the position of the camera on the x-z plane to:
    -- distance meters behind the self.target
    self.transform.position = self.target.position;

    self.transform.position = self.transform.position - currentRotation * Vector3.forward * self.distance;

    -- Set the height of the camera
    self.transform.position = Vector3.New(self.transform.position.x,currentHeight,self.transform.position.z);

    -- Always look at the self.target
    self.transform:LookAt(self.target);
end