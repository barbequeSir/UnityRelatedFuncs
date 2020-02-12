// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//调试shader输出颜色
Shader "BarbequeSir/DebugShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f{
                float4 pos:SV_POSITION;
                float4 color:COLOR;
            };
            
            v2f vert(appdata_full i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.color = float4(i.normal * 0.5 + float3(0.5,0.5,0.5),1.0);
                o.color = float4(i.tangent.xyz * 0.5 + float3(0.5,0.5,0.5),1.0);
                float3 bitangent = cross(i.normal,i.tangent.xyz)*i.tangent.w;
                o.color = float4(bitangent*0.5 + float3(0.5,0.5,0.5),1.0);
                o.color = float4(i.texcoord.xy,0.0,1.0);
                o.color = float4(i.texcoord1.xy,0.0,1.0);
                o.color = i.color;
                return o;                
            }
            
            float4 frag(v2f i):SV_TARGET
            {
                float3 color = i.color;
                return float4(color,1);
            }
            ENDCG
        }
    }
}   