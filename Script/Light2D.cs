using UnityEngine;

public class Light2D : MonoBehaviour
{
    public bool isIsometry;
    public float speed = 5;
    public float elevation, streight = 1, radius = 1, accuracy = 10, obstacleMul = 100;
    public GameObject height;

    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().material;
        mat.SetFloat("_Accuracy", accuracy);
        mat.SetFloat("_ObstacleMul", obstacleMul);
        mat.SetFloat("_Elevation", elevation);
        mat.SetFloat("_Streight", streight);
        mat.SetFloat("_Radius", radius); 
        mat.SetTexture("_ObstacleHeightTex", LightManager.heightObsTex);
        mat.SetTexture("_DepthTex", LightManager.depthTex);
            mat.SetTexture("_ObstacleTex", LightManager.obstTex);
    }
    void FixedUpdate()
    {
    }
}
