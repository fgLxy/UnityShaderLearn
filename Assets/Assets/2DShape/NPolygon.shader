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

            #include "../CGLibrary/shape.cginc"

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

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = input.texcoord.xy - 0.5;
                fixed l = _R*raycastNPolygon(_N,uv);
                return abs(l - length(uv)) < _Width ? _LineColor : _BackgroundColor;
            }

            

            ENDCG
        }
    }
}