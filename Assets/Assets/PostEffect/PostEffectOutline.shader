/**
实现基于canny的轮廓识别
算法流程：
1、灰度图
2、高斯模糊
3、求sobel梯度（也可以选择其他算子来计算梯度）和梯度的角度
4、根据梯度角度，找到对应方向的两个像素点。舍弃较小者的梯度（它不是边）
5、根据低阈值排除噪点（梯度小于低阈值的不是边）
6、根据高阈值确定边（梯度大于高阈值的为边）
7、介于高低阈值之间的，判断邻域是否有边存在，有则其也为边，否则不是。（这一步偷懒了）
最终效果：
球体在光照情况下看起来非常糟糕（有一片连续的空间被识别为边界了。按理说这不可能啊。。）
其他有弧面的物体貌似也有类似的情况。立方体的识别效果仿佛还行。
**/
Shader "PostEffect/Outline" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _SourceTex ("SourceTex", 2D) = "white" {}
        _ScanStep ("ScanStep", Float) = 0.5
        _EdgeColor ("EdgeColor", Color) = (0,1,0,1)
        _CannyLowT ("CannyLowT", Range(0,12)) = 0.003
        _CannyHighT ("CannyHighT", Range(0,12)) = 0.01
    }


    SubShader {
        
        CGINCLUDE

        #include "UnityCG.cginc"
        #include "../CGLibrary/convolution.cginc"

        struct v2f {
            fixed4 pos:SV_POSITION;
            fixed2 uv[9]:TEXCOORD0;
        };

        fixed _ScanStep;
        fixed4 _MainTex_TexelSize;
        sampler2D _MainTex;
        sampler2D _SourceTex;
        fixed4 _EdgeColor;
        fixed _CannyLowT;//低阈值，低于这个的边界直接抛弃
        fixed _CannyHighT;

        v2f vert(appdata_base input) {
            v2f output;
            output.pos = UnityObjectToClipPos(input.vertex);
            fixed2 uv = input.texcoord.xy;
            int i,j;
            for (i = 0; i < 3; i++) {
                for (j = 0; j < 3; j++) {
                    output.uv[i*3+j] = uv + _MainTex_TexelSize.xy * fixed2(j-1,i-1) *_ScanStep;
                }
            }
            return output;
        }

        inline void getGrayMatrix(v2f input,out fixed3 grays[3]) {
            fixed4 c[9];
            for (int i = 0; i < 9; i++) {
                c[i] = tex2D(_MainTex, input.uv[i]);
            }
            grays[0] = fixed3(toGray(c[0]),toGray(c[1]),toGray(c[2]));
            grays[1] = fixed3(toGray(c[3]),toGray(c[4]),toGray(c[5]));
            grays[2] = fixed3(toGray(c[6]),toGray(c[7]),toGray(c[8]));
        }

        inline void getColors(v2f input,out fixed3 c[9]) {
            for (int i = 0; i < 9; i++) {
                c[i] = tex2D(_MainTex, input.uv[i]);
            }
        }

        fixed4 gaussian(v2f input):SV_TARGET {
            fixed3 grayMatrix[3];
            getGrayMatrix(input,grayMatrix);
            fixed g = gaussian(grayMatrix);
            return fixed4(g,g,g,1);
        }

        fixed4 gradient(v2f input):SV_TARGET {
            fixed3 grayMatrix[3];
            getGrayMatrix(input,grayMatrix);
            fixed2 g = sobel(grayMatrix);
            return fixed4(g/10,0,0);
        }

        fixed getGDirect(fixed3 data) {
            fixed angle = data.y*10*UNITY_TWO_PI;
            angle += UNITY_PI/4;
            angle = angle > UNITY_TWO_PI ? angle - UNITY_TWO_PI : angle;
            return floor(angle/(UNITY_PI/4)) % 8;
        }

        fixed check(fixed3 data, fixed idx, fixed2 uv) {
            if (idx == 4) return 0;//not erase;
            fixed gd = getGDirect(data);
            fixed2 uv1;
            if (idx == 0 && gd == 3) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,-1)*_ScanStep;
            }
            else if (idx == 1 && gd == 4) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(0,1)*_ScanStep;
            }
            else if (idx == 2 && gd == 5) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,1)*_ScanStep;
            }
            else if (idx == 3 && gd == 2) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,0)*_ScanStep;
            }
            else if (idx == 5 && gd == 6) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,0)*_ScanStep;
            }
            else if (idx == 6 && gd == 1) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,-1)*_ScanStep;
            }
            else if (idx == 7 && gd == 0) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(0,-1)*_ScanStep;
            }
            else if (idx == 8 && gd == 7) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,-1)*_ScanStep;
            }
            else {
                return 0;
            }
            fixed4 d = tex2D(_MainTex, uv1);
            return d.x;
        }

        fixed4 canny(v2f input):SV_TARGET {
            fixed3 datas[9];
            getColors(input, datas);
            fixed checked = 0;
            for (fixed i = 0; i < 9; i++) {
                checked += datas[4].x < check(datas[i], i, input.uv[i]) ? 1 : 0;
            }
            checked += datas[4].x < _CannyLowT ? 1 : 0;
            fixed4 c = tex2D(_MainTex, input.uv[4]);
            if (checked > 0) return c;
            if (datas[4].x > _CannyHighT) return _EdgeColor;
            checked = 0;
            checked += datas[1].x > _CannyHighT ? 1 : 0;
            checked += datas[3].x > _CannyHighT ? 1 : 0;
            checked += datas[5].x > _CannyHighT ? 1 : 0;
            checked += datas[7].x > _CannyHighT ? 1 : 0;
            return checked > 0 ? c : _EdgeColor;
        }

        ENDCG

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment gaussian
            #pragma target 3.0
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment gradient
            #pragma target 3.0
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment canny
            #pragma target 3.0
            ENDCG
        }
    }
}