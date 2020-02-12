Shader "Color/HSV" {
    Properties {
        _HOffset ("HOffset", Range(0.,360.)) = 0
        _SOffset ("SOffset", Range(0,1)) = 0
        _VOffset ("VOffset", Range(0,1)) = 1
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

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed2 uv = input.texcoord.xy - 0.5;
                fixed h = acos(dot(normalize(uv), fixed2(0,1)));
                h = uv.x < 0 ? UNITY_TWO_PI - h : h;
                h = (h/UNITY_TWO_PI)*360. + _HOffset;
                int multi = h/360;
                h -= multi*360;

                fixed s = saturate(length(uv) + _SOffset);
                fixed3 rgb = toRGB(fixed3(h,s, _VOffset));
                return fixed4(rgb,1);
            }


            ENDCG
        }
    }
}