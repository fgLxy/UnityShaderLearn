using System;
using UnityEngine;

public class SimplexScale : MonoBehaviour
{
    public int n;

    public float r2;
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(1.0/maxV());
    }

    private double maxV() {
        double maxValue = 0;
        double eV = e()/2;
        double h = r2 - Math.Pow(eV,2);
        maxValue += h*h*h*h*eV*Math.Sqrt(2);
        return maxValue*n;
    }

    private double e() {
        return Math.Sqrt(Math.Pow(k2(),2) + Math.Pow(1+k2(),2));
    }

    private double k2() {
        return ((1.0/Math.Sqrt(n + 1.0)) - 1) / n;
    }
}
