/**
实现一个效果，越靠近中心区域越清晰，越靠近边界越模糊
思路：
1、shader部分定义两个通道。第一个通道单纯负责半径为N的高斯模糊。第二个通道负责混合模糊图和原图
2、csharp脚本部分实现OnWillRenderObject方法（主要为了方便在editor调整参数，其实放到Awake应该就完事了）。在这个方法里面多次触发一通道的模糊效果，然后将模糊结果设置为纹理
3、正常渲染流程走第二个通道
*/
Shader "Gaussian/CircleFilter" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _SrcTex ("SrcTex", 2D) = "White" {}
        _R ("R", Range(0,0.5)) = 0.1
        _GaussianR("GaussianR", Int) = 5 
        _ScanStep ("ScanStep", Range(1, 10)) = 1
        _StandardD("StandardD", Float) = 1.5
    }

    SubShader  {
        CGINCLUDE
        #include "../CGLibrary/convolution.cginc"
            struct v2f {
                fixed4 pos:SV_POSITION;
                fixed2 uv:TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _SrcTex;

            fixed _R;
            fixed4 _MainTex_TexelSize;
            fixed _ScanStep;
            
            int _GaussianR;
            fixed _StandardD;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                return output;
            } 

            fixed3 doGaussian(v2f input):SV_TARGET {
                fixed r = floor((_GaussianR-1)/2);
                fixed3 gc = 0;
                fixed sw = 0;
                for (fixed i = -r; i <= r; i++) {
                    for (fixed j = -r; j <= r; j++) {
                        fixed w = gaussianNxN(_StandardD,i,j);
                        fixed2 uv = input.uv + _MainTex_TexelSize*fixed2(i,j)*_ScanStep;
                        sw += w;
                        gc += tex2D(_MainTex, uv)*w;
                    }
                }
                gc /= sw;
                return gc;
            }

            fixed4 frag(v2f input):SV_TARGET {
                // fixed3 gaussianColor = tex2D(_MainTex, input.uv);
                fixed3 color = tex2D(_SrcTex, input.uv);
                fixed l = length(input.uv - 0.5);
                return l > _R ? fixed4(0,0,0,0) : fixed4(color,1);
            }
        ENDCG
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment doGaussian

            #pragma target 3.0

            ENDCG
        }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            ENDCG
        }
    }
}