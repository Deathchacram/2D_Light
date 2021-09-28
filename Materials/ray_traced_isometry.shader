Shader "Unlit/ray_traced_isometry"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ObstacleHeightTex("Obstacle", 2D) = "black" {}
        _ObstacleMul("Obstacle Mul", Float) = 500
        _Accuracy("accuracy", Float) = 1
        _Elevation("elevation", Float) = 1
        _Streight("streight", Float) = 1
        _Radius("radius", Float) = 1
    }
        SubShader
        {
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Cull Off
            Lighting Off
            ZWrite Off
            Blend One OneMinusSrcAlpha

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma 3.0

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float4 col : COLOR;
                    fixed4 normal : TEXCOORD1;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    half2 scrPos : TEXCOORD2;
                    float4 col : COLOR;
                    half2 scrPosCenter : TEXCOORD1;
                };

                sampler2D _MainTex;
                sampler2D _ObstacleHeightTex;
                half _Accuracy;
                half _Streight;
                half _ObstacleMul;
                half _Elevation;
                half _Radius;
                float4 _MainTex_ST;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.col = v.col;
                    o.vertex = UnityObjectToClipPos(fixed4(v.vertex.xy * _Radius * cos(_Elevation), v.vertex.zw));
                    //o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.scrPos = ComputeScreenPos(o.vertex);
                    o.scrPosCenter = ComputeScreenPos(UnityObjectToClipPos(float4(o.uv, 0, 1))).xy;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed pi = 3.14159265359;
                    fixed2 thisPos = i.scrPos.xy;
                    fixed2 centerPos = i.scrPosCenter;
                    fixed a = 0;
                    float bol = ceil(saturate(tex2D(_ObstacleHeightTex, thisPos).r * 2 - 1 + 0.1) * saturate(tex2D(_ObstacleHeightTex, thisPos).g * 2 - 1 + 0.1));
                    if (bol > 0)
                    {
                        fixed3 angle = fixed3(thisPos - centerPos, _Elevation);
                        angle = fixed3(sin((angle.x + angle.y) * pi), sin((angle.y - angle.x) * pi), angle.z);
                        angle = normalize(angle);

                        fixed4 obs = tex2D(_ObstacleHeightTex, thisPos);
                        obs = (obs - 0.5) * 2;
                        a = dot(obs.xyz, angle.xyz) * tex2D(_ObstacleHeightTex, thisPos).a * tex2D(_MainTex, i.uv).a;
                    }
                    fixed4 col = a * i.col;

                    fixed4 c = tex2D(_ObstacleHeightTex, thisPos);
                    float r = c.r + c.g + c.b - 3;
                    if (r == 0)
                        col = 0;
                    //return col * _Streight * cos(_Elevation);
                    //return fixed4(angle.y + angle.x, angle.y + angle.x, angle.y + angle.x, 1);
                    //return fixed4(angle.y, angle.y, angle.y, 1);
                    return col * _Streight;
                    //return a;
                }
                ENDCG
            }
        }
}
