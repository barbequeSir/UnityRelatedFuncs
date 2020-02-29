Shader "BarbequeSir/PostEffectGauss"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("BlurSize",Float) = 1
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderTyoe"="Transparent" }
        ZWrite Off
        ZTest Always
        Cull Off
        
        CGINCLUDE
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv)
#pragma exclude_renderers d3d11
        #include "UnityCG.cginc"
        
        float _BlurSize;
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv[5]:TEXCOORD0;
        };
        
        v2f vertVertical(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord;
            o.uv[1] = v.texcoord + float2(0,1)*_MainTex_TexelSize.xy * _BlurSize;
            o.uv[2] = v.texcoord + float2(0,-1) * _MainTex_TexelSize.xy* _BlurSize;
            o.uv[3] = v.texcoord + float2(0,2)*_MainTex_TexelSize.xy* _BlurSize;
            o.uv[4] = v.texcoord + float2(0,-2)*_MainTex_TexelSize.xy* _BlurSize;
            
            return o;
        }
        v2f vertHorizontal(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            
            o.uv[0] = v.texcoord;
            o.uv[1] = v.texcoord + float2(1,0)*_MainTex_TexelSize.xy* _BlurSize;
            o.uv[2] = v.texcoord + float2(-1,0) * _MainTex_TexelSize.xy* _BlurSize;
            o.uv[3] = v.texcoord + float2(2,0)*_MainTex_TexelSize.xy* _BlurSize;
            o.uv[4] = v.texcoord + float2(-2,0)*_MainTex_TexelSize.xy* _BlurSize;
            
            return o;
        }
        
        
        float4 fragGauss(v2f i):SV_Target
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            
            float3 acc = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
            for(int k = 1;k<3;k++)
            {
                acc+= tex2D(_MainTex,i.uv[2*k]).rgb * weight[k];
                acc+= tex2D(_MainTex,i.uv[2*k-1]).rgb * weight[k];
            }
            
            return float4(acc,1);
        }
        
        ENDCG
        
        Pass
        {
            NAME "GAUSS_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertHorizontal
            #pragma fragment fragGauss
            ENDCG
        }
        
        Pass
        {
            NAME "GAUSS_VERTICAL"
            CGPROGRAM
            #pragma vertex vertVertical
            #pragma fragment fragGauss
            ENDCG
        }
    }
    Fallback "Diffuse"
}
