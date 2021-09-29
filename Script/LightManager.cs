using UnityEngine;
using UnityEngine.UI;

public class LightManager : MonoBehaviour
{
    public Text fps, lvl;
    public GameObject[] lights, lamps;
    public bool isIsometry, depth;
    public GameObject cameraPrefab;
    public Material postProcess;
    public static RenderTexture lightTex, obstTex, heightObsTex, depthTex;

    private bool lighteSystemEnabled = true, ambientLightEnabled = true, lampsEnabled;
    private Camera cam;
    

    void Awake()
    {
        //Camera camer = GetComponent<Camera>();
        //camer.depthTextureMode = DepthTextureMode.Depth;

        lightTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        lightTex.name = "light_Tex";
        lightTex.filterMode = FilterMode.Point;
        obstTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        obstTex.name = "obstance_Tex";
        obstTex.filterMode = FilterMode.Point;

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
            heightObsTex.filterMode = FilterMode.Point;

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
            depthTex.filterMode = FilterMode.Point;

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
        fps.text = (1 / Time.deltaTime).ToString();
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (lighteSystemEnabled)
            Graphics.Blit(source, destination, postProcess);
        else
            Graphics.Blit(source, destination);
    }

    public void LightSystemEnabled()
    {
        lighteSystemEnabled = !lighteSystemEnabled;
    }
    public void AmbientLightEnabled()
    {
        if (ambientLightEnabled)
        {
            foreach (GameObject lamp in lights)
            {
                lamp.SetActive(false);
            }
            postProcess.SetFloat("_AmbientLight", 0);
        }
        else
        {
            foreach (GameObject lamp in lights)
            {
                lamp.SetActive(true);
            }
            postProcess.SetFloat("_AmbientLight", 0.25f);
        }

            ambientLightEnabled = !ambientLightEnabled;
    }

    public void LampsEnabled()
    {
        if (lampsEnabled)
            foreach (GameObject lamp in lamps)
            {
                lamp.SetActive(false);
            }
        else
            foreach (GameObject lamp in lamps)
            {
                lamp.SetActive(true);
            }

        lampsEnabled = !lampsEnabled;
    }
    public void ChangeLevel(Scrollbar sb)
    {
        foreach (GameObject lamp in lights)
        {
            Material mat = lamp.GetComponent<SpriteRenderer>().material;
            mat.SetFloat("_DepthLevel", sb.value);
            lvl.text = sb.value.ToString();
        }
    }
}
