using UnityEngine;

public class DeferredRenderOutline : MonoBehaviour
{
    public Shader shader;

    private Material mr;
    private void Awake() {
        if (shader != null) {
            mr = new Material(shader);
        }
    }
    /**
    这里必须开启深度和法线，否则shader中无法获取到
    **/
    void OnEnable() {
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
	}


    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (mr == null) {
            Graphics.Blit(src,dest);
            return;
        }
        mr.SetTexture("_SourceTex", src);
        RenderTexture r1 = RenderTexture.GetTemporary(src.width, src.height,0,src.format);
        RenderTexture r2 = RenderTexture.GetTemporary(src.width, src.height,0,src.format);

        Graphics.Blit(src, r1);
        for (int i = 0; i < shader.passCount; i++) {
            Graphics.Blit(r1, r2, mr, i);
            Graphics.Blit(r2, r1);
        }
        Graphics.Blit(r2, dest);
        RenderTexture.ReleaseTemporary(r1);
        RenderTexture.ReleaseTemporary(r2);
    }
}
