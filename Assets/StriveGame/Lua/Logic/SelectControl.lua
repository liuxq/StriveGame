
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
            -- UI_Target ui_target = World.instance.getUITarget();
            -- ui_target.GE_target = hit.collider.GetComponent<GameEntity>();
            -- ui_target.UpdateTargetUI();

            -- string name = Utility.getPreString(ui_target.GE_target.name);
            -- if (name == "NPC" && !MenuBox.hasMenu()) then                
            --     Int32 id = Utility.getPostInt(ui_target.GE_target.name);
            --     NPC _npc = (NPC)KBEngineApp.app.findEntity(id);

            --     if _npc != null then                    
            --         UInt32 dialogID = (UInt32)_npc.getDefinedProperty("dialogID");
            --         avatar.dialog(id, dialogID);
            --     end
            -- end
        end
	end
end