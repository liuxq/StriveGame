using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class EquipWeapon : MonoBehaviour {
    public Transform[] weapon;
    public Transform weaponHand;

    private Transform currentweapon = null;
    private Dictionary<int, Transform> models = new Dictionary<int,Transform>();
    bool isInit = false;
	// Use this for initialization
	void Start () {
        init();
	}
    void init()
    {
        models[6] = weapon[0];
        models[5] = weapon[1];
        models[9] = weapon[2];
        models[10] = weapon[3];
        isInit = true;
    }

    public void equipWeapon(int wIndex)
    {
        if (!isInit)
            init();
        clearWeapon();
        currentweapon = Instantiate(models[wIndex], weaponHand.position,
            Quaternion.Euler(new Vector3(weaponHand.rotation.eulerAngles.x, weaponHand.rotation.eulerAngles.y, weaponHand.rotation.eulerAngles.z + 270))) as Transform;
        currentweapon.parent = weaponHand;
    }

    public void clearWeapon()
    {
        if (currentweapon != null)
        {
            currentweapon.parent = null;
            Destroy(currentweapon.gameObject);
        }
    }

    void OnDestroy()
    {
        clearWeapon();
    }
}
