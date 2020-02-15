using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CircleFilter : MonoBehaviour
{
    public Shader shader;

    public Texture tex;

    public int gaussianCount;
    [Range(0,0.5f)]
    public float R;
    [Range(1, 10)]
    public float ScanStep;

    public int GaussianR;
    public float StandardD;

    private Material m;

    private void Awake() {
        m = new Material(shader);
        this.GetComponent<MeshRenderer>().material = m;
    }
    private void OnWillRenderObject() {
        m.SetFloat("_R", R);
        m.SetFloat("_ScanStep", ScanStep);
        m.SetTexture("_SrcTex", tex);
        m.SetInt("_GaussianR", GaussianR);
        m.SetFloat("_StandardD", StandardD);
        RenderTexture r1 = RenderTexture.GetTemporary(tex.width, tex.height);
        RenderTexture r2 = RenderTexture.GetTemporary(tex.width, tex.height);

        Graphics.Blit(tex, r1);
        for (int i = 0; i < gaussianCount; i++) {
            Graphics.Blit(r1, r2, m, 0);
            Graphics.Blit(r2, r1);
        }
        m.SetTexture("_MainTex", r2);
        
        RenderTexture.ReleaseTemporary(r1);
        RenderTexture.ReleaseTemporary(r2);
    }
}
