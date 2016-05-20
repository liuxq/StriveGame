// EasyJoystick library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com
using UnityEngine;
using System.Collections;

/// <summary>
/// Release notes:
/// EasyJoystick V2.2 Mai 2013
/// =============================
/// 	* Dynamic joystick no longer show when there are hover reserved area
/// 
/// EasyJoystick V2.1 Mai 2013
/// =============================
/// 	* Bugs fixed
/// 	------------
/// 	- The joystick touch wasn't been correct in some case
/// 
/// 
/// EasyJoystick V2.0 Avril 2013
/// ============================= 
///		* New
/// 	-----------------
/// 	- Add virtual screen to keep size position
/// 	- Add new joystick events : On_JoystickMoveStart, On_JoystickTouchStart, On_JoystickTap, On_JoystickDoubleTap,On_JoystickTouchUp
/// 	- Add new option to reset joystick position, when touch exit the joystick area
/// 	- Add the possibility to enable / disable joystick axis X or Y 
/// 	- Add new member isActivated to desactivated the joystick, but it always show on the screen
/// 	- Add new member to clamp rotation in direct mode when you're in localrotation
/// 	- Add new member to do an auto stabilisation in direct mode when you're in localrotation
/// 	- Add show dynamic joystick in edit mode
/// 	- Some optimisations
/// 	- Add new method Axis2Angle to MovingJoystick class that allow to return the joystick angle direction between -170 to 170
/// 	- Add option to show real area use by the joystick texture
/// 	- Add UseGuiLayout option
/// 	- Add Gui depth parameter
/// 
/// 	* Bugs fixed
/// 	------------
/// 	- Gravity is now always apply correctly
/// 	- Dead zone is correctly take into account
/// 	- the event JoystickMoveEnd don't send any more at startup
/// 
/// V1.0 November 2012
/// =============================
/// 	- First release

/// <summary>
/// This is the main class of EasyJoystick engine. 
/// 
/// For add joystick to your scene, use the menu Hedgehog Team<br>
/// </summary>
[ExecuteInEditMode]
public class EasyJoystick : MonoBehaviour {
	
	#region Delegate
	public delegate void JoystickMoveStartHandler(MovingJoystick move);
	public delegate void JoystickMoveHandler(MovingJoystick move);
	public delegate void JoystickMoveEndHandler(MovingJoystick move);
	public delegate void JoystickTouchStartHandler(MovingJoystick move);
	public delegate void JoystickTapHandler(MovingJoystick move);
	public delegate void JoystickDoubleTapHandler(MovingJoystick move);
	public delegate void JoystickTouchUpHandler(MovingJoystick move);
	#endregion
	
	#region Event
	/// <summary>
	/// Occurs the joystick starts move.
	/// </summary>
	public static event JoystickMoveStartHandler On_JoystickMoveStart;
	/// <summary>
	/// Occurs when the joystick move.
	/// </summary>
	public static event JoystickMoveHandler On_JoystickMove;
	/// <summary>
	/// Occurs when the joystick stops move
	/// </summary>
	public static event JoystickMoveEndHandler On_JoystickMoveEnd;
	/// <summary>
	/// Occurs when a touch start hover the joystick
	/// </summary>
	public static event JoystickTouchStartHandler On_JoystickTouchStart;
	/// <summary>
	/// Occurs when a tap happen's on the joystick
	/// </summary>
	public static event JoystickTapHandler On_JoystickTap;
	/// <summary>
	/// Occurs when a double tap happen's on the joystick
	/// </summary>
	public static event JoystickDoubleTapHandler On_JoystickDoubleTap;
	/// <summary>
	/// Occurs when touch up happen's on the joystick
	/// </summary>
	public static event JoystickTouchUpHandler On_JoystickTouchUp;
	#endregion
	
	#region Enumeration
	/// <summary>
	/// Joystick anchor.
	/// </summary>
	public enum JoystickAnchor {None,UpperLeft, UpperCenter, UpperRight, MiddleLeft, MiddleCenter, MiddleRight, LowerLeft, LowerCenter, LowerRight};
	/// <summary>
	/// Properties influenced by the joystick
	/// </summary>
	public enum PropertiesInfluenced {Rotate, RotateLocal,Translate, TranslateLocal, Scale}
	/// <summary>
	/// Axis influenced by the joystick
	/// </summary>
	public enum AxisInfluenced{X,Y,Z,XYZ}
	/// <summary>
	/// Dynamic area zone.
	/// </summary>
	public enum DynamicArea {FullScreen, Left,Right,Top, Bottom, TopLeft, TopRight, BottomLeft, BottomRight};
	/// <summary>
	/// Interaction type.
	/// </summary>
	public enum InteractionType {Direct, Include, EventNotification, DirectAndEvent}
	/// <summary>
	/// Broadcast mode for javascript
	/// </summary>
	public enum Broadcast {SendMessage,SendMessageUpwards,BroadcastMessage }
	/// <summary>
	/// Message name.
	/// </summary>
	private enum MessageName{On_JoystickMoveStart,On_JoystickTouchStart, On_JoystickTouchUp, On_JoystickMove, On_JoystickMoveEnd, On_JoystickTap, On_JoystickDoubleTap};
	#endregion
	
	#region Members
	
	#region Public Members
	
	#region   property
	private Vector2 joystickAxis;
	/// <summary>
	/// Gets the joystick axis value between -1 & 1...
	/// </summary>
	/// <value>
	/// The joystick axis.
	/// </value>
	public Vector2 JoystickAxis {
		get {
			return this.joystickAxis;
		}
	}	
	
	/// <summary>
	/// Gest or set the touch position.
	/// </summary>
	private Vector2 joystickTouch;
	public Vector2 JoystickTouch {
		get {
			return new Vector2(this.joystickTouch.x/zoneRadius, this.joystickTouch.y/zoneRadius);
		}
		set {
			float x = Mathf.Clamp( value.x,-1f,1f)*zoneRadius;
			float y = Mathf.Clamp( value.y,-1f,1f)*zoneRadius;
			joystickTouch = new Vector2(x,y);
		}
	}	
	
	private Vector2 joystickValue;
	/// <summary>
	/// Gets the joystick value = joystic axis value * jostick speed * Time.deltaTime...
	/// </summary>
	/// <value>
	/// The joystick value.
	/// </value>
	public Vector2 JoystickValue {
		get {
			return this.joystickValue;
		}
	}
	#endregion
	
	#region public joystick properties
	
	/// <summary>
	/// Enable or disable the joystick.
	/// </summary>
	public bool enable = true;

	/// <summary>
	/// Activacte or deactivate the joystick
	/// </summary>
	public bool isActivated = true;

	/// <summary>
	/// The show debug radius area
	/// </summary>
	public bool showDebugRadius=false;
		
	/// <summary>
	/// Use fixed update.
	/// </summary>
	public bool useFixedUpdate = false;
	
	/// <summary>
	///  Disable this lets you skip the GUI layout phase.
	/// </summary>
	public bool isUseGuiLayout=true;	
	
	#endregion
	
	#region Joystick Position & size
	[SerializeField]
	private bool dynamicJoystick=false;
	/// <summary>
	/// Gets or sets a value indicating whether this is a dynamic joystick.
	/// When this option is enabled, the joystick will display the location of the touch
	/// </summary>
	/// <value>
	/// <c>true</c> if dynamic joystick; otherwise, <c>false</c>.
	/// </value>
	public bool DynamicJoystick {
		get {
			return this.dynamicJoystick;
		}
		set {
			if (!Application.isPlaying){
			joystickIndex=-1;
			
			dynamicJoystick = value;
			if (dynamicJoystick){
				virtualJoystick=false;
			}
			else{
				virtualJoystick=true;
				joystickCenter = joystickPositionOffset;
			}	
			}
		}
	}
	
	/// <summary>
	/// When the joystick is dynamic mode, this value indicates the area authorized for display
	/// </summary>
	public DynamicArea area = DynamicArea.FullScreen;	
	
	/// <summary>
	/// The joystick anchor.
	/// </summary>
	[SerializeField]
	private JoystickAnchor joyAnchor = JoystickAnchor.LowerLeft;
	public JoystickAnchor JoyAnchor {
		get {
			return this.joyAnchor;
		}
		set {
			joyAnchor = value;
			ComputeJoystickAnchor(joyAnchor);
		}
	}	
	
	/// <summary>
	/// The joystick position on the screen
	/// </summary>
	[SerializeField]
	private Vector2 joystickPositionOffset = Vector2.zero;
	public Vector2 JoystickPositionOffset {
		get {
			return this.joystickPositionOffset;
		}
		set {
			
			joystickPositionOffset = value;
			ComputeJoystickAnchor(joyAnchor);
		}
	}	
	
	/// <summary>
	/// The zone radius size.
	/// </summary>
	/// 
	[SerializeField]
	private float zoneRadius=100f;
	public float ZoneRadius {
		get {
			return this.zoneRadius;
		}
		set {
			zoneRadius = value;
			ComputeJoystickAnchor(joyAnchor);
		}
	}
	
	[SerializeField]
	private float touchSize = 30;
	/// <summary>
	/// Gets or sets the size of the touch.
	/// 
	/// </summary>
	/// <value>
	/// The size of the touch.
	/// </value>
	public float TouchSize {
		get {
			return this.touchSize;
		}
		set {
			touchSize = value;
			if (touchSize>zoneRadius/2 && restrictArea){
				touchSize =zoneRadius/2; 	
			}
			ComputeJoystickAnchor(joyAnchor);
		}
	}
	
	/// <summary>
	/// The dead zone size. While the touch is in this area, the joystick is considered stalled
	/// </summary> 
	public float deadZone=20;

	[SerializeField]
	private bool restrictArea=false;
	/// <summary>
	/// Gets or sets a value indicating whether the touch must be in the radius area.
	/// </summary>
	/// <value>
	/// <c>true</c> if restrict area; otherwise, <c>false</c>.
	/// </value>
	public bool RestrictArea {
		get {
			return this.restrictArea;
		}
		set {
			restrictArea = value;
			if (restrictArea){
				touchSizeCoef = touchSize;
			}
			else{
				touchSizeCoef=0;	
			}
			ComputeJoystickAnchor(joyAnchor);
		}
	}	
	
	/// <summary>
	/// The reset finger exit.
	/// </summary>
	public bool resetFingerExit = false;	
	#endregion
	
	#region Joystick axes properties & event
	/// <summary>
	/// The interaction.
	/// </summary>
	[SerializeField]
	private  InteractionType interaction = InteractionType.Direct;
	public InteractionType Interaction {
		get {
			return this.interaction;
		}
		set {
			interaction = value;
			if (interaction == InteractionType.Direct || interaction == InteractionType.Include){
				useBroadcast = false;	
			}
		}
	}		
	
	/// <summary>
	/// The use broadcast for javascript
	/// </summary>
	public bool useBroadcast = false;
	
	/// <summary>
	/// The message sending mode fro broacast
	/// </summary>
	public Broadcast messageMode;
	
	// Messaging
	/// <summary>
	/// The receiver gameobject when you're in broacast mode for events
	/// </summary>
	public GameObject receiverGameObject; 
	
	/// <summary>
	/// The speed of each joystick axis
	/// </summary>
	public Vector2 speed;
	
	#region X axis
	public bool enableXaxis = true;

	[SerializeField]
	private Transform xAxisTransform;
	/// <summary>
	/// Gets or sets the transform influenced by x axis of the joystick.
	/// </summary>
	/// <value>
	/// The X axis transform.
	/// </value>
	public Transform XAxisTransform {
		get {
			return this.xAxisTransform;
		}
		set {
			xAxisTransform = value;
			if (xAxisTransform!=null){
				xAxisCharacterController = xAxisTransform.GetComponent<CharacterController>();
			}
			else{
				xAxisCharacterController=null;	
				xAxisGravity=0;
			}
		}
	}	
	
	/// <summary>
	/// The character controller attached to the X axis transform (if exist)
	/// </summary>
	public CharacterController xAxisCharacterController;
	
	/// <summary>
	/// The gravity.
	/// </summary>
	public float xAxisGravity=0;
	
	[SerializeField]
	private PropertiesInfluenced xTI;
	/// <summary>
	/// The Property influenced by the x axis joystick
	/// </summary>
	public PropertiesInfluenced XTI {
		get {
			return this.xTI;
		}
		set {
			xTI = value;
			if (xTI != PropertiesInfluenced.RotateLocal){
				enableXAutoStab = false;
				enableXClamp = false;
			}
		}
	}	
	
	/// <summary>
	/// The axis influenced by the x axis joystick
	/// </summary>
	public AxisInfluenced xAI;
	/// <summary>
	/// Inverse X axis.
	/// </summary>
	public bool inverseXAxis=false;
	/// <summary>
	/// The limit angle.
	/// </summary>
	public bool enableXClamp=false;

	/// <summary>
	/// The clamp X max.
	/// </summary>
	public float clampXMax;
	/// <summary>
	/// The clamp X minimum.
	/// </summary>
	public float clampXMin;
	
	/// <summary>
	/// The enable X auto stab.
	/// </summary>
	public bool enableXAutoStab=false;
	
	[SerializeField]
	private float thresholdX=0.01f;
	/// <summary>
	/// Gets or sets the threshold x.
	/// </summary>
	/// <value>
	/// The threshold x.
	/// </value>
	public float ThresholdX {
		get {
			return this.thresholdX;
		}
		set {
			if (value<=0){
				thresholdX=value*-1f;
			}
			else{
				thresholdX = value;
				}
		}
	}	
	
	[SerializeField]
	private float stabSpeedX = 20f;	
	/// <summary>
	/// Gets or sets the stab speed x.
	/// </summary>
	/// <value>
	/// The stab speed x.
	/// </value>
	public float StabSpeedX {
		get {
			return this.stabSpeedX;
		}
		set {
			if (value<=0){
				stabSpeedX = value*-1f;
			}
			else{
				stabSpeedX = value;
			}
		}
	}
	#endregion
	
	#region Y axis
	public bool enableYaxis = true;
	
	[SerializeField]
	private Transform yAxisTransform;
	/// <summary>
	/// Gets or sets the transform influenced by y axis of the joystick.
	/// </summary>
	/// <value>
	/// The Y axis transform.
	/// </value>
	public Transform YAxisTransform {
		get {
			return this.yAxisTransform;
		}
		set {
			yAxisTransform = value;
			if (yAxisTransform!=null){
				yAxisCharacterController = yAxisTransform.GetComponent<CharacterController>();
			}
			else{
				yAxisCharacterController=null;
				yAxisGravity=0;
			}
		}
	}	
	
	/// <summary>
	/// The character controller attached to the X axis transform (if exist)
	/// </summary>
	public CharacterController yAxisCharacterController;
	
	/// <summary>
	/// The y axis gravity.
	/// </summary>
	public float yAxisGravity=0;

	/// <summary>
	/// The Property influenced by the y axis joystick
	/// </summary>
	[SerializeField]
	private PropertiesInfluenced yTI;
	public PropertiesInfluenced YTI {
		get {
			return this.yTI;
		}
		set {
			yTI = value;
			if (yTI != PropertiesInfluenced.RotateLocal){
				enableYAutoStab = false;
				enableYClamp = false;
			}
		}
	}	
	
	/// <summary>
	/// The axis influenced by the y axis joystick
	/// </summary>
	public AxisInfluenced yAI;
	
	/// <summary>
	/// Inverse Y axis.
	/// </summary>	
	public bool inverseYAxis=false;
	/// <summary>
	/// The enable Y clamp.
	/// </summary>
	public bool enableYClamp=false;
	/// <summary>
	/// The clamp Y max.
	/// </summary>
	public float clampYMax;
	/// <summary>
	/// The clamp Y minimum.
	/// </summary>
	public float clampYMin;
	/// <summary>
	/// The enable Y auto stab.
	/// </summary>
	public bool enableYAutoStab = false;
	
	[SerializeField]
	private float thresholdY=0.01f;
	/// <summary>
	/// Gets or sets the threshold y.
	/// </summary>
	/// <value>
	/// The threshold y.
	/// </value>
	public float ThresholdY {
		get {
			return this.thresholdY;
		}
		set {
			if (value<=0){
				thresholdY=value*-1f;
			}
			else{
				thresholdY = value;
			}
		}
	}	
	
	[SerializeField]
	private float stabSpeedY = 20f;
	/// <summary>
	/// Gets or sets the stab speed y.
	/// </summary>
	/// <value>
	/// The stab speed y.
	/// </value>
	public float StabSpeedY {
		get {
			return this.stabSpeedY;
		}
		set {
			if (value<=0){
				stabSpeedY=value*-1f;
			}
			else{
				stabSpeedY = value;
			};
		}
	}

	#endregion	

	/// <summary>
	/// The enable smoothing.When smoothing is enabled, resets the joystick slowly in the start position
	/// </summary>
	public bool enableSmoothing = false;
	
	[SerializeField]
	public Vector2 smoothing = new Vector2(2f,2f);
	/// <summary>
	/// Gets or sets the smoothing values
	/// </summary>
	/// <value>
	/// The smoothing.
	/// </value>
	public Vector2 Smoothing {
		get {
			return this.smoothing;
		}
		set {
			smoothing = value;
			if (smoothing.x<0f){
				smoothing.x=0;
			}
			if (smoothing.y<0){
				smoothing.y=0;	
			}
		}
	}
	
	/// <summary>
	/// The enable inertia. Inertia simulates sliding movements (like a hovercraft, for example)
	/// </summary>
	public bool enableInertia = false;
	
	[SerializeField]
	public Vector2 inertia = new Vector2(100,100);
	/// <summary>
	/// Gets or sets the inertia values
	/// </summary>
	/// <value>
	/// The inertia.
	/// </value>
	public Vector2 Inertia {
		get {
			return this.inertia;
		}
		set {
			inertia = value;
			if (inertia.x<=0){
				inertia.x=1;
			}
			if (inertia.y<=0){
				inertia.y=1;
			}
			
		}
	}
	#endregion

	#region Joystick textures & color
	/// <summary>
	/// The GUI depth.
	/// </summary>
	public int guiDepth = 0;
	
	// Joystick Texture
	/// <summary>
	/// The show zone.
	/// </summary>
	public bool showZone = true;
	/// <summary>
	/// The show touch.
	/// </summary>
	public bool showTouch = true;
	/// <summary>
	/// The show dead zone.
	/// </summary>
	public bool showDeadZone = true;
	/// <summary>
	/// The area texture.
	/// </summary>
	public Texture areaTexture;
	/// <summary>
	/// The color of the area.
	/// </summary>
	public Color areaColor = Color.white;
	/// <summary>
	/// The touch texture.
	/// </summary>
	public Texture touchTexture;
	/// <summary>
	/// The color of the touch.
	/// </summary>
	public Color touchColor = Color.white;
	/// <summary>
	/// The dead texture.
	/// </summary>
	public Texture deadTexture;	
	#endregion

	#region Inspector
	public bool showProperties=true;
	public bool showInteraction=false;
	public bool showAppearance=false;
	public bool showPosition=true;
	#endregion

	#endregion

	#region private members
	// Joystick properties
	private Vector2 joystickCenter;
	
	private Rect areaRect;
	private Rect deadRect;
	
	private Vector2 anchorPosition = Vector2.zero;
	private bool virtualJoystick = true;
	private int joystickIndex=-1;
	private float touchSizeCoef=0;
	private bool sendEnd=true;
	
	private float startXLocalAngle=0;
	private float startYLocalAngle=0;
	#endregion
	
	#endregion
	
	#region Monobehaviour methods
	void OnEnable(){
		EasyTouch.On_TouchStart += On_TouchStart;
		EasyTouch.On_TouchUp += On_TouchUp;
		EasyTouch.On_TouchDown += On_TouchDown;
		EasyTouch.On_SimpleTap += On_SimpleTap;
		EasyTouch.On_DoubleTap += On_DoubleTap;
	}

	void OnDisable(){
		EasyTouch.On_TouchStart -= On_TouchStart;
		EasyTouch.On_TouchUp -= On_TouchUp;
		EasyTouch.On_TouchDown -= On_TouchDown;	
		EasyTouch.On_SimpleTap -= On_SimpleTap;
		EasyTouch.On_DoubleTap -= On_DoubleTap;	
		
		if (Application.isPlaying){
			EasyTouch.RemoveReservedArea( areaRect );
		}
	}
		
	void OnDestroy(){
		EasyTouch.On_TouchStart -= On_TouchStart;
		EasyTouch.On_TouchUp -= On_TouchUp;
		EasyTouch.On_TouchDown -= On_TouchDown;	
		EasyTouch.On_SimpleTap -= On_SimpleTap;
		EasyTouch.On_DoubleTap -= On_DoubleTap;	
		
		if (Application.isPlaying){
			EasyTouch.RemoveReservedArea( areaRect);
		}
	}		
			
	void Start(){
					
		if (!dynamicJoystick){
			joystickCenter = joystickPositionOffset;
			ComputeJoystickAnchor(joyAnchor);
			virtualJoystick = true;
		}
		else{
			virtualJoystick = false;	
		}
		VirtualScreen.ComputeVirtualScreen();

		startXLocalAngle = GetStartAutoStabAngle( xAxisTransform, xAI);
		startYLocalAngle = GetStartAutoStabAngle( yAxisTransform, yAI);	
	}
	
	void Update(){
		if (!useFixedUpdate && enable){
			UpdateJoystick();	
		}
	}
	
	void FixedUpdate(){
		if (useFixedUpdate && enable){
			UpdateJoystick();	
		}		
	}
	
	void UpdateJoystick(){
		
		if (Application.isPlaying){
			
			if (isActivated){
				
				if ((joystickIndex==-1) || (joystickAxis == Vector2.zero && joystickIndex>-1)){
					if (enableXAutoStab){
						DoAutoStabilisation(xAxisTransform, xAI,thresholdX,stabSpeedX,startXLocalAngle);
					}
					if (enableYAutoStab){
						DoAutoStabilisation(yAxisTransform, yAI,thresholdY,stabSpeedY,startYLocalAngle);
					}	
				}
				
				if (!dynamicJoystick){
					joystickCenter = joystickPositionOffset;
				}
				
				// Reset to initial position
				if (joystickIndex==-1){
					if (!enableSmoothing){
						joystickTouch = Vector2.zero;
					}
					else{ 
						if (joystickTouch.sqrMagnitude>0.0001){
							joystickTouch = new Vector2( joystickTouch.x - joystickTouch.x*smoothing.x*Time.deltaTime, joystickTouch.y - joystickTouch.y*smoothing.y*Time.deltaTime);	
						}
						else{
							joystickTouch = Vector2.zero;
						}
					}
				}
				
				
				// Joystick Axis & dead zone
				Vector2 oldJoystickAxis = new Vector2(joystickAxis.x,joystickAxis.y);
   				float deadCoef = ComputeDeadZone();
    			joystickAxis= new Vector2(joystickTouch.x*deadCoef, joystickTouch.y*deadCoef);				
				
				// Inverse axis ?
				if (inverseXAxis){
					joystickAxis.x *= -1;	
				}
				if (inverseYAxis){
					joystickAxis.y *= -1;	
				}
				
				// Joystick Value
				Vector2 realvalue = new Vector2(  speed.x*joystickAxis.x,speed.y*joystickAxis.y);
				if (enableInertia){
					Vector2 tmp = (realvalue - joystickValue);
					tmp.x /= inertia.x;
					tmp.y /= inertia.y;
					joystickValue += tmp;
					
				}
				else{
					joystickValue = realvalue;	
					
				}

				// Start moving
				if (oldJoystickAxis == Vector2.zero && joystickAxis != Vector2.zero){
					if (interaction != InteractionType.Direct && interaction != InteractionType.Include){
						CreateEvent(MessageName.On_JoystickMoveStart);	
					}
				}				
				
				// interaction manager
				UpdateGravity();
	
				
				if (joystickAxis != Vector2.zero){
					sendEnd = false;
					switch(interaction){
						case InteractionType.Direct:
							UpdateDirect();
							break;
						case InteractionType.EventNotification:
							CreateEvent(MessageName.On_JoystickMove);
							break;
						case InteractionType.DirectAndEvent:
							UpdateDirect();
							CreateEvent(MessageName.On_JoystickMove);
							break;
					}
				}
				else{
					if (!sendEnd){
						CreateEvent(MessageName.On_JoystickMoveEnd);
						sendEnd = true;
					}
								
				}
			}
		}	
	}
	
	void OnGUI(){
							
		if (enable){
	
			GUI.depth = guiDepth;
			
			useGUILayout = isUseGuiLayout;
			
			if (dynamicJoystick && Application.isEditor && !Application.isPlaying){
				switch (area){
					case DynamicArea.Bottom:	
						ComputeJoystickAnchor(JoystickAnchor.LowerCenter);
						break;
					case DynamicArea.BottomLeft:
						ComputeJoystickAnchor(JoystickAnchor.LowerLeft);
						break;
					case DynamicArea.BottomRight:
						ComputeJoystickAnchor(JoystickAnchor.LowerRight);
						break;
					case DynamicArea.FullScreen:
						ComputeJoystickAnchor(JoystickAnchor.MiddleCenter);
						break;
					case DynamicArea.Left:
						ComputeJoystickAnchor(JoystickAnchor.MiddleLeft);
						break;
					case DynamicArea.Right:
						ComputeJoystickAnchor(JoystickAnchor.MiddleRight);
						break;
					case DynamicArea.Top:
						ComputeJoystickAnchor(JoystickAnchor.UpperCenter);
						break;
					case DynamicArea.TopLeft:
						ComputeJoystickAnchor(JoystickAnchor.UpperLeft);
						break;
					case DynamicArea.TopRight:
						ComputeJoystickAnchor(JoystickAnchor.UpperRight);
						break;
				}
			}
			
			if (Application.isEditor && !Application.isPlaying){
				VirtualScreen.ComputeVirtualScreen();
				ComputeJoystickAnchor( joyAnchor);
			}
			
			VirtualScreen.SetGuiScaleMatrix();
			
			
			
			// area zone
			if ((showZone && areaTexture!=null && !dynamicJoystick) || (showZone && dynamicJoystick && virtualJoystick && areaTexture!=null) 
				|| (dynamicJoystick && Application.isEditor && !Application.isPlaying)){
				if (isActivated){
					GUI.color = areaColor;
					
					if (Application.isPlaying && !dynamicJoystick){
						EasyTouch.RemoveReservedArea( areaRect );
						EasyTouch.AddReservedArea( areaRect );
					}
				}
				else{
					GUI.color = new Color(areaColor.r,areaColor.g,areaColor.b,0.2f);	
					if (Application.isPlaying && !dynamicJoystick){
						EasyTouch.RemoveReservedArea( areaRect );	
					}
				}		
				
				if (showDebugRadius && Application.isEditor){
					GUI.Box( areaRect,"");				
				}
				
				GUI.DrawTexture( areaRect, areaTexture,ScaleMode.StretchToFill,true);
			}
			
			
			// area touch
			if ((showTouch && touchTexture!=null && !dynamicJoystick)|| (showTouch && dynamicJoystick && virtualJoystick && touchTexture!=null) 
				|| (dynamicJoystick && Application.isEditor && !Application.isPlaying)){
				if (isActivated){
					GUI.color = touchColor;
				}
				else{
					GUI.color = new Color(touchColor.r,touchColor.g,touchColor.b,0.2f);	
				}			
				GUI.DrawTexture( new Rect(anchorPosition.x +  joystickCenter.x+(joystickTouch.x -touchSize) ,anchorPosition.y + joystickCenter.y-(joystickTouch.y+touchSize),touchSize*2,touchSize*2), touchTexture,ScaleMode.ScaleToFit,true);
			}	
	
			// dead zone
			if ((showDeadZone && deadTexture!=null && !dynamicJoystick)|| (showDeadZone && dynamicJoystick && virtualJoystick && deadTexture!=null) 
				|| (dynamicJoystick && Application.isEditor && !Application.isPlaying)){			
				GUI.DrawTexture( deadRect, deadTexture,ScaleMode.ScaleToFit,true);
			}	
			
			GUI.color = Color.white;
		}
		else{
			EasyTouch.RemoveReservedArea( areaRect );	
		}
	}
	
	void OnDrawGizmos(){
	}
	
	#endregion
	
	#region Private methods
	void CreateEvent(MessageName message){
		
		MovingJoystick move = new MovingJoystick();
		move.joystickName = gameObject.name;
		move.joystickAxis = joystickAxis;
		move.joystickValue = joystickValue;
		move.joystick = this;
		
		//
		if (!useBroadcast){
			switch (message){
				case MessageName.On_JoystickMoveStart:
					if (On_JoystickMoveStart!=null){
						On_JoystickMoveStart( move);	
					}
					break;					
				case MessageName.On_JoystickMove:
					if (On_JoystickMove!=null){
						On_JoystickMove( move);	
					}
					break;
				case MessageName.On_JoystickMoveEnd:
					if (On_JoystickMoveEnd!=null){
						On_JoystickMoveEnd( move);	
					}
					break;	
				case MessageName.On_JoystickTouchStart:
					if (On_JoystickTouchStart!=null){
						On_JoystickTouchStart( move);	
					}
					break;
				case MessageName.On_JoystickTap:
					if (On_JoystickTap!=null){
						On_JoystickTap( move);	
					}
					break;				
				
				case MessageName.On_JoystickDoubleTap:
					if (On_JoystickDoubleTap!=null){
						On_JoystickDoubleTap( move);	
					}
					break;	
				case MessageName.On_JoystickTouchUp:
					if (On_JoystickTouchUp!=null){
						On_JoystickTouchUp( move);	
					}
					break;
			}			
		}
		else if (useBroadcast){
			if (receiverGameObject!=null){
				switch(messageMode){
					case Broadcast.BroadcastMessage:
						receiverGameObject.BroadcastMessage( message.ToString(),move,SendMessageOptions.DontRequireReceiver);
						break;
					case Broadcast.SendMessage:
						receiverGameObject.SendMessage( message.ToString(),move,SendMessageOptions.DontRequireReceiver);
						break;
					case Broadcast.SendMessageUpwards:
						receiverGameObject.SendMessageUpwards( message.ToString(),move,SendMessageOptions.DontRequireReceiver);
						break;
					}
			}
			else{
				Debug.LogError("Joystick : " + gameObject.name + " : you must setup receiver gameobject");	
			}
		}
		
	}
	
	void UpdateDirect(){
		
		// X joystick axis
		if (xAxisTransform !=null){
			// Axis influenced
			Vector3 axis =GetInfluencedAxis( xAI);
			// Action
			DoActionDirect( xAxisTransform, xTI, axis, joystickValue.x, xAxisCharacterController);

			if (enableXClamp &&  xTI == PropertiesInfluenced.RotateLocal){
				DoAngleLimitation( xAxisTransform, xAI, clampXMin,clampXMax, startXLocalAngle );
			}
		}
		
		
		// y joystick axis
		if (YAxisTransform !=null){
			// Axis
			Vector3 axis = GetInfluencedAxis(yAI);
			// Action
			DoActionDirect( yAxisTransform, yTI, axis,joystickValue.y, yAxisCharacterController);
			
			if (enableYClamp &&  yTI == PropertiesInfluenced.RotateLocal){
				DoAngleLimitation( yAxisTransform, yAI, clampYMin, clampYMax, startYLocalAngle );
			}
			
		}
		
	}
	
	void UpdateGravity(){
		// Gravity
		if (xAxisCharacterController!=null && xAxisGravity>0){
			xAxisCharacterController.Move( Vector3.down*xAxisGravity*Time.deltaTime);	
		}
			
		if (yAxisCharacterController!=null && yAxisGravity>0){
			yAxisCharacterController.Move( Vector3.down*yAxisGravity*Time.deltaTime);
		}		
	}
	
	Vector3 GetInfluencedAxis(AxisInfluenced axisInfluenced){
		
		Vector3 axis = Vector3.zero;
		
		switch(axisInfluenced){
			case AxisInfluenced.X:
				axis = Vector3.right;
				break;
			case AxisInfluenced.Y:
				axis = Vector3.up;
				break;
			case AxisInfluenced.Z:
				axis = Vector3.forward;
				break;
			case AxisInfluenced.XYZ:
				axis = Vector3.one;
				break;
				
		}	
		
		return axis;
	}
	
	void DoActionDirect(Transform axisTransform, PropertiesInfluenced inlfuencedProperty,Vector3 axis, float sensibility, CharacterController charact){
		

		switch(inlfuencedProperty){
			
			case PropertiesInfluenced.Rotate:
				axisTransform.Rotate( axis * sensibility * Time.deltaTime,Space.World);
				break;	
			
			case PropertiesInfluenced.RotateLocal:
				axisTransform.Rotate( axis * sensibility * Time.deltaTime,Space.Self);
				break;
			
			case PropertiesInfluenced.Translate:
				if (charact==null){
					axisTransform.Translate(axis * sensibility * Time.deltaTime,Space.World);
				}
				else{
					charact.Move( axis * sensibility * Time.deltaTime );
				}
				break;
			
			case PropertiesInfluenced.TranslateLocal:
				if (charact==null){
					axisTransform.Translate(axis * sensibility * Time.deltaTime,Space.Self);
				}
				else{
					
					charact.Move( charact.transform.TransformDirection(axis) * sensibility * Time.deltaTime );
				}
				break;	
			
			case PropertiesInfluenced.Scale:
				axisTransform.localScale +=  axis * sensibility * Time.deltaTime;
				break;
		}
		
	}
	
	void DoAngleLimitation(Transform axisTransform, AxisInfluenced axisInfluenced,float clampMin, float clampMax,float startAngle){
		
		float angle=0;
		
		switch(axisInfluenced){
			case AxisInfluenced.X:
				angle = axisTransform.localRotation.eulerAngles.x;
				break;
			case AxisInfluenced.Y:
				angle = axisTransform.localRotation.eulerAngles.y;
				break;
			case AxisInfluenced.Z:
				angle = axisTransform.localRotation.eulerAngles.z;
				break;			
		}
		
		if (angle<=360 && angle>=180){
			angle = angle -360;	
		}
		
		//angle = Mathf.Clamp (angle, startAngle-clampMax, clampMin+startAngle);
		angle = Mathf.Clamp (angle, -clampMax, clampMin);
		
		
		switch(axisInfluenced){
			case AxisInfluenced.X:
				axisTransform.localEulerAngles = new Vector3( angle,axisTransform.localEulerAngles.y, axisTransform.localEulerAngles.z);
				break;	
			case AxisInfluenced.Y:
				axisTransform.localEulerAngles = new Vector3( axisTransform.localEulerAngles.x,angle, axisTransform.localEulerAngles.z);
				break;
			case AxisInfluenced.Z:
				axisTransform.localEulerAngles = new Vector3( axisTransform.localEulerAngles.x,axisTransform.localEulerAngles.y,angle);
				break;	
								
		}
		
	}
	
	void DoAutoStabilisation(Transform axisTransform, AxisInfluenced axisInfluenced, float threshold, float speed,float startAngle){
	
		float angle=0;
		switch(axisInfluenced){
			case AxisInfluenced.X:
				angle = axisTransform.localRotation.eulerAngles.x;
				break;
			case AxisInfluenced.Y:
				angle = axisTransform.localRotation.eulerAngles.y;
				break;
			case AxisInfluenced.Z:
				angle = axisTransform.localRotation.eulerAngles.z;
				break;			
		}
		
		
		if (angle<=360 && angle>=180){
			angle = angle -360;	
		}		
		
		
		if (angle > startAngle - threshold || angle < startAngle + threshold){
			
			float axis=0;
			Vector3 stabAngle = Vector3.zero;
			
			if (angle > startAngle - threshold){
				axis = angle + speed/100f*Mathf.Abs (angle-startAngle) * Time.deltaTime*-1;
			}
		
		
			if (angle < startAngle + threshold){
				axis = angle + speed/100f*Mathf.Abs (angle-startAngle) * Time.deltaTime;
			}
		
			switch(axisInfluenced){
				case AxisInfluenced.X:	
					stabAngle = new Vector3(axis,axisTransform.localRotation.eulerAngles.y,axisTransform.localRotation.eulerAngles.z);
					break;
				case AxisInfluenced.Y:	
					stabAngle = new Vector3(axisTransform.localRotation.eulerAngles.x,axis,axisTransform.localRotation.eulerAngles.z);
					break;
				case AxisInfluenced.Z:	
					stabAngle = new Vector3(axisTransform.localRotation.eulerAngles.x,axisTransform.localRotation.eulerAngles.y,axis);
					break;
			}
			
			axisTransform.localRotation  = Quaternion.Euler( stabAngle);	
		}
	}
	
	float GetStartAutoStabAngle(Transform axisTransform, AxisInfluenced axisInfluenced){
		
		float angle=0;
		
		if (axisTransform!=null){
			switch(axisInfluenced){
				case AxisInfluenced.X:
					angle = axisTransform.localRotation.eulerAngles.x;
					break;
				case AxisInfluenced.Y:
					angle = axisTransform.localRotation.eulerAngles.y;
					break;
				case AxisInfluenced.Z:
					angle = axisTransform.localRotation.eulerAngles.z;
					break;			
			}	
			
			if (angle<=360 && angle>=180){
				angle = angle -360;	
			}
		}
		
		return angle;
	}
	
	float ComputeDeadZone(){
		
		float dead = 0;
		float dist = Mathf.Max(joystickTouch.magnitude,0.1f);
		
		if (restrictArea){
			dead = Mathf.Max(dist - deadZone, 0)/(zoneRadius-touchSize - deadZone)/dist;
		}
		else{
			dead = Mathf.Max(dist - deadZone, 0)/(zoneRadius - deadZone)/dist;
		}		
		
		return dead;
	}
	
	void ComputeJoystickAnchor(JoystickAnchor anchor){
	
		float touch=0;
		if (!restrictArea){
			touch = touchSize;	
		}
		// Anchor position
		switch (anchor){
			case JoystickAnchor.UpperLeft:
				anchorPosition = new Vector2( zoneRadius+touch, zoneRadius+touch);
				break;
			case JoystickAnchor.UpperCenter:
				anchorPosition = new Vector2( VirtualScreen.width/2, zoneRadius+touch);
				break;
			case JoystickAnchor.UpperRight:
				anchorPosition = new Vector2( VirtualScreen.width-zoneRadius-touch,zoneRadius+touch);
				break;
			
			
			case JoystickAnchor.MiddleLeft:
				anchorPosition = new Vector2( zoneRadius+touch, VirtualScreen.height/2);
				break;
			case JoystickAnchor.MiddleCenter:
				anchorPosition = new Vector2( VirtualScreen.width/2, VirtualScreen.height/2);
				break;
			case JoystickAnchor.MiddleRight:
				anchorPosition = new Vector2( VirtualScreen.width-zoneRadius-touch,VirtualScreen.height/2);
				break;
			
			case JoystickAnchor.LowerLeft:
				anchorPosition = new Vector2( zoneRadius+touch, VirtualScreen.height-zoneRadius-touch);
				break;
			case JoystickAnchor.LowerCenter:
				anchorPosition = new Vector2( VirtualScreen.width/2, VirtualScreen.height-zoneRadius-touch);
				break;
			case JoystickAnchor.LowerRight:
				anchorPosition = new Vector2( VirtualScreen.width-zoneRadius-touch,VirtualScreen.height-zoneRadius-touch);
				break;	
			
			case JoystickAnchor.None:
				anchorPosition = Vector2.zero;
				break;
		}
				
		//joystick rect
		areaRect = new Rect(anchorPosition.x + joystickCenter.x -zoneRadius , anchorPosition.y+joystickCenter.y-zoneRadius,zoneRadius*2,zoneRadius*2);
		deadRect = new Rect(anchorPosition.x +  joystickCenter.x -deadZone,anchorPosition.y + joystickCenter.y-deadZone,deadZone*2,deadZone*2);
		
	}
	#endregion
	
	#region EasyTouch events
	// Touch start
	void On_TouchStart(Gesture gesture){
					
		if ((!gesture.isHoverReservedArea && dynamicJoystick) || !dynamicJoystick){

			if (isActivated){
				if (!dynamicJoystick){
				
					Vector2 center = new Vector2( (anchorPosition.x+joystickCenter.x) * VirtualScreen.xRatio , (VirtualScreen.height-anchorPosition.y - joystickCenter.y) * VirtualScreen.yRatio);
					
					if ((gesture.position - center).sqrMagnitude < (zoneRadius *VirtualScreen.xRatio )*(zoneRadius *VirtualScreen.xRatio )){
						joystickIndex = gesture.fingerIndex;
						CreateEvent(MessageName.On_JoystickTouchStart);
					}			
				}
				else{
					if (!virtualJoystick){
						
						#region area restriction
						switch (area){
							// full
							case DynamicArea.FullScreen:
								virtualJoystick = true;	;
								break;
							// bottom
							case DynamicArea.Bottom:
								if (gesture.position.y< Screen.height/2){
									virtualJoystick = true;	
								}
								break;
							// top
							case DynamicArea.Top:
								if (gesture.position.y> Screen.height/2){
									virtualJoystick = true;	
								}
								break;
							// Right
							case DynamicArea.Right:
								if (gesture.position.x> Screen.width/2){
									virtualJoystick = true;	
								}
								break;
							// Left
							case DynamicArea.Left:
								if (gesture.position.x< Screen.width/2){
									virtualJoystick = true;	
								}
								break;				
							
							// top Right
							case DynamicArea.TopRight:
								if (gesture.position.y> Screen.height/2 && gesture.position.x> Screen.width/2){
									virtualJoystick = true;	
								}
								break;	
							// top Left
							case DynamicArea.TopLeft:
								if (gesture.position.y> Screen.height/2 && gesture.position.x< Screen.width/2){
									virtualJoystick = true;	
								}
								break;					
							// bottom Right
							case DynamicArea.BottomRight:
								if (gesture.position.y< Screen.height/2 && gesture.position.x> Screen.width/2){
									virtualJoystick = true;	
								}
								break;					
							// bottom left
							case DynamicArea.BottomLeft:
								if (gesture.position.y< Screen.height/2 && gesture.position.x< Screen.width/2){
									virtualJoystick = true;	
								}
							break;							
						}				
						#endregion
						
						if (virtualJoystick){
							joystickCenter =new Vector2(gesture.position.x/VirtualScreen.xRatio,  VirtualScreen.height - gesture.position.y/VirtualScreen.yRatio);
							JoyAnchor = JoystickAnchor.None;
							joystickIndex = gesture.fingerIndex;
						}	
					}
				}
			
			}
		}
	}
	
	// Simple tap
	void On_SimpleTap(Gesture gesture){
		if ((!gesture.isHoverReservedArea && dynamicJoystick) || !dynamicJoystick){
			if (isActivated){
				if (gesture.fingerIndex == joystickIndex){
					CreateEvent(MessageName.On_JoystickTap);	
				}	
			}
		}
	}
	
	// Double tap
	void On_DoubleTap(Gesture gesture){
		if ((!gesture.isHoverReservedArea && dynamicJoystick) || !dynamicJoystick){
			if (isActivated){
				if (gesture.fingerIndex == joystickIndex){
					CreateEvent(MessageName.On_JoystickDoubleTap);	
				}
			}
		}
	}
	
	// Joystick move
	void On_TouchDown(Gesture gesture){
		
		if ((!gesture.isHoverReservedArea && dynamicJoystick) || !dynamicJoystick){
			
			if (isActivated){
				
				Vector2 center = new Vector2( (anchorPosition.x+joystickCenter.x) * VirtualScreen.xRatio , (VirtualScreen.height-(anchorPosition.y +joystickCenter.y)) * VirtualScreen.yRatio);
				if (gesture.fingerIndex == joystickIndex){
					if (((gesture.position - center).sqrMagnitude < (zoneRadius *VirtualScreen.xRatio )*(zoneRadius *VirtualScreen.xRatio) && resetFingerExit) || !resetFingerExit) {
						
						
						joystickTouch  = new Vector2( gesture.position.x , gesture.position.y) - center;
						joystickTouch = new Vector2( joystickTouch.x / VirtualScreen.xRatio, joystickTouch.y / VirtualScreen.yRatio);
						
							if (!enableXaxis){
								joystickTouch.x =0;
							}
							
							if (!enableYaxis){
								joystickTouch.y=0;
							}
						
						if ((joystickTouch/(zoneRadius-touchSizeCoef)).sqrMagnitude > 1){
							joystickTouch.Normalize();
							joystickTouch *= zoneRadius-touchSizeCoef;
						}
					}
					else{
						On_TouchUp( gesture);	
					}
				}
			}
		}
	}
	
	// Touch end
	void On_TouchUp( Gesture gesture){
		
		if ((!gesture.isHoverReservedArea && dynamicJoystick) || !dynamicJoystick){
			if (isActivated){
				if (gesture.fingerIndex == joystickIndex){
					joystickIndex=-1;
					if (dynamicJoystick){
						
						virtualJoystick=false;	
					}
					CreateEvent(MessageName.On_JoystickTouchUp);
				}
			}
		}
	}

	#endregion
	
}
