using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public class PostEffecctColor : MonoBehaviour
{
    [Range(0,3)]
    public float Brightness = 1;
    [Range(0,1)]
    public float Saturation = 1;
    [Range(0,1)]
    public float Contrast = 1;
    public Shader Shader;
    private Material _material;
    Material Mat
    {
        get
        {
            if (_material == null)
            {
                _material = new Material(Shader);
                _material.hideFlags = HideFlags.DontSave;
            }

            return _material;
        }
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material mat = Mat;
        mat.SetFloat("_Brightness",Brightness);
        mat.SetFloat("_Saturation",Saturation);
        mat.SetFloat("_Contrast",Contrast);
        Graphics.Blit(src,dest,Mat);
    }
}
