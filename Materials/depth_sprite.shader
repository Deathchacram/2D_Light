Shader "Unlit/depth_sprite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObstacleTex("Support depth", 2D) = "black" {}
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
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 col : COLOR1;
            };

            sampler2D _MainTex;
            sampler2D _ObstacleTex;
            float4 _MainTex_ST;
            float _DepthLevel;

            v2f vert (appdata v)
            {
                v2f o;
                o.color = v.color;
                //o.vertex = UnityObjectToClipPos(fixed4(v.vertex.xy * _Radius * cos(_Elevation * 3.14159265359), v.vertex.zw));
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                fixed4 scrPosCenter = ComputeScreenPos(UnityObjectToClipPos(float4(o.uv, 0, 1)));
                o.color = tex2Dlod(_ObstacleTex, scrPosCenter);
                //o.vertex = UnityObjectToClipPos(fixed4(v.vertex.x, v.vertex.y - o.col.r * _DepthLevel, v.vertex.zw));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv).r;
                col.rgb *= i.color.rgb;
                col.rgb *= col.a;
                return col;
            }
            ENDCG
        }
    }
}
//Properties
//			{
//				[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
//				_ObstacleTex("Support depth", 2D) = "black" {}
//				_Color("Tint", Color) = (1,1,1,1)
//				_Streight("streight", Float) = 0
//				[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
//			}
//
//				SubShader
//				{
//					Tags
//					{
//						"Queue" = "Transparent"
//						"IgnoreProjector" = "True"
//						"RenderType" = "Transparent"
//						"PreviewType" = "Plane"
//						"CanUseSpriteAtlas" = "True"
//					}
//
//					Cull Off
//					Lighting Off
//					ZWrite Off
//					Blend One OneMinusSrcAlpha
//
//					Pass
//					{
//					CGPROGRAM
//						#pragma vertex vert
//						#pragma fragment frag
//						#pragma multi_compile _ PIXELSNAP_ON
//						#include "UnityCG.cginc"
//
//						struct appdata_t
//						{
//							float4 vertex   : POSITION;
//							float4 color    : COLOR;
//							float2 texcoord : TEXCOORD0;
//						};
//
//						struct v2f
//						{
//							float4 vertex   : SV_POSITION;
//							fixed4 color : COLOR;
//							fixed4 col : COLOR1;
//							float2 texcoord  : TEXCOORD0;
//						};
//
//						sampler2D _MainTex;
//						sampler2D _ObstacleTex;
//						sampler2D _AlphaTex;
//						float _AlphaSplitEnabled;
//						float _Streight;
//						fixed4 _Color;
//
//						v2f vert(appdata_t IN)
//						{
//							v2f OUT;
//							OUT.vertex = UnityObjectToClipPos(IN.vertex);
//							OUT.texcoord = IN.texcoord;
//							OUT.color = IN.color * _Color;
//							#ifdef PIXELSNAP_ON
//							OUT.vertex = UnityPixelSnap(OUT.vertex);
//							#endif
//
//							fixed4 scrPosCenter = ComputeScreenPos(UnityObjectToClipPos(float4(IN.texcoord, 0, 1)));
//							OUT.col = tex2Dlod(_ObstacleTex, scrPosCenter);
//							//OUT.col = 0.1;
//							OUT.vertex = UnityPixelSnap(UnityObjectToClipPos(fixed4(IN.vertex.x, IN.vertex.y - OUT.color.r * _Streight, IN.vertex.zw)));
//
//							return OUT;
//						}
//
//
//						fixed4 SampleSpriteTexture(float2 uv)
//						{
//							fixed4 color = tex2D(_MainTex, uv);
//
//			#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
//							if (_AlphaSplitEnabled)
//								color.a = tex2D(_AlphaTex, uv).r;
//			#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED
//
//							return color;
//						}
//
//						fixed4 frag(v2f IN) : SV_Target
//						{
//							//fixed4 c = tex2D(_MainTex, IN.texcoord) + IN.color;
//							fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
//							c.rgb + IN.col.rgb;
//							c.rgb *= c.a;
//							return c;
//						}
//					ENDCG
//					}
//				}
//}
