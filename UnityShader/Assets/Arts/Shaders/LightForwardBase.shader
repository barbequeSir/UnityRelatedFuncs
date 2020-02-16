// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "BarbequeSir/LightForwardBase"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(1,300)) = 150
    }

    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Color;
            float4 _Specular;
            float _Gloss;
            struct a2v 
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float4 color:Color;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float3 worldPos:TEXCOORD0;
                float4 color:Color;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.pos);

                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
                float3 worldView = UnityWorldSpaceViewDir(i.worldPos);
                float3 albedo = _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLight));
                float3 halfDir = normalize(worldLight + worldView);
                float3 specular = _LightColor0.rgb  * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                
                float atten = 1;
                return float4(ambient + (diffuse + specular) * atten,1);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            float4 _Color;
            float4 _Specular;
            float _Gloss;
            struct a2v 
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float4 color:Color;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float3 worldPos:TEXCOORD0;
                float4 color:Color;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.pos);

                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
                float3 worldView = UnityWorldSpaceViewDir(i.worldPos);
                float3 albedo = _Color.rgb;
                
                float3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLight));
                float3 halfDir = normalize(worldLight + worldView);
                float3 specular = _LightColor0.rgb  * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                
                
                #ifdef USING_DIRECTIONAL_LIGHT
                    float atten = 1;
                #else
                    float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                    float atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                return float4((diffuse + specular) * atten,1);
            }
            ENDCG
        }
        
    }

    Fallback "Diffuse"
}
