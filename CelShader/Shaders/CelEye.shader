Shader "Custom/CelEye"
{
    properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Base Map", 2D) = "white" {}
        [Toggle(_ALPHATEST_ON)] _AlphaTest("AlphaTest", Float) = 0
        _Cutoff ("Cutoff", range(0,1)) = 0.5
        _CenterIris ("Center Iris", vector) = (0.5, 0.5, 0, 0)
        _IrisRadiusX ("IrisRadiusX", Range(0,1)) = 0.2
        _IrisRadiusY ("IrisRadiusY", Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags{"RenderPipeline"="UniversalPipeline"}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor;
        half _Cutoff;
        float4 _CenterIris;
        half _IrisRadiusX;
        half _IrisRadiusY;
        CBUFFER_END
        
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        ENDHLSL

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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

            half4 frag(Varyings IN):SV_Target
            {
                float2 uv = IN.uv;
                float2 irispos = IN.uv - _CenterIris.xy;
                float2 irisUV = irispos / float2(_IrisRadiusX,_IrisRadiusY);
                float irisDist = length(irisUV);

                half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                #if defined(_ALPHATEST_ON)
                    clip(baseMap.a - _Cutoff);
                #endif
                half3 color =  baseMap.rgb * _BaseColor.rgb;

                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
