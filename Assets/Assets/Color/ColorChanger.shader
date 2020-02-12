Shader "Color/ColorChanger" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,1)
        _HOffset ("HOffset", Range(0.,360.)) = 0
        _SOffset ("SOffset", Range(0,1)) = 0
        _VOffset ("VOffset", Range(0,1)) = 1

        _MaxS ("MaxS", Float) = 1
        _MaxV ("MaxV", Float) = 1
    }
    SubShader {
        Tags {"Queue" = "Transparent"}
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "../CGLibrary/color.cginc"

            struct v2f {
                float4 pos:SV_POSITION;
                float4 texcoord:TEXCOORD0;
            };

            fixed _HOffset;
            fixed _SOffset;
            fixed _VOffset;

            fixed _MaxS;
            fixed _MaxV;

            fixed4 _Tint;

            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = TRANSFORM_TEX(input.texcoord, _MainTex);
                fixed4 color = tex2D(_MainTex, uv);
                color *= _Tint * 2;
                fixed3 hsv = toHSV(color.rgb);
                hsv = hsvOffset(hsv, fixed3(_HOffset,_SOffset*_MaxS,_VOffset*_MaxV));
                return fixed4(toRGB(hsv), 1);
            }


            ENDCG
        }
    }
}