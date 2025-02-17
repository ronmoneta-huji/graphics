﻿Shader "CG/BlinnPhong"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (0.14, 0.43, 0.84, 1)
        _SpecularColor ("Specular Color", Color) = (0.7, 0.7, 0.7, 1)
        _AmbientColor ("Ambient Color", Color) = (0.05, 0.13, 0.25, 1)
        _Shininess ("Shininess", Range(0.1, 50)) = 10
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                // Declare used properties
                uniform fixed4 _DiffuseColor;
                uniform fixed4 _SpecularColor;
                uniform fixed4 _AmbientColor;
                uniform float _Shininess;

                struct appdata
                { 
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 normal: TEXC00RD0;
                    float3 pixelWorld : TEXC00RD1;
                };

                // Calculates diffuse lighting of secondary point lights (part 3)
                fixed4 pointLights(v2f input)
                {
                    fixed4 color_sum = fixed4(0,0,0,0);
                    float3 n = normalize(mul(unity_ObjectToWorld, input.normal));
                    
                    
                    for (int i=0; i < 4; i++)
                    {
                        float3 light_pos = float3(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i]);
                        float3 diff = light_pos - input.pixelWorld;
                        float d = length(diff);
                        float3 l = normalize(diff);
                        float intens = 1.0 / (1.0 + unity_4LightAtten0[i] * pow(d,2));
                        color_sum += intens * (max(dot(l, n), 0) * _DiffuseColor  * unity_LightColor[i]);
                    }

                    return color_sum;

                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.pixelWorld = mul(unity_ObjectToWorld, input.vertex);
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.normal = input.normal;
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    fixed4 colora = _AmbientColor * _LightColor0;

                    float3 n = normalize(mul(unity_ObjectToWorld, input.normal));
                    float3 l = normalize(_WorldSpaceLightPos0);

                    fixed4 colord = max(dot(l, n), 0) * _DiffuseColor * _LightColor0;

                    float3 v = normalize(_WorldSpaceCameraPos - input.pixelWorld);
                    float3 h = normalize(l + v);

                    fixed4 colors = pow(max(dot(n, h), 0), _Shininess) * _SpecularColor * _LightColor0;

                    fixed4 finalColor = colord + colors + colora + pointLights(input);
                    return finalColor;
                }

            ENDCG
        }
    }
}
