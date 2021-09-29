using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LampLight : MonoBehaviour
{
    private Vector3 pos;
    void Start()
    {
        pos = transform.position;
        gameObject.SetActive(false);
    }

    private void OnEnable()
    {
        StartCoroutine("Fire");
    }
    private void OnDisable()
    {
        StopCoroutine("Fire");
    }
    void Update()
    {
           
    }
    IEnumerator Fire()
    {
        while (true)
        {
            yield return new WaitForSeconds(0.1f);
            Vector3 delta = new Vector3(Random.Range(-0.02f, 0.02f), Random.Range(-0.02f, 0.02f), 0);
            transform.position = pos + delta;
        }
    }
}
