
SelectControl = {};

function SelectControl.Update()
	if UnityEngine.Input.GetMouseButtonDown(0) then
        local ray = UnityEngine.Camera.main:ScreenPointToRay(UnityEngine.Input.mousePosition);

        local isHit, hit = UnityEngine.Physics.Raycast(ray, nil, 100.0, bit.lshift(1,LayerMask.NameToLayer("CanAttack")));
        if isHit then
            for i,v in pairs(KBEngineLua.entities) do
            	if v.renderObj == hit.collider.gameObject then
            		TargetHeadCtrl.target = v;
            		TargetHeadCtrl.UpdateTargetUI();
            	end
            end
        end
	end
end