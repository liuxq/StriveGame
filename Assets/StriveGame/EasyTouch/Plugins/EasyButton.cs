// EasyButton library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com
using UnityEngine;
using System.Collections;

/// <summary>
/// Release notes:
/// EasyButton V1.0 April 2013
/// =============================
/// 	* Bugs fixed
/// 	------------
/// 	- Fixe Normaltexture property, if you changes the texture during runtime, it taken into account after une first click on a button
/// 
/// EasyButton V1.0 April 2013
/// =============================
/// 	- First release
/// 

/// <summary>
/// This is the main class of EasyButton engine. 
/// 
/// For add EasyButton to your scene, use the menu Hedgehog Team<br>
/// </summary>
[ExecuteInEditMode]
public class EasyButton : MonoBehaviour {
	
	#region Delegate
	public delegate void ButtonUpHandler(string buttonName);
	public delegate void ButtonPressHandler(string buttonName);
	public delegate void ButtonDownHandler(string buttonName);
	#endregion
	
	#region Event
	/// <summary>
	/// Occurs when the button is down for the first time.
	/// </summary>
	public static event ButtonDownHandler On_ButtonDown;
	/// <summary>
	/// Occurs when the button is pressed.
	/// </summary>
	public static event ButtonPressHandler On_ButtonPress;
	/// <summary>
	/// Occurs when the button is up
	/// </summary>
	public static event ButtonUpHandler On_ButtonUp;
	#endregion
	
	#region Enumerations
	/// <summary>
	/// Button anchor.
	/// </summary>
	public enum ButtonAnchor {UpperLeft, UpperCenter, UpperRight, MiddleLeft, MiddleCenter, MiddleRight, LowerLeft, LowerCenter, LowerRight};
	/// <summary>
	/// Broadcast mode for javascript
	/// </summary>
	public enum Broadcast {SendMessage,SendMessageUpwards,BroadcastMessage }
	/// <summary>
	/// Button state, for include mode
	/// </summary>
	public enum ButtonState { Down, Press, Up, None};
	/// <summary>
	/// Interaction type.
	/// </summary>
	public enum InteractionType {Event, Include}
	
	private enum MessageName{On_ButtonDown, On_ButtonPress,On_ButtonUp};
	#endregion
	
	#region Members
	
	#region public members
	
	#region Button properties
	/// <summary>
	/// Enable or disable the button.
	/// </summary>
	public bool enable = true;
	
	/// <summary>
	/// Activacte or deactivate the button
	/// </summary>
	public bool isActivated = true;
	
	public bool showDebugArea=true;
	
	/// <summary>
	/// Disable this lets you skip the GUI layout phase.
	/// </summary>
	public bool isUseGuiLayout=true;
	
	/// <summary>
	/// The state of the button
	/// </summary>
	public ButtonState buttonState = ButtonState.None;
	#endregion
	
	#region Button position & size
	[SerializeField]
	private ButtonAnchor anchor = ButtonAnchor.LowerRight;
	/// <summary>
	/// Gets or sets the anchor.
	/// </summary>
	/// <value>
	/// The anchor.
	/// </value>
	public ButtonAnchor Anchor {
		get {
			return this.anchor;
		}
		set {
			anchor = value;
			ComputeButtonAnchor( anchor);
		}
	}	

	[SerializeField]
	private Vector2 offset = Vector2.zero;
	/// <summary>
	/// Gets or sets the offset.
	/// </summary>
	/// <value>
	/// The offset.
	/// </value>
	public Vector2 Offset {
		get {
			return this.offset;
		}
		set {
			offset = value;
			ComputeButtonAnchor( anchor);
		}
	}	
	
	[SerializeField]
	private Vector2 scale = Vector2.one;
	/// <summary>
	/// Gets or sets the scale.
	/// </summary>
	/// <value>
	/// The scale.
	/// </value>
	public Vector2 Scale {
		get {
			return this.scale;
		}
		set {
			scale = value;
			ComputeButtonAnchor( anchor);
		}
	}	
		
	/// <summary>
	/// Enable or disable swipe in option
	/// </summary>
	public bool isSwipeIn = false;
	/// <summary>
	/// enable or disable siwpe out
	/// </summary>
	public bool isSwipeOut = false;
	#endregion
	
	#region Interaction & Events
	/// <summary>
	/// The interaction.
	/// </summary>/
	public InteractionType interaction = InteractionType.Event;
	/// <summary>
	/// Enable or disable Broadcast message mode.
	/// </summary>
	public bool useBroadcast = false;
	// Messaging
	/// <summary>
	/// The receiver gameobject when you're in broacast mode for events
	/// </summary>
	public GameObject receiverGameObject; 
	/// <summary>
	/// The message sending mode for broacast
	/// </summary>
	public Broadcast messageMode;
	/// <summary>
	/// The use specifical method.
	/// </summary>
	public bool useSpecificalMethod=false;
	/// <summary>
	/// The name of the method.
	/// </summary>
	
	/// <summary>
	/// The name of the down method.
	/// </summary>
	public string downMethodName;
	/// <summary>
	/// The name of the press method.
	/// </summary>
	public string pressMethodName;
	/// <summary>
	/// The name of the up method.
	/// </summary>
	public string upMethodName;
	#endregion
		
	#region Button texture & color
	/// <summary>
	/// The GUI depth.
	/// </summary>
	public int guiDepth = 0;
	
	// Normal
	[SerializeField]
	private Texture2D normalTexture;
	/// <summary>
	/// Gets or sets the normal texture.
	/// </summary>
	/// <value>
	/// The normal texture.
	/// </value>
	public Texture2D NormalTexture {
		get {
			return this.normalTexture;
		}
		set {
			normalTexture = value;
			if (normalTexture!=null){
				ComputeButtonAnchor( anchor);
				currentTexture = normalTexture;
			}
		}
	}	
	/// <summary>
	/// The color of the button normal.
	/// </summary>
	public Color buttonNormalColor = Color.white;
	
	// Active
	[SerializeField]
	private Texture2D activeTexture;
	/// <summary>
	/// Gets or sets the active texture.
	/// </summary>
	/// <value>
	/// The active texture.
	/// </value>
	public Texture2D ActiveTexture {
		get {
			return this.activeTexture;
		}
		set {
			activeTexture = value;
		}
	}	
	/// <summary>
	/// The color of the button active.
	/// </summary>
	public Color buttonActiveColor = Color.white;
	#endregion

	#region Inspector
	public bool showInspectorProperties=true;
	public bool showInspectorPosition=true;
	public bool showInspectorEvent=false;
	public bool showInspectorTexture=false;
	#endregion
	
	#endregion
	
	#region Private member
	private Rect buttonRect;
	private int buttonFingerIndex=-1;
	private Texture2D currentTexture;
	private Color currentColor;
	private int frame=0;
	#endregion
	
	#endregion

	#region MonoBehaviour methods

	
	void OnEnable(){
		EasyTouch.On_TouchStart += On_TouchStart;
		EasyTouch.On_TouchDown += On_TouchDown;
		EasyTouch.On_TouchUp += On_TouchUp;
	}

	void OnDisable(){
		EasyTouch.On_TouchStart -= On_TouchStart;
		EasyTouch.On_TouchDown -= On_TouchDown;
		EasyTouch.On_TouchUp -= On_TouchUp;	
		
		if (Application.isPlaying){
			EasyTouch.RemoveReservedArea( buttonRect);
		}		
	}

	void OnDestroy(){
		EasyTouch.On_TouchStart -= On_TouchStart;
		EasyTouch.On_TouchDown -= On_TouchDown;
		EasyTouch.On_TouchUp -= On_TouchUp;	
		
		if (Application.isPlaying){
			EasyTouch.RemoveReservedArea( buttonRect);
		}
	}

	void Start(){
		currentTexture = normalTexture;	
		currentColor = buttonNormalColor;
		buttonState = ButtonState.None;
		VirtualScreen.ComputeVirtualScreen();
		ComputeButtonAnchor(anchor);		
	}
	
	void OnGUI(){
		
		if (enable){
			GUI.depth = guiDepth;
			
			useGUILayout = isUseGuiLayout;
			
			VirtualScreen.ComputeVirtualScreen();
			VirtualScreen.SetGuiScaleMatrix();
			
			if (normalTexture!=null && activeTexture!=null){
				ComputeButtonAnchor(anchor);
				
				if (normalTexture!=null){
					if (Application.isEditor && !Application.isPlaying){
						currentTexture = normalTexture;
					}
					
					if (showDebugArea && Application.isEditor){
						GUI.Box( buttonRect,"");				
					}
				
						
					if (currentTexture!=null){
						if (isActivated){
							GUI.color = currentColor;	
							if (Application.isPlaying){
								EasyTouch.RemoveReservedArea( buttonRect);
								EasyTouch.AddReservedArea( buttonRect);
							}							
						}
						else{
							GUI.color = new Color(currentColor.r,currentColor.g,currentColor.b,0.2f);
							if (Application.isPlaying){
								EasyTouch.RemoveReservedArea( buttonRect);
							}
						}
						GUI.DrawTexture( buttonRect,currentTexture);
						GUI.color = Color.white;
					}
				}
			}
		}
		else{
			EasyTouch.RemoveReservedArea( buttonRect);	
		}
	}
	
	void Update(){
	
		if (buttonState == ButtonState.Up){
			buttonState = ButtonState.None;	
		}
	}
	
	void OnDrawGizmos(){
	}
	#endregion
	
	#region Private methods
	void ComputeButtonAnchor(ButtonAnchor anchor){
	
		if (normalTexture!=null){
			Vector2 buttonSize = new Vector2(normalTexture.width*scale.x, normalTexture.height*scale.y);
			Vector2 anchorPosition = Vector2.zero;
			
			// Anchor position
			switch (anchor){
				case ButtonAnchor.UpperLeft:
					anchorPosition = new Vector2( 0, 0);
					break;
				case ButtonAnchor.UpperCenter:
					anchorPosition = new Vector2( VirtualScreen.width/2- buttonSize.x/2, offset.y);
					break;
				case ButtonAnchor.UpperRight:
					anchorPosition = new Vector2( VirtualScreen.width-buttonSize.x ,0);
					break;
				
				case ButtonAnchor.MiddleLeft:
					anchorPosition = new Vector2( 0, VirtualScreen.height/2- buttonSize.y/2);
					break;
				case ButtonAnchor.MiddleCenter:
					anchorPosition = new Vector2( VirtualScreen.width/2- buttonSize.x/2, VirtualScreen.height/2- buttonSize.y/2);
					break;
				
				case ButtonAnchor.MiddleRight:
					anchorPosition = new Vector2( VirtualScreen.width-buttonSize.x,VirtualScreen.height/2- buttonSize.y/2);
					break;
				
				case ButtonAnchor.LowerLeft:
					anchorPosition = new Vector2( 0, VirtualScreen.height- buttonSize.y);
					break;
				case ButtonAnchor.LowerCenter:
					anchorPosition = new Vector2( VirtualScreen.width/2- buttonSize.x/2, VirtualScreen.height- buttonSize.y);
					break;
				case ButtonAnchor.LowerRight:
					anchorPosition = new Vector2( VirtualScreen.width-buttonSize.x,VirtualScreen.height- buttonSize.y);
					break;	
								
			}
					
			//button rect
			buttonRect = new Rect(anchorPosition.x + offset.x, anchorPosition.y + offset.y ,buttonSize.x,buttonSize.y);
		}
		
	}
		
	void RaiseEvent(MessageName msg){
		
		if (interaction == InteractionType.Event){
			if (!useBroadcast){
				switch (msg){	
					case MessageName.On_ButtonDown:
						if (On_ButtonDown!=null){
							On_ButtonDown( gameObject.name);
						}	
						break;
					case MessageName.On_ButtonUp:
						if (On_ButtonUp!=null){
							On_ButtonUp( gameObject.name);	
						}
						break;
					case MessageName.On_ButtonPress:
						
						if (On_ButtonPress!=null){
							On_ButtonPress( gameObject.name);	
						}
						break;
				}
			}
			else{
				string method = msg.ToString();
				
				if (msg == MessageName.On_ButtonDown && downMethodName!="" && useSpecificalMethod){
					method = downMethodName;		
				}
				
				if (msg == MessageName.On_ButtonPress && pressMethodName!="" && useSpecificalMethod){
					method = pressMethodName;		
				}				
				
				if (msg == MessageName.On_ButtonUp && upMethodName!="" && useSpecificalMethod){
					method = upMethodName;		
				}
				if (receiverGameObject!=null){		
					switch(messageMode){
						case Broadcast.BroadcastMessage:
							receiverGameObject.BroadcastMessage( method,name,SendMessageOptions.DontRequireReceiver);
							break;
						case Broadcast.SendMessage:
							receiverGameObject.SendMessage( method,name,SendMessageOptions.DontRequireReceiver);
							break;
						case Broadcast.SendMessageUpwards:
							receiverGameObject.SendMessageUpwards( method,name,SendMessageOptions.DontRequireReceiver);
							break;
					}	
				}
				else{
					Debug.LogError("Button : " + gameObject.name + " : you must setup receiver gameobject");	
					
				}
				
			}
		}
	}
	#endregion
	
	#region EasyTouch Event
	void On_TouchStart (Gesture gesture){
	
		if (gesture.IsInRect( VirtualScreen.GetRealRect(buttonRect),true) && enable && isActivated){
			
			buttonFingerIndex = gesture.fingerIndex;
			currentTexture = activeTexture;
			currentColor = buttonActiveColor;
			buttonState = ButtonState.Down;
			frame=0;
			RaiseEvent( MessageName.On_ButtonDown);
		}
	}
	
	void On_TouchDown (Gesture gesture){
		
		if (gesture.fingerIndex == 	buttonFingerIndex || (isSwipeIn && buttonState==ButtonState.None) ){
			
			
			if (gesture.IsInRect( VirtualScreen.GetRealRect(buttonRect),true) && enable && isActivated){	
				currentTexture = activeTexture;
				currentColor = buttonActiveColor;
				
				frame++;
				
				if ((buttonState == ButtonState.Down || buttonState == ButtonState.Press) && frame>=2){ 
					RaiseEvent(MessageName.On_ButtonPress);	
					buttonState = ButtonState.Press;
				}
				
				if (buttonState == ButtonState.None){
					buttonFingerIndex = gesture.fingerIndex;
					buttonState = ButtonState.Down;
					frame=0;
					RaiseEvent( MessageName.On_ButtonDown);
					
				}
			}
			
			else {
				if (((isSwipeIn || !isSwipeIn ) && !isSwipeOut) && buttonState == ButtonState.Press){
					buttonFingerIndex=-1;
					currentTexture = normalTexture;
					currentColor = buttonNormalColor;	
					buttonState = ButtonState.None;					
				}
				else if (isSwipeOut && buttonState == ButtonState.Press) {
					RaiseEvent(MessageName.On_ButtonPress);
					buttonState = ButtonState.Press;
				}
			}
		}
		
	}
	
	void On_TouchUp (Gesture gesture){
		
		if (gesture.fingerIndex == 	buttonFingerIndex){
			if ((EasyTouch.IsRectUnderTouch( VirtualScreen.GetRealRect(buttonRect),true) || (isSwipeOut && buttonState == ButtonState.Press))  && enable && isActivated){
				RaiseEvent(MessageName.On_ButtonUp);
			}
			buttonState = ButtonState.Up;
			buttonFingerIndex=-1;
			currentTexture = normalTexture;
			currentColor = buttonNormalColor;
		}
	}
	
	#endregion
	

}
