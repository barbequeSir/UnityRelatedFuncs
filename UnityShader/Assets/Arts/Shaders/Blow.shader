// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BarbequeSir/Blow"
{
    Properties
    {
        _Color ("Color",Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Speed("Speed",Range(1,100)) = 60
        _HNum("HNum",FLoat) = 4
        _VNum("VNum",Float) = 4
    }
    SubShader
    {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct a2v 
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _HNum;
            float _VNum;
            float4 _Color;
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }
            
            float4 frag(v2f i):SV_TARGET
            {
                float time = floor(_Time.y * _Speed);
                float row = floor(time /_HNum);
                float column = time - row * _HNum;
                
                fixed2 uv = i.uv + fixed2(column,-row);
                
                uv.x /= _HNum;
                uv.y /= _VNum;
                
                float4 c = tex2D(_MainTex,uv);
                c.rgb *= _Color;
                return c;
            }
            ENDCG
        }
        
        
    }
    Fallback "Transparent/VertexLit"
}
