// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BarbequeSir/DiffuseFragLevel"
{
    
    Properties
    {
        _diffuse("Diffuse",Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float4 worldPos:TEXCOORD0;
            };

            float4 _diffuse;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.worldPos = mul(unity_ObjectToWorld,v.pos);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 color = _LightColor0.rgb* _diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                return float4(color,1.0);
            }
            ENDCG
        }
    }
}