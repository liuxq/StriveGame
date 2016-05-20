// EasyButton v1.0 (April 2013)
// EasyButton library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com
using UnityEngine;
using System.Collections;

/// <summary>
/// C_ easy button template.
/// </summary>
/// 
public class C_EasyButtonTemplate : MonoBehaviour {

	void OnEnable(){
		EasyButton.On_ButtonDown += On_ButtonDown;	
		EasyButton.On_ButtonPress += On_ButtonPress;
		EasyButton.On_ButtonUp += On_ButtonUp;
	}
	
	void OnDisable(){
		EasyButton.On_ButtonDown -= On_ButtonDown;	
		EasyButton.On_ButtonPress -= On_ButtonPress;
		EasyButton.On_ButtonUp -= On_ButtonUp;		
	}
	
	void OnDestroy(){
		EasyButton.On_ButtonDown -= On_ButtonDown;	
		EasyButton.On_ButtonPress -= On_ButtonPress;
		EasyButton.On_ButtonUp -= On_ButtonUp;			
	}
	
	void On_ButtonDown( string buttonName){}

	void On_ButtonPress( string buttonName){}
		
	void On_ButtonUp( string buttonName){}
		
}
