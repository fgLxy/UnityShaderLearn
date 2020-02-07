Shader "Outline3D/VF" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _OutlineWidth ("OutlineWidth", Range(0,1)) = 0.2
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
    }

    SubShader {
        Tags { "Queue" = "Transparent" }
        

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float3 normal:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert(appdata_base input) {
                v2f output;
                float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                output.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                output.uv = input.texcoord;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = TRANSFORM_TEX(input.uv, _MainTex);
                float4 color = tex2D(_MainTex, uv);
                if (dot(input.viewDir,input.normal) <= _OutlineWidth) {
                    return _OutlineColor;
                } else {
                    return color;
                }
            }

            ENDCG
        }
    }
}