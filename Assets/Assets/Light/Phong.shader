Shader "Light/Phong" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        //光泽度，控制亮斑范围.
        _GLS ("GLS",Range(1,10)) = 0.5
        //反射颜色（灰度值），越大反射光强度越大
        _Spec ("Spec", Range(0,1)) = 0.5
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f {
                fixed4 pos:SV_POSITION;
                fixed4 uv:TEXCOORD0;
                fixed3 v:COLOR1;
                fixed3 r:COLOR2;
                fixed3 n:NORMAL;
                fixed3 l:COLOR3;
            };

            sampler2D _MainTex;

            fixed _Spec;
            fixed _GLS;
            fixed4 _LightColor0;
            
            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                output.v = normalize(WorldSpaceLightDir(input.vertex));
                output.l = normalize(WorldSpaceLightDir(input.vertex));
                output.r = reflect(output.l, input.normal);
                output.n = input.normal;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                fixed4 color = 0;
                //镜面反射分量,使用Phong光照模型公式
                color += pow(max(dot(-input.v,input.r),0), _GLS)*_LightColor0*_Spec;
                //物体材质定义为物体的表面反射色
                fixed4 mDiff = tex2D(_MainTex, input.uv);
                color += max(dot(input.n,input.l),0)*_LightColor0*mDiff;
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}