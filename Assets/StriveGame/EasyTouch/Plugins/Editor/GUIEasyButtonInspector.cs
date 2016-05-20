using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(EasyButton))]
public class GUIEasyButtonInspector : Editor {

	GUIStyle paddingStyle1;

	public GUIEasyButtonInspector(){

		paddingStyle1 = new GUIStyle();
		paddingStyle1.padding = new RectOffset(15,0,0,0);
	}

	void OnEnable(){
			
		EasyButton t = (EasyButton)target;
		if (t.NormalTexture==null){
			t.NormalTexture = (Texture2D)Resources.Load("Button_normal");
			EditorUtility.SetDirty(t);
		}
		if (t.ActiveTexture==null){
			t.ActiveTexture = (Texture2D)Resources.Load("Button_active");
			EditorUtility.SetDirty(t);
		}
		
		t.showDebugArea = true;
		EditorUtility.SetDirty(t);

	}
	
	void OnDisable(){
		EasyButton t = (EasyButton)target;
		t.showDebugArea = false;
		
	}
	
	public override void OnInspectorGUI(){
		
		EasyButton t = (EasyButton)target;
	
		// Button Properties
		t.showInspectorProperties = HTEditorToolKit.DrawTitleFoldOut( t.showInspectorProperties,"Button properties");
		if (t.showInspectorProperties){
			
			EditorGUILayout.BeginVertical(paddingStyle1);		
			
			t.name = EditorGUILayout.TextField("Button name",t.name);

			t.enable = EditorGUILayout.Toggle("Enable button",t.enable);
			t.isActivated = EditorGUILayout.Toggle("Activated",t.isActivated);
			t.showDebugArea = EditorGUILayout.Toggle("Show debug area",t.showDebugArea);
						
			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			EditorGUILayout.Separator();
			
			t.isUseGuiLayout = EditorGUILayout.Toggle("Use GUI Layout",t.isUseGuiLayout);
			if (!t.isUseGuiLayout){
				EditorGUILayout.HelpBox("This lets you skip the GUI layout phase (Increase GUI performance). It can only be used if you do not use GUI.Window and GUILayout inside of this OnGUI call.",MessageType.Warning);	
			}						
			EditorGUILayout.EndVertical();
		}
		
		// Button position and size
		t.showInspectorPosition = HTEditorToolKit.DrawTitleFoldOut( t.showInspectorPosition,"Button position & size");
		if (t.showInspectorPosition){
			t.Anchor = (EasyButton.ButtonAnchor)EditorGUILayout.EnumPopup("Anchor",t.Anchor);
			t.Offset = EditorGUILayout.Vector2Field("Offset",t.Offset);	
			t.Scale =  EditorGUILayout.Vector2Field("Scale",t.Scale);	
			
			HTEditorToolKit.DrawSeparatorLine(paddingStyle1.padding.left);
			EditorGUILayout.Separator();
			
			t.isSwipeIn = EditorGUILayout.Toggle("Swipe in",t.isSwipeIn);
			t.isSwipeOut = EditorGUILayout.Toggle("Swipe out",t.isSwipeOut);			
		}
		
		// Event
		t.showInspectorEvent = HTEditorToolKit.DrawTitleFoldOut( t.showInspectorEvent,"Button Interaction & Events");
		if (t.showInspectorEvent){
			EditorGUILayout.BeginVertical(paddingStyle1);
			t.interaction = (EasyButton.InteractionType)EditorGUILayout.EnumPopup("Interaction type",t.interaction);
			
			if (t.interaction == EasyButton.InteractionType.Event){
				t.useBroadcast = EditorGUILayout.Toggle("Broadcast messages",t.useBroadcast); 
				if (t.useBroadcast){
					EditorGUILayout.BeginVertical(paddingStyle1);
					t.receiverGameObject =(GameObject) EditorGUILayout.ObjectField("Receiver object",t.receiverGameObject,typeof(GameObject),true);
					t.messageMode =(EasyButton.Broadcast) EditorGUILayout.EnumPopup("Sending mode",t.messageMode);
					
					EditorGUILayout.Separator();
					
					t.useSpecificalMethod = EditorGUILayout.Toggle("Use specific method",t.useSpecificalMethod); 
					if (t.useSpecificalMethod){
						t.downMethodName = EditorGUILayout.TextField("   Down method name",t.downMethodName);
						t.pressMethodName = EditorGUILayout.TextField("   Press method name",t.pressMethodName);
						t.upMethodName = EditorGUILayout.TextField("   Up method name",t.upMethodName);
						
					}
					EditorGUILayout.EndVertical();
				}
			}
			EditorGUILayout.EndVertical();
			
		}
		
		// Button texture
		t.showInspectorTexture = HTEditorToolKit.DrawTitleFoldOut( t.showInspectorTexture,"Button textures");
		if (t.showInspectorTexture){
			EditorGUILayout.BeginVertical(paddingStyle1);
			t.guiDepth = EditorGUILayout.IntField("Gui depth",t.guiDepth);
			EditorGUILayout.Separator();
			t.buttonNormalColor = EditorGUILayout.ColorField("Color",t.buttonNormalColor);
			t.NormalTexture = (Texture2D)EditorGUILayout.ObjectField("Normal texture",t.NormalTexture,typeof(Texture),true);
			EditorGUILayout.Separator();
			t.buttonActiveColor = EditorGUILayout.ColorField("Color",t.buttonActiveColor);
			t.ActiveTexture = (Texture2D)EditorGUILayout.ObjectField("Normal texture",t.ActiveTexture,typeof(Texture),true);
			EditorGUILayout.EndVertical();
						
		}
		
		
		
		// Refresh
		if (GUI.changed){
		 	EditorUtility.SetDirty(t);
		}
	}
}


