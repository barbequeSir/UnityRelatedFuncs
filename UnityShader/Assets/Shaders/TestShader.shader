Shader "BarbequeSir/Test"
{
    Properties
    {
        _Int("Int",int) = 1
        _Color("Color",Color)=(1,1,1,1)
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members pos)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct a2v{
                float4 pos:POSITION;
            };
            struct v2f{
                float4 pos:POSITION;
            };
            float4 _Color;
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.pos);
                return o;
            }
            
            fixed4 frag( v2f i):SV_TARGET
            {
                return _Color;
            }
            ENDCG
        }
    }
    
    Fallback "diffuse"

}
