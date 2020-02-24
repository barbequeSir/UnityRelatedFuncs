using UnityEngine;

public class PostEffectGauss : MonoBehaviour
{
    public Shader Shader;
    [Range(1, 4)] public int IterateNum;
    [Range(1, 8)] public int DownSample;
    [Range(1, 10)] public float BlurSpread;
    private Material _mat;
    private Material Mat
    {
        get
        {
            if (_mat == null)
            {
                _mat = new Material(Shader);
            }

            return _mat;
        }
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material mat = Mat;

        if (mat != null)
        {
            int width = src.width;
            int height = src.height;
            RenderTexture buffer0 = RenderTexture.GetTemporary(width/DownSample, height/DownSample, 0);
            buffer0.filterMode = FilterMode.Bilinear;
        
            Graphics.Blit(src,buffer0);
            for (int i = 0; i < IterateNum; i++)
            {
                mat.SetFloat("_BlurSize",BlurSpread * i +1);
                RenderTexture buffer1 = RenderTexture.GetTemporary(width / DownSample, height / DownSample, 0);
                Graphics.Blit(buffer0, buffer1, mat, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width / DownSample, height / DownSample, 0);
                Graphics.Blit(buffer0,buffer1,mat,1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
        
            Graphics.Blit(buffer0,dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
        
    }
}
