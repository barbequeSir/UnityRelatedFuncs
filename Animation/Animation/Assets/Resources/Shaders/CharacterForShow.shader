// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BA/Character For Show"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(0.0, 1)) = 1
        _MainTex("Base (RGB)", 2D) = "white" {}
        _BumpMap("Bump Map", 2D) = "bump" {}
        _GlossMap("Gloss (R)", 2D) = "white" {}
        _GlossFactor("Gloss Factor", Range(0.0, 10.0)) = 1.0
        _EmissionMap("Self Illum (RGB)", 2D) = "black" {}
        _AmbientColor("Ambient Color", Color) = (0.7, 0.7, 0.7, 1)
		_FakeSpotLightColor("Fake Spotlight Color", Color) = (0.7, 0.7, 1, 1)
		_FakeSpotLightPos("Fake Spotlight Position (A:Intensity)", Vector) = (0.0, 1.0, 0.5, 10.0)
		_FakeSpotLightDir("Fake Spotlight Direction (A:Range)", Vector) = (0.0, 1.0, 0.0, 1.5)
		_EnvMap("Env Map", Cube) = "" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM

        #pragma target 3.0
        #pragma surface surf BlinnPhong vertex:vert noambient

        sampler2D _MainTex;
        fixed4 _Color;
        half _Shininess;
        fixed _GlossFactor;
        fixed4 _AmbientColor;
		fixed4 _FakeSpotLightColor;
		float4 _FakeSpotLightPos;
		float4 _FakeSpotLightDir;

        sampler2D _BumpMap;
        sampler2D _GlossMap;
        sampler2D _EmissionMap;
		samplerCUBE _EnvMap;
        

        struct Input
        {
            fixed2 uv_MainTex;
			float3 viewPos;
			float3 worldRefl;
			float3 worldNormal;
			INTERNAL_DATA
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
			
			float4 viewSpacePos = UnityObjectToClipPos(v.vertex);
			//float3 viewSpaceNormal = mul(UNITY_MATRIX_MV, v.normal).xyz;
			//float3 viewDir = -normalize(viewSpacePos);
			//float3 fakeIncidentDir = 2 * dot(viewDir, viewSpaceNormal) * viewSpaceNormal - viewDir;
			o.viewPos = viewSpacePos.xyz / viewSpacePos.w;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
			//float fakeLightIntensity = pow(saturate(dot(IN.fakeIncidentDir, normalize(float3(0, 1, 1)))), 16);
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

			float3 reflVector = WorldReflectionVector(IN, o.Normal);
			float3 worldNormal = WorldNormalVector(IN, o.Normal);
            half4 glossColor = tex2D(_GlossMap, IN.uv_MainTex);

			o.Albedo = tex.rgb * _Color.rgb;
			o.Gloss = _GlossFactor * glossColor.r * texCUBE(_EnvMap, reflVector).rgb;
            o.Alpha = tex.a * _Color.a;
            o.Specular = _Shininess;

			half3 h = normalize(float3(0, 0, 1) + normalize(_FakeSpotLightDir.rgb));
			half fakeSpotLight = saturate(dot(h, worldNormal));
			half dist = length(IN.viewPos - _FakeSpotLightPos.xyz);
			half fakeSpotLightIntensity = max(0, _FakeSpotLightPos.w * (1 - dist * dist / _FakeSpotLightDir.w));

			o.Emission = tex2D(_EmissionMap, IN.uv_MainTex) + _AmbientColor * o.Albedo + fakeSpotLight * fakeSpotLightIntensity * _FakeSpotLightColor * glossColor.g;
        }

        ENDCG
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf BlinnPhong

        sampler2D _MainTex;
        fixed4 _Color;
        half _Shininess;
        fixed _GlossFactor;
        fixed4 _AmbientColor;

        sampler2D _BumpMap;
        sampler2D _GlossMap;
        sampler2D _EmissionMap;
        
        struct Input
        {
            fixed2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _Color.rgb;
            half4 glossColor = tex2D(_GlossMap, IN.uv_MainTex);
            o.Gloss = _GlossFactor * glossColor.r;
            o.Alpha = tex.a * _Color.a;
            o.Specular = _Shininess;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Emission = tex2D(_EmissionMap, IN.uv_MainTex) + _AmbientColor * o.Albedo;
        }

        ENDCG
    }

    Fallback "Mobile/Diffuse"
}
