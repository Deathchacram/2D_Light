Shader "Unlit/plane_Light"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Light("Light", 2D) = "white" {}
        _HeightObstanceCam("Light", 2D) = "white" {}
        _DepthTex("Depth texture", 2D) = "black" {}
        _Level("depth level", Float) = 0.01
        _Accuracy("accuracy", Float) = 10
        _A("accuracy", Float) = 1
        _AmbientLight("ambient light", Float) = 0.2
        _AmbientColor("ambient color", Color) = (0, 0, 0, 0)
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
            #pragma target 3.0

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
            };

            sampler2D _MainTex;
            sampler2D _Light;
            sampler2D _DepthTex;
            sampler2D _HeightObstanceCam;
            float4 _MainTex_ST;
            float4 _AmbientColor;
            half _AmbientLight;
            half _Level;
            half _Accuracy;
            half _A;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed sub = 1 / _Accuracy;
                fixed m = -1;
                fixed delta = 0;
                fixed depth = 1;
                for (int l = 0; l < _Accuracy; l++)
                {
                    //fixed a = tex2D(_DepthTex, fixed2(i.uv.x, i.uv.y + (1 - sub * l))).r;
                    delta = tex2D(_DepthTex, i.uv).r - tex2D(_DepthTex, fixed2(i.uv.x, i.uv.y + _Level * saturate(sub * l))).r;
                    if (delta < 0)
                    {
                        if(sub * l + delta < sub)
                            depth = 0;
                    }
                }
                //fixed delta = tex2D(_DepthTex, i.uv).r - tex2D(_DepthTex, fixed2(i.uv.x, i.uv.y + _Level * (1 - tex2D(_DepthTex, i.uv).r))).r;

               //fixed4 light = (depth) * tex2D(_Light, fixed2(i.uv.x, i.uv.y + _Level * (tex2D(_DepthTex, i.uv).r)));
                fixed4 light = tex2D(_Light, fixed2(i.uv.x, i.uv.y));
                fixed4 col = tex2D(_MainTex, i.uv) * (light + _AmbientLight * _AmbientColor);


              //return depth * tex2D(_DepthTex, i.uv).r;
                return col;
            }
            ENDCG
        }
    }
}
