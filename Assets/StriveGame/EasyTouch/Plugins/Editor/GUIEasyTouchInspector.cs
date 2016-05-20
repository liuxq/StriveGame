using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(EasyTouch))]
public class GUIEasyTouchInspector : Editor {

	GUIStyle paddingStyle1;

	public GUIEasyTouchInspector(){

		paddingStyle1 = new GUIStyle();
		paddingStyle1.padding = new RectOffset(15,0,0,0);
	}
	
	public override void OnInspectorGUI(){
			
		EasyTouch t = (EasyTouch)target;
		
		t.showGeneral = HTEditorToolKit.DrawTitleFoldOut( t.showGeneral,"General properties");
		if (t.showGeneral){
			t.enable = EditorGUILayout.Toggle("Enable EasyTouch",t.enable);
			
			t.enableRemote = EditorGUILayout.Toggle("Enable unity remote",t.enableRemote);
			
			
			
			t.useBroadcastMessage = EditorGUILayout.BeginToggleGroup("Broadcast messages",t.useBroadcastMessage);
			if (t.useBroadcastMessage){
				EditorGUILayout.BeginVertical(paddingStyle1);
				t.receiverObject = (GameObject)EditorGUILayout.ObjectField("Other receiver",t.receiverObject,typeof(GameObject),true);
				t.isExtension = EditorGUILayout.Toggle("Joysticks & buttons",t.isExtension);
				EditorGUILayout.EndVertical();
			}
			
			EditorGUILayout.EndToggleGroup();
			EditorGUILayout.Space();
			
			t.enableReservedArea = EditorGUILayout.Toggle("Enable reserved area",t.enableReservedArea);
			EditorGUILayout.Space();
			t.enabledNGuiMode = EditorGUILayout.Toggle("Enable NGUI compatibilty",t.enabledNGuiMode);
			if (t.enabledNGuiMode){
					EditorGUILayout.BeginVertical(paddingStyle1);
				
					// Camera
					serializedObject.Update();
			   		EditorGUIUtility.LookLikeInspector();
			    	SerializedProperty cameras = serializedObject.FindProperty("nGUICameras");
					EditorGUILayout.PropertyField( cameras,true);
			   		serializedObject.ApplyModifiedProperties();
					EditorGUIUtility.LookLikeControls();
					
					EditorGUILayout.Space();
				
					// layers
					serializedObject.Update();
			   		EditorGUIUtility.LookLikeInspector();
			    	SerializedProperty layers = serializedObject.FindProperty("nGUILayers");
					EditorGUILayout.PropertyField( layers,false);
			   		serializedObject.ApplyModifiedProperties();
					EditorGUIUtility.LookLikeControls();
				
					EditorGUILayout.EndVertical();
			}			
		}
			
		if (t.enable){
			
			// Auto select porperties
			 t.showSelect = HTEditorToolKit.DrawTitleFoldOut( t.showSelect,  "Auto-select properties");
			if (t.showSelect){
				t.easyTouchCamera = (Camera)EditorGUILayout.ObjectField("Camera",t.easyTouchCamera,typeof(Camera),true);
				t.autoSelect = EditorGUILayout.Toggle("Enable auto-select",t.autoSelect);
				
				if (t.autoSelect){
					
					serializedObject.Update();
			   		EditorGUIUtility.LookLikeInspector();
			    	SerializedProperty layers = serializedObject.FindProperty("pickableLayers");
					EditorGUILayout.PropertyField( layers,true);
			   		serializedObject.ApplyModifiedProperties();
					EditorGUIUtility.LookLikeControls();
				}
			}
				
			// General gesture properties
			t.showGesture = HTEditorToolKit.DrawTitleFoldOut(t.showGesture, "General gesture properties");
				if (t.showGesture){
				t.StationnaryTolerance = EditorGUILayout.FloatField("Stationary tolerance",t.StationnaryTolerance);
				t.longTapTime = EditorGUILayout.FloatField("Long tap time",t.longTapTime);
				t.swipeTolerance = EditorGUILayout.FloatField("Swipe tolerance",t.swipeTolerance);
			}
			
			// Two fingers gesture
			t.showTwoFinger = HTEditorToolKit.DrawTitleFoldOut(t.showTwoFinger, "Two fingers gesture properties");
			if (t.showTwoFinger){
				t.enable2FingersGesture = EditorGUILayout.Toggle("2 fingers gesture",t.enable2FingersGesture);
		
				if (t.enable2FingersGesture){
					EditorGUILayout.Separator();
					t.enablePinch = EditorGUILayout.Toggle("Enable Pinch",t.enablePinch);
					if (t.enablePinch){
						t.minPinchLength = EditorGUILayout.FloatField("Min pinch length",t.minPinchLength);
					}
					EditorGUILayout.Separator();
					t.enableTwist = EditorGUILayout.Toggle("Enable twist",t.enableTwist);
					if (t.enableTwist){
						t.minTwistAngle = EditorGUILayout.FloatField("Min twist angle",t.minTwistAngle);
					}
					
					EditorGUILayout.Separator();
					
				}
			}
			
			// Second Finger simulation
			t.showSecondFinger = HTEditorToolKit.DrawTitleFoldOut(t.showSecondFinger, "Second finger simulation");
			if (t.showSecondFinger){
				if (t.secondFingerTexture==null){
					t.secondFingerTexture =Resources.Load("secondFinger") as Texture;
				}
				
				t.secondFingerTexture = (Texture)EditorGUILayout.ObjectField("Texture",t.secondFingerTexture,typeof(Texture),true);
				EditorGUILayout.HelpBox("Change the keys settings for a fash compilation, or if you want to change the keys",MessageType.Info);
				t.twistKey = (KeyCode)EditorGUILayout.EnumPopup( "Twist & pinch key", t.twistKey);	
				t.swipeKey = (KeyCode)EditorGUILayout.EnumPopup( "Swipe key", t.swipeKey);
			}
		}		
		
	}
}
