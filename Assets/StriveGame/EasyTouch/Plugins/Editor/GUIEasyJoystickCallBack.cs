using UnityEngine;
using UnityEditor;
using System;

[InitializeOnLoad]
public class GUIEasyJoystickCallBack{
	
	private static readonly EditorApplication.HierarchyWindowItemCallback hiearchyItemCallback;
	private static Texture2D hierarchyIcon;
	private static Texture2D HierarchyIcon {
		get {
			if (GUIEasyJoystickCallBack.hierarchyIcon==null){
				GUIEasyJoystickCallBack.hierarchyIcon = (Texture2D)Resources.Load( "EasyJoystick_Icon");
			}
			return GUIEasyJoystickCallBack.hierarchyIcon;
		}
	}	
	// constructor
	static GUIEasyJoystickCallBack()
	{
		GUIEasyJoystickCallBack.hiearchyItemCallback = new EditorApplication.HierarchyWindowItemCallback(GUIEasyJoystickCallBack.DrawHierarchyIcon);
		EditorApplication.hierarchyWindowItemOnGUI = (EditorApplication.HierarchyWindowItemCallback)Delegate.Combine(EditorApplication.hierarchyWindowItemOnGUI, GUIEasyJoystickCallBack.hiearchyItemCallback);
		
	}
	
	private static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
	{
		GameObject gameObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
		if (gameObject != null && gameObject.GetComponent<EasyJoystick>() != null)
		{
			//Rect rect = new Rect(selectionRect.x + selectionRect.width - 16f, selectionRect.y, 16f, 16f);
			//GUI.DrawTexture( rect,GUIEasyJoystickCallBack.HierarchyIcon);
		}
	}
		
}
