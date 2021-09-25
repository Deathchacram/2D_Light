// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/ray_traced_2D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObstacleTex("Support depth", 2D) = "black" {}
        _ObstacleHeightTex("Obstacle", 2D) = "black" {}
        _DepthTex("Depth texture", 2D) = "black" {}
        _ObstacleMul("Obstacle Mul", Float) = 500
        _Accuracy("accuracy", Float) = 1
        _Elevation("elevation", Float) = 1
        _Streight("streight", Float) = 1
        _Radius("radius", Float) = 1
        _DepthLevel("depth level", Float) = 1
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
            sampler2D _ObstacleTex; 
            sampler2D _ObstacleHeightTex;
            sampler2D _DepthTex;
            half _Accuracy;
            half _Streight;
            half _ObstacleMul;
            half _Elevation;
            half _Radius;
            half _DepthLevel;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.col = v.col;
                //o.vertex = UnityObjectToClipPos(fixed4(v.vertex.xy * _Radius * cos(_Elevation * 3.14159265359), v.vertex.zw));
                o.vertex = UnityObjectToClipPos(fixed4(v.vertex.xy * _Radius, v.vertex.zw));
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.scrPos = ComputeScreenPos(o.vertex);
                o.scrPosCenter = ComputeScreenPos(UnityObjectToClipPos(float4(o.uv, 0, 1))).xy; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 thisPos = i.scrPos.xy;
                fixed2 centerPos = i.scrPosCenter;
                fixed4 col = tex2D(_MainTex, i.uv) * i.col;
                col.rgb *= col.a;

                fixed2 t = fixed2(thisPos.x, thisPos.y - tex2D(_ObstacleTex, thisPos).r * _DepthLevel);
                fixed hPos = _Elevation;
                fixed pos = 1;
                fixed sub = 1 / _Accuracy;
                //fixed m = _ObstacleMul * length((thisPos - centerPos) * fixed2(_ScreenParams.x / _ScreenParams.y, 1) * sub);
                float isHeight = (1 - tex2D(_ObstacleHeightTex, thisPos).a);
                for (int l = 0; l < _Accuracy; l++)
                {
                    pos -= sub;
                    //col *= saturate(1 - tex2D(_ObstacleTex, lerp(centerPos, thisPos, pos)) * m);
                    hPos = lerp(_Elevation, tex2D(_ObstacleTex, thisPos).r, pos);
                    col *= saturate(ceil(hPos - tex2D(_DepthTex, lerp(centerPos, t, pos)).r));
                }
                /*fixed bol = saturate(tex2D(_ObstacleTex, thisPos).r - tex2D(_DepthTex, thisPos).r);
                if (bol > 0)
                {
                    col = tex2D(_MainTex, i.uv) * i.col;
                    col.rgb *= col.a * ceil(saturate(_Elevation - tex2D(_ObstacleTex, thisPos).r));
                }*/

                return col * _Streight * isHeight;
                //return col;
            }
            ENDCG
        }
    }
}