Shader "BarbequeSir/PostEffectMotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
    }
    SubShader
    {
        
        CGINCLUDE
        
        #include "UnityCG.cginc"
        
        float4x4 _FrustumCornersRay;
        float4 _FogColor;
        float _FogStart;
        float _FogEnd;
        float _FogDensity;
        sampler2D _CameraDepthTexture;
        sampler2D _MainTex; 
        float4 _MainTex_TexelSize;
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
            float2 uv_depth:TEXCOORD1;
            float4 ray:TEXCOORD2;
        };
        
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    o.uv_depth.y = 1 - o.uv_depth.y;
             
            #endif
            
            int index = 0;
            if(v.texcoord.x<0.5 && v.texcoord.y < 0.5)
            {
                index = 0;
            }
            else if(v.texcoord.x>0.5 && v.texcoord.y < 0.5)
            {
                index = 1;
            }
            else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
            {
                index =2 ;
            }
            else
            {
                index  =3 ;
            }
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    index = 3-index;
            #endif
            
            o.ray = _FrustumCornersRay[index];
            return o;            
        }
        
        float4 frag(v2f i):SV_Target
        {
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
            
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * normalize(i.ray.xyz);
            float fogDensity = (_FogEnd - worldPos.y) /(_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity);
            float4 finalColor = tex2D(_MainTex, i.uv);
			finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);
			return finalColor;
        }
        ENDCG
        Pass
        {
        ZWrite Off
        ZTest Always
        Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            ENDCG
        }
    }
    
    Fallback Off
}
