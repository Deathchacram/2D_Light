using UnityEngine;

public class LightManager : MonoBehaviour
{
    public bool isIsometry, depth;
    public GameObject cameraPrefab;
    public Material postProcess;
    public static RenderTexture lightTex, obstTex, heightObsTex, depthTex;

    Camera cam;

    void Awake()
    {
        //Camera camer = GetComponent<Camera>();
        //camer.depthTextureMode = DepthTextureMode.Depth;

        lightTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        lightTex.name = "light_Tex";
        obstTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        obstTex.name = "obstance_Tex";

        GameObject cam = Instantiate(cameraPrefab, transform.position, Quaternion.identity, transform);
        cam.name = "Light camera";
        Camera camera = cam.GetComponent<Camera>();
        camera.cullingMask = 1 << 6;
        camera.cullingMask += 1 << 8;
        camera.targetTexture = lightTex;

        cam = Instantiate(cameraPrefab, transform.position, Quaternion.identity, transform);
        cam.name = "Obstance camera";
        camera = cam.GetComponent<Camera>();
        camera.cullingMask = 1 << 7;
        camera.targetTexture = obstTex;

        if (isIsometry)
        {
            heightObsTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            heightObsTex.name = "heightObstance_Tex";

            cam = Instantiate(cameraPrefab, transform.position, Quaternion.identity, transform);
            cam.name = "Height obstance camera";
            camera = cam.GetComponent<Camera>();
            camera.cullingMask = 1 << 9;
            camera.targetTexture = heightObsTex;

            postProcess.SetTexture("_HeightObstanceCam", heightObsTex);
        }
        if (depth)
        {
            depthTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            depthTex.name = "Depth_Tex";

            cam = Instantiate(cameraPrefab, transform.position, Quaternion.identity, transform);
            cam.name = "Depth camera";
            camera = cam.GetComponent<Camera>();
            camera.cullingMask = 1 << 10;
            camera.targetTexture = depthTex;

            postProcess.SetTexture("_DepthTex", depthTex);
        }
        postProcess.SetTexture("_Light", lightTex);
        postProcess.SetTexture("_ObstanceCam", obstTex);
    }


    void Update()
    {
        transform.rotation = Quaternion.identity;
        float deltaX = Input.GetAxisRaw("Horizontal") * Time.deltaTime * 5;
        float deltay = Input.GetAxisRaw("Vertical") * Time.deltaTime * 5;
        transform.position += new Vector3(deltaX, deltay, 0);
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postProcess);
    }
}
