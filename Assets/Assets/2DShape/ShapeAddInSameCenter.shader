Shader "2DShape/ShapeAddInSameCenter" {
    Properties {
        _ShapeType0 ("ShapeType0", Int) = -1
        _ShapeR0 ("ShapeR0", Range(0,1)) = 0.2
        _ShapeType1 ("ShapeType1", Int) = -1
        _ShapeR1 ("ShapeR1", Range(0,1)) = 0.2
        _ShapeType2 ("ShapeType2", Int) = -1
        _ShapeR2 ("ShapeR2", Range(0,1)) = 0.2
        _ShapeType3 ("ShapeType3", Int) = -1
        _ShapeR3 ("ShapeR3", Range(0,1)) = 0.2
        _Width ("Width", Range(0,0.03)) = 0.01
        _BackgroundColor ("BackgroundColor", Color) = (0,0,0,1)
        _LineColor ("LineColor", Color) = (1,1,1,1)
    }

    SubShader {
        Tags {"Queue" = "Transparent"}
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "../CGLibrary/shape.cginc"

            struct v2f {
                fixed4 pos:SV_POSITION;
                fixed4 texcoord:TEXCOORD0;
            };

            int _ShapeType0;
            int _ShapeType1;
            int _ShapeType2;
            int _ShapeType3;
            fixed _ShapeR0;
            fixed _ShapeR1;
            fixed _ShapeR2;
            fixed _ShapeR3;

            fixed4 _LineColor;
            fixed4 _BackgroundColor;
            fixed _Width;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed raycast(int type, fixed2 dir) {
                return type < 0 ? 0 :
                type == 0 ? 1 : raycastNPolygon(type, dir);
            }

            fixed frag(v2f input):SV_TARGET {
                fixed l = 0;
                fixed2 uv = input.texcoord.xy - 0.5;
                l += _ShapeR0*raycast(_ShapeType0, uv);
                l += _ShapeR1*raycast(_ShapeType1, uv);
                l += _ShapeR2*raycast(_ShapeType2, uv);
                l += _ShapeR3*raycast(_ShapeType3, uv);
                return abs(l - length(uv)) < _Width ? _LineColor : _BackgroundColor;
            }

            ENDCG
        }
    }
}