Shader "BarbequeSir/PostEffectOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        sampler2D _CameraDepthNormalsTexture;
        float4 _MainTex_TexelSize;
        float4 _edgeColor;
        float4 _backColor;
        float _threadHold;
        float _edgeOnly;
        float _sampleDistance;
        float _sensDepth;
        float _sensNorm;
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv[5]:TEXCOORD0;
        };
        
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            
            float2 uv = v.texcoord;
            o.uv[0] = uv;
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    uv.y = 1 - uv.y;
            #endif
            o.uv[1] = uv + float2(-1,1) *_MainTex_TexelSize.xy * _sampleDistance;
            o.uv[2] = uv + float2(1,-1)*_MainTex_TexelSize.xy * _sampleDistance;
            o.uv[3] = uv + float2(1,1) * _MainTex_TexelSize.xy * _sampleDistance;
            o.uv[4] = uv + float2(-1,-1)*_MainTex_TexelSize.xy * _sampleDistance;
            return o;
        }
        
        float CheckDiff(float4 a,float4 b)
        {
            float2 anorm = a.xy;
            float adepth = DecodeFloatRG(a.zw);
            float2 bnorm = b.xy;
            float bdepth = DecodeFloatRG(b.zw);
            
            float2 normDiff = abs(anorm - bnorm)*_sensNorm;
            int isNormalDiff = (normDiff.x + normDiff.y) < 0.1;
            float depthDiff = abs(adepth - bdepth)*_sensDepth;
            float isDepthDiff = depthDiff < 0.1 * adepth;
            return isNormalDiff * isDepthDiff ? 1:0;
        }
        
        float4 frag(v2f i):SV_Target
        {
            float4 s1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
            float4 s2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
            float4 s3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
            float4 s4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);
            
            float dx = CheckDiff(s1,s2);
            float dy = CheckDiff(s3,s4);
            
            float edge = dx * dy;
            float4 withEdgeCol = lerp(_edgeColor,tex2D(_MainTex,i.uv[0]),edge);
            float4 backCol = lerp(_edgeColor,_backColor,edge);
            float4 finalCol = lerp(withEdgeCol,backCol,_edgeOnly);
                        
            
            return finalCol;
        }
        ENDCG
        
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    
    Fallback Off
}
