﻿Shader "Disappear/Vertical" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _Speed ("Speed", Range(0,1)) = 0.5
    }
    SubShader {
        Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        fixed _Speed;
        struct v2f {
            fixed4 pos:SV_POSITION;
            fixed2 uv:TEXCOORD0;
        };

        v2f vert(appdata_base input) {
            v2f output;
            output.pos = UnityObjectToClipPos(input.vertex);
            output.uv = input.texcoord;
            return output;
        }


        fixed4 frag(v2f input):SV_TARGET {
            fixed4 c = tex2D(_MainTex, input.uv);
            if (1-input.uv.y<_Speed*_Time.y) {
                discard;
            }
            c.a = saturate(lerp(0,1,(1-input.uv.y-_Speed*_Time.y)/max((1-_Speed*_Time.y)/2,0.0001)));
            return c;
        }
        ENDCG

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            ENDCG
        }
    }
    Fallback "Diffuse"
}