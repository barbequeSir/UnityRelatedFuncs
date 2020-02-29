// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BarbequeSir/DiffuseTexture"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _Diffuse("Diffuse",Color) = (0,1,0,1)
        _Specular("Specular",Color)=(1,0,0,1)
        _Color("Color",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(0,1000)) = 1
    }

    SubShader
    {
        Tags{"Queue"="Geometry"  "RenderType"="Opaque" }
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"  }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include"Lighting.cginc"
            struct a2v
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float2 tex:TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float2 tex:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld,i.pos);
                o.tex = TRANSFORM_TEX(i.tex,_MainTex);
                //o.tex = i.tex;
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                float3 worldLightReflectDir = normalize(reflect(-worldLightDir,worldNormal));
                float3 halfDir = normalize(worldViewDir + worldLightDir);

                float4 texColor = tex2D(_MainTex,i.tex);
                float3 albedo = texColor.xyz * _Color.xyz;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo*0.21;
                float3 diffuse =  _LightColor0.rgb *  _Diffuse.rgb * max(0,(dot(worldLightDir,worldNormal))) * albedo;
                
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,(dot(worldNormal,halfDir))),_Gloss);
                //float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,(dot(worldLightReflectDir,worldViewDir))),_Gloss);
                float3 col = ambient + diffuse + specular;
                return float4(col,1.0);
            }
            ENDCG
        }
    }

    Fallback "VertexLit"
}