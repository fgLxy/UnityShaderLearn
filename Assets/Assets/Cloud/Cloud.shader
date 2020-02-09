
Shader "Cloud/Cloud0" {
    Properties {
        _SkyColor ("SkyColor", Color) = (0,0,1,1)
        _SkyDarkColor ("SkyDarkColor", Color) = (0,0,1,1)
        _SkyTint ("SkyTint", Range(0,1)) = .5

        _M ("M", Vector) = (1.6,-1.2,1.6,1.2)

        _CloudBaseColor ("CloudBaseColor", Vector) = (1.1,1.1,0.9,1.)

        _CloudScale ("CloudScale", Range(1,2)) = 1.1
        _CloudDark ("CloudDark", Range(0,1)) = 0.5
        _CloudLight ("CloudLight", Range(0,1)) = 0.3
        _CloudCover ("CloudCover", Range(0,1)) = 0.2
        _CloudAlpha ("CloudAlpha", Float) = 8.
        
        _Speed ("Speed", Float) = 0.03
    }

    SubShader {
        Tags {"Queue" = "Transparent"}
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            /**
            复写的：https://www.shadertoy.com/view/4tdSWr
            **/
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../CGLibrary/noise.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 texcoord:TEXCOORD0;
            };

            float4 _SkyColor;
            float4 _SkyDarkColor;
            float _SkyTint;

            float4 _M;

            float4 _CloudBaseColor;

            float _CloudScale;
            float _CloudDark;
            float _CloudLight;
            float _CloudCover;
            float _CloudAlpha;

            float _Speed;


            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            float fbm(float2 n) {
                const float2x2 m = {{_M.x,_M.y},{_M.z,_M.w}};
                float total = 0.0, amplitude = 0.1;
                for (int i = 0; i < 7; i++) {
                    total += simplexNoise2(n) * amplitude;
                    n = mul(m, n);
                    amplitude *= 0.4;
                }
                return total;
            }

            float ridgedNoiseShapeFbm(float2 uv, float delta) {
                const float2x2 m = {{_M.x,_M.y},{_M.z,_M.w}};
                float r = 0.0;
                uv *= _CloudScale;
                uv -= delta;
                float weight = 0.8;
                for (int i=0; i<8; i++){
                    r += abs(weight*simplexNoise2( uv ));
                    uv = mul(m,uv) + _Time.x*_Speed;
                    weight *= 0.7;
                }
                return r;
            }

            float noiseShapeFbm(float2 uv, float delta) {
                const float2x2 m = {{_M.x,_M.y},{_M.z,_M.w}};
                float f = 0.0;
                uv *= _CloudScale;
                uv -= delta;
                float weight = 0.7;
                for (int i=0; i<8; i++){
                    f += weight*simplexNoise2( uv );
                    uv = mul(m,uv) + _Time.x*_Speed;
                    weight *= 0.6;
                }
                return f;
            }

            float noiseColorFbm(float2 uv, float delta) {
                const float2x2 m = {{_M.x,_M.y},{_M.z,_M.w}};
                float c = 0.0;
                float time = _Time.x * _Speed * 2.0;
                uv *= _CloudScale*2.0;
                uv -= delta;
                float weight = 0.4;
                for (int i=0; i<7; i++){
                    c += weight*simplexNoise2( uv );
                    uv = mul(m,uv) + time;
                    weight *= 0.6;
                }
                return c;
            }

            float noiseRidgeColorFbm(float2 uv, float delta) {
                const float2x2 m = {{_M.x,_M.y},{_M.z,_M.w}};
                float c1 = 0.0;
                float time = _Time.x * _Speed * 3.0;
                uv *= _CloudScale*3.0;
                uv -= delta;
                float weight = 0.4;
                for (int i=0; i<7; i++){
                    c1 += abs(weight*simplexNoise2( uv ));
                    uv = mul(m,uv) + time;
                    weight *= 0.6;
                }
                return c1;
            }
            
            float4 frag(v2f input):SV_TARGET {
                float q = fbm(input.texcoord.xy*_CloudScale*0.5);
                float delta = q - _Time.x;

                float2 uv = input.texcoord.xy;

                float ridgedNoiseShape = ridgedNoiseShapeFbm(uv, delta);
                float noiseShape = noiseShapeFbm(uv, delta);
                //以noiseShape的采样形状为基础形状(如果noiseShape为0或负数则相乘也不会出现云彩。)
                noiseShape *= ridgedNoiseShape + noiseShape;

                float noiseColor = noiseColorFbm(uv, delta);
                float noiseRidgeColor = noiseRidgeColorFbm(uv, delta);
                //noiseRidgeColor应该可以被理解为云的暗色部分。两部分做叠加
                noiseColor += noiseRidgeColor;

                float3 skyColor = lerp(_SkyDarkColor, _SkyColor, input.texcoord.y).rgb;
                // noiseColor这里影响了cloudLight的比重。_CloudDark为云的基础色做了兜底。
                float3 cloudColor = _CloudBaseColor * saturate(_CloudDark + _CloudLight * noiseColor);
                //_CloudCover决定了noiseShape的基础，它越大云的比例应该越大。
                //noiseShape和ridgedNoiseShape
                noiseShape = _CloudCover + _CloudAlpha * noiseShape * ridgedNoiseShape;
                //在天空和云彩之间做线性插值。很奇怪，这里skyInt可控制云彩部分的亮度
                //noiseShape在这里控制云彩的形状。同时，noiseColor较高的位置应该是云彩比较亮的地方。
                float3 color = lerp(skyColor, saturate(_SkyTint * skyColor + cloudColor), saturate(noiseShape + noiseColor));

                return float4(color,1);
            }
            ENDCG
        }
    }
}