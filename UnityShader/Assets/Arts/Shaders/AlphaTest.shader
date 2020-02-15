Shader "BarbequeSir/AlphaTest"
{
    Properties
    {
        _MainTex("MainTex",2D)="white"{}     
        _Threadhold("Threadhold",Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;           
            float4 _MainTex_ST;          
            float _Threadhold;

            struct a2v
            {
                float4 pos:POSITION;
                float3 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };
            struct v2f 
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:NORMAL;
                float2 uv:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);                
                o.worldPos = mul(unity_ObjectToWorld,v.pos).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.pos);
                return o;

            }

            float4 frag(v2f i):SV_TARGET
            {       
                float4 mainCol = tex2D(_MainTex,i.uv.xy);                
                clip(mainCol.a - _Threadhold);

                float3 normal = normalize(i.worldNormal);             
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * mainCol.rgb;
                float3 diffuse = _LightColor0.rgb * max(0,dot(lightDir,normal)) * mainCol.rgb;
                float3 col = ambient + diffuse;
                return float4(col,1);
            }
            ENDCG
        }
    }

    Fallback "Transparent/Cutout/VertexLit"
}
