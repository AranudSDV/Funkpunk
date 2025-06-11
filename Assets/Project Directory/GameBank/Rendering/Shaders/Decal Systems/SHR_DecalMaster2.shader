// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader  "SHR_DecalMaster2"
{
	Properties
    {
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        _Cels_LitThreshold("Cels_LitThreshold", Float) = 1
        _Cels_FallOffThreshold("Cels_FallOffThreshold", Float) = 1
        _BumpNormal("BumpNormal", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range( 0 , 1)) = 0
        _ShadingWhiteMult("ShadingWhiteMult", Float) = 0.1
        _Shadow_FallOffThreshold("Shadow_FallOffThreshold", Float) = 1
        _Shadow_LitThreshold("Shadow_LitThreshold", Float) = 0.8
        [Toggle(_SHADOWS_PROCEDURALORTEXTURE_ON)] _Shadows_ProceduralOrTexture("Shadows_ProceduralOrTexture?", Float) = 0
        _ShadowPatternDensity("ShadowPatternDensity", Vector) = (100,100,0,0)
        _ShadowTex("ShadowTex", 2D) = "white" {}
        _WorldPosDiv("WorldPosDiv", Float) = 0
        [Toggle(_USINGTRIPLANAR_ON)] _UsingTriplanar("UsingTriplanar?", Float) = 0
        _ShadowTex_Pow("ShadowTex_Pow", Float) = 0.27
        _tex("tex", 2D) = "white" {}
        _AtlasCols("AtlasCols", Int) = 4
        _AtlasRows("AtlasRows", Int) = 4
        _MinRotation("MinRotation", Float) = 0
        _MaxRotation("MaxRotation", Float) = 0
        _NumGraffiti("NumGraffiti", Int) = 0
        _SeedMultiplier("SeedMultiplier", Float) = 0
        _SeedScale("SeedScale", Float) = 1
        _MinOffset_X("MinOffset_X", Float) = 0
        _MaxOffset_X("MaxOffset_X", Float) = 0
        [Toggle(_USINGTRIPLANAR1_ON)] _UsingTriplanar1("UsingTriplanar?", Float) = 0
        _MinOffset_Y("MinOffset_Y", Float) = 0
        _MaxOffset_Y("MaxOffset_Y", Float) = 0
        _MinScale_X("MinScale_X", Float) = 0
        _MaxScale_X("MaxScale_X", Float) = 0
        _MinScale_Y("MinScale_Y", Float) = 0
        _MaxScale_Y("MaxScale_Y", Float) = 0
        [Toggle(_XZORXY_ON)] _XZorXY("XZorXY", Float) = 0
        [Toggle(_WORLDZY_ON)] _WorldZY("WorldZY", Float) = 0
        [Toggle(_GAMEPLAYORENVIRO_ON)] _GameplayOrEnviro("GameplayOrEnviro", Float) = 1
        _ErosionValue("ErosionValue", Float) = 0.31
        [Toggle(_WORLDPOSORSEED_ON)] _WorldPosOrSeed("WorldPosOrSeed", Float) = 0
        _Seed("Seed", Int) = 0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}


        [HideInInspector] _DrawOrder("Draw Order", Range(-50, 50)) = 0
        [HideInInspector][Enum(Depth Bias, 0, View Bias, 1)] _DecalMeshBiasType("DecalMesh BiasType", Float) = 0

        [HideInInspector] _DecalMeshDepthBias("DecalMesh DepthBias", Float) = 0
        [HideInInspector] _DecalMeshViewBias("DecalMesh ViewBias", Float) = 0

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

        [HideInInspector] _DecalAngleFadeSupported("Decal Angle Fade Supported", Float) = 1
    }

    SubShader
    {
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "PreviewType"="Plane" "DisableBatching"="LODFading" "ShaderGraphShader"="true" "ShaderGraphTargetId"="UniversalDecalSubTarget" }

		HLSLINCLUDE
		#pragma target 3.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
		ENDHLSL

		
        Pass
        {
			
            Name "DBufferProjector"
            Tags { "LightMode"="DBufferProjector" }

			Cull Front
			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off
			ColorMask RGBA
			ColorMask RGBA 1
			ColorMask RGBA 2

            HLSLPROGRAM

		    #define _MATERIAL_AFFECTS_ALBEDO 1
		    #define _MATERIAL_AFFECTS_NORMAL 1
		    #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
		    #define DECAL_ANGLE_FADE 1
		    #define _MATERIAL_AFFECTS_EMISSION 1
		    #define ASE_SRP_VERSION 140010


		    #pragma exclude_renderers glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _FOVEATED_RENDERING_NON_UNIFORM_RASTER
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DBUFFER_PROJECTOR

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES2
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            #if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
            #endif
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                #else
                    surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord1.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord2 = screenPos;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord3.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord.xy = inputMesh.ase_texcoord1.xy;
				packedOutput.ase_texcoord.zw = inputMesh.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord1.zw = 0;
				packedOutput.ase_texcoord3.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				OUTPUT_DBUFFER(outDBuffer)
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif


				#if UNITY_REVERSED_Z
					float depth = LoadSceneDepth(packedInput.positionCS.xy);
				#else
					float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
				#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);


				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);
				DecalSurfaceData surfaceData;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = worldNormal;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (texCoord1*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (texCoord2*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord1.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = texCoord0 * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( worldTangent.x, worldBitangent.x, worldNormal.x );
				float3 tanToWorld1 = float3( worldTangent.y, worldBitangent.y, worldNormal.y );
				float3 tanToWorld2 = float3( worldTangent.z, worldBitangent.z, worldNormal.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord3.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = texCoord1 * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = texCoord0 * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, worldNormal, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				GetSurfaceData(surfaceDescription, angleFadeFactor, surfaceData);
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif

			}
            ENDHLSL
        }

		
        Pass
        {
			
            Name "DecalProjectorForwardEmissive"
            Tags { "LightMode"="DecalProjectorForwardEmissive" }

			Cull Front
			Blend 0 SrcAlpha One
			ZTest Greater
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_FORWARD_EMISSIVE_PROJECTOR

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


			struct SurfaceDescription
			{
				float Alpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            #if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
            #endif
			CBUFFER_END

			sampler2D _tex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
                	surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out half4 outEmissive : SV_Target0
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if UNITY_REVERSED_Z
					float depth = LoadSceneDepth(packedInput.positionCS.xy);
				#else
					float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
				#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);

				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);
				DecalSurfaceData surfaceData;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				float2 texCoord11 = texCoord1 * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = texCoord0 * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				

				surfaceDescription.Alpha = staticSwitch83.a;

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData( surfaceDescription, angleFadeFactor, surfaceData);

				outEmissive.rgb = surfaceData.emissive;
				outEmissive.a = surfaceData.baseColor.a;

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif
			}
            ENDHLSL
        }

		
        Pass
        {
			
            Name "DecalScreenSpaceProjector"
            Tags { "LightMode"="DecalScreenSpaceProjector" }

			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile_fragment _ _FOVEATED_RENDERING_NON_UNIFORM_RASTER
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES2
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 viewDirectionWS : TEXCOORD1;
				float2 staticLightmapUV : TEXCOORD2;
				float2 dynamicLightmapUV : TEXCOORD3;
				float3 sh : TEXCOORD4;
				float4 fogFactorAndVertexLight : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            #if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
            #endif
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
                	surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                #else
                    surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;
				inputData.shadowCoord = float4(0, 0, 0, 0);

				inputData.fogCoord = half(input.fogFactorAndVertexLight.x);
				inputData.vertexLighting = half3(input.fogFactorAndVertexLight.yzw);

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
				#endif

				#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV && LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV;
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord7.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord8 = screenPos;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord9.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord6.xy = inputMesh.ase_texcoord1.xy;
				packedOutput.ase_texcoord6.zw = inputMesh.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord7.zw = 0;
				packedOutput.ase_texcoord9.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);

				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif
				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh.xyz =  float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out half4 outColor : SV_Target0
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if UNITY_REVERSED_Z
					float depth = LoadSceneDepth(packedInput.positionCS.xy);
				#else
					float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
				#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);

				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = worldNormal;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (texCoord1*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (texCoord2*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord7.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = texCoord0 * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( worldTangent.x, worldBitangent.x, worldNormal.x );
				float3 tanToWorld1 = float3( worldTangent.y, worldBitangent.y, worldNormal.y );
				float3 tanToWorld2 = float3( worldTangent.z, worldBitangent.z, worldNormal.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord9.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = texCoord1 * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = texCoord0 * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, worldNormal, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;
				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData( surfaceDescription, angleFadeFactor, surfaceData);

				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

				InputData inputData;
				InitializeInputData( packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				half4 color = UniversalFragmentPBR(inputData, surface);
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				outColor = color;

               #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
               positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
               #endif

			}
			ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalGBufferProjector"
            Tags { "LightMode"="DecalGBufferProjector" }

			Cull Front
			Blend 0 SrcAlpha OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha
			Blend 3 SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off
			ColorMask RGB
			ColorMask 0 1
			ColorMask RGB 2
			ColorMask RGB 3

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_PROJECTOR

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES2
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 viewDirectionWS : TEXCOORD1;
				float2 staticLightmapUV : TEXCOORD2;
				float2 dynamicLightmapUV : TEXCOORD3;
				float3 sh : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
            #if defined(DECAL_ANGLE_FADE)
			float _DecalAngleFadeSupported;
            #endif
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(SurfaceDescription surfaceDescription, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                #else
                    surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;

				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = float4(input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = half3(input.fogFactorAndVertexLight.yzw);
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
				#endif

				#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV && LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV;
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord6.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord7 = screenPos;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord8.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord5.xy = inputMesh.ase_texcoord1.xy;
				packedOutput.ase_texcoord5.zw = inputMesh.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord6.zw = 0;
				packedOutput.ase_texcoord8.w = 0;

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh = float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out FragmentOutput fragmentOutput
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if UNITY_REVERSED_Z
					float depth = LoadSceneDepth(packedInput.positionCS.xy);
				#else
					float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, LoadSceneDepth(packedInput.positionCS.xy));
				#endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;

				float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);

				float3 positionDS = TransformWorldToObject(positionWS);
				positionDS = positionDS * float3(1.0, -1.0, 1.0);

				float clipValue = 0.5 - Max3(abs(positionDS).x, abs(positionDS).y, abs(positionDS).z);
				clip(clipValue);

				float2 texCoord = positionDS.xz + float2(0.5, 0.5);

				float4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
				float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
				float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
				texCoord.xy = texCoord.xy * scale + offset;

				float2 texCoord0 = texCoord;
				float2 texCoord1 = texCoord;
				float2 texCoord2 = texCoord;
				float2 texCoord3 = texCoord;

				float3 worldTangent = TransformObjectToWorldDir(float3(1, 0, 0));
				float3 worldNormal = TransformObjectToWorldDir(float3(0, 1, 0));
				float3 worldBitangent = TransformObjectToWorldDir(float3(0, 0, 1));

				#ifdef DECAL_ANGLE_FADE
					half2 angleFade = half2(normalToWorld[1][3], normalToWorld[2][3]);

					if (angleFade.y < 0.0f)
					{
						half3 decalNormal = half3(normalToWorld[0].z, normalToWorld[1].z, normalToWorld[2].z);
						half dotAngle = dot(normalWS, decalNormal);
						angleFadeFactor = saturate(angleFade.x + angleFade.y * (dotAngle * (dotAngle - 2.0)));
					}
				#endif

				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);
				DecalSurfaceData surfaceData;

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = worldNormal;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (texCoord1*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (texCoord2*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord6.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord7;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = texCoord0 * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( worldTangent.x, worldBitangent.x, worldNormal.x );
				float3 tanToWorld1 = float3( worldTangent.y, worldBitangent.y, worldNormal.y );
				float3 tanToWorld2 = float3( worldTangent.z, worldBitangent.z, worldNormal.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord8.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = texCoord1 * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = texCoord0 * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, worldNormal, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion =1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(surfaceDescription, angleFadeFactor, surfaceData);

				InputData inputData;
				InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				BRDFData brdfData;
				InitializeBRDFData(surface.albedo, surface.metallic, 0, surface.smoothness, surface.alpha, brdfData);

				#ifdef _MATERIAL_AFFECTS_ALBEDO
					#ifdef DECAL_RECONSTRUCT_NORMAL
						half3 normalGI = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
					#else
						half3 normalGI = surfaceData.normalWS.xyz;
					#endif

					Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
					MixRealtimeAndBakedGI(mainLight, normalGI, inputData.bakedGI, inputData.shadowMask);
					half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surface.occlusion, normalGI, inputData.viewDirectionWS);
				#else
					half3 color = 0;
				#endif

				half3 packedNormalWS = PackNormal(surfaceData.normalWS.xyz);
				fragmentOutput.GBuffer0 = half4(surfaceData.baseColor.rgb, surfaceData.baseColor.a);
				fragmentOutput.GBuffer1 = 0;
				fragmentOutput.GBuffer2 = half4(packedNormalWS, surfaceData.normalWS.a);
				fragmentOutput.GBuffer3 = half4(surfaceData.emissive + color, surfaceData.baseColor.a);

				#if OUTPUT_SHADOWMASK
					fragmentOutput.GBuffer4 = inputData.shadowMask;
				#endif

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif

			}
            ENDHLSL
        }

		
        Pass
        {
            
			Name "DBufferMesh"
            Tags { "LightMode"="DBufferMesh" }

			Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			ColorMask RGBA
			ColorMask RGBA 1
			ColorMask 0 2

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DBUFFER_MESH

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
            #include "../HLSL/HLSL_GraffitiDecal.hlsl"
            #define ASE_NEEDS_VERT_NORMAL
            #define ASE_NEEDS_VERT_TANGENT
            #define ASE_NEEDS_VERT_POSITION
            #pragma shader_feature_local _GAMEPLAYORENVIRO_ON
            #pragma shader_feature_local _WORLDPOSORSEED_ON
            #pragma shader_feature_local _WORLDZY_ON
            #pragma shader_feature_local _XZORXY_ON
            #pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
            #pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
			};

			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
                #ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    float sgn = input.tangentWS.w;
                    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

                    surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                #else
                    surfaceData.normalWS.xyz = half3(input.normalWS);
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
            #if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
            #else
				input.positionCS.z += _DecalMeshDepthBias;
            #endif
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.uv1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord5.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord6 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				float ase_vertexTangentSign = inputMesh.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				packedOutput.ase_texcoord7.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord8.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord4.xy = inputMesh.uv1.xy;
				packedOutput.ase_texcoord4.zw = inputMesh.uv2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord5.zw = 0;
				packedOutput.ase_texcoord7.w = 0;
				packedOutput.ase_texcoord8.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);

				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionWS.xyz =  positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				OUTPUT_DBUFFER(outDBuffer)
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;
				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = packedInput.normalWS;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (packedInput.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (packedInput.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord5.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = packedInput.positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = packedInput.texCoord0.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 ase_worldBitangent = packedInput.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( packedInput.tangentWS.xyz.x, ase_worldBitangent.x, packedInput.normalWS.x );
				float3 tanToWorld1 = float3( packedInput.tangentWS.xyz.y, ase_worldBitangent.y, packedInput.normalWS.y );
				float3 tanToWorld2 = float3( packedInput.tangentWS.xyz.z, ase_worldBitangent.z, packedInput.normalWS.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord8.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = packedInput.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.texCoord0.xy * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( packedInput.positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, packedInput.normalWS, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);
				ENCODE_INTO_DBUFFER(surfaceData, outDBuffer);

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif
			}

            ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalMeshForwardEmissive"
            Tags { "LightMode"="DecalMeshForwardEmissive" }

			Blend 0 SrcAlpha One
			ZTest LEqual
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation

			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_FORWARD_EMISSIVE_MESH

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

            struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(SurfaceDescription surfaceDescription, float4 positionCS, out DecalSurfaceData surfaceData)
            {
                #ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
            #if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
            #else
				input.positionCS.z += _DecalMeshDepthBias;
            #endif
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.uv1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord5.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord6 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				float ase_vertexTangentSign = inputMesh.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				packedOutput.ase_texcoord7.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord8.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord4.xy = inputMesh.uv1.xy;
				packedOutput.ase_texcoord4.zw = inputMesh.uv2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord5.zw = 0;
				packedOutput.ase_texcoord7.w = 0;
				packedOutput.ase_texcoord8.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				packedOutput.positionWS.xyz = positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out half4 outEmissive : SV_Target0
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;
				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(1.0, 1.0, 1.0);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = packedInput.normalWS;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (packedInput.ase_texcoord4.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (packedInput.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord5.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = packedInput.positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = packedInput.texCoord0.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 ase_worldBitangent = packedInput.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( packedInput.tangentWS.xyz.x, ase_worldBitangent.x, packedInput.normalWS.x );
				float3 tanToWorld1 = float3( packedInput.tangentWS.xyz.y, ase_worldBitangent.y, packedInput.normalWS.y );
				float3 tanToWorld2 = float3( packedInput.tangentWS.xyz.z, ase_worldBitangent.z, packedInput.normalWS.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord8.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = packedInput.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.texCoord0.xy * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( packedInput.positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, packedInput.normalWS, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(surfaceDescription, packedInput.positionCS, surfaceData);

				outEmissive.rgb = surfaceData.emissive;
				outEmissive.a = surfaceData.baseColor.a;

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif

			}
            ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalScreenSpaceMesh"
            Tags { "LightMode"="DecalScreenSpaceMesh" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_MESH

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


            struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

            struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float3 viewDirectionWS : TEXCOORD4;
				float2 staticLightmapUV : TEXCOORD5;
				float2 dynamicLightmapUV : TEXCOORD6;
				float3 sh : TEXCOORD7;
				float4 fogFactorAndVertexLight : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				float4 ase_texcoord12 : TEXCOORD12;
				float4 ase_texcoord13 : TEXCOORD13;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
                #ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    float sgn = input.tangentWS.w;
                    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

                    surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                #else
                    surfaceData.normalWS.xyz = half3(input.normalWS);
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }


            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
            #if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
            #else
				input.positionCS.z += _DecalMeshDepthBias;
            #endif
			}

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;

				inputData.shadowCoord = float4(0, 0, 0, 0);

				#ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
					inputData.fogCoord = half(input.fogFactorAndVertexLight.x);
					inputData.vertexLighting = half3(input.fogFactorAndVertexLight.yzw);
				#endif

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
				#endif

				#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV && LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV;
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.uv1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord10.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord11 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				float ase_vertexTangentSign = inputMesh.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				packedOutput.ase_texcoord12.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord13.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord9.xy = inputMesh.uv1.xy;
				packedOutput.ase_texcoord9.zw = inputMesh.uv2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord10.zw = 0;
				packedOutput.ase_texcoord12.w = 0;
				packedOutput.ase_texcoord13.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);
				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
					fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif

				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				packedOutput.positionWS.xyz = positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh = float3(SampleSHVertex(half3(normalWS)));
				#endif

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
						out half4 outColor : SV_Target0
						
					)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

				#if defined(DECAL_RECONSTRUCT_NORMAL)
					#if defined(_DECAL_NORMAL_BLEND_HIGH)
						half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
					#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
						half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
					#else
						half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
					#endif
				#elif defined(DECAL_LOAD_NORMAL)
					half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
				#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;
				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = packedInput.normalWS;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (packedInput.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (packedInput.ase_texcoord9.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord10.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = packedInput.positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord11;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = packedInput.texCoord0.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 ase_worldBitangent = packedInput.ase_texcoord12.xyz;
				float3 tanToWorld0 = float3( packedInput.tangentWS.xyz.x, ase_worldBitangent.x, packedInput.normalWS.x );
				float3 tanToWorld1 = float3( packedInput.tangentWS.xyz.y, ase_worldBitangent.y, packedInput.normalWS.y );
				float3 tanToWorld2 = float3( packedInput.tangentWS.xyz.z, ase_worldBitangent.z, packedInput.normalWS.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord13.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = packedInput.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.texCoord0.xy * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( packedInput.positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, packedInput.normalWS, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);

				#ifdef DECAL_RECONSTRUCT_NORMAL
					surfaceData.normalWS.xyz = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
				#endif

				InputData inputData;
				InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				half4 color = UniversalFragmentPBR(inputData, surface);
				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				outColor = color;

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif

			}
            ENDHLSL
        }

		
        Pass
        {
            
			Name "DecalGBufferMesh"
            Tags { "LightMode"="DecalGBufferMesh" }

			Blend 0 SrcAlpha OneMinusSrcAlpha
			Blend 1 SrcAlpha OneMinusSrcAlpha
			Blend 2 SrcAlpha OneMinusSrcAlpha
			Blend 3 SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ColorMask RGB
			ColorMask 0 1
			ColorMask RGB 2
			ColorMask RGB 3

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex Vert
			#pragma fragment Frag
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma editor_sync_compilation

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
			#pragma multi_compile _ _DECAL_LAYERS
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_MESH

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
				float NormalAlpha;
				float Metallic;
				float Occlusion;
				float Smoothness;
				float MAOSAlpha;
				float3 Emission;
			};

            struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2;
				float4 texCoord0 : TEXCOORD3;
				float3 viewDirectionWS : TEXCOORD4;
				float2 staticLightmapUV : TEXCOORD5;
				float2 dynamicLightmapUV : TEXCOORD6;
				float3 sh : TEXCOORD7;
				float4 fogFactorAndVertexLight : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_texcoord10 : TEXCOORD10;
				float4 ase_texcoord11 : TEXCOORD11;
				float4 ase_texcoord12 : TEXCOORD12;
				float4 ase_texcoord13 : TEXCOORD13;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            void GetSurfaceData(PackedVaryings input, SurfaceDescription surfaceDescription, out DecalSurfaceData surfaceData)
            {
				#ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade( input.positionCS );
                #endif

                half fadeFactor = half(1.0);

                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);

                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceData.emissive.rgb = half3(surfaceDescription.Emission.rgb * fadeFactor);
				#endif

                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);

                #if defined(_MATERIAL_AFFECTS_NORMAL)
                    float sgn = input.tangentWS.w;
                    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

                    surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                #else
                    surfaceData.normalWS.xyz = half3(input.normalWS);
                #endif

                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceData.metallic = half(surfaceDescription.Metallic);
					surfaceData.occlusion = half(surfaceDescription.Occlusion);
					surfaceData.smoothness = half(surfaceDescription.Smoothness);
					surfaceData.MAOSAlpha = half(surfaceDescription.MAOSAlpha * fadeFactor);
				#endif
            }

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			void MeshDecalsPositionZBias(inout PackedVaryings input)
			{
            #if UNITY_REVERSED_Z
				input.positionCS.z -= _DecalMeshDepthBias;
            #else
				input.positionCS.z += _DecalMeshDepthBias;
            #endif
			}

			void InitializeInputData(PackedVaryings input, float3 positionWS, half3 normalWS, half3 viewDirectionWS, out InputData inputData)
			{
				inputData = (InputData)0;

				inputData.positionWS = positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = viewDirectionWS;

				inputData.shadowCoord = float4(0, 0, 0, 0);

				inputData.fogCoord = half(input.fogFactorAndVertexLight.x);
				inputData.vertexLighting = half3(input.fogFactorAndVertexLight.yzw);

				#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, half3(input.sh), normalWS);
				#elif defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, half3(input.sh), normalWS);
				#endif

				#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV)
					inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
				#endif

				#if defined(DEBUG_DISPLAY)
					#if defined(VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV) && defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(VARYINGS_NEED_STATIC_LIGHTMAP_UV && LIGHTMAP_ON)
						inputData.staticLightmapUV = input.staticLightmapUV;
					#elif defined(VARYINGS_NEED_SH)
						inputData.vertexSH = input.sh;
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
			}

			void GetSurface(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData)
			{
				surfaceData.albedo = decalSurfaceData.baseColor.rgb;
				surfaceData.metallic = saturate(decalSurfaceData.metallic);
				surfaceData.specular = 0;
				surfaceData.smoothness = saturate(decalSurfaceData.smoothness);
				surfaceData.occlusion = decalSurfaceData.occlusion;
				surfaceData.emission = decalSurfaceData.emissive;
				surfaceData.alpha = saturate(decalSurfaceData.baseColor.w);
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;
			}

			PackedVaryings Vert(Attributes inputMesh  )
			{
				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_VIEW_BIAS)
				{
					float3 viewDirectionOS = GetObjectSpaceNormalizeViewDir(inputMesh.positionOS);
					inputMesh.positionOS += viewDirectionOS * (_DecalMeshViewBias);
				}

				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float2 texCoord2_g69 = inputMesh.uv1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord10.xy = vertexToFrag10_g69;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord11 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				float ase_vertexTangentSign = inputMesh.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				packedOutput.ase_texcoord12.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord13.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord9.xy = inputMesh.uv1.xy;
				packedOutput.ase_texcoord9.zw = inputMesh.uv2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord10.zw = 0;
				packedOutput.ase_texcoord12.w = 0;
				packedOutput.ase_texcoord13.w = 0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(inputMesh.positionOS.xyz);

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				if (_DecalMeshBiasType == DECALMESHDEPTHBIASTYPE_DEPTH_BIAS)
				{
					MeshDecalsPositionZBias(packedOutput);
				}

				packedOutput.positionWS.xyz = positionWS;
				packedOutput.normalWS.xyz =  normalWS;
				packedOutput.tangentWS.xyzw =  tangentWS;
				packedOutput.texCoord0.xyzw =  inputMesh.uv0;
				packedOutput.viewDirectionWS.xyz =  GetWorldSpaceViewDir(positionWS);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(inputMesh.uv1, unity_LightmapST, packedOutput.staticLightmapUV);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					packedOutput.dynamicLightmapUV.xy = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					packedOutput.sh.xyz =  float3(SampleSHVertex(half3(normalWS)));
				#endif

				half fogFactor = 0;
				#if !defined(_FOG_FRAGMENT)
						fogFactor = ComputeFogFactor(packedOutput.positionCS.z);
				#endif

				half3 vertexLight = VertexLighting(positionWS, normalWS);
				packedOutput.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out FragmentOutput fragmentOutput
				
			)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
				UNITY_SETUP_INSTANCE_ID(packedInput);

				half angleFadeFactor = 1.0;

            #ifdef _DECAL_LAYERS
            #ifdef _RENDER_PASS_ENABLED
				uint surfaceRenderingLayer = DecodeMeshRenderingLayer(LOAD_FRAMEBUFFER_INPUT(GBUFFER4, packedInput.positionCS.xy).r);
            #else
				uint surfaceRenderingLayer = LoadSceneRenderingLayer(packedInput.positionCS.xy);
            #endif
				uint projectorRenderingLayer = uint(UNITY_ACCESS_INSTANCED_PROP(Decal, _DecalLayerMaskFromDecal));
				clip((surfaceRenderingLayer & projectorRenderingLayer) - 0.1);
            #endif

			#if defined(DECAL_RECONSTRUCT_NORMAL)
				#if defined(_DECAL_NORMAL_BLEND_HIGH)
					half3 normalWS = half3(ReconstructNormalTap9(packedInput.positionCS.xy));
				#elif defined(_DECAL_NORMAL_BLEND_MEDIUM)
					half3 normalWS = half3(ReconstructNormalTap5(packedInput.positionCS.xy));
				#else
					half3 normalWS = half3(ReconstructNormalDerivative(packedInput.positionCS.xy));
				#endif
			#elif defined(DECAL_LOAD_NORMAL)
				half3 normalWS = half3(LoadSceneNormals(packedInput.positionCS.xy));
			#endif

				float2 positionSS = packedInput.positionCS.xy * _ScreenSize.zw;
				float3 positionWS = packedInput.positionWS.xyz;
				half3 viewDirectionWS = half3(packedInput.viewDirectionWS);

				DecalSurfaceData surfaceData;
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 temp_output_71_0_g87 = packedInput.normalWS;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (packedInput.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (packedInput.ase_texcoord9.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord10.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g130 = packedInput.positionWS;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord11;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = packedInput.texCoord0.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 ase_worldBitangent = packedInput.ase_texcoord12.xyz;
				float3 tanToWorld0 = float3( packedInput.tangentWS.xyz.x, ase_worldBitangent.x, packedInput.normalWS.x );
				float3 tanToWorld1 = float3( packedInput.tangentWS.xyz.y, ase_worldBitangent.y, packedInput.normalWS.y );
				float3 tanToWorld2 = float3( packedInput.tangentWS.xyz.z, ase_worldBitangent.z, packedInput.normalWS.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord13.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = packedInput.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.texCoord0.xy * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( packedInput.positionWS / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, packedInput.normalWS, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				surfaceDescription.BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = 1;

				#if defined( _MATERIAL_AFFECTS_MAOS )
					surfaceDescription.Metallic = 0;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.MAOSAlpha = 1;
				#endif

				#if defined( _MATERIAL_AFFECTS_EMISSION )
					surfaceDescription.Emission = float3(0, 0, 0);
				#endif

				GetSurfaceData(packedInput, surfaceDescription, surfaceData);

				InputData inputData;
				InitializeInputData(packedInput, positionWS, surfaceData.normalWS.xyz, viewDirectionWS, inputData);

				SurfaceData surface = (SurfaceData)0;
				GetSurface(surfaceData, surface);

				BRDFData brdfData;
				InitializeBRDFData(surface.albedo, surface.metallic, 0, surface.smoothness, surface.alpha, brdfData);

				#ifdef _MATERIAL_AFFECTS_ALBEDO
					#ifdef DECAL_RECONSTRUCT_NORMAL
						half3 normalGI = normalize(lerp(normalWS.xyz, surfaceData.normalWS.xyz, surfaceData.normalWS.w));
					#else
						half3 normalGI = surfaceData.normalWS.xyz;
					#endif

					Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
					MixRealtimeAndBakedGI(mainLight, normalGI, inputData.bakedGI, inputData.shadowMask);
					half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surface.occlusion, normalGI, inputData.viewDirectionWS);
				#else
					half3 color = 0;
				#endif

				half3 packedNormalWS = PackNormal(surfaceData.normalWS.xyz);
				fragmentOutput.GBuffer0 = half4(surfaceData.baseColor.rgb, surfaceData.baseColor.a);
				fragmentOutput.GBuffer1 = 0;
				fragmentOutput.GBuffer2 = half4(packedNormalWS, surfaceData.normalWS.a);
				fragmentOutput.GBuffer3 = half4(surfaceData.emissive + color, surfaceData.baseColor.a);

				#if OUTPUT_SHADOWMASK
					fragmentOutput.GBuffer4 = inputData.shadowMask;
				#endif

                #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                positionSS = RemapFoveatedRenderingDistortCS(packedInput.positionCS.xy, true) * _ScreenSize.zw;
                #endif

			}

            ENDHLSL
        }

		
        Pass
        {
            
			Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

            Cull Back

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define _MATERIAL_AFFECTS_EMISSION 1
			#define ASE_SRP_VERSION 140010


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma multi_compile_instancing
			#pragma editor_sync_compilation
			#pragma vertex Vert
			#pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"

            #define HAVE_MESH_MODIFICATION

            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1

			#ifdef SCENEPICKINGPASS
			float4 _SelectionID;
			#endif
			#if _RENDER_PASS_ENABLED
			#define GBUFFER3 0
			#define GBUFFER4 1
			FRAMEBUFFER_INPUT_HALF(GBUFFER3);
			FRAMEBUFFER_INPUT_HALF(GBUFFER4);
			#endif

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float2 _ShadowPatternDensity;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowTex_Pow;
			float _WorldPosDiv;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
			CBUFFER_END

			sampler2D _BumpNormal;
			sampler2D _tex;
			sampler2D _ShadowTex;
			UNITY_INSTANCING_BUFFER_START(SHR_DecalMaster2)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _tex_ST)
				UNITY_DEFINE_INSTANCED_PROP(int, _Seed)
				UNITY_DEFINE_INSTANCED_PROP(int, _NumGraffiti)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasCols)
				UNITY_DEFINE_INSTANCED_PROP(int, _AtlasRows)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxScale_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxRotation)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_X)
				UNITY_DEFINE_INSTANCED_PROP(float, _MinOffset_Y)
				UNITY_DEFINE_INSTANCED_PROP(float, _MaxOffset_Y)
			UNITY_INSTANCING_BUFFER_END(SHR_DecalMaster2)


			
			float4 URPDecodeInstruction19_g87(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBilinear( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV, unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        float4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP( LM_NAME, LM_SAMPLER, LM_EXTRA_ARGS ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        illuminance = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			
			float4 SampleLightmapHD11_g69( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g69(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = SRGBToLinear(color);
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			
			half4 CalculateShadowMask1_g128( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsLambertMask14x( float3 WorldPosition, float2 ScreenUV, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#if defined(_ADDITIONAL_LIGHTS)
					#define SUM_LIGHT(Light)\
						half3 AttLightColor = Light.color * ( Light.distanceAttenuation * Light.shadowAttenuation );\
						Color += LightingLambert( AttLightColor, Light.direction, WorldNormal );
					InputData inputData = (InputData)0;
					inputData.normalizedScreenSpaceUV = ScreenUV;
					inputData.positionWS = WorldPosition;
					uint meshRenderingLayers = GetMeshRenderingLayer();
					uint pixelLightCount = GetAdditionalLightsCount();	
					#if USE_FORWARD_PLUS
					for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
					{
						FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					}
					#endif
					
					LIGHT_LOOP_BEGIN( pixelLightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#ifdef _LIGHT_LAYERS
						if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
						#endif
						{
							SUM_LIGHT( light );
						}
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
					float2 voronoihash73_g127( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g127( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash73_g127( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 //		if( d<F1 ) {
						 //			F2 = F1;
						 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
						 //		} else if( d<F2 ) {
						 //			F2 = d;
						
						 //		}
						 	}
						}
						return F1;
					}
			
			inline float4 TriplanarSampling81_g127( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
            #define DECAL_PROJECTOR
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_MESH
            #endif

            #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DBUFFER_MESH)
            #define DECAL_DBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH)
            #define DECAL_SCREEN_SPACE
            #endif

            #if (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
            #define DECAL_GBUFFER
            #endif

            #if (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_MESH)
            #define DECAL_FORWARD_EMISSIVE
            #endif

            #if ((!defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_ALBEDO)) || (defined(_MATERIAL_AFFECTS_NORMAL) && defined(_MATERIAL_AFFECTS_NORMAL_BLEND))) && (defined(DECAL_SCREEN_SPACE) || defined(DECAL_GBUFFER))
            #define DECAL_RECONSTRUCT_NORMAL
            #elif defined(DECAL_ANGLE_FADE)
            #define DECAL_LOAD_NORMAL
            #endif

            #ifdef _DECAL_LAYERS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareRenderingLayerTexture.hlsl"
            #endif

            #if defined(DECAL_LOAD_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
            #endif

            #if defined(DECAL_PROJECTOR) || defined(DECAL_RECONSTRUCT_NORMAL)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #endif

            #ifdef DECAL_MESH
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DecalMeshBiasTypeEnum.cs.hlsl"
            #endif

            #ifdef DECAL_RECONSTRUCT_NORMAL
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NormalReconstruction.hlsl"
            #endif

            #if defined(_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #endif

			PackedVaryings Vert(Attributes inputMesh  )
			{
				PackedVaryings packedOutput;
				ZERO_INITIALIZE(PackedVaryings, packedOutput);

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, packedOutput);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(packedOutput);

				inputMesh.tangentOS = float4( 1, 0, 0, -1 );
				inputMesh.normalOS = float3( 0, 1, 0 );

				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				packedOutput.ase_texcoord.xyz = ase_worldNormal;
				float2 texCoord2_g69 = inputMesh.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g69 = ( ( texCoord2_g69 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				packedOutput.ase_texcoord2.xy = vertexToFrag10_g69;
				float3 ase_worldPos = TransformObjectToWorld( (inputMesh.positionOS).xyz );
				packedOutput.ase_texcoord3.xyz = ase_worldPos;
				float4 ase_clipPos = TransformObjectToHClip((inputMesh.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				packedOutput.ase_texcoord4 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				packedOutput.ase_texcoord5.xyz = ase_worldTangent;
				float ase_vertexTangentSign = inputMesh.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				packedOutput.ase_texcoord6.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				packedOutput.ase_texcoord7.xyz = objectSpaceLightDir;
				
				packedOutput.ase_texcoord1.xy = inputMesh.ase_texcoord1.xy;
				packedOutput.ase_texcoord1.zw = inputMesh.ase_texcoord2.xy;
				packedOutput.ase_texcoord2.zw = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord.w = 0;
				packedOutput.ase_texcoord3.w = 0;
				packedOutput.ase_texcoord5.w = 0;
				packedOutput.ase_texcoord6.w = 0;
				packedOutput.ase_texcoord7.w = 0;

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out float4 outColor : SV_Target0
				
			)
			{
				Gradient gradient30_g127 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float localSampleLightmapBilinear153_g87 = ( 0.0 );
				float3 ase_worldNormal = packedInput.ase_texcoord.xyz;
				float3 temp_output_71_0_g87 = ase_worldNormal;
				float3 normalWS67_g87 = temp_output_71_0_g87;
				float3 normalWS153_g87 = normalWS67_g87;
				float3 backNormalWS170_g87 = ( temp_output_71_0_g87 * float3( -1,-1,-1 ) );
				float3 backNormalWS153_g87 = backNormalWS170_g87;
				float2 staticUV55_g87 = (packedInput.ase_texcoord1.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 staticUV153_g87 = staticUV55_g87;
				float2 dynamicUV62_g87 = (packedInput.ase_texcoord1.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 dynamicUV153_g87 = dynamicUV62_g87;
				float3 bakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting153_g87 = float3( 0,0,0 );
				float4 localURPDecodeInstruction19_g87 = URPDecodeInstruction19_g87();
				float4 decodeInstructions101_g87 = localURPDecodeInstruction19_g87;
				float4 decodeInstructions153_g87 = decodeInstructions101_g87;
				float localSampleDirectionBilinear188_g87 = ( 0.0 );
				float2 staticUV188_g87 = staticUV55_g87;
				float2 dynamicUV188_g87 = dynamicUV62_g87;
				float4 staticDir188_g87 = float4( 0,0,0,0 );
				float4 dynamicDir188_g87 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_EXTRA_ARGS staticUV188_g87, unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_EXTRA_ARGS staticUV188_g87
				        #endif
				        dynamicDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( LM_IND_NAME, LM_SAMPLER, LM_EXTRA_ARGS );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        staticDir188_g87 = SAMPLE_TEXTURE2D_LIGHTMAP( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV188_g87 );
				    #endif
				#endif
				}
				float4 staticDir153_g87 = staticDir188_g87;
				float4 dynamicDir153_g87 = dynamicDir188_g87;
				SampleLightmapBilinear( normalWS153_g87 , backNormalWS153_g87 , staticUV153_g87 , dynamicUV153_g87 , bakeDiffuseLighting153_g87 , backBakeDiffuseLighting153_g87 , decodeInstructions153_g87 , staticDir153_g87 , dynamicDir153_g87 );
				float2 vertexToFrag10_g69 = packedInput.ase_texcoord2.xy;
				float2 UV11_g69 = vertexToFrag10_g69;
				float4 localSampleLightmapHD11_g69 = SampleLightmapHD11_g69( UV11_g69 );
				float4 localURPDecodeInstruction19_g69 = URPDecodeInstruction19_g69();
				float3 decodeLightMap6_g69 = DecodeLightmap(localSampleLightmapHD11_g69,localURPDecodeInstruction19_g69);
				float3 decodeLightMap131 = DecodeLightmap(float4( bakeDiffuseLighting153_g87 , 0.0 ),float4( decodeLightMap6_g69 , 0.0 ));
				float3 Lightmaps28_g127 = decodeLightMap131;
				float3 clampResult14_g127 = clamp( (( Lightmaps28_g127 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 ase_worldPos = packedInput.ase_texcoord3.xyz;
				float3 worldPosValue44_g130 = ase_worldPos;
				float3 WorldPosition86_g130 = worldPosValue44_g130;
				float4 screenPos = packedInput.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g130 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g130 = ScreenUV75_g130;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_BumpNormal_ST);
				float2 uv_BumpNormal = packedInput.ase_texcoord2.zw * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack55_g127 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g127.z = lerp( 1, unpack55_g127.z, saturate(_NormalScale) );
				float3 ase_worldTangent = packedInput.ase_texcoord5.xyz;
				float3 ase_worldBitangent = packedInput.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal44_g127 = unpack55_g127;
				float3 worldNormal44_g127 = normalize( float3(dot(tanToWorld0,tanNormal44_g127), dot(tanToWorld1,tanNormal44_g127), dot(tanToWorld2,tanNormal44_g127)) );
				float3 worldNormal43_g127 = worldNormal44_g127;
				float3 worldNormalValue50_g130 = worldNormal43_g127;
				float3 WorldNormal86_g130 = worldNormalValue50_g130;
				half2 LightmapUV1_g128 = Lightmaps28_g127.xy;
				half4 localCalculateShadowMask1_g128 = CalculateShadowMask1_g128( LightmapUV1_g128 );
				float4 shadowMaskValue33_g130 = localCalculateShadowMask1_g128;
				float4 ShadowMask86_g130 = shadowMaskValue33_g130;
				float3 localAdditionalLightsLambertMask14x86_g130 = AdditionalLightsLambertMask14x( WorldPosition86_g130 , ScreenUV86_g130 , WorldNormal86_g130 , ShadowMask86_g130 );
				float3 lambertResult38_g130 = localAdditionalLightsLambertMask14x86_g130;
				float3 break19_g127 = lambertResult38_g130;
				float3 mainLight52_g127 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g127 = mainLight52_g127;
				float temp_output_36_0_g127 = ( max( max( break19_g127.x , break19_g127.y ) , break19_g127.z ) + max( max( break9_g127.x , break9_g127.y ) , break9_g127.z ) );
				float3 objectSpaceLightDir = packedInput.ase_texcoord7.xyz;
				float dotResult3_g127 = dot( worldNormal43_g127 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g127 = ( temp_output_36_0_g127 + ( (dotResult3_g127*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g127 ) );
				float2 texCoord11 = packedInput.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.ase_texcoord2.zw * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
				float2 uv25 = texCoord11;
				float4 transform78 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 break27 = transform78;
				float2 appendResult74 = (float2(break27.x , break27.z));
				float2 appendResult28 = (float2(break27.x , break27.y));
				#ifdef _XZORXY_ON
				float2 staticSwitch70 = appendResult28;
				#else
				float2 staticSwitch70 = appendResult74;
				#endif
				float2 appendResult76 = (float2(break27.z , break27.y));
				#ifdef _WORLDZY_ON
				float2 staticSwitch73 = appendResult76;
				#else
				float2 staticSwitch73 = staticSwitch70;
				#endif
				float2 WorldSeed2D92 = ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier );
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_4 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_4;
				#else
				float2 staticSwitch105 = round( ( WorldSeed2D92 * 1000.0 ) );
				#endif
				float2 seed2D25 = staticSwitch105;
				sampler2D tex25 = _tex;
				int _NumGraffiti_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_NumGraffiti);
				float NumGraffiti25 = (float)_NumGraffiti_Instance;
				int _AtlasCols_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasCols);
				float AtlasCols25 = (float)_AtlasCols_Instance;
				int _AtlasRows_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_AtlasRows);
				float AtlasRows25 = (float)_AtlasRows_Instance;
				float _MinScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_X);
				float MinScaleX25 = _MinScale_X_Instance;
				float _MaxScale_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_X);
				float MaxScaleX25 = _MaxScale_X_Instance;
				float _MinScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinScale_Y);
				float MinScaleY25 = _MinScale_Y_Instance;
				float _MaxScale_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxScale_Y);
				float MaxScaleY25 = _MaxScale_Y_Instance;
				float _MinRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinRotation);
				float MinRota25 = _MinRotation_Instance;
				float _MaxRotation_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxRotation);
				float MaxRota25 = _MaxRotation_Instance;
				float _MinOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_X);
				float MinOffsetX25 = _MinOffset_X_Instance;
				float _MaxOffset_X_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_X);
				float MaxOffsetX25 = _MaxOffset_X_Instance;
				float _MinOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MinOffset_Y);
				float MinOffsetY25 = _MinOffset_Y_Instance;
				float _MaxOffset_Y_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_MaxOffset_Y);
				float MaxOffsetY25 = _MaxOffset_Y_Instance;
				float4 localSampleGraffitis25 = SampleGraffitis( uv25 , seed2D25 , tex25 , NumGraffiti25 , AtlasCols25 , AtlasRows25 , MinScaleX25 , MaxScaleX25 , MinScaleY25 , MaxScaleY25 , MinRota25 , MaxRota25 , MinOffsetX25 , MaxOffsetX25 , MinOffsetY25 , MaxOffsetY25 );
				#ifdef _GAMEPLAYORENVIRO_ON
				float4 staticSwitch83 = localSampleGraffitis25;
				#else
				float4 staticSwitch83 = ( smoothstepResult84 * tex2D( _tex, uv_tex ) );
				#endif
				float4 temp_output_107_0_g127 = staticSwitch83;
				float3 hsvTorgb58_g127 = RGBToHSV( temp_output_107_0_g127.rgb );
				float3 hsvTorgb57_g127 = HSVToRGB( float3(hsvTorgb58_g127.x,hsvTorgb58_g127.y,( hsvTorgb58_g127.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g127 = temp_output_24_0_g127;
				float3 clampResult61_g127 = clamp( (( ( Lightmaps28_g127 + RealtimeLights34_g127 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g127 = 0.0;
				float2 voronoiSmoothId73_g127 = 0;
				float voronoiSmooth73_g127 = 0.0;
				float2 texCoord70_g127 = packedInput.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g127 = ( texCoord70_g127 * _ShadowPatternDensity );
				float2 coords73_g127 = temp_output_72_0_g127 * 1.0;
				float2 id73_g127 = 0;
				float2 uv73_g127 = 0;
				float voroi73_g127 = voronoi73_g127( coords73_g127, time73_g127, id73_g127, uv73_g127, voronoiSmooth73_g127, voronoiSmoothId73_g127 );
				float2 temp_cast_12 = (voroi73_g127).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g127 = half2(0,0);
				#else
				float2 staticSwitch74_g127 = temp_cast_12;
				#endif
				float2 temp_cast_13 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g127 = ( ase_worldPos / _WorldPosDiv );
				float3 break92_g127 = temp_output_93_0_g127;
				float2 appendResult91_g127 = (float2(break92_g127.x , break92_g127.z));
				float4 triplanar81_g127 = TriplanarSampling81_g127( _ShadowTex, temp_output_93_0_g127, ase_worldNormal, 1.0, ( appendResult91_g127 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g127 = triplanar81_g127;
				#else
				float4 staticSwitch82_g127 = tex2D( _ShadowTex, temp_output_72_0_g127 );
				#endif
				float4 temp_cast_16 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g127 = pow( staticSwitch82_g127 , temp_cast_16 );
				#else
				float4 staticSwitch69_g127 = float4( pow( staticSwitch74_g127 , temp_cast_13 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g127 = smoothstep( clampResult61_g127.x , staticSwitch69_g127.r , 1.0);
				float4 lerpResult96_g127 = lerp( float4( hsvTorgb57_g127 , 0.0 ) , temp_output_107_0_g127 , smoothstepResult98_g127);
				

				float3 BaseColor = ( ( SampleGradient( gradient30_g127, clampResult14_g127.x ) + SampleGradient( gradient30_g127, temp_output_24_0_g127 ) ) * lerpResult96_g127 ).rgb;

				outColor = _SelectionID;
			}
			ENDHLSL
        }
    }
	CustomEditor "UnityEditor.Rendering.Universal.DecalShaderGraphGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;99;-3873.972,-6.698559;Inherit;False;533.1865;277;Tex;2;22;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-3881.484,-638.1755;Inherit;False;1907.109;420.5435;WorldSeed;13;79;60;21;73;26;70;27;76;74;28;78;77;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectScaleNode;81;-1915.582,-179.8933;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;89;-1028.107,-465.7858;Inherit;True;Property;_TextureSample0;Texture Sample 0;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;96;-1230.449,-453.7798;Inherit;False;94;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.BreakToComponentsNode;27;-3616.456,-536.5723;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;76;-3436.327,-403.2784;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;74;-3442.209,-588.1755;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-3436.792,-496.4156;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;78;-3831.484,-537.6157;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;82;-1727.115,-158.5629;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;87;-1326.109,-753.4496;Inherit;True;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;22;-3823.972,43.30145;Inherit;True;Property;_tex;tex;29;0;Create;True;0;0;0;False;0;False;e0f0197ff3bc4454ca6cdb2f9fd73d47;e0f0197ff3bc4454ca6cdb2f9fd73d47;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-3582.786,58.72379;Inherit;False;MainTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.OneMinusNode;91;-1044.364,-754.1238;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;25;-948.1661,-141.418;Float;False;return tex2D(tex, uv)@;4;File;16;True;uv;FLOAT2;0,0;In;;Inherit;False;True;seed2D;FLOAT2;0,0;In;;Inherit;False;True;tex;SAMPLER2D;_Sampler210;In;;Inherit;False;True;NumGraffiti;FLOAT;0;In;;Inherit;False;True;AtlasCols;FLOAT;0;In;;Inherit;False;True;AtlasRows;FLOAT;0;In;;Inherit;False;True;MinScaleX;FLOAT;0;In;;Inherit;False;True;MaxScaleX;FLOAT;0;In;;Inherit;False;True;MinScaleY;FLOAT;0;In;;Inherit;False;True;MaxScaleY;FLOAT;0;In;;Inherit;False;True;MinRota;FLOAT;0;In;;Inherit;False;True;MaxRota;FLOAT;0;In;;Inherit;False;True;MinOffsetX;FLOAT;0;In;;Inherit;False;True;MaxOffsetX;FLOAT;0;In;;Inherit;False;True;MinOffsetY;FLOAT;0;In;;Inherit;False;True;MaxOffsetY;FLOAT;0;In;;Inherit;False;SampleGraffitis;False;False;0;6471f0035b765b445a9787e379b162a0;False;16;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;SAMPLER2D;_Sampler210;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2077.571,-19.36152;Inherit;False;92;WorldSeed2D;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1870.198,-9.180033;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-1237.999,-109.2999;Inherit;False;94;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2118.785,90.69466;Inherit;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;0;False;0;False;1000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;104;-1706.385,-28.7053;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;105;-1548.261,48.34949;Inherit;False;Property;_WorldPosOrSeed;WorldPosOrSeed;49;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;106;-1785.995,116.816;Inherit;False;InstancedProperty;_Seed;Seed;50;0;Create;True;0;0;0;False;0;False;0;0;True;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;24;-1252.572,-39.18608;Inherit;False;InstancedProperty;_NumGraffiti;NumGraffiti;34;0;Create;True;0;0;0;False;0;False;0;0;True;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;13;-1231.261,33.07231;Inherit;False;InstancedProperty;_AtlasCols;AtlasCols;30;0;Create;True;0;0;0;False;0;False;4;0;True;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;14;-1232.644,93.98862;Inherit;False;InstancedProperty;_AtlasRows;AtlasRows;31;0;Create;True;0;0;0;False;0;False;4;0;True;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1259.677,153.8611;Inherit;False;InstancedProperty;_MinScale_X;MinScale_X;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1262.143,216.1942;Inherit;False;InstancedProperty;_MaxScale_X;MaxScale_X;42;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1271.276,271.1944;Inherit;False;InstancedProperty;_MinScale_Y;MinScale_Y;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1266.41,337.9943;Inherit;False;InstancedProperty;_MaxScale_Y;MaxScale_Y;44;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1269.213,399.1853;Inherit;False;InstancedProperty;_MinRotation;MinRotation;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1269.468,465.7492;Inherit;False;InstancedProperty;_MaxRotation;MaxRotation;33;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1272.041,531.3686;Inherit;False;InstancedProperty;_MinOffset_X;MinOffset_X;37;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1277.263,603.62;Inherit;False;InstancedProperty;_MaxOffset_X;MaxOffset_X;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1276.026,671.6688;Inherit;False;InstancedProperty;_MinOffset_Y;MinOffset_Y;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1282.248,738.3778;Inherit;False;InstancedProperty;_MaxOffset_Y;MaxOffset_Y;40;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferProjector;0;0;DBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;True;1;False;;False;False;False;True;True;True;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DBufferProjector;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;119;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalProjectorForwardEmissive;0;1;DecalProjectorForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalProjectorForwardEmissive;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferProjector;0;3;DecalGBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;True;1;False;;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalGBufferProjector;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;122;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferMesh;0;4;DBufferMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;True;False;False;False;False;0;False;;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DBufferMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;123;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalMeshForwardEmissive;0;5;DecalMeshForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalMeshForwardEmissive;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;124;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceMesh;0;6;DecalScreenSpaceMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalScreenSpaceMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;125;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferMesh;0;7;DecalGBufferMesh;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;False;False;True;1;LightMode=DecalGBufferMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;126;475.4376,-167.9221;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;1;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;ScenePickingPass;0;8;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.StaticSwitch;70;-3286.855,-586.7281;Inherit;False;Property;_XZorXY;XZorXY;45;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;73;-3058.162,-422.8963;Inherit;False;Property;_WorldZY;WorldZY;46;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2996.35,-330.2986;Inherit;False;Property;_SeedScale;SeedScale;36;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2812.533,-424.1779;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2824.735,-330.5619;Inherit;False;Property;_SeedMultiplier;SeedMultiplier;35;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;79;-2636.729,-424.4957;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2510.351,-351.9987;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-2203.359,-353.2826;Inherit;False;WorldSeed2D;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;84;-716.836,-764.0854;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1238.601,-561.306;Inherit;False;Constant;_ErosionSmoothness;ErosionSmoothness;19;0;Create;True;0;0;0;False;0;False;1.64;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-909.3278,-592.5407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1116.047,-683.9438;Inherit;False;Property;_ErosionValue;ErosionValue;48;0;Create;True;0;0;0;False;0;False;0.31;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-503.9245,-471.4211;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;120;616.3772,-138.4951;Float;False;True;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;SHR_DecalMaster2;c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceProjector;0;2;DecalScreenSpaceProjector;9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalScreenSpaceProjector;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;7;Affect BaseColor;1;0;Affect Normal;1;0;Blend;1;0;Affect MAOS;0;638852459575395217;Affect Emission;1;638852471223580018;Support LOD CrossFade;0;0;Angle Fade;1;0;0;9;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.StaticSwitch;83;-95.12553,-160.7692;Inherit;False;Property;_GameplayOrEnviro;GameplayOrEnviro;47;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;138;303.9811,-245.3996;Inherit;False;SHF_CelShading;0;;127;93dbdbe8226a5044aa915b6ef7341db4;0;2;146;FLOAT3;0,0,0;False;107;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;215.4015,-29.32458;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DecodeLightmapHlpNode;131;182.3362,-445.4998;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;140;-63.03555,-343.5732;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1555.982,-242.066;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;132;-182.1428,-525.5765;Inherit;False;FetchLightmapValue;27;;69;43de3d4ae59f645418fdd020d1b8e78e;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;135;-250.0635,-457.4008;Inherit;False;Sample Lightmap;24;;87;6976f0f966a01684ca0a6dde441141c2;6,209,0,195,0,196,0,238,0,191,0,249,0;2;71;FLOAT3;0,0,0;False;169;FLOAT3;0,0,0;False;2;FLOAT3;0;FLOAT3;178
Node;AmplifyShaderEditor.FunctionNode;130;-106.5422,-593.0087;Inherit;False;Lightmap UV;-1;;68;1940f027d0458684eb0ad486f669d7d5;1,1,0;0;1;FLOAT2;0
WireConnection;89;0;96;0
WireConnection;27;0;78;0
WireConnection;76;0;27;2
WireConnection;76;1;27;1
WireConnection;74;0;27;0
WireConnection;74;1;27;2
WireConnection;28;0;27;0
WireConnection;28;1;27;1
WireConnection;82;0;81;1
WireConnection;82;1;81;2
WireConnection;87;0;11;0
WireConnection;94;0;22;0
WireConnection;91;0;87;0
WireConnection;25;0;11;0
WireConnection;25;1;105;0
WireConnection;25;2;95;0
WireConnection;25;3;24;0
WireConnection;25;4;13;0
WireConnection;25;5;14;0
WireConnection;25;6;51;0
WireConnection;25;7;52;0
WireConnection;25;8;50;0
WireConnection;25;9;53;0
WireConnection;25;10;17;0
WireConnection;25;11;18;0
WireConnection;25;12;58;0
WireConnection;25;13;56;0
WireConnection;25;14;55;0
WireConnection;25;15;57;0
WireConnection;102;0;93;0
WireConnection;102;1;103;0
WireConnection;104;0;102;0
WireConnection;105;1;104;0
WireConnection;105;0;106;0
WireConnection;70;1;74;0
WireConnection;70;0;28;0
WireConnection;73;1;70;0
WireConnection;73;0;76;0
WireConnection;60;0;73;0
WireConnection;60;1;26;0
WireConnection;79;0;60;0
WireConnection;77;0;79;0
WireConnection;77;1;21;0
WireConnection;92;0;77;0
WireConnection;84;0;91;0
WireConnection;84;1;86;0
WireConnection;84;2;90;0
WireConnection;90;0;86;0
WireConnection;90;1;85;0
WireConnection;88;0;84;0
WireConnection;88;1;89;0
WireConnection;120;0;138;0
WireConnection;120;1;9;3
WireConnection;83;1;88;0
WireConnection;83;0;25;0
WireConnection;138;146;131;0
WireConnection;138;107;83;0
WireConnection;9;0;83;0
WireConnection;131;0;135;0
WireConnection;131;1;132;0
ASEEND*/
//CHKSM=578E238C4D98625D92740F877AD4CEFCB68F6535