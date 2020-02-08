Shader "Noise/Value" {
    Properties {
        _Tint ("Tint", Color) = (0,0,0,1)
        _Unit ("Unit", Int) = 8
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
                    noise += w*valueNoise2(pos);
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
                    noise += w*abs(valueNoise2(pos));
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
                    noise += w*abs(valueNoise2(pos));
                    w /= 2;
                    pos *= 2;
                }
                return sin(p.x + noise);
            }

            float4 frag(v2f input):SV_TARGET {
                float2 pos = input.texcoord.xy;
                if (pos.x < 0.5 && pos.y > 0.5) {
                    return _Tint * valueNoise2(_Unit*input.texcoord.xy);
                }
                else if (pos.x > 0.5 && pos.y > 0.5) {
                    return _Tint * fbm1(_Unit*input.texcoord.xy);
                }
                else if (pos.x < 0.5 && pos.y < 0.5) {
                    return _Tint * fbm2(_Unit*input.texcoord.xy);
                }
                else {
                    return _Tint * fbm3(_Unit*input.texcoord.xy);
                }
                
            }

            ENDCG
        }
    }
}