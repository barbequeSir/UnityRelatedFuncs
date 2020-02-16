Shader "BarbequeSir/Transparent"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex("MainTex",2D)="white"{}     
        _AlphaScale("AlphaScale",Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        
        //Pass//这个pass 在因为关闭深度写到这的非凸多边形的排序错误 无法正确渲染时候使用 正常情况下不需要这个pass
        //{
        //    ZWrite on
        //    ColorMask 0
        //}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Off  //双面透镜效果是需要这个     
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            //BlendOp Add
            //Blend OneMinusDstColor One
           
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Color;
            sampler2D _MainTex;           
            float4 _MainTex_ST;          
            float _AlphaScale;

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
                float3 albedo = mainCol.rgb * _Color.rgb;                
                //clip(mainCol.a - _Threadhold);

                float3 normal = normalize(i.worldNormal);             
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * max(0,dot(lightDir,normal)) * albedo;
                float3 col = ambient + diffuse;
                return float4(col,mainCol.a*_AlphaScale);
            }
            ENDCG
        }
    }

    Fallback "Transparent/Cutout/VertexLit"
}
