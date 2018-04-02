using UnityEngine;
using System.Collections;

public class csLightIntancityControl : MonoBehaviour {
	
	public Light _light;
	float _time = 0;
	public float Delay = 0.5f;
	public float Down = 1;

	void Update ()
	{
		_time += Time.deltaTime;

		if(_time > Delay)
		{
			if(_light.intensity > 0)
				_light.intensity -= Time.deltaTime*Down;

			if(_light.intensity <= 0)
				_light.intensity = 0;
		}
	}
}
