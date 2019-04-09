Shader "Test/None"
{
	Properties
	{
		_src("src",2D) = "white"{}
		_dst("dst",2d) = "white"{}		
	}

	SubShader
	{
		Tags{"Queue"="Geometry" "RenderType"="Geometry"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			struct appdata
			{
				float4 vertex:POSITION;				
				float2 uv:TEXCOORD0;
				float2 uv2:TEXCOORD1;
			};
			
			struct a2f 
			{
				float4 pos:SV_POSITION;				
				float2 uv:TEXCOORD0;
				float2 uv2:TEXCOORD1;
			};
			uniform sampler2D _src;
			uniform sampler2D _dst;		
			float4 _src_ST;			
			float4 _dst_ST;
			float Hash( float2 p)
			{
				float3 p2 = float3(p.xy,1.0);
				return frac(sin(dot(p2,float3(37.1,61.7, 12.4)))*3758.5453123);

			}

			float noise(in float2 p)
			{
				float2 i = floor(p);
				float2 f = frac(p);
				f *= f * (3.0-2.0*f);

				return lerp(lerp(Hash(i + float2(0.,0.)), Hash(i + float2(1.,0.)),f.x),
					lerp(Hash(i + float2(0.,1.)), Hash(i + float2(1.,1.)),f.x),
					f.y);
			}

			float fbm(float2 p) 
			{
				float v = 0.0;
				v += noise(p*1.)*.5;
				v += noise(p*2.)*.25;
				v += noise(p*4.)*.125;
				return v;
			}
			
			a2f vert(appdata i)
			{				
				a2f o;				
				o.pos = UnityObjectToClipPos(i.vertex);		
				o.uv = TRANSFORM_TEX(i.uv,_src);
				o.uv2 = TRANSFORM_TEX(i.uv,_dst);
				return o;
			}
			
			float4 frag(a2f i):SV_Target
			{			
				float2 uv = (i.pos.xy - _ScreenParams.xy*.5)/_ScreenParams.y;
				float3 src = tex2D(_src,i.uv).rgb;
				float3 tgt = tex2D(_dst,i.uv).rgb;
				
				float3 col = src;
				
				uv.x -= 1.5;
				
				float ctime = fmod(_Time.x*3.5,2.5);
				
				// burn
				float d = uv.x+uv.y*0.5 + 0.5*fbm(uv*15.1) + ctime*1.3;
				if (d >0.35) col = clamp(col-(d-0.35)*10.,0.0,1.0);
				if (d >0.47) {
					if (d < 0.5 ) col += (d-0.4)*33.0*0.5*(0.0+noise(100.*uv+float2(-ctime*2.,0.)))*float3(1.5,0.5,0.0);
					else col += tgt; }
				
				
				return float4(col,1);
						
				
			}
			ENDCG
		}
	}
}
