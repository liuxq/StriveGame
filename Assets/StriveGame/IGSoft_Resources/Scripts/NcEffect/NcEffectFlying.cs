using System;
using UnityEngine;

/* 由于 H/W 的参数加入, TgtTran会到处跑, 飞行轨迹无法确定
 * 所以暂时只支持点到点的飞行, 不支持Transform到Transform的飞行
 */
public class NcEffectFlying : MonoBehaviour
{
	public Vector3 FromPos = Vector3.zero;
	public Vector3 ToPos = Vector3.zero;
	public float Speed = 30.0f;
	public float HWRate = 0f;
	
	private Vector3 m_RelaCoor = Vector3.up;	// 相对坐标系
	private float m_fStartRockon = 0f;
	private float m_fDistance = 0f;
	
	public void Awake()
	{
		// 如果是飞行特效, 不让特效自行销毁
		NcAutoDestruct des = GetComponent<NcAutoDestruct>();
		if(null != des) des.enabled = false;
	}
	
	public void Start()
	{
		m_RelaCoor = (ToPos - FromPos).normalized;
		m_fStartRockon = Time.time;
		m_fDistance = Vector3.Distance(ToPos, FromPos);
	}
	
	public void Update()
	{
		float fDelta = Time.time - m_fStartRockon;
		if(fDelta > m_fDistance / Speed)
		{
			Destroy(gameObject);
			return;
		}
		Vector3 pos = m_RelaCoor * Speed * fDelta;
		float y = 4 * ( Speed * fDelta * HWRate - Mathf.Pow( Speed * fDelta, 2) * HWRate / m_fDistance);
		pos.y += y;
		Vector3 tgtPos = FromPos + m_RelaCoor + pos;
		transform.LookAt(tgtPos);
		transform.position = tgtPos;
	}
}
