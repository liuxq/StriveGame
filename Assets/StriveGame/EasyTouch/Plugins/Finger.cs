// EasyTouch v2.0 (September 2012)
// EasyTouch library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com
using UnityEngine;
using System.Collections;

// Represents informations on Finger for touch
// Internal use only, DO NOT USE IT
public class Finger{

	public int fingerIndex;				// Finger index
	public int touchCount;				// Number of youch
	public Vector2 startPosition; 		// Starting position
	public Vector2 complexStartPosition;// Stating position for two finger
	public Vector2 position;			// current position of the touch.
	public Vector2 deltaPosition;  		// The position delta since last change. 
	public Vector2 oldPosition;			
	public int tapCount;				// Number of taps.
	public float deltaTime;				// Amount of time passed since last change.
	public TouchPhase phase;			// Describes the phase of the touch.
	public  EasyTouch.GestureType gesture;			
	public GameObject pickedObject;
}
