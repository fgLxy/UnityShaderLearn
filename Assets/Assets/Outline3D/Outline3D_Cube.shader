Shader "Outline3D/Cube" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _OutlineWidth ("OutlineWidth", Range(0,1)) = 0.2
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
    }

    SubShader {
        Tags { "Queue" = "Transparent" }
        Pass {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineWidth;
            //顶点膨胀
            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                float3 pOrigin = UnityObjectToClipPos(float3(0,0,0));
                float2 surfDir = normalize(output.pos.xy-pOrigin.xy);
                
                output.pos.xy += surfDir.xy*_OutlineWidth;
                return output;
            }
            fixed4 frag():SV_TARGET {
                return _OutlineColor;
            }

            ENDCG
        }
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                return output;
            }


            fixed4 frag(v2f input) : SV_TARGET {
                float2 uv = TRANSFORM_TEX(input.uv, _MainTex);
                float4 color = tex2D(_MainTex, uv);
                return color;
            }


            ENDCG
        }
    }
    Fallback "Standard"
}