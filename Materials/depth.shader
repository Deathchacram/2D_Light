Shader "Unlit/depth"
{
    Properties
    {
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, .5) //Color when intersecting
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 projPos : TEXCOORD1; //Screen position of pos
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            uniform float4 _HighlightColor;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.projPos = ComputeScreenPos(o.vertex) ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 finalColor;                
                float sceneZ = (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r);
                fixed4 col = sceneZ;
                return col;
            }
            ENDCG
        }
    }
}
