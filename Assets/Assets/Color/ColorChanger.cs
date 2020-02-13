using System;
using System.Collections;
using UnityEngine;

public class ColorChanger : MonoBehaviour {

    public Color color;

    public Texture2D tex;
    [Range (0f, 360f)]
    public float hOffset;
    [Range (0f, 1f)]
    public float sOffset;
    [Range (0f, 1f)]
    public float vOffset;

    private Color _color;

    private Texture2D _tex;
    [Range (0f, 360f)]
    private float _hOffset;
    [Range (0f, 1f)]
    private float _sOffset;
    [Range (0f, 1f)]
    private float _vOffset;

    private MeshRenderer mr;

    private IEnumerator t;
    private Color[, ] colors;

    private float maxV;
    private float maxS;

    private bool needRecalculate = false;

    void Awake () {
        this.mr = this.GetComponent<MeshRenderer> ();
        colors = new Color[this.tex.width, this.tex.height];
        for (int i = 0; i < this.tex.width; i++) {
            for (int j = 0; j < this.tex.height; j++) {
                colors[i, j] = this.tex.GetPixel (i, j);
            }
        }
    }
    void Update () {
        bool flag = needUpdate ();
        if (flag) {
            if (t != null) {
                StopCoroutine (t);
            }
            t = fixedShader ();
            StartCoroutine (t);
        }
    }

    private bool needUpdate () {
        if (_color == color && hOffset == _hOffset && vOffset == _vOffset && sOffset == _sOffset) return false;
        if (_color != color) needRecalculate = true;
        _color = color;
        _tex = tex;
        _hOffset = hOffset;
        _vOffset = vOffset;
        _sOffset = sOffset;
        return true;
    }

    private IEnumerator fixedShader () {
        float aV = 10000f;
        float aS = 10000f;
        int pixelCount = this.colors.GetLength (0) * this.colors.GetLength (1);
        int perCount = pixelCount / 10;
        int counter = 0;
        if (needRecalculate) {
            needRecalculate = false;
            for (int i = 0; i < this.colors.GetLength (0); i++) {
                for (int j = 0; j < this.colors.GetLength (1); j++) {
                    Vector3 rgb = new Vector3 ((color.r / 255.0f) * (colors[i, j].r / 255.0f) * 2, (color.g / 255.0f) * (colors[i, j].g / 255.0f) * 2, (color.b / 255.0f) * (colors[i, j].b / 255.0f) * 2);
                    Vector3 hsv = toHSV (rgb);
                    aV += hsv.z;
                    aS += hsv.y;
                    if (Double.IsNaN (hsv.y)) {
                        Debug.Log (rgb);
                    }
                    counter++;
                    if (counter % perCount == 0) yield return null;
                }
            }
            maxV = (aV / (pixelCount)) * 0.8f;
            maxS = (aS / (pixelCount)) * 0.5f;
        }
        MaterialPropertyBlock materialProperties = new MaterialPropertyBlock ();
        mr.GetPropertyBlock (materialProperties);
        materialProperties.SetColor ("_Tint", this.color);
        materialProperties.SetFloat ("_MaxS", maxS);
        materialProperties.SetFloat ("_MaxV", maxV);
        materialProperties.SetFloat ("_HOffset", this.hOffset);
        materialProperties.SetFloat ("_SOffset", this.sOffset);
        materialProperties.SetFloat ("_VOffset", this.vOffset);
        materialProperties.SetTexture ("_MainTex", this.tex);
        mr.SetPropertyBlock (materialProperties);
    }

    Vector3 toHSV (Vector3 rgb) {
        float r = rgb.x;
        float g = rgb.y;
        float b = rgb.z;
        float mx = Math.Max (r, Math.Max (g, b));
        float mn = Math.Min (r, Math.Min (g, b));
        float v = mx;
        if (mx == 0 || mx == mn) return new Vector3 (0f, 0f, v);
        float s = (mx - mn) / mx;
        float h = 0f;
        if (r == mx) h = 60 * ((g - b) / (mx - mn));
        if (g == mx) h = 120 + 60 * ((b - r) / (mx - mn));
        if (b == mx) h = 240 + 60 * ((r - g) / (mx - mn));
        if (h < 0) h += 360;
        // if (h<0) h = 1/0;
        return new Vector3 (h, s, v);
    }
}