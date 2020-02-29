using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class PostEffectFog:MonoBehaviour
{
    public float fogDensity = 1;
    public Color fogColor = Color.green;
    public float fogStart = 1;
    public float fogEnd = 10;

    public Shader Shader;
    private Material _mat;

    private Material Mat
    {
        get
        {
            _mat = new Material(Shader);
            return _mat;
        }
    }

    private Camera _Camera;
    private Camera CacheCamera
    {
        get
        {
            if (_Camera == null)
            {
                _Camera = GetComponent<Camera>();
            }

            return _Camera;
        }
    }

    private Transform _CameraTransform;
    private Transform CameraTransform
    {
        get
        {
            if (_CameraTransform == null)
            {
                _CameraTransform = CacheCamera.transform;
            }

            return _CameraTransform;
        }
    }
    private void OnEnable()
    {
        CacheCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material mat = Mat;
        if (mat)
        {
            Matrix4x4 matConor = Matrix4x4.identity;
            
            float fov = CacheCamera.fieldOfView;
            float near = CacheCamera.nearClipPlane;
            float aspect = CacheCamera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;
            Vector3 toTop = CameraTransform.up * halfHeight;
            
            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.forward*near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;
            
            
            matConor.SetRow(0,bottomLeft);
            matConor.SetRow(1,bottomRight);
            matConor.SetRow(2,topRight);
            matConor.SetRow(3,topLeft);
            
            mat.SetMatrix("_FrustumCornersRay",matConor);

            mat.SetFloat("_FogDensity",fogDensity);
            mat.SetColor("_FogColor",fogColor);
            mat.SetFloat("_FogStart",fogStart);
            mat.SetFloat("_FogEnd",fogEnd);

            Graphics.Blit(src,dest,mat);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
