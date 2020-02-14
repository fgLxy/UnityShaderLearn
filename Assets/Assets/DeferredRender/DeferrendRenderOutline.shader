/**
思路：利用延迟渲染拿到表面法线和深度信息。借助深度和法线的变化判断物体的边界
流程：
1、sobel卷积核*法线角度及深度
2、利用canny的非极大抑制，剔除出干净的边界
**/
Shader "DeferrendRender/Outline"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _SourceTex ("SourceTex", 2D) = "white" {}
        _EdgeColor ("EdgeColor", Color) = (0,0,0,1)
        _BackgroundColor ("BackgroundColor", Color) = (1,1,1,1)
        _FixedRate ("FixedRate", Range(0,1)) = 0.5
        _ThresholdN ("ThresholdN", Range(0,1)) = 0.1
        _ThresholdD ("ThresholdD", Range(0,1)) = 0.1
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        
        struct v2f {
            fixed4 pos:SV_POSITION;
            fixed2 uv[9]:TEXCOORD0;
        };

        sampler2D _MainTex;
        sampler2D _SourceTex;
        fixed4 _MainTex_TexelSize;
        sampler2D _CameraDepthNormalsTexture;

        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;

        fixed _FixedRate;
        fixed _ThresholdN;
        fixed _ThresholdD;

        v2f vert(appdata_base input) {
            v2f output;
            output.pos = UnityObjectToClipPos(input.vertex);
            for (fixed i = 0; i < 3; i++) {
                for (fixed j = 0; j < 3; j++) {
                    output.uv[i*3+j] = input.texcoord.xy + _MainTex_TexelSize.xy*fixed2(j-1,i-1);
                }
            }
            return output;
        }

        fixed4 getGradientAndTheta(fixed4 enc[9]) {
            fixed3 normals[9];
            fixed depth[9];
            for (fixed i = 0; i < 9; i++) {
                DecodeDepthNormal(enc[i], depth[i], normals[i]);
            }
            fixed xNormalDelta = dot(normals[0],normals[2])-2*dot(normals[3],normals[5])-dot(normals[6],normals[8]);
            fixed yNormalDelta = dot(normals[0],normals[6])-2*dot(normals[1],normals[7])-dot(normals[2],normals[8]);
            xNormalDelta = xNormalDelta != 0 ? 1/xNormalDelta : 0;
            yNormalDelta = yNormalDelta != 0 ? 1/yNormalDelta : 0;
            fixed xDepthDelta = (depth[0]-depth[2]) + 2*(depth[3]-depth[5]) + (depth[6]-depth[8]);
            fixed yDepthDelta = (depth[0]-depth[6]) + 2*(depth[1]-depth[7]) + (depth[2]-depth[8]);
            //最大值应该是4*sqrt(2);缩放到0-1域的话除10够用了
            fixed nNormal = length(fixed2(xNormalDelta, yNormalDelta));
            //角度先缩放到0~2*pi,然后归一化.(0,1)单位向量的方向角度定义为0
            fixed nTheta = UNITY_PI/2 - atan2(yNormalDelta,xNormalDelta);
            nTheta = nTheta < 0 ? UNITY_TWO_PI + nTheta : nTheta;

            fixed dNormal = length(fixed2(xDepthDelta, yDepthDelta));
            fixed dTheta = UNITY_PI/2 - atan2(yDepthDelta,xDepthDelta);
            dTheta = dTheta < 0 ? UNITY_TWO_PI + dTheta : dTheta;
            return fixed4(nNormal/10, nTheta/UNITY_TWO_PI, dNormal/10, dTheta/UNITY_TWO_PI);
        }

        fixed4 gradient(v2f input):SV_TARGET {
            fixed4 enc[9];
            for (fixed i = 0; i < 9; i++) {
                enc[i] = tex2D(_CameraDepthNormalsTexture, input.uv[i]);
            }
            return getGradientAndTheta(enc);
        }

        fixed getGDirect(fixed angle) {
            angle *= UNITY_TWO_PI;
            //右旋pi/4
            angle += UNITY_PI/4;
            angle = angle > UNITY_TWO_PI ? angle - UNITY_TWO_PI : angle;
            return floor(angle/(UNITY_PI/4)) % 8;
        }

        fixed checkData(fixed4 data, fixed idx, fixed2 uv, fixed dimension) {
            if (idx == 4) return 0;//not erase;
            fixed gd = getGDirect(dimension == 0 ? data.y : data.w);
            fixed2 uv1;
            if (idx == 0 && gd == 3) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,-1);
            }
            else if (idx == 1 && gd == 4) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(0,1);
            }
            else if (idx == 2 && gd == 5) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,1);
            }
            else if (idx == 3 && gd == 2) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,0);
            }
            else if (idx == 5 && gd == 6) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,0);
            }
            else if (idx == 6 && gd == 1) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(-1,-1);
            }
            else if (idx == 7 && gd == 0) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(0,-1);
            }
            else if (idx == 8 && gd == 7) {
                uv1 = uv + _MainTex_TexelSize.xy*fixed2(1,-1);
            }
            else {
                return 0;
            }
            fixed4 d = tex2D(_MainTex, uv1);
            return dimension == 0 ? d.x : d.z;
        }

        fixed4 frag(v2f input):SV_TARGET {
            fixed4 datas[9];
            fixed result[2];
            result[0] = 0;
            result[1] = 0;
            for (fixed i = 0; i < 9; i++) {
                datas[i] = tex2D(_MainTex, input.uv[i]);
            }
            for (fixed j = 0; j < 9; j++) {
                result[0] += datas[4].x < checkData(datas[j], j, input.uv[j], 0) ? 1 : 0;
                result[1] += datas[4].z < checkData(datas[j], j, input.uv[j], 1) ? 1 : 0;
            }
            fixed4 c = lerp(tex2D(_SourceTex, input.uv[4]), _BackgroundColor, _FixedRate);
            if (result[0] > 0 && result[1] > 0) {
                return c;
            }
            if (datas[4].x <= _ThresholdN && datas[4].z <= _ThresholdD) {
                return c;
            }
            return _EdgeColor;

        }

        ENDCG
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
            #pragma fragment frag
            #pragma target 3.0
            ENDCG
        }
    }
    FallBack "Diffuse"
}
