Shader "Custom/CelShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Base Map", 2D) = "white" {}
        _RampMap ("Ramp Map", 2D) = "white" {}
        _AmbientStrength ("AmbientStrength", range(0,1)) = 0.3
        _OutlineColor ("OutLineColor", Color) = (0.2, 0.15, 0.2, 1)
        _OutlineWidth ("OutLineWidth", range(0,10)) = 2
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
        _ShadingStrength ("Shading Strength",Range(0,1)) = 1
        _ReceiveShadow ("Receive Shadow", Range(0,1)) = 1
        _ShadeOffset("Shade Offset", Range(-1,1)) = 0

    }
    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _OutlineColor;
                half _AmbientStrength;
                half _OutlineWidth;
                half _ShadingStrength;
                half _ReceiveShadow;
                half _ShadeOffset;
        CBUFFER_END
        ENDHLSL
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Cull [_Cull]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_RampMap);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_RampMap);
            SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }
            half4 frag (Varyings IN) : SV_Target
            {
                float3 N = normalize(IN.normalWS);

                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light light = GetMainLight(shadowCoord);

                float3 L = light.direction;

                half shadow = lerp(1, light.shadowAttenuation, _ReceiveShadow);
                float NdotL = dot(N,L);
                float rampU = NdotL * 0.5 + 0.5;
                rampU = saturate(rampU + _ShadeOffset) * shadow;
                half3 ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampU, 0.5)).rgb;
                half3 basecolor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv).rgb;
                return half4(basecolor * _BaseColor.rgb * (lerp(1, ramp, _ShadingStrength) * light.color + SampleSH(N) * _AmbientStrength),1);
            }
            ENDHLSL
        }
        Pass
        {
            Name "Outline"
            Cull Front
            Offset 1, 1

            HLSLPROGRAM
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            float4 OutlineVert (Attributes IN) : SV_POSITION
            {
                float4 positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                float3 normalCS = TransformWorldToHClipDir(normalWS);
                float2 normalizenormalCS = normalize(normalCS.xy);
                float2 pixelsize = 2 / _ScreenParams.xy;
                positionCS.xy += normalizenormalCS * _OutlineWidth * pixelsize * positionCS.w;
                return positionCS;
            }

            float4 OutlineFrag () : SV_Target
            {
                clip(_OutlineWidth - 0.0001);
                return _OutlineColor;    
            }
            ENDHLSL
        }
        Pass
        {

            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowVert
            #pragma fragment ShadowFrag
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            float3 _LightDirection;
            float3 _LightPosition;
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            float4 ShadowVert (Attributes IN) : SV_POSITION
            {
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDir = normalize(_LightPosition - positionWS);
            #else
                float3 lightDir = _LightDirection;
            #endif
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS,normalWS,lightDir));
            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z,UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z,UNITY_NEAR_CLIP_VALUE);
            #endif

                return positionCS;
            }
            half4 ShadowFrag () : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }

    }
    CustomEditor "CelShaderGUI"
}
