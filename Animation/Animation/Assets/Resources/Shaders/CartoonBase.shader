// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader"BA/CartoonBase"
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

	}
	SubShader
	{
	Tags { "RenderType"="Transparent" "Queue" = "Geometry+1" }
		
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			//Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
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

				//return fixed4(ambient+diffuse+rim1+specular,1.0);//spcular open
				return fixed4(ambient+diffuse+rim1,1.0);


			}


			ENDCG

		}

	}


}