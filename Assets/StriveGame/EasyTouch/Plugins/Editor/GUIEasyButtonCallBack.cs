using UnityEngine;
using UnityEditor;
using System;

[InitializeOnLoad]
public class GUIEasyButtonCallBack : MonoBehaviour {

	private static readonly EditorApplication.HierarchyWindowItemCallback hiearchyItemCallback;
	private static Texture2D hierarchyIcon;
	private static Texture2D HierarchyIcon {
		get {
			if (GUIEasyButtonCallBack.hierarchyIcon==null){
				GUIEasyButtonCallBack.hierarchyIcon = (Texture2D)Resources.Load( "EasyButton_Icon");
			}
			return GUIEasyButtonCallBack.hierarchyIcon;
		}
	}	
	// constructor
	static GUIEasyButtonCallBack()
	{
		GUIEasyButtonCallBack.hiearchyItemCallback = new EditorApplication.HierarchyWindowItemCallback(GUIEasyButtonCallBack.DrawHierarchyIcon);
		EditorApplication.hierarchyWindowItemOnGUI = (EditorApplication.HierarchyWindowItemCallback)Delegate.Combine(EditorApplication.hierarchyWindowItemOnGUI, GUIEasyButtonCallBack.hiearchyItemCallback);
		
	}
	
	private static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
	{
		GameObject gameObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
		if (gameObject != null && gameObject.GetComponent<EasyButton>() != null)
		{
			Rect rect = new Rect(selectionRect.x + selectionRect.width - 16f, selectionRect.y, 16f, 16f);
			GUI.DrawTexture( rect,GUIEasyButtonCallBack.HierarchyIcon);
		}
	}
}
