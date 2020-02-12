#ifndef MY_LIBRARY_COLOR
#define MY_LIBRARY_COLOR

#include "UnityCG.cginc"

    fixed3 toRGB(fixed3 hsv) {
        fixed h = hsv.x;
        fixed s = hsv.y;
        fixed v = hsv.z;
        fixed a,b,c;
        if (s <= 0.) return fixed3(v,v,v);
        else {
            h /= 60.;
            int i = floor(h) % 6;
            fixed f = frac(h);
            a = v*(1-s);
            b = v*(1-s*f);
            c = v*(1-s*(1-f));
            if (i == 0) return fixed3(v,c,a);
            if (i == 1) return fixed3(b,v,a);
            if (i == 2) return fixed3(a,v,c);
            if (i == 3) return fixed3(a,b,v);
            if (i == 4) return fixed3(c,a,v);
            if (i == 5) return fixed3(v,a,b);
            return fixed3(abs(i/360.),0,0);
        }
        
    }
    /**
    h:0~360,表示色彩的偏移角度
    s:0~1,表示色彩纯度
    v:0~1,表示色彩亮度
    **/
    fixed3 toHSV(fixed3 rgb) {
        fixed r = rgb.r;
        fixed g = rgb.g;
        fixed b = rgb.b;
        fixed mx = max(r, max(g,b));
        fixed mn = min(r, min(g,b));
        fixed v = mx;
        if (mx == mn || mx == 0) return fixed3(0,0,v);
        fixed s = (mx - mn) / mx;
        fixed h;
        if(rgb.r == mx) h = 60*((g-b)/(mx-mn));
        if(rgb.g == mx) h = 120 + 60*((b-r)/(mx-mn));
        if(rgb.b == mx) h = 240 + 60*((r-g)/(mx-mn));
        if (h<0) h += 360;
        // if (h<0) h = 1/0;
        return fixed3(h, s, v);
    }

    fixed3 hsvOffset(fixed3 hsv, fixed3 offset) {
        offset.y = hsv.y <= 0.1 ? 0 : offset.y;
        hsv += offset;
        int multi = hsv.x / 360;
        hsv.x -= multi*360;
        hsv.y = frac(hsv.y);
        hsv.z = saturate(hsv.z);
        return hsv;
    }

#endif