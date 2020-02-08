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

            float fbm1(float2 p) {
                float noise = 0;
                float2 pos = p;
                float w = 1.;
                for (int i = 0; i < 5; i++) {
                    noise += w*seamlessSimplexNoise2(pos,_Unit);
                    w /= 2;
                    pos *= 2;
                }
                return noise;
            }

            float fbm2(float2 p) {
                float noise = 0;
                float2 pos = p;
                float w = 1.;
                for (int i = 0; i < 5; i++) {
                    noise += w*abs(seamlessSimplexNoise2(pos,_Unit));
                    w /= 2;
                    pos *= 2;
                }
                return noise;
            }

            float fbm3(float2 p) {
                float noise = 0;
                float2 pos = p;
                float w = 1.;
                for (int i = 0; i < 5; i++) {
                    noise += w*abs(seamlessSimplexNoise2(pos,_Unit));
                    w /= 2;
                    pos *= 2;
                }
                return sin(p.x + noise);
            }

            float4 frag(v2f input):SV_TARGET {
                return _Tint*(_Type == 1 ? seamlessSimplexNoise2(input.texcoord.xy,_Unit) :
                    _Type == 2 ? fbm1(input.texcoord.xy) :
                    _Type == 3 ? fbm2(input.texcoord.xy) :
                    fbm3(input.texcoord.xy));

            }

            ENDCG
        }
    }
}