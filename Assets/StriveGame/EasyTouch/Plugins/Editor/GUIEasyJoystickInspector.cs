using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(EasyJoystick))]
public class GUIEasyJoystickInspector : Editor{
	
	
	GUIStyle paddingStyle1;

	public GUIEasyJoystickInspector(){

		paddingStyle1 = new GUIStyle();
		paddingStyle1.padding = new RectOffset(15,0,0,0);
	}
	
	void OnEnable(){
			
		EasyJoystick t = (EasyJoystick)target;
		if (t.areaTexture==null){
			t.areaTexture = (Texture)Resources.Load("RadialJoy_Area");
			EditorUtility.SetDirty(t);
		}
		if (t.touchTexture==null){
			t.touchTexture = (Texture)Resources.Load("RadialJoy_Touch");
			EditorUtility.SetDirty(t);
		}
		if (t.deadTexture==null){
			t.deadTexture =  (Texture)Resources.Load("RadialJoy_Dead");
			EditorUtility.SetDirty(t);
		}
		
		t.showDebugRadius = true;
	}
	
	void OnDisable(){
		EasyJoystick t = (EasyJoystick)target;
		t.showDebugRadius = false;
		
	}
	
	public override void OnInspectorGUI(){
		
		EasyJoystick t = (EasyJoystick)target;
				
		// Joystick Properties
		t.showProperties = HTEditorToolKit.DrawTitleFoldOut( t.showProperties,"Joystick properties");
		if (t.showProperties){
			
			EditorGUILayout.BeginVertical(paddingStyle1);
				
			t.name = EditorGUILayout.TextField("Joystick name",t.name);
			t.enable = EditorGUILayout.Toggle("Enable joystick",t.enable);
			t.isActivated = EditorGUILayout.Toggle("Activated",t.isActivated);
			t.showDebugRadius = EditorGUILayout.Toggle("Show debug area",t.showDebugRadius);

			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			EditorGUILayout.Separator();
			
			t.useFixedUpdate = EditorGUILayout.Toggle("Use fixed update",t.useFixedUpdate);
			t.isUseGuiLayout = EditorGUILayout.Toggle("Use GUI Layout",t.isUseGuiLayout);
			if (!t.isUseGuiLayout){
				EditorGUILayout.HelpBox("This lets you skip the GUI layout phase (Increase GUI performance). It can only be used if you do not use GUI.Window and GUILayout inside of this OnGUI call.",MessageType.Warning);	
			}
			EditorGUILayout.EndVertical();

		}
		
		t.showPosition = HTEditorToolKit.DrawTitleFoldOut( t.showPosition,"Joystick position & size");
		if (t.showPosition){
			
			// Dynamic joystick
			t.DynamicJoystick = EditorGUILayout.Toggle("Dynamic joystick",t.DynamicJoystick);
			if (t.DynamicJoystick){
				t.area = (EasyJoystick.DynamicArea) EditorGUILayout.EnumPopup("Free area",t.area);
			}
			else{	
				t.JoyAnchor = (EasyJoystick.JoystickAnchor)EditorGUILayout.EnumPopup("Anchor",t.JoyAnchor);
				t.JoystickPositionOffset = EditorGUILayout.Vector2Field("Offset",t.JoystickPositionOffset);	
			}
			
			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			EditorGUILayout.Separator();
			
			t.ZoneRadius = EditorGUILayout.FloatField("Area radius",t.ZoneRadius);
			t.TouchSize = EditorGUILayout.FloatField("Touch radius",t.TouchSize);	
			t.RestrictArea = EditorGUILayout.Toggle("    Restrict to area",t.RestrictArea);
			t.resetFingerExit = EditorGUILayout.Toggle("    Reset  finger exit",t.resetFingerExit);			
			t.deadZone =  EditorGUILayout.FloatField("Dead zone radius",t.deadZone);

		}
			
		// Joystick axes properties
		t.showInteraction =HTEditorToolKit.DrawTitleFoldOut( t.showInteraction,"Joystick axes properties & events");
		if (t.showInteraction){
			
			EditorGUILayout.BeginVertical(paddingStyle1);
			
			// Interaction
			t.Interaction = (EasyJoystick.InteractionType)EditorGUILayout.EnumPopup("Interaction type",t.Interaction);
			
			if (t.Interaction == EasyJoystick.InteractionType.EventNotification || t.Interaction == EasyJoystick.InteractionType.DirectAndEvent){
				t.useBroadcast = EditorGUILayout.Toggle("Broadcast messages",t.useBroadcast); 
				if (t.useBroadcast){
					t.receiverGameObject =(GameObject) EditorGUILayout.ObjectField("    Receiver gameobject",t.receiverGameObject,typeof(GameObject),true);
					t.messageMode =(EasyJoystick.Broadcast) EditorGUILayout.EnumPopup("    Sending mode",t.messageMode);
				}
			}
			
			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			
			// X axis
			GUI.color = new Color(255f/255f,69f/255f,40f/255f);
			t.enableXaxis = EditorGUILayout.BeginToggleGroup("Enable X axis",t.enableXaxis);
			GUI.color = Color.white;
			if (t.enableXaxis){
				
				EditorGUILayout.BeginVertical(paddingStyle1);
				t.speed.x = EditorGUILayout.FloatField("Speed",t.speed.x);	
				t.inverseXAxis = EditorGUILayout.Toggle("Inverse axis",t.inverseXAxis);
				EditorGUILayout.Separator();

				if (t.Interaction == EasyJoystick.InteractionType.Direct || t.Interaction == EasyJoystick.InteractionType.DirectAndEvent){
					t.XAxisTransform = (Transform)EditorGUILayout.ObjectField("Joystick X to",t.XAxisTransform,typeof(Transform),true);
					if ( t.XAxisTransform!=null){
						// characterCollider
						if (t.XAxisTransform.GetComponent<CharacterController>() && (t.XTI==EasyJoystick.PropertiesInfluenced.Translate || t.XTI==EasyJoystick.PropertiesInfluenced.TranslateLocal)){
							EditorGUILayout.HelpBox("CharacterController detected",MessageType.Info);
							t.xAxisGravity = EditorGUILayout.FloatField("Gravity",t.xAxisGravity);
						}
						else{
							t.xAxisGravity=0;	
						}
						t.XTI = (EasyJoystick.PropertiesInfluenced)EditorGUILayout.EnumPopup("Influenced",t.XTI);
						
						switch( t.xAI){
						case EasyJoystick.AxisInfluenced.X:
							GUI.color = new Color(255f/255f,69f/255f,40f/255f);
							break;
						case EasyJoystick.AxisInfluenced.Y:
							GUI.color = Color.green;
							break;
						case EasyJoystick.AxisInfluenced.Z:
							GUI.color = new Color(63f/255f,131f/255f,245f/255f);
							break;
						}
							
						t.xAI = (EasyJoystick.AxisInfluenced)EditorGUILayout.EnumPopup("Axis influenced",t.xAI);
						GUI.color = Color.white;
						
						EditorGUILayout.Separator();
						
						
						
						if (t.XTI == EasyJoystick.PropertiesInfluenced.RotateLocal){
							// auto stab
							t.enableXAutoStab = EditorGUILayout.Toggle( "AutoStab",t.enableXAutoStab);
							if (t.enableXAutoStab){
								EditorGUILayout.BeginVertical(paddingStyle1);
								t.ThresholdX = EditorGUILayout.FloatField("Threshold ", t.ThresholdX);
								t.StabSpeedX = EditorGUILayout.FloatField("Speed",t.StabSpeedX);
								EditorGUILayout.EndVertical();
							}
							
							EditorGUILayout.Separator();
							
							// Clamp
							t.enableXClamp = EditorGUILayout.Toggle("Clamp rotation",t.enableXClamp);
							if (t.enableXClamp){
								EditorGUILayout.BeginVertical(paddingStyle1);
								t.clampXMax = EditorGUILayout.FloatField("Max angle value",t.clampXMax);	
								t.clampXMin = EditorGUILayout.FloatField("Min angle value",t.clampXMin);
								EditorGUILayout.EndVertical();
							}
						}
					
					}
				}
				EditorGUILayout.EndVertical();
			}
			EditorGUILayout.EndToggleGroup();
			
			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			
			// Y axis
			GUI.color = Color.green;
			t.enableYaxis = EditorGUILayout.BeginToggleGroup("Enable Y axis",t.enableYaxis);
			GUI.color = Color.white;
			if (t.enableYaxis){
				EditorGUILayout.BeginVertical(paddingStyle1);
				t.speed.y = EditorGUILayout.FloatField("Speed",t.speed.y);	
				t.inverseYAxis = EditorGUILayout.Toggle("Inverse axis",t.inverseYAxis);
				EditorGUILayout.Separator();	
				
				if (t.Interaction == EasyJoystick.InteractionType.Direct || t.Interaction == EasyJoystick.InteractionType.DirectAndEvent){
					t.YAxisTransform = (Transform)EditorGUILayout.ObjectField("Joystick Y to",t.YAxisTransform,typeof(Transform),true);
					if ( t.YAxisTransform!=null){
						// characterCollider
						if (t.YAxisTransform.GetComponent<CharacterController>() && (t.YTI==EasyJoystick.PropertiesInfluenced.Translate || t.YTI==EasyJoystick.PropertiesInfluenced.TranslateLocal)){
							EditorGUILayout.HelpBox("CharacterController detected",MessageType.Info);
							t.yAxisGravity = EditorGUILayout.FloatField("Gravity",t.yAxisGravity);
						}
						else{
							t.yAxisGravity=0;	
						}
						t.YTI = (EasyJoystick.PropertiesInfluenced)EditorGUILayout.EnumPopup("Influenced",t.YTI);
						
						switch( t.yAI){
						case EasyJoystick.AxisInfluenced.X:
							GUI.color = new Color(255f/255f,69f/255f,40f/255f);
							break;
						case EasyJoystick.AxisInfluenced.Y:
							GUI.color = Color.green;
							break;
						case EasyJoystick.AxisInfluenced.Z:
							GUI.color = new Color(63f/255f,131f/255f,245f/255f);
							break;
						}						
						t.yAI = (EasyJoystick.AxisInfluenced)EditorGUILayout.EnumPopup("Axis influenced",t.yAI);
						GUI.color = Color.white;
						
						EditorGUILayout.Separator();
						
						
						
						if (t.YTI == EasyJoystick.PropertiesInfluenced.RotateLocal){
							// auto stab
							t.enableYAutoStab = EditorGUILayout.Toggle( "AutoStab",t.enableYAutoStab);
							if (t.enableYAutoStab){
								EditorGUILayout.BeginVertical(paddingStyle1);
								t.ThresholdY = EditorGUILayout.FloatField("Threshold ", t.ThresholdY);
								t.StabSpeedY = EditorGUILayout.FloatField("Speed",t.StabSpeedY);
								EditorGUILayout.EndVertical();
							}
							
							EditorGUILayout.Separator();
							
							// Clamp
							t.enableYClamp = EditorGUILayout.Toggle("Clamp rotation",t.enableYClamp);
							if (t.enableYClamp){
								EditorGUILayout.BeginVertical(paddingStyle1);
								t.clampYMax = EditorGUILayout.FloatField("Max angle value",t.clampYMax);
								t.clampYMin = EditorGUILayout.FloatField("Min angle value",t.clampYMin);
								EditorGUILayout.EndVertical();
							}
						}
				
					}	
				}
				EditorGUILayout.EndVertical();
			}
			EditorGUILayout.EndToggleGroup();

			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			EditorGUILayout.Separator();
			
			// Smoothing return
			t.enableSmoothing = EditorGUILayout.BeginToggleGroup("Smoothing return",t.enableSmoothing);
			if (t.enableSmoothing){
				EditorGUILayout.BeginVertical(paddingStyle1);
				t.Smoothing = EditorGUILayout.Vector2Field( "Smoothing",t.Smoothing);
				EditorGUILayout.EndVertical();
			}
			EditorGUILayout.EndToggleGroup();
			
			t.enableInertia = EditorGUILayout.BeginToggleGroup("Enable inertia",t.enableInertia);
			if (t.enableInertia){
				EditorGUILayout.BeginVertical(paddingStyle1);
				t.Inertia = EditorGUILayout.Vector2Field( "Inertia",t.Inertia);
				EditorGUILayout.EndVertical();
			}
			EditorGUILayout.EndToggleGroup();
			
			EditorGUILayout.EndVertical();
		}
		
		// Joystick Texture 
		t.showAppearance = HTEditorToolKit.DrawTitleFoldOut( t.showAppearance,"Joystick textures");
		if (t.showAppearance){
			EditorGUILayout.BeginVertical(paddingStyle1);
			
			t.guiDepth = EditorGUILayout.IntField("Gui depth",t.guiDepth);
			EditorGUILayout.Separator();
			
			t.showZone = EditorGUILayout.Toggle("Show area",t.showZone);
			if (t.showZone){ 
				t.areaColor = EditorGUILayout.ColorField( "Color",t.areaColor);
				t.areaTexture = (Texture)EditorGUILayout.ObjectField("Area texture",t.areaTexture,typeof(Texture),true);
			}
			EditorGUILayout.Separator();
			
			t.showTouch = EditorGUILayout.Toggle("Show touch",t.showTouch);
			if (t.showTouch){
				t.touchColor = EditorGUILayout.ColorField("Color",t.touchColor);
				t.touchTexture = (Texture)EditorGUILayout.ObjectField("Area texture",t.touchTexture,typeof(Texture),true);
			}
			EditorGUILayout.Separator();
			
			t.showDeadZone = EditorGUILayout.Toggle("Show dead",t.showDeadZone);
			if (t.showDeadZone){
				t.deadTexture = (Texture)EditorGUILayout.ObjectField("Dead zone texture",t.deadTexture,typeof(Texture),true);
			}
			
			EditorGUILayout.EndVertical();
		}
		
		// Refresh
		if (GUI.changed){
		 	EditorUtility.SetDirty(t);
		}
		
	}
}
