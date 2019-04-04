Shader"BA/RoleBase_Low"
{
	Properties{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_Ramp("Ramp Texture",2D) = "white"{}
		_Ramp2("Ramp2 Texture",2D) = "white"{}
		_Mask("Mask",2D) = "white"{}
		_Outline("Outline",Range(0,1)) = 0.05
		_OutlineColor("Outline Color",Color)=(0,0,0,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_SpecularScale("Specular Scale",Range(0,0.1))=0.01
		_SpecDiff ("SpecDiff", range (0.001,1)) = 0.03
		_rimcol ("Rimlight Color",color) = (0,0,0,1)
		_rimpow ("Rimlight Power", range (0.001,5)) = 1
		_rimran ("Rimlight Range", range (0.001,1)) = 1
		_shadow_color("Shadow Color",Color)=(0,0,0,0.5)
		_objpos_y("Shadow Y",Range(-10,10))=-3
		_KeepOut_color("KeepOut Color",Color)=(0.1,0.9,0.95,0.8)

	}
	SubShader
	{
		Tags {"RenderType"="Transparent" "IngoreProject"="true" "Queue"="Transparent"}
		//Pass{
		//	Tags {"RenderType"="Transparent" "IngoreProject"="true" "Queue"="Transparent"}
		//	Blend SrcAlpha One
		//	ZTest off
		//	ZWrite off
		//	Stencil
		//	{
		//		Ref 64
		//		writeMask 64
		//		readMask 64
		//		Comp NotEqual
		//		Pass Replace
		//		Fail Keep
		//		ZFail Keep
		//	}
		//	//Offset 10, 10
		//	CGPROGRAM

		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#include "UnityCG.cginc"

		//	sampler2D _MainTex;
		//	struct appdata_t{
		//		float4 vertex : POSITION;
		//		fixed4 color : COLOR;
		//		float3 normal : NORMAL;
		//		float2 texcoord :TEXCOORD0;
		//	};

		//	struct v2f {
		//		float4 pos : SV_POSITION;
		//		fixed4 color : COLOR;
		//		float2 uv : TEXCOORD0;
		//	};

		//	v2f vert(appdata_t v)
		//	{
		//		v2f o;
		//		o.pos = UnityObjectToClipPos(v.vertex);
		//		o.uv = v.texcoord;
		//		o.color = v.color;

		//		return o; 
		//	}

		//	fixed4 _KeepOut_color;

		//	fixed4 frag(v2f i) :SV_Target
		//	{
		//		//fixed4 c = _KeepOut_color;
		//		fixed4 c = tex2D(_MainTex,i.uv) * _KeepOut_color * 1.8;
		//		c.a = 1;
		//		return c;
		//	}
		//	ENDCG
		//}
		/*Pass {
			Tags {
				"LightMode"="Always"
			}
			ZTest LEqual
			Offset -40, 0
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Stencil {
				Ref 64
				ReadMask 64
				WriteMask 64
				Comp NotEqual
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"
			fixed4 _Color;

			uniform fixed _objpos_y;
			uniform fixed4 _shadow_color;

			struct VertexInput {
                float4 vertex : POSITION;
            };
			
			struct VertexOutput {
                float4 pos : SV_POSITION;
            };

            VertexOutput vert (VertexInput v) {
				float4 worldpos = mul(unity_ObjectToWorld, v.vertex);
				worldpos.x -= (worldpos.y - _objpos_y) * _WorldSpaceLightPos0.x / _WorldSpaceLightPos0.y;
				worldpos.z -= (worldpos.y - _objpos_y) * _WorldSpaceLightPos0.z / _WorldSpaceLightPos0.y;
				worldpos.y = _objpos_y;
                VertexOutput o = (VertexOutput)0;
				o.pos = mul(UNITY_MATRIX_VP, worldpos);
                return o;
            }
            
			fixed4 frag(VertexOutput i) : COLOR {
					return _shadow_color;
				
            }
            ENDCG
		}*/	


		Pass
		{
			Tags {"RenderType"="Transparent" "IngoreProject"="true" "Queue"="Transparent+1"}
			Tags{"LightMode"="ForwardBase"}
			//Cull Back
			Blend SrcAlpha OneMinusSrcAlpha

//			Stencil
//			{
//				Ref 100
//				Comp always
//				Pass Replace
//			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Ramp;
			sampler2D _Ramp2;
			sampler2D _Mask;
			fixed4 _Color;
			float4 _Specular;
			float _SpecularScale;
			float4 _rimcol;
			float _rimpow;
			float _rimran;
			float _SpecDiff;

			struct a2v{
				float4 vertex : POSITION;
				float3 color :COLOR;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal :TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)

			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir= normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldHalfDir = normalize(worldLightDir+worldViewDir);
				half rim =  1-saturate(dot(worldLightDir+worldViewDir,worldNormal));//*0.5+0.5  ;
				float4 rim1 = pow(rim*_rimpow,_rimran*4) * _rimcol;
				fixed4 c = tex2D(_MainTex,i.uv);
				fixed4 mask = tex2D(_Mask,i.uv);
				fixed3 albedo = c.rgb*_Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed diff = dot(worldNormal,worldLightDir);
				diff = (diff*0.5+0.5) * atten;

				fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp,float2(diff,diff)).rgb;

				float diffuse2offset = saturate(float2(diff,diff));
				fixed3 diffuse2 = tex2D(_Ramp2,diffuse2offset).rgb;
				diffuse=diffuse*diffuse2;
				fixed spec = dot(worldNormal,worldHalfDir);

				fixed w = fwidth(spec)*2.0;

				w=_SpecDiff;
				fixed3 specular =mask.b * _Specular.rgb * lerp(0,1,smoothstep(-w,w,spec+_SpecularScale - 1)) * step(0.0001,_SpecularScale);
				//fixed3 specular =mask.b * _Specular.rgb;

				return fixed4(ambient+diffuse+rim1,1.0);


			}


			ENDCG

		}



	}


}