Shader "BarbequeSir/ReflectRefract"
{
    Properties
    {
        _Rate ("Rate", Range(0,1)) = 1
        _CubeMap("CubeMap",CUBE)="cube"{}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include"AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                SHADOW_COORDS(4)
                float4 pos : SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldReflect:TEXCOORD2;
                float3 worldRefract:TEXCOORD3;
            };

            float _Rate;
            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldView = UnityWorldSpaceViewDir(o.worldPos);
                o.worldReflect = reflect(-worldView,o.worldNormal);
                o.worldRefract = refract(-normalize(worldView),normalize(o.worldNormal),_Rate);
                TRANSFER_SHADOW(v);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 diffuse = float3(1,1,1) * max(0,dot(worldNormal,worldLight));
                float3 reflect1 = texCUBE(_CubeMap,i.worldReflect).rgb;
                float3 col = lerp(diffuse,reflect1,_Rate);
                float shadow = UNITY_SHADOW_ATTENUATION(i,i.worldPos);
                return float4(col,1);
            }
            ENDCG
        }
    }
}
