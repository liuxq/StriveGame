// EasyTouch library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com

using UnityEngine;
using UnityEditor;
using System;

[InitializeOnLoad]
public class GUIEasytouchCallBack{
	
	private static readonly EditorApplication.HierarchyWindowItemCallback hiearchyItemCallback;
	private static Texture2D hierarchyIcon;
	private static Texture2D HierarchyIcon {
		get {
			if (GUIEasytouchCallBack.hierarchyIcon==null){
				GUIEasytouchCallBack.hierarchyIcon = (Texture2D)Resources.Load( "EasyTouch_Icon");
			}
			return GUIEasytouchCallBack.hierarchyIcon;
		}
	}	
	// constructor
	static GUIEasytouchCallBack()
	{
		GUIEasytouchCallBack.hiearchyItemCallback = new EditorApplication.HierarchyWindowItemCallback(GUIEasytouchCallBack.DrawHierarchyIcon);
		EditorApplication.hierarchyWindowItemOnGUI = (EditorApplication.HierarchyWindowItemCallback)Delegate.Combine(EditorApplication.hierarchyWindowItemOnGUI, GUIEasytouchCallBack.hiearchyItemCallback);
		
	}
	
	private static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
	{
		GameObject gameObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
		if (gameObject != null && gameObject.GetComponent<EasyTouch>() != null)
		{
			//Rect rect = new Rect(selectionRect.x + selectionRect.width - 16f, selectionRect.y, 16f, 16f);
			//GUI.DrawTexture( rect,GUIEasytouchCallBack.HierarchyIcon);
		}
	}
		
}
