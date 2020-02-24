Shader "BarbequeSir/PostEffectBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomThreadhold("BloomThreadhold",Float) = 1
        _Bloom("Bloom",2D)="white"{}
    }
    SubShader
    {
        ZTest Always
        ZWrite Off
        Cull Off
        CGINCLUDE
        #include"UnityCG.cginc"
        
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
        };
        
        fixed luminance(fixed4 color) {
			return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
		}
        
        sampler2D _MainTex;
        sampler2D _Bloom;
        float _BloomThreadhold;
        v2f vertBright(appdata_img v)
        {   
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        
        float4 fragBright(v2f i):SV_TARGET
        {
            float4 col = tex2D(_MainTex,i.uv);
            float lum = luminance(col);
            float value = clamp(lum - _BloomThreadhold,0,1);
            return col * value;
        }
        
        struct v2f_Bloom
        {
            float4 pos:SV_POSITION;
            float4 uv:TEXCOORD0;
        };
        
        v2f_Bloom vertBloom(appdata_img v)
        {
            v2f_Bloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;
            return o;
        }
        float4 fragBloom(v2f_Bloom i):SV_TARGET
        {
            float4 colMain = tex2D(_MainTex,i.uv.xy);
            float4 colBloom = tex2D(_Bloom,i.uv.zw);
            float4 col = colMain + colBloom;
            return col;
        }
        ENDCG
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBright
            #pragma fragment fragBright
            ENDCG
        }
        
        UsePass "BarbequeSir/PostEffectGauss/GAUSS_HORIZONTAL"
        UsePass "BarbequeSir/PostEffectGauss/GAUSS_VERTICAL"
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
    Fallback "Off"
}
