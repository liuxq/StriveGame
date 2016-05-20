using UnityEngine;
using System.Collections;

/// <summary>
/// Moving joystick.This is the class passed as parameter to the event On_JoystickMove
/// </summary>
public class MovingJoystick{
	
	/// <summary>
	/// The name of the joystick.
	/// </summary>
	public string joystickName;
	
	/// <summary>
	/// The joystick axis value between -1 & 1 on each axis
	/// </summary>
	public Vector2 joystickAxis;
	
	/// <summary>
	/// The joystick value joystickAxis * speed * Time.deltaTime more inertia etc ....
	/// </summary>
	public Vector2 joystickValue;
	
	/// <summary>
	/// Axis2s the angle.
	/// </summary>
	/// <returns>
	/// The angle.
	/// </returns>
	public float Axis2Angle(bool inDegree=true){
		
		float angle = Mathf.Atan2( joystickAxis.x,joystickAxis.y );
		
		if (inDegree){
			return angle* Mathf.Rad2Deg	;
		}
		else{
			return angle;
		}
	}
	
	/// <summary>
	/// The joystick.
	/// </summary>
	public EasyJoystick joystick;
}
