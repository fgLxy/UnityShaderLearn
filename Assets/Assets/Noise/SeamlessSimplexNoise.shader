Shader "Noise/SeamlessSimplex" {
    Properties {
        _Tint ("Tint", Color) = (0,0,0,1)
        _Unit ("Unit", Int) = 8
        _Type ("Type", Int) = 1
    }

    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../CGLibrary/noise.cginc"

            struct v2f {
                float4 pos:POSITION;
                float4 texcoord: TEXCOORD0;
            };

            float4 _Tint;
            int _Unit;
            int _Type;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            

            float4 frag(v2f input):SV_TARGET {
                return _Tint*((seamlessSimplexNoise2(input.texcoord.xy,_Unit,_Type)+1)*.5);
            }

            ENDCG
        }
    }
}