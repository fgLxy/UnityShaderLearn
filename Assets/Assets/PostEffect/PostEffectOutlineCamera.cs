using System;
using UnityEngine;

public class PostEffectOutlineCamera : MonoBehaviour {
    
    public Shader shader;

    private Material m;

    private void Awake() {
        m = new Material(shader);
    }
    
    /**
    在不透明物体渲染完成后开始(忽略透明物体)
    **/
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        m.SetTexture("_SourceTex", src);
        RenderTexture rt1 = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);  
        RenderTexture rt2 = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
        Graphics.Blit(src, rt1);
        for (int i = 0; i < 3; i++) {
            Graphics.Blit(rt1, rt2, m, i);
            Graphics.Blit(rt2, rt1);
        }
        Graphics.Blit(rt2, dest);

        //释放申请的两块RenderBuffer内容
        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
    }

}