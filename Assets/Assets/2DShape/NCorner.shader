Shader "2DShape/NCorner" {
    Properties {
        _N ("N", Int) = 3
        _OutR ("OutR", Range(0.25,0.5)) = 0.5
        _InR ("InR", Range(0, 0.25)) = 0.25
        _Width ("Width", Range(0, 0.05)) = 0.01
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

            int _N;
            fixed _OutR;
            fixed _InR;
            fixed _Width;
            fixed4 _BackgroundColor;
            fixed4 _LineColor;
            
            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = input.texcoord - 0.5;
                fixed l = raycastNCorner(_N, uv, _OutR, _InR);
                return abs(l - length(uv)) < _Width ? _LineColor : _BackgroundColor;
            }

            ENDCG
        }
    }
}