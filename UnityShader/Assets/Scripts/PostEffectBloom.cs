using UnityEngine;

public class PostEffectBloom : MonoBehaviour
{
    public Shader Shader;
    [Range(1, 4)] public int IterateNum;
    [Range(1, 8)] public int DownSample;
    [Range(1, 10)] public float BlurSpread;
    [Range(0, 4)] public float BloomThreadhold;
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
            mat.SetFloat("_BloomThreadhold",BloomThreadhold);
            int width = src.width;
            int height = src.height;
            RenderTexture buffer0 = RenderTexture.GetTemporary(width/DownSample, height/DownSample, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src,buffer0,mat,0);
            
            for (int i = 0; i < IterateNum; i++)
            {
                mat.SetFloat("_BlurSize",BlurSpread * i +1);
                RenderTexture buffer1 = RenderTexture.GetTemporary(width / DownSample, height / DownSample, 0);
                Graphics.Blit(buffer0, buffer1, mat, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width / DownSample, height / DownSample, 0);
                Graphics.Blit(buffer0,buffer1,mat,2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            
            mat.SetTexture("_Bloom",buffer0);
        
            Graphics.Blit(src,dest,mat,3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
        
    }
}
