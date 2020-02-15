Shader "Light/Blinn" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _GLS ("GLS", Range(1,10)) = 0.5
        _SPEC ("SPEC", Range(0,1)) = 0.5
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f {
                fixed4 pos:SV_POSITION;
                fixed2 uv:TEXCOORD0;
                fixed3 n:NORMAL;
                fixed3 h:COLOR1;
                fixed3 l:COLOR2;
            };

            sampler2D _MainTex;

            fixed4 _LightColor0;
            
            fixed _SPEC;
            fixed _GLS;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                output.n = input.normal;
                output.l = normalize(WorldSpaceLightDir(input.vertex));
                fixed3 v = normalize(WorldSpaceViewDir(input.vertex));
                output.h = (output.l+v)/2;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed4 color = 0;
                color += pow(max(dot(input.n,input.h), 0), _GLS) *_LightColor0 * _SPEC;
                fixed4 mDiff = tex2D(_MainTex,input.uv);
                color += max(dot(input.n, input.l),0)*_LightColor0*mDiff;
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}