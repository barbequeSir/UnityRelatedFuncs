Shader "BarbequeSir/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex("BumpTex",2D) = "bump" {}
        _CubeMap("CubeMap",Cube) = "_Skybox"{}
        _Distortion("Distortion",Range(0,100)) = 50
        _FractAmount("FractAmount",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "RenderType"="Qpeque"}
        GrabPass 
        {
            "_RefractionTex"
        }
        
        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct a2v 
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 uv:TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 tTow1:TEXCOORD1;
                float4 tTow2:TEXCOORD2;
                float4 tTow3:TEXCOORD3;
                float4 screenPos:TEXCOORD4;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            float _FractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
              
                o.uv.xy = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv * _BumpTex_ST.xy + _BumpTex_ST.zw;
                
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);                
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldBitangent = cross(worldNormal,worldTangent) * v.tangent.w;
                
                o.tTow1 = float4(worldTangent.x,worldBitangent.x,worldNormal.x,worldPos.x);
                o.tTow2 = float4(worldTangent.y,worldBitangent.y,worldNormal.y,worldPos.y);
                o.tTow3 = float4(worldTangent.z,worldBitangent.z,worldNormal.z,worldPos.z);
                
                o.screenPos = ComputeGrabScreenPos(o.pos);
                return o;
            }
            
            float4 frag(v2f i):SV_TARGET
            {
                float3 bump = tex2D(_BumpTex,i.uv.zw).rgb;
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.screenPos.xy = offset + i.screenPos.xy;
                float3 fractCol = tex2D(_RefractionTex,i.screenPos.xy/i.screenPos.w).rgb;
                
                float3 mainCol = tex2D(_MainTex,i.uv.xy).rgb;
                float3 worldPos = float3(i.tTow1.w,i.tTow2.w,i.tTow3.w);
                float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldBump = normalize(float3(dot(i.tTow1.xyz,bump),dot(i.tTow2.xyz,bump),dot(i.tTow3.xyz,bump)));
                float3 reflectDir = reflect(-worldView,worldBump);
                float3 reflectCol = texCUBE(_CubeMap,reflectDir).rgb * mainCol;
                
                float3 col = fractCol * _FractAmount + reflectCol * ( 1-_FractAmount);
                return float4(col,1);
            }
            ENDCG
        }
    }
}
