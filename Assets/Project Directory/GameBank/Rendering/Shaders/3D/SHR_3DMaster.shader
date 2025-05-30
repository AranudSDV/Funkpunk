// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_3DMaster"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_TriplanarTiling("TriplanarTiling", Float) = 10
		_BlendPow("BlendPow", Range( 0 , 1)) = 1
		_OutlineWidth("Outline Width", Range( 0 , 0.1)) = 0.1
		_TimeDelay("TimeDelay", Float) = 0
		[Toggle(_DEBUG_ON)] _Debug("Debug", Float) = 0
		_DistanceCutoff("Distance Cutoff", Range( 0 , 100)) = 0
		_MainTex("Base Color", 2D) = "white" {}
		_BaseVertexOffsetValue("BaseVertexOffsetValue", Vector) = (0,0,0,0)
		_BumpNormal("BumpNormal", 2D) = "bump" {}
		_BaseVertexOffsetDelay("BaseVertexOffsetDelay", Vector) = (0,0,0,0)
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_TopMask("TopMask", Float) = 0
		[Toggle(_COLORORTEX_ON)] _ColorOrTex("ColorOrTex?", Float) = 1
		_BaseColor("BaseColor", Color) = (1,1,1,0)
		_TopVertexOffsetValue("TopVertexOffset Value", Vector) = (0,0,0,0)
		_TopVertexDelay("TopVertexDelay", Vector) = (0,0,0,0)
		_ShadingWhiteMult("ShadingWhiteMult", Float) = 0.1
		_Cels_FallOffThreshold("Cels_FallOffThreshold", Float) = 0.45
		_Shadow_FallOffThreshold("Shadow_FallOffThreshold", Float) = 0.45
		_Cels_LitThreshold("Cels_LitThreshold", Float) = 0.42
		_Shadow_LitThreshold("Shadow_LitThreshold", Float) = 0.42
		[Toggle(_FULLSHADINGHALFSHADING_ON)] _FullShadingHalfShading("FullShading/HalfShading", Float) = 0
		[Toggle(_BAKEDORRT_ON)] _BakedOrRT("BakedOrRT", Float) = 0
		[Toggle(_SHADOWS_PROCEDURALORTEXTURE_ON)] _Shadows_ProceduralOrTexture("Shadows_ProceduralOrTexture?", Float) = 0
		_ShadowPatternDensity("ShadowPatternDensity", Vector) = (10,10,0,0)
		[Toggle(_LIGHTINDDONE_ON)] _LightindDone("LightindDone?", Float) = 0
		[Toggle(_USING3DMOVEMENTS_ON)] _Using3DMovements("Using3DMovements?", Float) = 0
		_ShadowTex("ShadowTex", 2D) = "white" {}
		_WorldPosDiv("WorldPosDiv", Float) = 0
		[Toggle(_USINGTRIPLANAR_ON)] _UsingTriplanar("UsingTriplanar?", Float) = 0
		_ShadowTex_Pow("ShadowTex_Pow", Float) = 0.27
		_FresnelErase("FresnelErase", Float) = 0.01
		[Toggle(_ISENNEMIES_ON)] _IsEnnemies("IsEnnemies", Float) = 0
		_FresnelErase_Smoothness("FresnelErase_Smoothness", Float) = 1.5
		_FresnelPower("FresnelPower", Float) = 5
		[Toggle(_ISOUTLINE_ON)] _IsOutline("IsOutline", Float) = 0
		_BPM("BPM", Float) = 60
		[HDR]_OutlineColor("OutlineColor", Color) = (0.9937374,1.498039,0,0)
		[HDR]_OutlineColor2("OutlineColor2", Color) = (0.4558116,0,1.498039,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define ASE_SRP_VERSION 140010


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _ISENNEMIES_ON
			#pragma shader_feature _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;
			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTex;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
			
			float4 SampleLightmapHD11_g51( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g51(  )
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
			
			half4 CalculateShadowMask1_g49( half2 LightmapUV )
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
					float2 voronoihash275( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi275( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash275( n + g );
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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			
			inline float4 TriplanarSampling535( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				
				float2 texCoord2_g51 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g51 = ( ( texCoord2_g51 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.zw = vertexToFrag10_g51;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 5, 2, float4( 0.3207547, 0.3207547, 0.3207547, 0.1193713 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.3913939 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.616434 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.8767071 ), float4( 1, 1, 1, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g51 = IN.ase_texcoord8.zw;
				float2 UV11_g51 = vertexToFrag10_g51;
				float4 localSampleLightmapHD11_g51 = SampleLightmapHD11_g51( UV11_g51 );
				float4 localURPDecodeInstruction19_g51 = URPDecodeInstruction19_g51();
				float3 decodeLightMap6_g51 = DecodeLightmap(localSampleLightmapHD11_g51,localURPDecodeInstruction19_g51);
				float3 Lightmaps738 = decodeLightMap6_g51;
				float3 clampResult437 = clamp( (( Lightmaps738 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g46 = WorldPosition;
				float3 WorldPosition86_g46 = worldPosValue44_g46;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g46 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g46 = ScreenUV75_g46;
				float2 uv_BumpNormal = IN.ase_texcoord8.xy * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g46 = worldNormal209;
				float3 WorldNormal86_g46 = worldNormalValue50_g46;
				half2 LightmapUV1_g49 = Lightmaps738.xy;
				half4 localCalculateShadowMask1_g49 = CalculateShadowMask1_g49( LightmapUV1_g49 );
				float4 shadowMaskValue33_g46 = localCalculateShadowMask1_g49;
				float4 ShadowMask86_g46 = shadowMaskValue33_g46;
				float3 localAdditionalLightsLambertMask14x86_g46 = AdditionalLightsLambertMask14x( WorldPosition86_g46 , ScreenUV86_g46 , WorldNormal86_g46 , ShadowMask86_g46 );
				float3 lambertResult38_g46 = localAdditionalLightsLambertMask14x86_g46;
				float3 break190 = lambertResult38_g46;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 mainLight210 = ( ase_lightAtten * _MainLightColor.rgb );
				float3 break194 = mainLight210;
				float temp_output_328_0 = ( max( max( break190.x , break190.y ) , break190.z ) + max( max( break194.x , break194.y ) , break194.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult189 = dot( worldNormal209 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_423_0 = ( temp_output_328_0 + ( (dotResult189*_RT_SO.x + _RT_SO.y) * temp_output_328_0 ) );
				#ifdef _BAKEDORRT_ON
				float4 staticSwitch388 = SampleGradient( gradient203, temp_output_423_0 );
				#else
				float4 staticSwitch388 = SampleGradient( gradient203, clampResult437.x );
				#endif
				float4 CelShadingCalc736 = staticSwitch388;
				#ifdef _COLORORTEX_ON
				float4 staticSwitch219 = tex2DNode207;
				#else
				float4 staticSwitch219 = _BaseColor;
				#endif
				float3 hsvTorgb258 = RGBToHSV( staticSwitch219.rgb );
				float3 hsvTorgb257 = HSVToRGB( float3(hsvTorgb258.x,hsvTorgb258.y,( hsvTorgb258.z * _ShadingWhiteMult )) );
				float3 temp_cast_4 = (temp_output_423_0).xxx;
				#ifdef _BAKEDORRT_ON
				float3 staticSwitch379 = temp_cast_4;
				#else
				float3 staticSwitch379 = Lightmaps738;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time275 = 0.0;
				float2 voronoiSmoothId275 = 0;
				float voronoiSmooth275 = 0.0;
				float2 texCoord270 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_616_0 = ( texCoord270 * _ShadowPatternDensity );
				float2 coords275 = temp_output_616_0 * 1.0;
				float2 id275 = 0;
				float2 uv275 = 0;
				float voroi275 = voronoi275( coords275, time275, id275, uv275, voronoiSmooth275, voronoiSmoothId275 );
				float2 temp_cast_6 = (voroi275).xx;
				float3 objToWorld682 = mul( GetObjectToWorldMatrix(), float4( IN.ase_normal, 1 ) ).xyz;
				float3 temp_output_641_0 = abs( objToWorld682 );
				float2 temp_cast_7 = (_BlendPow).xx;
				float2 temp_output_648_0 = pow( (temp_output_641_0).yz , temp_cast_7 );
				float2 temp_cast_8 = (_BlendPow).xx;
				float2 temp_output_643_0 = pow( (temp_output_641_0).xz , temp_cast_8 );
				float2 temp_cast_9 = (_BlendPow).xx;
				float2 temp_output_647_0 = pow( (temp_output_641_0).xy , temp_cast_9 );
				float2 temp_output_654_0 = ( temp_output_648_0 + temp_output_643_0 + temp_output_647_0 );
				float3 temp_output_658_0 = ( WorldPosition * _TriplanarTiling );
				float2 uv653 = 0;
				float3 unityVoronoy653 = UnityVoronoi(IN.ase_texcoord8.xy,0.0,10.0,uv653);
				float2 ShadowDot_Triplanar754 = ( ( ( temp_output_648_0 / temp_output_654_0 ) * ( (temp_output_658_0).yz * unityVoronoy653.x ) ) + ( ( temp_output_643_0 / temp_output_654_0 ) * ( (temp_output_658_0).xz * unityVoronoy653.x ) ) + ( ( temp_output_647_0 / temp_output_654_0 ) * ( (temp_output_658_0).xy * unityVoronoy653.x ) ) );
				#ifdef _USINGTRIPLANAR_ON
				float2 staticSwitch629 = ShadowDot_Triplanar754;
				#else
				float2 staticSwitch629 = temp_cast_6;
				#endif
				float2 temp_cast_10 = (_ShadowTex_Pow).xx;
				float3 temp_output_547_0 = ( WorldPosition / _WorldPosDiv );
				float3 break556 = temp_output_547_0;
				float2 appendResult557 = (float2(break556.x , break556.z));
				float4 triplanar535 = TriplanarSampling535( _ShadowTex, temp_output_547_0, WorldNormal, 1.0, ( appendResult557 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch549 = triplanar535;
				#else
				float4 staticSwitch549 = tex2D( _ShadowTex, temp_output_616_0 );
				#endif
				float4 temp_cast_13 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = pow( staticSwitch549 , temp_cast_13 );
				#else
				float4 staticSwitch448 = float4( pow( staticSwitch629 , temp_cast_10 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , 1.0);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( CelShadingCalc736 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				float2 texCoord712 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float temp_output_784_0 = ( simplePerlin2D728 * simplePerlin2D785 );
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , temp_output_784_0);
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				#ifdef _DEBUG_ON
				float staticSwitch56_g55 = BPM;
				#else
				float staticSwitch56_g55 = 60.0;
				#endif
				float mulTime5_g55 = _TimeParameters.x * ( staticSwitch56_g55 / 60.0 );
				float temp_output_52_0_g55 = ( mulTime5_g55 - _TimeDelay );
				float temp_output_16_0_g55 = ( PI / 1.0 );
				float temp_output_19_0_g55 = cos( ( temp_output_52_0_g55 * temp_output_16_0_g55 ) );
				float saferPower20_g55 = abs( abs( temp_output_19_0_g55 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g55 , 20.0 ));
				float fresnelNdotV707 = dot( worldNormal209, WorldViewDirection );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * temp_output_784_0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = staticSwitch480;
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				
				float3 temp_cast_16 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch753.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_16;
				float Metallic = 0;
				float Smoothness = 0.0;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.clipPos, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif				
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;
				o.clipPosV = clipPos;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask R
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _ISENNEMIES_ON
			#pragma shader_feature _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;
			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTex;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
			
			float4 SampleLightmapHD11_g51( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g51(  )
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
			
			half4 CalculateShadowMask1_g49( half2 LightmapUV )
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
					float2 voronoihash275( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi275( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash275( n + g );
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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			
			inline float4 TriplanarSampling535( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.texcoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				
				float2 texCoord2_g51 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g51 = ( ( texCoord2_g51 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord4.zw = vertexToFrag10_g51;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord6.xyz = ase_worldTangent;
				o.ase_texcoord7.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord8.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.w = 0;
				o.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(v.vertex.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
					o.VizUV = float4(VizUV, 0, 0);
					o.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord4.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 5, 2, float4( 0.3207547, 0.3207547, 0.3207547, 0.1193713 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.3913939 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.616434 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.8767071 ), float4( 1, 1, 1, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g51 = IN.ase_texcoord4.zw;
				float2 UV11_g51 = vertexToFrag10_g51;
				float4 localSampleLightmapHD11_g51 = SampleLightmapHD11_g51( UV11_g51 );
				float4 localURPDecodeInstruction19_g51 = URPDecodeInstruction19_g51();
				float3 decodeLightMap6_g51 = DecodeLightmap(localSampleLightmapHD11_g51,localURPDecodeInstruction19_g51);
				float3 Lightmaps738 = decodeLightMap6_g51;
				float3 clampResult437 = clamp( (( Lightmaps738 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g46 = WorldPosition;
				float3 WorldPosition86_g46 = worldPosValue44_g46;
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g46 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g46 = ScreenUV75_g46;
				float2 uv_BumpNormal = IN.ase_texcoord4.xy * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 ase_worldTangent = IN.ase_texcoord6.xyz;
				float3 ase_worldNormal = IN.ase_texcoord7.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord8.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g46 = worldNormal209;
				float3 WorldNormal86_g46 = worldNormalValue50_g46;
				half2 LightmapUV1_g49 = Lightmaps738.xy;
				half4 localCalculateShadowMask1_g49 = CalculateShadowMask1_g49( LightmapUV1_g49 );
				float4 shadowMaskValue33_g46 = localCalculateShadowMask1_g49;
				float4 ShadowMask86_g46 = shadowMaskValue33_g46;
				float3 localAdditionalLightsLambertMask14x86_g46 = AdditionalLightsLambertMask14x( WorldPosition86_g46 , ScreenUV86_g46 , WorldNormal86_g46 , ShadowMask86_g46 );
				float3 lambertResult38_g46 = localAdditionalLightsLambertMask14x86_g46;
				float3 break190 = lambertResult38_g46;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 mainLight210 = ( ase_lightAtten * _MainLightColor.rgb );
				float3 break194 = mainLight210;
				float temp_output_328_0 = ( max( max( break190.x , break190.y ) , break190.z ) + max( max( break194.x , break194.y ) , break194.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult189 = dot( worldNormal209 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_423_0 = ( temp_output_328_0 + ( (dotResult189*_RT_SO.x + _RT_SO.y) * temp_output_328_0 ) );
				#ifdef _BAKEDORRT_ON
				float4 staticSwitch388 = SampleGradient( gradient203, temp_output_423_0 );
				#else
				float4 staticSwitch388 = SampleGradient( gradient203, clampResult437.x );
				#endif
				float4 CelShadingCalc736 = staticSwitch388;
				#ifdef _COLORORTEX_ON
				float4 staticSwitch219 = tex2DNode207;
				#else
				float4 staticSwitch219 = _BaseColor;
				#endif
				float3 hsvTorgb258 = RGBToHSV( staticSwitch219.rgb );
				float3 hsvTorgb257 = HSVToRGB( float3(hsvTorgb258.x,hsvTorgb258.y,( hsvTorgb258.z * _ShadingWhiteMult )) );
				float3 temp_cast_4 = (temp_output_423_0).xxx;
				#ifdef _BAKEDORRT_ON
				float3 staticSwitch379 = temp_cast_4;
				#else
				float3 staticSwitch379 = Lightmaps738;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time275 = 0.0;
				float2 voronoiSmoothId275 = 0;
				float voronoiSmooth275 = 0.0;
				float2 texCoord270 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_616_0 = ( texCoord270 * _ShadowPatternDensity );
				float2 coords275 = temp_output_616_0 * 1.0;
				float2 id275 = 0;
				float2 uv275 = 0;
				float voroi275 = voronoi275( coords275, time275, id275, uv275, voronoiSmooth275, voronoiSmoothId275 );
				float2 temp_cast_6 = (voroi275).xx;
				float3 objToWorld682 = mul( GetObjectToWorldMatrix(), float4( IN.ase_normal, 1 ) ).xyz;
				float3 temp_output_641_0 = abs( objToWorld682 );
				float2 temp_cast_7 = (_BlendPow).xx;
				float2 temp_output_648_0 = pow( (temp_output_641_0).yz , temp_cast_7 );
				float2 temp_cast_8 = (_BlendPow).xx;
				float2 temp_output_643_0 = pow( (temp_output_641_0).xz , temp_cast_8 );
				float2 temp_cast_9 = (_BlendPow).xx;
				float2 temp_output_647_0 = pow( (temp_output_641_0).xy , temp_cast_9 );
				float2 temp_output_654_0 = ( temp_output_648_0 + temp_output_643_0 + temp_output_647_0 );
				float3 temp_output_658_0 = ( WorldPosition * _TriplanarTiling );
				float2 uv653 = 0;
				float3 unityVoronoy653 = UnityVoronoi(IN.ase_texcoord4.xy,0.0,10.0,uv653);
				float2 ShadowDot_Triplanar754 = ( ( ( temp_output_648_0 / temp_output_654_0 ) * ( (temp_output_658_0).yz * unityVoronoy653.x ) ) + ( ( temp_output_643_0 / temp_output_654_0 ) * ( (temp_output_658_0).xz * unityVoronoy653.x ) ) + ( ( temp_output_647_0 / temp_output_654_0 ) * ( (temp_output_658_0).xy * unityVoronoy653.x ) ) );
				#ifdef _USINGTRIPLANAR_ON
				float2 staticSwitch629 = ShadowDot_Triplanar754;
				#else
				float2 staticSwitch629 = temp_cast_6;
				#endif
				float2 temp_cast_10 = (_ShadowTex_Pow).xx;
				float3 temp_output_547_0 = ( WorldPosition / _WorldPosDiv );
				float3 break556 = temp_output_547_0;
				float2 appendResult557 = (float2(break556.x , break556.z));
				float4 triplanar535 = TriplanarSampling535( _ShadowTex, temp_output_547_0, ase_worldNormal, 1.0, ( appendResult557 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch549 = triplanar535;
				#else
				float4 staticSwitch549 = tex2D( _ShadowTex, temp_output_616_0 );
				#endif
				float4 temp_cast_13 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = pow( staticSwitch549 , temp_cast_13 );
				#else
				float4 staticSwitch448 = float4( pow( staticSwitch629 , temp_cast_10 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , 1.0);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( CelShadingCalc736 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				float2 texCoord712 = IN.ase_texcoord4.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord4.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float temp_output_784_0 = ( simplePerlin2D728 * simplePerlin2D785 );
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , temp_output_784_0);
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				#ifdef _DEBUG_ON
				float staticSwitch56_g55 = BPM;
				#else
				float staticSwitch56_g55 = 60.0;
				#endif
				float mulTime5_g55 = _TimeParameters.x * ( staticSwitch56_g55 / 60.0 );
				float temp_output_52_0_g55 = ( mulTime5_g55 - _TimeDelay );
				float temp_output_16_0_g55 = ( PI / 1.0 );
				float temp_output_19_0_g55 = cos( ( temp_output_52_0_g55 * temp_output_16_0_g55 ) );
				float saferPower20_g55 = abs( abs( temp_output_19_0_g55 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g55 , 20.0 ));
				float fresnelNdotV707 = dot( worldNormal209, ase_worldViewDir );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * temp_output_784_0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = staticSwitch480;
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				

				float3 BaseColor = staticSwitch753.rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = IN.VizUV.xy;
					metaInput.LightCoord = IN.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _ISENNEMIES_ON
			#pragma shader_feature _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;
			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTex;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
			
			float4 SampleLightmapHD11_g51( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g51(  )
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
			
			half4 CalculateShadowMask1_g49( half2 LightmapUV )
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
					float2 voronoihash275( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi275( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash275( n + g );
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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			
			inline float4 TriplanarSampling535( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				
				float2 texCoord2_g51 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g51 = ( ( texCoord2_g51 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord2.zw = vertexToFrag10_g51;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord7.xyz = objectSpaceLightDir;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 5, 2, float4( 0.3207547, 0.3207547, 0.3207547, 0.1193713 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.3913939 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.616434 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.8767071 ), float4( 1, 1, 1, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g51 = IN.ase_texcoord2.zw;
				float2 UV11_g51 = vertexToFrag10_g51;
				float4 localSampleLightmapHD11_g51 = SampleLightmapHD11_g51( UV11_g51 );
				float4 localURPDecodeInstruction19_g51 = URPDecodeInstruction19_g51();
				float3 decodeLightMap6_g51 = DecodeLightmap(localSampleLightmapHD11_g51,localURPDecodeInstruction19_g51);
				float3 Lightmaps738 = decodeLightMap6_g51;
				float3 clampResult437 = clamp( (( Lightmaps738 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g46 = WorldPosition;
				float3 WorldPosition86_g46 = worldPosValue44_g46;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g46 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g46 = ScreenUV75_g46;
				float2 uv_BumpNormal = IN.ase_texcoord2.xy * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g46 = worldNormal209;
				float3 WorldNormal86_g46 = worldNormalValue50_g46;
				half2 LightmapUV1_g49 = Lightmaps738.xy;
				half4 localCalculateShadowMask1_g49 = CalculateShadowMask1_g49( LightmapUV1_g49 );
				float4 shadowMaskValue33_g46 = localCalculateShadowMask1_g49;
				float4 ShadowMask86_g46 = shadowMaskValue33_g46;
				float3 localAdditionalLightsLambertMask14x86_g46 = AdditionalLightsLambertMask14x( WorldPosition86_g46 , ScreenUV86_g46 , WorldNormal86_g46 , ShadowMask86_g46 );
				float3 lambertResult38_g46 = localAdditionalLightsLambertMask14x86_g46;
				float3 break190 = lambertResult38_g46;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 mainLight210 = ( ase_lightAtten * _MainLightColor.rgb );
				float3 break194 = mainLight210;
				float temp_output_328_0 = ( max( max( break190.x , break190.y ) , break190.z ) + max( max( break194.x , break194.y ) , break194.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord7.xyz;
				float dotResult189 = dot( worldNormal209 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_423_0 = ( temp_output_328_0 + ( (dotResult189*_RT_SO.x + _RT_SO.y) * temp_output_328_0 ) );
				#ifdef _BAKEDORRT_ON
				float4 staticSwitch388 = SampleGradient( gradient203, temp_output_423_0 );
				#else
				float4 staticSwitch388 = SampleGradient( gradient203, clampResult437.x );
				#endif
				float4 CelShadingCalc736 = staticSwitch388;
				#ifdef _COLORORTEX_ON
				float4 staticSwitch219 = tex2DNode207;
				#else
				float4 staticSwitch219 = _BaseColor;
				#endif
				float3 hsvTorgb258 = RGBToHSV( staticSwitch219.rgb );
				float3 hsvTorgb257 = HSVToRGB( float3(hsvTorgb258.x,hsvTorgb258.y,( hsvTorgb258.z * _ShadingWhiteMult )) );
				float3 temp_cast_4 = (temp_output_423_0).xxx;
				#ifdef _BAKEDORRT_ON
				float3 staticSwitch379 = temp_cast_4;
				#else
				float3 staticSwitch379 = Lightmaps738;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time275 = 0.0;
				float2 voronoiSmoothId275 = 0;
				float voronoiSmooth275 = 0.0;
				float2 texCoord270 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_616_0 = ( texCoord270 * _ShadowPatternDensity );
				float2 coords275 = temp_output_616_0 * 1.0;
				float2 id275 = 0;
				float2 uv275 = 0;
				float voroi275 = voronoi275( coords275, time275, id275, uv275, voronoiSmooth275, voronoiSmoothId275 );
				float2 temp_cast_6 = (voroi275).xx;
				float3 objToWorld682 = mul( GetObjectToWorldMatrix(), float4( IN.ase_normal, 1 ) ).xyz;
				float3 temp_output_641_0 = abs( objToWorld682 );
				float2 temp_cast_7 = (_BlendPow).xx;
				float2 temp_output_648_0 = pow( (temp_output_641_0).yz , temp_cast_7 );
				float2 temp_cast_8 = (_BlendPow).xx;
				float2 temp_output_643_0 = pow( (temp_output_641_0).xz , temp_cast_8 );
				float2 temp_cast_9 = (_BlendPow).xx;
				float2 temp_output_647_0 = pow( (temp_output_641_0).xy , temp_cast_9 );
				float2 temp_output_654_0 = ( temp_output_648_0 + temp_output_643_0 + temp_output_647_0 );
				float3 temp_output_658_0 = ( WorldPosition * _TriplanarTiling );
				float2 uv653 = 0;
				float3 unityVoronoy653 = UnityVoronoi(IN.ase_texcoord2.xy,0.0,10.0,uv653);
				float2 ShadowDot_Triplanar754 = ( ( ( temp_output_648_0 / temp_output_654_0 ) * ( (temp_output_658_0).yz * unityVoronoy653.x ) ) + ( ( temp_output_643_0 / temp_output_654_0 ) * ( (temp_output_658_0).xz * unityVoronoy653.x ) ) + ( ( temp_output_647_0 / temp_output_654_0 ) * ( (temp_output_658_0).xy * unityVoronoy653.x ) ) );
				#ifdef _USINGTRIPLANAR_ON
				float2 staticSwitch629 = ShadowDot_Triplanar754;
				#else
				float2 staticSwitch629 = temp_cast_6;
				#endif
				float2 temp_cast_10 = (_ShadowTex_Pow).xx;
				float3 temp_output_547_0 = ( WorldPosition / _WorldPosDiv );
				float3 break556 = temp_output_547_0;
				float2 appendResult557 = (float2(break556.x , break556.z));
				float4 triplanar535 = TriplanarSampling535( _ShadowTex, temp_output_547_0, ase_worldNormal, 1.0, ( appendResult557 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch549 = triplanar535;
				#else
				float4 staticSwitch549 = tex2D( _ShadowTex, temp_output_616_0 );
				#endif
				float4 temp_cast_13 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = pow( staticSwitch549 , temp_cast_13 );
				#else
				float4 staticSwitch448 = float4( pow( staticSwitch629 , temp_cast_10 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , 1.0);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( CelShadingCalc736 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				float2 texCoord712 = IN.ase_texcoord2.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord2.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float temp_output_784_0 = ( simplePerlin2D728 * simplePerlin2D785 );
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , temp_output_784_0);
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				#ifdef _DEBUG_ON
				float staticSwitch56_g55 = BPM;
				#else
				float staticSwitch56_g55 = 60.0;
				#endif
				float mulTime5_g55 = _TimeParameters.x * ( staticSwitch56_g55 / 60.0 );
				float temp_output_52_0_g55 = ( mulTime5_g55 - _TimeDelay );
				float temp_output_16_0_g55 = ( PI / 1.0 );
				float temp_output_19_0_g55 = cos( ( temp_output_52_0_g55 * temp_output_16_0_g55 ) );
				float saferPower20_g55 = abs( abs( temp_output_19_0_g55 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g55 , 20.0 ));
				float fresnelNdotV707 = dot( worldNormal209, ase_worldViewDir );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * temp_output_784_0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = staticSwitch480;
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				

				float3 BaseColor = staticSwitch753.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 tangentWS = float4(TransformObjectToWorldDir( v.ase_tangent.xyz), v.ase_tangent.w);
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;
				o.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag(	VertexOutput IN
						, out half4 outNormalWS : SV_Target0
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = IN.worldNormal;
				float4 WorldTangent = IN.worldTangent;

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float3 Normal = float3(0, 0, 1);
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define ASE_SRP_VERSION 140010


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif
			
			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _ISENNEMIES_ON
			#pragma shader_feature _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON
			#pragma shader_feature_local _USINGTRIPLANAR_ON


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;
			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTex;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			
			
			float4 SampleLightmapHD11_g51( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g51(  )
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
			
			half4 CalculateShadowMask1_g49( half2 LightmapUV )
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
					float2 voronoihash275( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi275( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash275( n + g );
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
			
			inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
			{
				float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
				UV = frac( sin(mul(UV, m) ) * 46839.32 );
				return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
			}
			
			//x - Out y - Cells
			float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
			{
				float2 g = floor( UV * CellDensity );
				float2 f = frac( UV * CellDensity );
				float t = 8.0;
				float3 res = float3( 8.0, 0.0, 0.0 );
			
				for( int y = -1; y <= 1; y++ )
				{
					for( int x = -1; x <= 1; x++ )
					{
						float2 lattice = float2( x, y );
						float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
						float d = distance( lattice + offset, f );
			
						if( d < res.x )
						{
							mr = f - lattice - offset;
							res = float3( d, offset.x, offset.y );
						}
					}
				}
				return res;
			}
			
			inline float4 TriplanarSampling535( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				
				float2 texCoord2_g51 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g51 = ( ( texCoord2_g51 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.zw = vertexToFrag10_g51;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				o.fogFactorAndVertexLight = half4(0, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 5, 2, float4( 0.3207547, 0.3207547, 0.3207547, 0.1193713 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.3913939 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.616434 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.8767071 ), float4( 1, 1, 1, 1 ), 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g51 = IN.ase_texcoord8.zw;
				float2 UV11_g51 = vertexToFrag10_g51;
				float4 localSampleLightmapHD11_g51 = SampleLightmapHD11_g51( UV11_g51 );
				float4 localURPDecodeInstruction19_g51 = URPDecodeInstruction19_g51();
				float3 decodeLightMap6_g51 = DecodeLightmap(localSampleLightmapHD11_g51,localURPDecodeInstruction19_g51);
				float3 Lightmaps738 = decodeLightMap6_g51;
				float3 clampResult437 = clamp( (( Lightmaps738 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g46 = WorldPosition;
				float3 WorldPosition86_g46 = worldPosValue44_g46;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g46 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g46 = ScreenUV75_g46;
				float2 uv_BumpNormal = IN.ase_texcoord8.xy * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g46 = worldNormal209;
				float3 WorldNormal86_g46 = worldNormalValue50_g46;
				half2 LightmapUV1_g49 = Lightmaps738.xy;
				half4 localCalculateShadowMask1_g49 = CalculateShadowMask1_g49( LightmapUV1_g49 );
				float4 shadowMaskValue33_g46 = localCalculateShadowMask1_g49;
				float4 ShadowMask86_g46 = shadowMaskValue33_g46;
				float3 localAdditionalLightsLambertMask14x86_g46 = AdditionalLightsLambertMask14x( WorldPosition86_g46 , ScreenUV86_g46 , WorldNormal86_g46 , ShadowMask86_g46 );
				float3 lambertResult38_g46 = localAdditionalLightsLambertMask14x86_g46;
				float3 break190 = lambertResult38_g46;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 mainLight210 = ( ase_lightAtten * _MainLightColor.rgb );
				float3 break194 = mainLight210;
				float temp_output_328_0 = ( max( max( break190.x , break190.y ) , break190.z ) + max( max( break194.x , break194.y ) , break194.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult189 = dot( worldNormal209 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_423_0 = ( temp_output_328_0 + ( (dotResult189*_RT_SO.x + _RT_SO.y) * temp_output_328_0 ) );
				#ifdef _BAKEDORRT_ON
				float4 staticSwitch388 = SampleGradient( gradient203, temp_output_423_0 );
				#else
				float4 staticSwitch388 = SampleGradient( gradient203, clampResult437.x );
				#endif
				float4 CelShadingCalc736 = staticSwitch388;
				#ifdef _COLORORTEX_ON
				float4 staticSwitch219 = tex2DNode207;
				#else
				float4 staticSwitch219 = _BaseColor;
				#endif
				float3 hsvTorgb258 = RGBToHSV( staticSwitch219.rgb );
				float3 hsvTorgb257 = HSVToRGB( float3(hsvTorgb258.x,hsvTorgb258.y,( hsvTorgb258.z * _ShadingWhiteMult )) );
				float3 temp_cast_4 = (temp_output_423_0).xxx;
				#ifdef _BAKEDORRT_ON
				float3 staticSwitch379 = temp_cast_4;
				#else
				float3 staticSwitch379 = Lightmaps738;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time275 = 0.0;
				float2 voronoiSmoothId275 = 0;
				float voronoiSmooth275 = 0.0;
				float2 texCoord270 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_616_0 = ( texCoord270 * _ShadowPatternDensity );
				float2 coords275 = temp_output_616_0 * 1.0;
				float2 id275 = 0;
				float2 uv275 = 0;
				float voroi275 = voronoi275( coords275, time275, id275, uv275, voronoiSmooth275, voronoiSmoothId275 );
				float2 temp_cast_6 = (voroi275).xx;
				float3 objToWorld682 = mul( GetObjectToWorldMatrix(), float4( IN.ase_normal, 1 ) ).xyz;
				float3 temp_output_641_0 = abs( objToWorld682 );
				float2 temp_cast_7 = (_BlendPow).xx;
				float2 temp_output_648_0 = pow( (temp_output_641_0).yz , temp_cast_7 );
				float2 temp_cast_8 = (_BlendPow).xx;
				float2 temp_output_643_0 = pow( (temp_output_641_0).xz , temp_cast_8 );
				float2 temp_cast_9 = (_BlendPow).xx;
				float2 temp_output_647_0 = pow( (temp_output_641_0).xy , temp_cast_9 );
				float2 temp_output_654_0 = ( temp_output_648_0 + temp_output_643_0 + temp_output_647_0 );
				float3 temp_output_658_0 = ( WorldPosition * _TriplanarTiling );
				float2 uv653 = 0;
				float3 unityVoronoy653 = UnityVoronoi(IN.ase_texcoord8.xy,0.0,10.0,uv653);
				float2 ShadowDot_Triplanar754 = ( ( ( temp_output_648_0 / temp_output_654_0 ) * ( (temp_output_658_0).yz * unityVoronoy653.x ) ) + ( ( temp_output_643_0 / temp_output_654_0 ) * ( (temp_output_658_0).xz * unityVoronoy653.x ) ) + ( ( temp_output_647_0 / temp_output_654_0 ) * ( (temp_output_658_0).xy * unityVoronoy653.x ) ) );
				#ifdef _USINGTRIPLANAR_ON
				float2 staticSwitch629 = ShadowDot_Triplanar754;
				#else
				float2 staticSwitch629 = temp_cast_6;
				#endif
				float2 temp_cast_10 = (_ShadowTex_Pow).xx;
				float3 temp_output_547_0 = ( WorldPosition / _WorldPosDiv );
				float3 break556 = temp_output_547_0;
				float2 appendResult557 = (float2(break556.x , break556.z));
				float4 triplanar535 = TriplanarSampling535( _ShadowTex, temp_output_547_0, WorldNormal, 1.0, ( appendResult557 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch549 = triplanar535;
				#else
				float4 staticSwitch549 = tex2D( _ShadowTex, temp_output_616_0 );
				#endif
				float4 temp_cast_13 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = pow( staticSwitch549 , temp_cast_13 );
				#else
				float4 staticSwitch448 = float4( pow( staticSwitch629 , temp_cast_10 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , 1.0);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( CelShadingCalc736 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				float2 texCoord712 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float temp_output_784_0 = ( simplePerlin2D728 * simplePerlin2D785 );
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , temp_output_784_0);
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				#ifdef _DEBUG_ON
				float staticSwitch56_g55 = BPM;
				#else
				float staticSwitch56_g55 = 60.0;
				#endif
				float mulTime5_g55 = _TimeParameters.x * ( staticSwitch56_g55 / 60.0 );
				float temp_output_52_0_g55 = ( mulTime5_g55 - _TimeDelay );
				float temp_output_16_0_g55 = ( PI / 1.0 );
				float temp_output_19_0_g55 = cos( ( temp_output_52_0_g55 * temp_output_16_0_g55 ) );
				float saferPower20_g55 = abs( abs( temp_output_19_0_g55 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g55 , 20.0 ));
				float fresnelNdotV707 = dot( worldNormal209, WorldViewDirection );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * temp_output_784_0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = staticSwitch480;
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				
				float3 temp_cast_16 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch753.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_16;
				float Metallic = 0;
				float Smoothness = 0.0;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = IN.clipPos;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = WorldNormal;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( WorldViewDirection );

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#else
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
					#else
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(IN.clipPos,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData
				(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SPECULAR_SETUP 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature _DEBUG_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float4 _OutlineColor2;
			float4 _MainTex_ST;
			float4 _OutlineColor;
			float4 _BumpNormal_ST;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _FresnelErase_Smoothness;
			float _FresnelErase;
			float _WorldPosDiv;
			float _ShadowTex_Pow;
			float _TriplanarTiling;
			float _BlendPow;
			float _TopMask;
			float _Shadow_FallOffThreshold;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_LitThreshold;
			float _TimeDelay;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float BPM;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

					float2 voronoihash766( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi766( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash766( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						
						 		}
						 	}
						}
						return F1;
					}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				#ifdef _DEBUG_ON
				float staticSwitch56_g43 = BPM;
				#else
				float staticSwitch56_g43 = 60.0;
				#endif
				float mulTime5_g43 = _TimeParameters.x * ( staticSwitch56_g43 / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g40 = BPM;
				#else
				float staticSwitch56_g40 = 60.0;
				#endif
				float mulTime5_g40 = _TimeParameters.x * ( staticSwitch56_g40 / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g42 = BPM;
				#else
				float staticSwitch56_g42 = 60.0;
				#endif
				float mulTime5_g42 = _TimeParameters.x * ( staticSwitch56_g42 / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g41 = BPM;
				#else
				float staticSwitch56_g41 = 60.0;
				#endif
				float mulTime5_g41 = _TimeParameters.x * ( staticSwitch56_g41 / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				#ifdef _DEBUG_ON
				float staticSwitch56_g39 = BPM;
				#else
				float staticSwitch56_g39 = 60.0;
				#endif
				float mulTime5_g39 = _TimeParameters.x * ( staticSwitch56_g39 / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				float3 VertexOffset617 = appendResult485;
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = VertexOffset617;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				float mulTime769 = _TimeParameters.x * ( 60.0 / _BPM );
				float time766 = ( mulTime769 * 5.0 );
				float2 voronoiSmoothId766 = 0;
				float2 texCoord767 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 coords766 = texCoord767 * 10.0;
				float2 id766 = 0;
				float2 uv766 = 0;
				float voroi766 = voronoi766( coords766, time766, id766, uv766, 0, voronoiSmoothId766 );
				float4 unityObjectToClipPos759 = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float fresnelNdotV830 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode830 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV830, 5.0 ) );
				float lerpResult832 = lerp( ( 1.0 - fresnelNode830 ) , voroi766 , 0.8);
				float smoothstepResult834 = smoothstep( 0.19 , ( 0.19 + 0.0 ) , lerpResult832);
				float3 OutlineOffset781 = ( v.ase_normal * ( sin( mulTime769 ) * _OutlineWidth * voroi766 ) * min( unityObjectToClipPos759.w , _DistanceCutoff ) * smoothstepResult834 );
				#ifdef _ISOUTLINE_ON
				float3 staticSwitch750 = OutlineOffset781;
				#else
				float3 staticSwitch750 = staticSwitch534;
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch750;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;756;-4860.079,-2199.631;Inherit;False;2980.416;1045.208;;30;646;670;668;669;654;647;649;655;643;650;648;684;685;686;667;641;682;681;651;652;659;660;666;662;661;658;657;653;671;754;TriplnarDots;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;727;-340.0536,1843.382;Inherit;False;1548.022;755.4004;Fresnel;19;712;713;723;707;718;708;728;732;784;785;788;789;802;804;805;811;812;809;747;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;381;-4175.744,-5973.477;Inherit;False;1209;1283.536;;12;182;54;53;28;29;27;31;342;213;208;211;210;ShadingComponents;0.8509804,0.5254902,0.8373843,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;380;-235.5422,-2560.735;Inherit;False;2267.363;1540.534;;31;207;230;219;265;260;258;266;255;251;275;289;290;257;282;283;379;449;448;535;549;624;626;627;629;630;631;632;638;739;550;755;ShadowShading;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;302;-1567.303,-5023.179;Inherit;False;1827.19;1032.5;LitRT;24;193;190;188;186;191;194;189;202;201;246;185;56;184;187;203;196;248;183;192;328;423;430;445;446;CelShading;1,0.9921199,0.6635219,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-4125.743,-5569.686;Inherit;False;1109;303;;4;215;214;212;209;Normals;0.6117647,0.6408768,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;215;-4075.743,-5471.686;Inherit;False;Property;_NormalScale;Normal Scale;17;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;-3259.745,-5519.686;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;212;-3499.743,-5519.686;Inherit;True;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;28;-4125.528,-4873.606;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;29;-3888.506,-4994.391;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;27;-4118.154,-5047.598;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-3760.073,-4995.635;Inherit;True;VS_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TangentVertexDataNode;342;-3311.146,-5117.054;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;213;-4004.94,-5811.978;Inherit;True;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-3719.554,-5862.886;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-3541.881,-5865.397;Inherit;True;mainLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-3819.593,-5245.737;Inherit;False;_Normalmap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;53;-4109.979,-5246.665;Inherit;True;Property;_Normal;Normal;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;214;-3803.743,-5519.686;Inherit;True;Property;_BumpNormal;BumpNormal;15;0;Create;True;0;0;0;False;0;False;-1;None;d21bc8946882b8e4fbfde16f49086ec9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;211;-3991.821,-5922.761;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;257;1380.547,-2498.95;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;405;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;406;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;407;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;408;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;409;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;410;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;411;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;412;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RGBToHSVNode;258;379.5233,-2528.069;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;283;147.253,-1927.864;Inherit;False;Property;_Shadow_FallOffThreshold;Shadow_FallOffThreshold;27;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;478.8806,-2022.663;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;255;777.2276,-2022.238;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.12;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;290;1066.306,-2021.914;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;344;2735.627,-2783.301;Inherit;False;Constant;_PourPasBrulerLesYeux;PourPasBrulerLesYeux;14;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;481;-323.888,-327.3439;Inherit;False;2213.736;1069.384;;23;533;532;531;530;527;522;521;520;519;518;517;516;515;514;513;512;511;510;509;508;507;506;505;TopVertexOffset;1,0.3930817,0.6767163,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;482;-323.2193,771.636;Inherit;False;2323.009;1021.379;;20;529;504;503;502;501;500;499;498;497;496;495;494;493;492;491;490;489;488;487;486;BaseVertexOffset;0.6469972,0.2421383,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;515;1743.847,559.1142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;486;374.6719,1662.998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;487;717.6396,1571.776;Inherit;False;SHF_Beat;7;;39;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;1184.227,1656.681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;1532.257,1570.341;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;490;708.1767,1026.945;Inherit;False;SHF_Beat;7;;40;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WireNode;491;233.3878,1151.219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;492;369.1038,1364.655;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;1154.022,1096.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;494;1265.165,977.7419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;1374.327,1351.296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;496;336.3369,1169.427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;497;1408.824,1509.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;498;-61.12444,1307.637;Inherit;False;Property;_BaseVertexOffsetValue;BaseVertexOffsetValue;14;0;Create;True;0;0;0;False;0;False;0,0,0;0.2,0.2,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;1413.345,1073.862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;500;906.2154,1147.551;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;501;1141.001,1357.551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;502;672.3246,1262.38;Inherit;False;SHF_Beat;7;;41;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WireNode;503;-273.2193,1392.438;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;504;-60.83023,1500.93;Inherit;False;Property;_BaseVertexOffsetDelay;BaseVertexOffsetDelay;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;505;1226.088,162.4421;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;1470.883,254.7004;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;1101.653,577.5452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;732.3401,596.7429;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;964.5128,272.4106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;510;267.404,420.0134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;742.7531,396.9777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;512;974.9277,387.3762;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;513;1386.929,558.415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;680.885,52.69627;Inherit;False;Property;_TopMask;TopMask;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;517;911.8718,-203.8798;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;518;1073.493,-46.09374;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;519;526.616,-61.42362;Inherit;False;Property;_Float2;Float 2;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;520;662.7401,-277.3438;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;521;-24.16517,582.0414;Inherit;False;SHF_Beat;7;;42;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;522;-27.94916,235.8788;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;527;-19.06507,426.2802;Inherit;False;SHF_Beat;7;;43;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WireNode;529;1300.982,869.0081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;530;-273.8881,491.0836;Inherit;False;Property;_TopVertexDelay;TopVertexDelay;23;1;[Header];Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;531;343.547,472.687;Inherit;False;Property;_TopVertexOffsetValue;TopVertexOffset Value;22;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;514;1650.261,389.0531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;485;2143.432,524.8366;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;617;2311.111,525.059;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;248;-1269.215,-4367.004;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;189;-1156.514,-4620.081;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-1557.887,-4983.049;Inherit;True;209;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-1555.202,-4649.046;Inherit;True;209;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;185;-1557.216,-4443.177;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;56;-1559.287,-4289.143;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;184;-1559.638,-4112.861;Inherit;False;210;mainLight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;194;-1372.724,-4136.042;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;191;-1193.879,-4237.398;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;430;-925.8401,-4082.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;192;-872.6011,-4235.596;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;436;-1050.225,-5532.215;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.12;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;437;-762.8779,-5537.092;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;391;-922.9512,-5173.512;Inherit;False;1;0;OBJECT;;False;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;387;-46.55334,-5226.284;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;439;-1280.742,-5142.08;Inherit;False;Property;_Cels_LitThreshold;Cels_LitThreshold;28;0;Create;True;0;0;0;False;0;False;0.42;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-1309.587,-5394.454;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;443;-1654.609,-5272.139;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;187;-911.2591,-4614.499;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;445;-1115.424,-4506.981;Inherit;False;Constant;_RT_SO;RT_SO;17;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;440;-1579.952,-5143.151;Inherit;False;Property;_Cels_FallOffThreshold;Cels_FallOffThreshold;26;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;-543.3197,-4369.479;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;201;-1324.182,-4874.571;Inherit;False;SRP Additional Light;-1;;46;6c86746ad131a0a408ca599df5f40861;7,6,1,9,1,23,0,27,1,25,1,24,1,26,1;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;1;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;190;-1093.958,-4881.02;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;193;-882.1261,-4880.597;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;188;-667.8192,-4862.382;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-274.8864,-4395.413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;446;-380.0405,-4545.772;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;388;581.8553,-4973.622;Inherit;True;Property;_Keyword0;Keyword 0;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;379;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;203;-1220.971,-4975.521;Inherit;False;1;5;2;0.3207547,0.3207547,0.3207547,0.1193713;0.3962264,0.3962264,0.3962264,0.3913939;0.5031446,0.5031446,0.5031446,0.616434;0.6100628,0.6100628,0.6100628,0.8767071;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.ColorNode;230;-185.4629,-2468.674;Inherit;False;Property;_BaseColor;BaseColor;21;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;303;-374.4714,-1434.62;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;282;150.3929,-1866.381;Inherit;False;Property;_Shadow_LitThreshold;Shadow_LitThreshold;29;0;Create;True;0;0;0;False;0;False;0.42;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;419.7105,-2360.027;Inherit;False;Property;_ShadingWhiteMult;ShadingWhiteMult;24;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;880.8932,-2429.883;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;219;144.1347,-2307.798;Inherit;False;Property;_ColorOrTex;ColorOrTex?;19;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;266;1727.36,-2340.35;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;273;-1197.615,-390.1845;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-1443.25,-292.1817;Inherit;False;Property;_ShadowPatternRotator;ShadowPatternRotator;25;0;Create;True;0;0;0;False;0;False;12.48;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;533;-99.06578,-97.18044;Inherit;True;False;False;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;638;1168.761,-2192.733;Inherit;False;Constant;_Float0;Float 0;37;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;674;-5299.583,-459.8854;Inherit;False;Constant;_GuardOffset;GuardOffset;36;0;Create;True;0;0;0;False;0;False;0.001,0.001,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;675;-5088.969,-462.7442;Inherit;False;Tangent;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;676;-4875.636,-462.7442;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;680;-5408.047,-715.9072;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;289;1532.023,-2068.908;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;624;1019.294,-1670.5;Inherit;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;448;1286.504,-1663.733;Inherit;False;Property;_Shadows_ProceduralOrTexture;Shadows_ProceduralOrTexture?;32;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;532;492.3669,616.6875;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;731;2563.484,-2250.713;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;196;-30.71794,-4960.337;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;423;-146.7746,-4607.104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;246;-1550.031,-4737.472;Inherit;False;Shadow Mask;-1;;49;b50f5becdd6b8504a861ba5b9b861159;0;1;3;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;735;-1997.969,-4479.366;Inherit;False;0;8;False;;16;False;;2;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;379;179.8387,-2022.746;Inherit;False;Property;_BakedOrRT;BakedOrRT;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;736;861.9258,-4968.686;Inherit;False;CelShadingCalc;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;207;-210.1147,-2229.401;Inherit;True;Property;_MainTex;Base Color;13;0;Create;False;0;0;0;False;0;False;-1;5814ca8d54113234e9a6debac2240083;5814ca8d54113234e9a6debac2240083;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;687;-2731.905,2066.082;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;688;-2682.738,2222.838;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;689;-2443.059,2125.863;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;707;66.33031,1892.438;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;708;-146.5304,1891.411;Inherit;False;209;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;528;-587.4907,758.6886;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;369;-2110.823,-4731.151;Inherit;True;FetchLightmapValue;11;;51;43de3d4ae59f645418fdd020d1b8e78e;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;738;-1826.86,-4732.679;Inherit;False;Lightmaps;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;739;-126.068,-2022.206;Inherit;False;738;Lightmaps;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;453;-1391.699,-1727.793;Inherit;False;Property;_ShadowPatternDensity;ShadowPatternDensity;33;0;Create;True;0;0;0;False;0;False;10,10;10,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-913.8222,-1956.751;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;639;-624.657,-1576.62;Inherit;False;SHF_Triplanar;0;;54;a98a4a005477b1a47a700ab3414ae047;0;2;17;FLOAT2;0,0;False;47;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;554;-183.6708,-1039.217;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;616;-533.229,-1821.531;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;275;-177.0543,-1819.655;Inherit;True;0;1;1;0;1;True;1;False;True;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.StaticSwitch;629;538.2086,-1802.196;Inherit;False;Property;_UsingTriplanar1;UsingTriplanar?;38;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;549;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;631;951.2159,-1480.134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;627;716.0479,-1466.671;Inherit;False;Property;_ShadowTex_Pow;ShadowTex_Pow;39;0;Create;True;0;0;0;False;0;False;0.27;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;630;951.5406,-1384.424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;449;374.6587,-1572.215;Inherit;True;Property;_ShadowTexture;ShadowTexture;27;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;632;-129.6051,-1535.996;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;550;-138.1447,-1462.093;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TriplanarNode;535;225.9414,-1327.611;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;549;692.8077,-1356.65;Inherit;False;Property;_UsingTriplanar;UsingTriplanar?;38;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;626;1011.144,-1374.832;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;537;-578.0997,-977.3243;Inherit;True;Property;_ShadowTex;ShadowTex;36;0;Create;True;0;0;0;False;0;False;550b1e21474ccb4428e53adc76cabbab;2d6feab26a948a540b313c2253379a91;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.BreakToComponentsNode;556;-739.862,-1347.11;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;557;-618.3826,-1341.869;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;547;-842.1275,-1223.39;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;546;-1031.193,-1313.027;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;548;-1023.31,-1157.016;Inherit;False;Property;_WorldPosDiv;WorldPosDiv;37;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;737;1823.626,-2643.512;Inherit;False;736;CelShadingCalc;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;2097.525,-2458.259;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;305;2351.047,-2376.036;Inherit;False;Property;_FullShadingHalfShading;FullShading/HalfShading;30;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;480;3211.188,-2294.058;Inherit;False;Property;_LightindDone;LightindDone?;34;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;403;3436.395,-2082.329;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;730;3240.327,-2190.673;Inherit;False;726;FresnelEffects;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;725;3504.915,-2295.023;Inherit;False;Property;_IsEnnemies;IsEnnemies;41;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;753;3716.537,-2293.083;Inherit;False;Property;_Keyword1;Keyword 1;44;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;750;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;752;3492.846,-2193.22;Inherit;False;747;OutlineColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;755;245.6461,-1733.416;Inherit;False;754;ShadowDot_Triplanar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;677;-4742.969,-462.0775;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;160;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;646;-4038.493,-1865.539;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;670;-2716.124,-1911.486;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;668;-2719.147,-1787.395;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;-2717.774,-1673.444;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;654;-3495.199,-2013.316;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;647;-3723.391,-1844.827;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;649;-3200.876,-1839.539;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;655;-3208.751,-1974.885;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;643;-3732.754,-1977.417;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;650;-3192.662,-2107.514;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;648;-3754.936,-2104.87;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;684;-3978.632,-1890.057;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;685;-3990.725,-2061.106;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;686;-3991.876,-1975.774;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;667;-4528.675,-2149.631;Inherit;False;Property;_BlendPow;BlendPow;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;641;-4390.596,-2031.192;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;682;-4613.511,-2030.608;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;681;-4810.079,-2032.856;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;651;-3184.189,-1590.735;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-3184.189,-1478.735;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;659;-3632.188,-1494.735;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;660;-3632.188,-1574.735;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;-3184.189,-1702.734;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;662;-4300.456,-1650.442;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;661;-3633.718,-1656.771;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-3878.279,-1660.966;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;657;-4257.535,-1490.558;Inherit;False;Property;_TriplanarTiling;TriplanarTiling;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;653;-3883.353,-1455.423;Inherit;True;0;1;1;0;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleAddOpNode;671;-2378.931,-1816.011;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;754;-2153.665,-1804.326;Inherit;False;ShadowDot_Triplanar;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TangentVertexDataNode;694;-3470.258,2383.396;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;695;-3466.814,2532.882;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;696;-3237.597,2500.387;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;697;-3013.017,2393.534;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;699;-2723.755,2396.028;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;698;-3218.351,2643.534;Inherit;False;Constant;_BiNormalSwitch;BiNormalSwitch;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;690;-2226.287,2275.695;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;692;-2102.677,2371.473;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;691;-1964.893,2130.967;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;703;-2907.561,1970.125;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;693;-1800.508,2131.282;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;704;-1542.94,1968.991;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;705;-1233.552,1954.912;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;733;-1008.693,1946.741;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;780;-408.1769,3634.101;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;765;34.40498,3208.218;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;757;-348.6638,3287.304;Inherit;False;Property;_OutlineWidth;Outline Width;6;0;Create;True;0;0;0;False;0;False;0.1;0.005;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;766;-236.4973,3408.696;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;767;-496.728,3396.691;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;775;-667.4691,3191.542;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;769;-882.118,3197.13;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;771;-1123.304,3213.056;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;770;-1315.563,3335.322;Inherit;True;Property;_BPM;BPM;45;0;Create;True;0;0;0;False;0;False;60;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;763;52.28562,3059.468;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;758;624.6308,3189.277;Inherit;True;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;759;164.0772,3450.298;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;760;-42.84191,3461.401;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;762;476.678,3601.813;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;761;-34.1477,3639.754;Inherit;False;Property;_DistanceCutoff;Distance Cutoff;10;0;Create;True;0;0;0;False;0;False;0;20;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;781;827.434,3192.785;Inherit;False;OutlineOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;774;-1329.431,3213.843;Inherit;False;Constant;_Seconds;Seconds;46;0;Create;True;0;0;0;False;0;False;60;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;712;-251.702,2098.34;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;791;-583.715,1898.958;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;801;-398.8774,2124.872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;795;-608.8223,2015.777;Inherit;False;Constant;_Vector4;Vector 4;46;0;Create;True;0;0;0;False;0;False;0,0.001;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;784;434.1385,2225.015;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;-5.533697,2103.306;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,40;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;728;134.0368,2104.883;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;785;167.3507,2350.48;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;810;-495.0067,1981.294;Inherit;False;SHF_Beat;7;;55;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;811;-132.912,1957.865;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;732;-400.7758,1884.032;Inherit;False;Property;_FresnelPower;FresnelPower;43;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;812;-263.5787,1905.865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;805;592.1577,2361.821;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;723;721.2307,1876.028;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;722;492.7141,2626.944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;800;-461.1347,2574.874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;823;-715.3161,2568.631;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;798;-697.2436,2647.232;Inherit;False;Constant;_Vector5;Vector 4;46;0;Create;True;0;0;0;False;0;False;0,0.001;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;789;-300.7875,2524.661;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;788;-70.44388,2373.123;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,40;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;824;1508.026,2401.556;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;783;-703.7028,2194.574;Inherit;False;Property;_OutlineColor;OutlineColor;46;1;[HDR];Create;True;0;0;0;False;0;False;0.9937374,1.498039,0,0;0.9937374,1.498039,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;787;-681.5322,2363.009;Inherit;False;Property;_OutlineColor2;OutlineColor2;47;1;[HDR];Create;True;0;0;0;False;0;False;0.4558116,0,1.498039,0;0.4558116,0,1.498039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;747;-396.3311,2262.975;Inherit;False;OutlineColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;717;70.34522,2702.34;Inherit;False;Property;_FresnelErase_Smoothness;FresnelErase_Smoothness;42;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;724;120.3022,2578.457;Inherit;False;Property;_FresnelErase;FresnelErase;40;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;817;840.295,2774.74;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;640.0356,2871.183;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;827;455.2982,2910.466;Inherit;False;Constant;_Float3;Float 3;48;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;829;458.1643,2832.282;Inherit;False;Constant;_Float1;Float 1;48;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;814;1214.159,2748.379;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;809;1030.869,2487.051;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;726;1736.656,2402.053;Inherit;False;FresnelEffects;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;825;883.5541,2976.904;Inherit;False;747;OutlineColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;3747.825,-2198.049;Inherit;False;54;_Normalmap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;404;4072.93,-2291.077;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;SHR_3DMaster;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;20;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;41;Workflow;0;638793705028820884;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;638833736281707076;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.StaticSwitch;534;3533.854,-1655.301;Inherit;False;Property;_Using3DMovements;Using3DMovements?;35;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;750;3818.526,-1651.248;Inherit;False;Property;_IsOutline;IsOutline;44;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;618;3335.383,-1631.8;Inherit;False;617;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;751;3574.574,-1545.488;Inherit;False;781;OutlineOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;368;3752.651,-2145.322;Inherit;False;Constant;_Spec;Spec;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;3735.613,-2080.527;Inherit;False;Constant;_Smoothness;Smoothness;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;830;111.8216,3990.928;Inherit;True;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;831;357.0141,3958.325;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;832;581.5555,3973.058;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;718;792.6173,2554.35;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;802;823.7466,2181.431;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;804;1164.091,2178.034;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;835;646.058,4177.71;Inherit;False;Constant;_Float4;Float 4;48;0;Create;True;0;0;0;False;0;False;0.19;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;836;635.1908,4297.8;Inherit;False;Constant;_Float5;Float 5;48;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;837;814.2963,4259.159;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;834;1072.49,3974.391;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;209;0;212;0
WireConnection;212;0;214;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;31;0;29;0
WireConnection;208;0;211;0
WireConnection;208;1;213;1
WireConnection;210;0;208;0
WireConnection;54;0;53;0
WireConnection;214;5;215;0
WireConnection;257;0;258;1
WireConnection;257;1;258;2
WireConnection;257;2;265;0
WireConnection;258;0;219;0
WireConnection;251;0;379;0
WireConnection;251;2;283;0
WireConnection;255;0;251;0
WireConnection;255;2;282;0
WireConnection;290;0;255;0
WireConnection;515;0;513;0
WireConnection;515;1;495;0
WireConnection;486;0;498;3
WireConnection;487;54;504;3
WireConnection;488;0;487;0
WireConnection;488;1;486;0
WireConnection;489;0;497;0
WireConnection;489;1;488;0
WireConnection;490;54;491;0
WireConnection;491;0;504;1
WireConnection;492;0;504;2
WireConnection;493;0;490;0
WireConnection;493;1;500;0
WireConnection;494;0;528;2
WireConnection;495;0;494;0
WireConnection;495;1;501;0
WireConnection;496;0;498;1
WireConnection;497;0;503;0
WireConnection;499;0;529;0
WireConnection;499;1;493;0
WireConnection;500;0;496;0
WireConnection;501;0;502;0
WireConnection;501;1;498;2
WireConnection;502;54;492;0
WireConnection;503;0;528;3
WireConnection;505;0;518;0
WireConnection;506;0;505;0
WireConnection;506;1;509;0
WireConnection;507;0;512;0
WireConnection;507;1;508;0
WireConnection;508;0;521;0
WireConnection;508;1;531;2
WireConnection;509;0;522;1
WireConnection;509;1;511;0
WireConnection;510;0;527;0
WireConnection;511;0;510;0
WireConnection;511;1;531;1
WireConnection;512;0;522;2
WireConnection;513;0;505;0
WireConnection;513;1;507;0
WireConnection;517;0;520;0
WireConnection;518;0;533;0
WireConnection;518;1;516;0
WireConnection;520;0;533;0
WireConnection;520;1;519;0
WireConnection;521;54;530;2
WireConnection;527;54;530;1
WireConnection;529;0;528;1
WireConnection;514;0;506;0
WireConnection;514;1;499;0
WireConnection;485;0;514;0
WireConnection;485;1;515;0
WireConnection;485;2;489;0
WireConnection;617;0;485;0
WireConnection;248;0;185;0
WireConnection;248;1;56;0
WireConnection;189;0;202;0
WireConnection;189;1;248;0
WireConnection;194;0;184;0
WireConnection;191;0;194;0
WireConnection;191;1;194;1
WireConnection;430;0;194;2
WireConnection;192;0;191;0
WireConnection;192;1;430;0
WireConnection;436;0;438;0
WireConnection;436;2;439;0
WireConnection;437;0;436;0
WireConnection;391;0;203;0
WireConnection;387;0;391;0
WireConnection;387;1;437;0
WireConnection;438;0;443;0
WireConnection;438;1;440;0
WireConnection;443;0;738;0
WireConnection;187;0;189;0
WireConnection;187;1;445;1
WireConnection;187;2;445;2
WireConnection;328;0;188;0
WireConnection;328;1;192;0
WireConnection;201;11;183;0
WireConnection;201;32;246;0
WireConnection;190;0;201;0
WireConnection;193;0;190;0
WireConnection;193;1;190;1
WireConnection;188;0;193;0
WireConnection;188;1;190;2
WireConnection;186;0;446;0
WireConnection;186;1;328;0
WireConnection;446;0;187;0
WireConnection;388;1;387;0
WireConnection;388;0;196;0
WireConnection;303;0;557;0
WireConnection;303;1;453;0
WireConnection;265;0;258;3
WireConnection;265;1;260;0
WireConnection;219;1;230;0
WireConnection;219;0;207;0
WireConnection;266;0;257;0
WireConnection;266;1;219;0
WireConnection;266;2;289;0
WireConnection;273;2;274;0
WireConnection;533;0;528;3
WireConnection;675;0;674;0
WireConnection;676;0;675;0
WireConnection;289;0;638;0
WireConnection;289;1;290;0
WireConnection;289;2;448;0
WireConnection;624;0;629;0
WireConnection;624;1;631;0
WireConnection;448;1;624;0
WireConnection;448;0;626;0
WireConnection;532;0;521;33
WireConnection;731;0;207;0
WireConnection;196;0;203;0
WireConnection;196;1;423;0
WireConnection;423;0;328;0
WireConnection;423;1;186;0
WireConnection;246;3;738;0
WireConnection;379;1;739;0
WireConnection;379;0;423;0
WireConnection;736;0;388;0
WireConnection;689;0;687;0
WireConnection;689;1;688;0
WireConnection;707;0;708;0
WireConnection;707;3;811;0
WireConnection;738;0;369;0
WireConnection;639;17;453;0
WireConnection;554;0;537;0
WireConnection;616;0;270;0
WireConnection;616;1;453;0
WireConnection;275;0;616;0
WireConnection;629;1;275;0
WireConnection;629;0;755;0
WireConnection;631;0;627;0
WireConnection;630;0;627;0
WireConnection;449;0;550;0
WireConnection;449;1;632;0
WireConnection;632;0;616;0
WireConnection;550;0;537;0
WireConnection;535;0;554;0
WireConnection;535;9;547;0
WireConnection;535;3;303;0
WireConnection;549;1;449;0
WireConnection;549;0;535;0
WireConnection;626;0;549;0
WireConnection;626;1;630;0
WireConnection;556;0;547;0
WireConnection;557;0;556;0
WireConnection;557;1;556;2
WireConnection;547;0;546;0
WireConnection;547;1;548;0
WireConnection;197;0;737;0
WireConnection;197;1;266;0
WireConnection;305;1;197;0
WireConnection;305;0;266;0
WireConnection;480;1;731;0
WireConnection;480;0;305;0
WireConnection;725;1;480;0
WireConnection;725;0;730;0
WireConnection;753;1;725;0
WireConnection;753;0;752;0
WireConnection;677;0;676;0
WireConnection;646;0;667;0
WireConnection;670;0;650;0
WireConnection;670;1;666;0
WireConnection;668;0;655;0
WireConnection;668;1;651;0
WireConnection;669;0;649;0
WireConnection;669;1;652;0
WireConnection;654;0;648;0
WireConnection;654;1;643;0
WireConnection;654;2;647;0
WireConnection;647;0;684;0
WireConnection;647;1;646;0
WireConnection;649;0;647;0
WireConnection;649;1;654;0
WireConnection;655;0;643;0
WireConnection;655;1;654;0
WireConnection;643;0;686;0
WireConnection;643;1;667;0
WireConnection;650;0;648;0
WireConnection;650;1;654;0
WireConnection;648;0;685;0
WireConnection;648;1;667;0
WireConnection;684;0;641;0
WireConnection;685;0;641;0
WireConnection;686;0;641;0
WireConnection;641;0;682;0
WireConnection;682;0;681;0
WireConnection;651;0;660;0
WireConnection;651;1;653;0
WireConnection;652;0;659;0
WireConnection;652;1;653;0
WireConnection;659;0;658;0
WireConnection;660;0;658;0
WireConnection;666;0;661;0
WireConnection;666;1;653;0
WireConnection;661;0;658;0
WireConnection;658;0;662;0
WireConnection;658;1;657;0
WireConnection;671;0;670;0
WireConnection;671;1;668;0
WireConnection;671;2;669;0
WireConnection;754;0;671;0
WireConnection;696;0;694;0
WireConnection;696;1;695;0
WireConnection;697;0;694;0
WireConnection;697;1;696;0
WireConnection;697;2;698;0
WireConnection;699;0;697;0
WireConnection;690;0;689;0
WireConnection;690;1;699;0
WireConnection;692;0;690;0
WireConnection;692;1;699;0
WireConnection;691;0;689;0
WireConnection;691;1;692;0
WireConnection;693;0;691;0
WireConnection;704;0;703;0
WireConnection;704;1;693;0
WireConnection;705;0;704;0
WireConnection;733;0;705;0
WireConnection;780;0;769;0
WireConnection;765;0;775;0
WireConnection;765;1;757;0
WireConnection;765;2;766;0
WireConnection;766;0;767;0
WireConnection;766;1;780;0
WireConnection;775;0;769;0
WireConnection;769;0;771;0
WireConnection;771;0;774;0
WireConnection;771;1;770;0
WireConnection;758;0;763;0
WireConnection;758;1;765;0
WireConnection;758;2;762;0
WireConnection;758;3;834;0
WireConnection;759;0;760;0
WireConnection;762;0;759;4
WireConnection;762;1;761;0
WireConnection;781;0;758;0
WireConnection;712;1;801;0
WireConnection;801;0;791;0
WireConnection;801;1;795;0
WireConnection;784;0;728;0
WireConnection;784;1;785;0
WireConnection;713;0;712;0
WireConnection;728;0;713;0
WireConnection;785;0;788;0
WireConnection;811;0;812;0
WireConnection;811;1;732;0
WireConnection;811;2;810;0
WireConnection;812;0;732;0
WireConnection;805;0;784;0
WireConnection;723;0;707;0
WireConnection;723;1;784;0
WireConnection;722;0;724;0
WireConnection;722;1;717;0
WireConnection;800;0;823;0
WireConnection;800;1;798;0
WireConnection;789;1;800;0
WireConnection;788;0;789;0
WireConnection;824;0;804;0
WireConnection;824;1;814;0
WireConnection;824;2;817;0
WireConnection;747;0;783;0
WireConnection;817;0;707;0
WireConnection;817;1;829;0
WireConnection;817;2;828;0
WireConnection;828;0;829;0
WireConnection;828;1;827;0
WireConnection;814;0;817;0
WireConnection;814;1;825;0
WireConnection;809;0;718;0
WireConnection;726;0;824;0
WireConnection;404;0;753;0
WireConnection;404;9;368;0
WireConnection;404;4;339;0
WireConnection;404;8;750;0
WireConnection;534;0;618;0
WireConnection;750;1;534;0
WireConnection;750;0;751;0
WireConnection;831;0;830;0
WireConnection;832;0;831;0
WireConnection;832;1;766;0
WireConnection;718;0;723;0
WireConnection;718;1;724;0
WireConnection;718;2;722;0
WireConnection;802;0;783;0
WireConnection;802;1;787;0
WireConnection;802;2;805;0
WireConnection;804;0;802;0
WireConnection;804;1;809;0
WireConnection;837;0;835;0
WireConnection;837;1;836;0
WireConnection;834;0;832;0
WireConnection;834;1;835;0
WireConnection;834;2;837;0
ASEEND*/
//CHKSM=FABA607EA84AEDB257403792125195302D78340D