Shader "BarbequeSir/TangentSpaceNormal"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _NormalTex("NormalTex",2D) = "whilte"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(0,250))=100
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
            sampler2D _NormalTex;
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            float _Gloss;
            float4 _Specular;

            /*transform tangentspace Normal to worldspace Normal*/
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
                float3 tangent:TEXCOORD;
                float3 bitangent:TEXCOORD1;
                float3 normal:TEXCOORD2;
                float4 uv:TEXCOORD3;
                float3 worldPos:TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);

                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBiTangent = cross(worldNormal,worldTangent)*v.tangent.w;
                o.tangent = float3(worldTangent.x,worldBiTangent.x,worldNormal.x);
                o.normal = float3(worldTangent.z,worldBiTangent.z,worldNormal.z);
                o.bitangent = float3(worldTangent.y,worldBiTangent.y,worldNormal.y);
                //o.uv.xy = TRANSFORM_TEX(v.uv,_MainTex);
                //o.uv.zw = TRANSFORM_TEX(v.uv,_NormalTex);
                o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
                o.worldPos = mul(unity_ObjectToWorld,v.pos).xyz;
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
               
                float3x3 rotation = float3x3(i.tangent,i.bitangent,i.normal);
                float3 tangentNormal = UnpackNormal(tex2D(_NormalTex,i.uv.zw));
                float3 worldNormal = normalize(float3(dot(i.tangent,tangentNormal),dot(i.bitangent,tangentNormal),dot(i.normal,tangentNormal)));
                float3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldLightReflect = reflect(-worldLight,worldNormal);
                float3 halfDir = normalize(worldLight + worldView);
                
                float4 mainCol = tex2D(_MainTex,i.uv.xy);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * mainCol;
                float3 diffuse = _LightColor0.xyz * mainCol * max(0,dot(worldNormal,worldLight));
                float3 specular = _LightColor0.xyz * _Specular.xyz *  pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                float3 col = ambient + diffuse + specular;
                return float4(col,1);
            }
            /**/
            /*  transform view light form model to tangent space
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
                float3 viewDir:TEXCOORD1;
                float3 lightDir:TEXCOORD2;
                
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                float3 bitangent = normalize(cross(v.normal,v.tangent.xyz)*v.tangent.w);
                float3x3 rotation = float3x3(v.tangent.xyz,bitangent,v.normal);
                o.uv.xy = TRANSFORM_TEX(v.uv,_MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv,_NormalTex);

                o.viewDir = mul(rotation,ObjSpaceViewDir(v.pos)).xyz;
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.pos)).xyz;

                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float3 viewDir = normalize(i.viewDir);
                float3 lightDir = normalize(i.lightDir);
                float3 normal = UnpackNormal( tex2D(_NormalTex,i.uv.zw));
                float4 mainCol = tex2D(_MainTex,i.uv.xy);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz  * mainCol.xyz;
                float3 diffuse = _LightColor0.rgb * max(0,dot(normal,lightDir))*mainCol.xyz;
                float3 reflectDir = reflect(-lightDir,normal);
                float3 specular = pow(max(0,dot(reflectDir,viewDir)),_Gloss);
                float3 col = ambient + diffuse + specular;
                
                return float4(col,1.0);
            }
            */

            ENDCG
        }
    }
    Fallback "Specular"
}
