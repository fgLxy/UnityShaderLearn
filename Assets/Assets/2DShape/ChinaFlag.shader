Shader "2DShape/ChinaFlag" {
    Properties {
        _W ("W", Float) = 16.
        _H ("H", Float) = 9.
        _BackgroundRed1("BackgroundRed1", Color) = (0.9,0.3,0.3)
        _BackgroundRed2("BackgroundRed2", Color) = (0.7,0.1,0.1)
        _Yellow1 ("Yellow1", Color) = (1.,1.,.5)
        _Yellow2 ("Yellow2", Color) = (.8,.8,.4)
    }
    SubShader {
        Tags {"Queue" = "Transparent"}
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "../CGLibrary/shape.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 texcoord:TEXCOORD0;
            };

            fixed _W;
            fixed _H;
            fixed4 _BackgroundRed1;
            fixed4 _BackgroundRed2;
            fixed4 _Yellow1;
            fixed4 _Yellow2;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            int drawFiveCorner(fixed2 center, fixed2 pos, fixed iR, fixed oR) {
                fixed2 dir = pos - center;
                fixed l = raycastNCorner(5, dir, oR, iR);
                return l >= length(dir) ? 1 : 0;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = fixed2(input.texcoord.x * (_W/_H), input.texcoord.y);
                //旗帜飘动借鉴的https://www.shadertoy.com/view/3lyGRd
                //想要看起来真实，需要让坐标本身抖动起来。同时颜色敏感应该也要根据抖动变化
                fixed a = (sin(.3*UNITY_PI*(uv.x + uv.y - 40*_Time.x + UNITY_PI*sin(1.5*uv.x + 4.5*uv.y))) + 1) /2;
                uv *= 1. + (.036 - .036 * a);
                int result = 0;
                result += drawFiveCorner(fixed2(.25,.7), uv, 0.06, 0.15);

                result += drawFiveCorner(fixed2(.45,.9), uv, 0.02, 0.05);
                result += drawFiveCorner(fixed2(.55,.75), uv, 0.02, 0.05);
                result += drawFiveCorner(fixed2(.55,.6), uv, 0.02, 0.05);
                result += drawFiveCorner(fixed2(.45,.45), uv, 0.02, 0.05);
                
                // float a = sin((uv.x + uv.y - _Time.x * .75 + sin(1.5 * uv.x + 4.5 * uv.y) * UNITY_PI * .3)
                //   * UNITY_PI * .6);
                
                fixed4 backgroundColor = lerp(_BackgroundRed1,_BackgroundRed2, uv.y);
                fixed4 yellowColor = lerp(_Yellow1, _Yellow2, uv.y);
                return (1+a)*(result > 0 ? yellowColor : backgroundColor)/2;
            }

            

            ENDCG
        }
    }
}