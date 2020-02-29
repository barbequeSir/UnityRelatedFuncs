using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffectOutline : MonoBehaviour
{
    public float EdgeOnly = 1;
    public Color EdgeColor;
    public Color BackColor;
    public float SampleDistance;
    public float SensNorm;
    public float SendDepth;
    public Shader Shader;
    private Material _material;

    public Material Mat
    {
        get
        {
            if (_material == null)
            {
                _material = new Material(Shader);
            }

            return _material;
        }
    }

    private Camera _camera;

    public Camera Camera
    {
        get
        {
            if (_camera == null)
            {
                _camera = GetComponent<Camera>();
            }

            return _camera;
        }
    }
    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material mat = Mat;
        if (mat != null)
        {
            mat.SetColor("_edgeColor",EdgeColor);
            mat.SetColor("_backColor",BackColor);
            mat.SetFloat("_edgeOnly",EdgeOnly);
            mat.SetFloat("_sampleDistance",SampleDistance);
            mat.SetFloat("_sensNorm",SensNorm);
            mat.SetFloat("_sendDepth",SendDepth);
            Graphics.Blit(src,dest,mat);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
