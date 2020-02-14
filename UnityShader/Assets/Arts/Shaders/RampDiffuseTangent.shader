Shader "BarbequeSir/RampDiffuseTangent"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _BumpTex("BumpTex",2D) = "white"{}
        _RampTex("RampTex",2D) = "white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(1,300)) = 100
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
            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _RampTex;
            float4 _MainTex_ST;
            float4 _BumpTex_ST;
            float4 _RampTex_ST;
            float4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 uv:TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 uv1:TEXCOORD1;
                float3 t2w1:TEXCOORD2;
                float3 t2w2:TEXCOORD3;
                float3 t2w3:TEXCOORD4;
                float3 worldPos:TEXCOORD5;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv.xy = TRANSFORM_TEX(v.uv,_MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv,_BumpTex);
                o.uv1.xy = TRANSFORM_TEX(v.uv,_RampTex);
                o.t2w1 = UnityObjectToWorldDir(v.tangent);
                o.t2w3 = UnityObjectToWorldNormal(v.normal);
                o.t2w2 =  cross(o.t2w3,o.t2w1);
                o.worldPos = mul((float3x3)unity_ObjectToWorld,v.pos);
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float3 tNormal = normalize(i.t2w3);
                float3 tTangent = normalize(i.t2w1);
                float3 tBitangent = normalize(i.t2w2);

                float3x3 rotation = transpose(float3x3(tTangent,tBitangent,tNormal));
                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex,i.uv.zw)).xyz;

                float3 worldNormal = normalize(mul(rotation,tangentNormal));
                float3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));

                float3 mainCol = tex2D(_MainTex,i.uv.xy).rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * mainCol*0.2;
                float halfDiffuse = 0.5 * dot(worldNormal,worldLight) + 0.5;
                float3 diffuse= tex2D(_RampTex,float2(halfDiffuse,halfDiffuse)).rgb * _LightColor0.xyz * mainCol;
                //float3 diffuse = _LightColor0.rgb * mainCol * max(0,dot(worldNormal,worldLight));
                float3 worldHalf = normalize(worldLight + worldView);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,worldHalf)),_Gloss);
                float3 col = ambient + diffuse + specular;
                //float3 col = diffuse;
                return float4(col,1);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}
