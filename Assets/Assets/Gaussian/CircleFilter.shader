/**
实现一个效果，越靠近中心区域越清晰，越靠近边界越模糊
思路：
1、对每个像素做高速模糊
2、根据当前点到中心的距离决定颜色的混合比率（中心圆内的使用清晰颜色，圆外的越远越模糊）
结果：
效果不好。高斯模糊在shader里不知道如何能够迭代多次。如果不迭代多次想提高模糊效果只能增加高斯模糊的半径（偷懒了，懒得再搞5*5的矩阵了。。）
姑且偷懒采用增加采样步长的方式来制造模糊（效果并不好。。）
*/
Shader "Gaussian/CircleFilter" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _R ("R", Range(0,0.5)) = 0.2
        _ScanStep ("ScanStep", Range(1, 10)) = 1
    }

    SubShader  {
        Pass {
             CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #include "../CGLibrary/convolution.cginc"

            struct v2f {
                fixed4 pos:SV_POSITION;
                fixed2 uv[9]:TEXCOORD0;
            };

            sampler2D _MainTex;

            fixed _R;
            fixed4 _MainTex_TexelSize;
            fixed _ScanStep;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                int i,j;
                for (i = 0; i < 3; i++) {
                    for (j = 0; j < 3; j++) {
                        output.uv[i*3+j] = input.texcoord.xy + _MainTex_TexelSize.xy * fixed2(j-1,i-1) * _ScanStep;
                    }
                }
                return output;
            } 

            inline void getColors(v2f input,out fixed3 c[9]) {
                for (int i = 0; i < 9; i++) {
                    c[i] = tex2D(_MainTex, input.uv[i]);
                }
            }

            fixed3 frag(v2f input):SV_TARGET {
                fixed3 colors[9];
                getColors(input, colors);
                fixed3 rArr[3];
                rArr[0] = (colors[0].r,colors[1].r,colors[2].r);
                rArr[1] = (colors[3].r,colors[4].r,colors[5].r);
                rArr[2] = (colors[6].r,colors[7].r,colors[8].r);
                fixed r = gaussian(rArr);
                fixed3 gArr[3];
                gArr[0] = (colors[0].g,colors[1].g,colors[2].g);
                gArr[1] = (colors[3].g,colors[4].g,colors[5].g);
                gArr[2] = (colors[6].g,colors[7].g,colors[8].g);
                fixed g = gaussian(gArr);
                fixed3 bArr[3];
                bArr[0] = (colors[0].b,colors[1].b,colors[2].b);
                bArr[1] = (colors[3].b,colors[4].b,colors[5].b);
                bArr[2] = (colors[6].b,colors[7].b,colors[8].b);
                fixed b = gaussian(bArr);
                fixed3 gaussianColor = fixed3(r,g,b);
                fixed l = length(input.uv[4] - 0.5);

                return l > _R ? lerp(colors[4],gaussianColor*.5,saturate((l-_R)/(0.7-_R))) : colors[4];
            }

            ENDCG
        }
    }
}