Shader "Unlit/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex("Texture",2D)="white"{}        
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Brightness;
            float _Saturation;
            float _Contrast;
            
            v2f_img vert(appdata_img v)
            {
                v2f_img o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            
            float luminace(float4 color)
            {
                float col =0.2125 * color.r + 0.7154 * color.g +0.072 * color.b;
                return col;
            }
            
            
            float4 frag(v2f_img i):SV_TARGET
            {
                float4 color = tex2D(_MainTex,i.uv);
                float3 finalColor = color.rgb * _Brightness;
                float luminance = 0.2125 * color.r + 0.7154 * color.g +0.072 * color.b;
                float3 luminanceColor = float3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);
                
                float3 avgColor = float3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);
                
                float Gx[9] = {-1,-2,-1,0,0,0,1,2,1};
                float Gy[9] = {-1,0,1,-2,0,2,-1,0,1};
                float accx = 0;
                float accy = 0;
                for(int k = -1;k<=1;k++)
                {
                    for(int j = -1;j<=1;j++)
                    {
                        float4 tempCol = tex2D(_MainTex,i.uv + float2(k,j) * _MainTex_TexelSize.xy);
                        float index = (k+1)*3 + j+1;
                        accx += luminace(tempCol) * Gx[index];
                        accy += luminace(tempCol) * Gy[index];
                    }
                }
                float acc = 1 - abs(accx) - abs(accy);
                
                finalColor *= acc;
                return float4(finalColor,1);
            } 
            ENDCG
        }
    }
}
