using UnityEngine;
using System.Collections;

public class csPrefebMake : MonoBehaviour 
{

    public Transform MakePrefeb;
    Transform _MakePrefeb;
    public float DeadTime;

    void Start()
    {
        _MakePrefeb = Instantiate(MakePrefeb, transform.position, Quaternion.identity) as Transform;
		_MakePrefeb.transform.parent = transform;
    }

    void Update()
    {

		if(DeadTime<=0)
			return;

        if (_MakePrefeb)
            Destroy(_MakePrefeb.gameObject, DeadTime);
        else if (!_MakePrefeb)
		{
            _MakePrefeb = Instantiate(MakePrefeb, transform.position, Quaternion.identity) as Transform;
			_MakePrefeb.transform.parent = transform;
		}
    }

}
