/**
实现一个椭圆形的涟漪效果
**/
Shader "Ripples/Circle" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _R ("R", Range(0.001, 0.5)) = 0.1
        _Speed("Speed", Range(1,10)) = 5
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
                fixed2 uv:TEXCOORD0;
            };

            sampler2D _MainTex;

            fixed _R;
            fixed _Speed;

            v2f vert(appdata_base input) {
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.uv = input.texcoord;
                return output;
            }

            fixed4 frag(v2f input):SV_TARGET {
                //TODO 后面可以改成，涟漪随时间变化半径增大，变形变弱，最终逐渐消散
                fixed time = frac(_Time.x);
                fixed speed = time*2*_Speed;
                //抖动位移计算
                fixed xyDelta = lerp(sin(time*UNITY_TWO_PI*1000)/100, 0, saturate(speed));
                fixed2 uv = input.uv - 0.5;
                uv = fixed2(uv.x, uv.y);
                fixed l = length(uv);
                //涟漪中心位置为0，距离中心越远delta越大，上限为1
                fixed delta = saturate(abs(l-speed)/_R);
                //涟漪区域像素采样进行偏移。越靠近中心偏移越小，越靠近边界偏移越大
                l += sin(delta*UNITY_PI)*0.1*((l-speed)/abs(l-speed));
                //抖动效果，沿着对角线方向抖动
                uv = normalize(uv)*l+xyDelta;
                uv += 0.5;
                //涟漪区域的渐变度
                fixed a = lerp(1,0.8,delta);
                fixed4 c = tex2D(_MainTex, uv);
                c = lerp(a*c, c, delta);
                return c;
            }

            ENDCG
        }
    }
}