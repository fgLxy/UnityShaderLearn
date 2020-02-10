Shader "2DShape/NPolygon" {
    Properties {
        _BackgroundColor ("BackgroundColor", Color) = (0,0,0,1)
        _LineColor ("LineColor", Color) = (1,1,1,1)
        _R ("R", Range(0,0.5)) = 0.25
        _N ("N", Int) = 3
        _Width ("Width", Range(0,0.02)) = 0.01
    }

    SubShader {
        Tags {"Queue" = "Transparent"}
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 texcoord:TEXCOORD0;
            };

            int _N;

            fixed4 _LineColor;
            fixed4 _BackgroundColor;
            fixed _R;
            fixed _Width;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed drawLine(float angle, float averageAngle, float l) {
                if (angle < averageAngle/2) {
                    return abs(cos(angle)*l - _R) < _Width ? 1 : 0;
                } else {
                    return abs(cos(averageAngle-angle)*l - _R) < _Width ? 1 : 0;
                }
            }

            fixed4 frag(v2f input):SV_TARGET {
                const float averageAngle = UNITY_TWO_PI / _N;
                const fixed2 originDir = normalize(fixed2(0., _R));
                //以(0.5,0.5)点为画布中心点
                fixed2 uv = input.texcoord.xy - 0.5;
                fixed2 uvDir = normalize(uv);
                float angle = acos(dot(originDir,uvDir));
                angle = uv.x > 0 ? angle : UNITY_TWO_PI - angle;
                int multi = angle / averageAngle;
                angle -= multi*averageAngle;
                fixed a = drawLine(angle, averageAngle, length(uv));
                return lerp(_BackgroundColor,_LineColor, a);
            }

            ENDCG
        }
    }
}