
SelectControl = {};

function SelectControl.Update()
	if Input.GetMouseButtonDown(0) then        
	        local ray = Camera.main.ScreenPointToRay(Input.mousePosition);
	        RaycastHit hit;
	        if (Physics.Raycast(ray, out hit, 100.0, 1 << LayerMask.NameToLayer("CanAttack")))then            
	            UI_Target ui_target = World.instance.getUITarget();
	            ui_target.GE_target = hit.collider.GetComponent<GameEntity>();
	            ui_target.UpdateTargetUI();

	            string name = Utility.getPreString(ui_target.GE_target.name);
	            if (name == "NPC" && !MenuBox.hasMenu())then                
	                Int32 id = Utility.getPostInt(ui_target.GE_target.name);
	                NPC _npc = (NPC)KBEngineApp.app.findEntity(id);

	                if (_npc != null)then                    
	                    UInt32 dialogID = (UInt32)_npc.getDefinedProperty("dialogID");
	                    avatar.dialog(id, dialogID);
	                end
	            end
	        end
	    end
end