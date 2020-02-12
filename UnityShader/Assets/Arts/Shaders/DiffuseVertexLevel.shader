// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "BarbequeSir/DiffuseVertexLevel"
{
    Properties
    {
        _diffuse("Diffuse",Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

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
                float3 color:COLOR;
            };

            float4 _diffuse;
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.pos);
                float3 worldPos = (float3)(mul(unity_ObjectToWorld,i.pos));
                float3 worldNormal = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                //float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                float3 worldLightDir = UnityWorldSpaceLightDir(worldPos);
                float3 lightColor = _LightColor0.rgb;

                float3 diffuse = lightColor.rgb * _diffuse.rgb * max(0,dot(worldNormal,worldLightDir));
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                o.color = diffuse + ambient;
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                return float4(i.color,1.0);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"
}