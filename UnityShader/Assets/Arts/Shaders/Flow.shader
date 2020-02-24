// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BarbequeSir/Flow"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _Magtitude("Magtitude",Range(0,2)) = 1
        _Frenquency("Frenquency",Range(0,2)) = 1
        _Wave("Wave",Range(1,100)) = 1
        _Speed("Speed",Range(0,1)) = 1
    }
    SubShader
    {
    
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
            float _Frenquency;
            float _Magtitude;
            float _Wave;
            float _Speed;
            v2f vert(a2v v)
            {
                v2f o;
                float4 offset;
                offset.yzw = float3(0,0,0);
                offset.x = _Magtitude * sin(_Frenquency*_Time.y + v.vertex.x * _Wave + v.vertex.y * _Wave + v.vertex.z*_Wave );
         
                
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.uv+=float2(0,_Time.y * _Speed);
                return o;
            }
            
            float4 frag(v2f i):SV_TARGET
            {
                float4 c = tex2D(_MainTex,i.uv);
                return c;
            }
            ENDCG
        }
        
        
    }
    Fallback "Transparent/VertexLit"
}
