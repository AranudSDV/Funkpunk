// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_3DMaster"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BPM("BPM", Float) = 60
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
		_ShadowPatternRotator("ShadowPatternRotator", Float) = 0
		_ShadowSoftness("ShadowSoftness", Range( 0 , 1)) = 1
		_Cels_FallOffThreshold("Cels_FallOffThreshold", Float) = 0.45
		_Shadow_FallOffThreshold("Shadow_FallOffThreshold", Float) = 0.45
		_Cels_LitThreshold("Cels_LitThreshold", Float) = 0.42
		_Shadow_LitThreshold("Shadow_LitThreshold", Float) = 0.42
		[Toggle(_FULLSHADINGHALFSHADING_ON)] _FullShadingHalfShading("FullShading/HalfShading", Float) = 0
		[Toggle(_BAKEDORRT_ON)] _BakedOrRT("BakedOrRT", Float) = 0
		[Toggle(_SHADOWS_PROCEDURALORTEXTURE_ON)] _Shadows_ProceduralOrTexture("Shadows_ProceduralOrTexture?", Float) = 0
		_ShadowTexture("ShadowTexture", 2D) = "white" {}
		_ShadowPatternDensity("ShadowPatternDensity", Vector) = (10,10,0,0)
		[Toggle(_LIGHTINDDONE_ON)] _LightindDone("LightindDone?", Float) = 0
		[Toggle(_USING3DMOVEMENTS_ON)] _Using3DMovements("Using3DMovements?", Float) = 0
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing
			#pragma shader_feature_local _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTexture;
			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
			float4 SampleLightmapHD11_g38( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g38(  )
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
			
			half4 CalculateShadowMask1_g29( half2 LightmapUV )
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				
				float2 texCoord2_g38 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g38 = ( ( texCoord2_g38 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.zw = vertexToFrag10_g38;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 6, 2, float4( 0.2767295, 0.2741188, 0.2741188, 0.1000076 ), float4( 0.3207547, 0.3207547, 0.3207547, 0.4 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.6 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.8 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.9499962 ), float4( 1, 1, 1, 1 ), 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g38 = IN.ase_texcoord8.zw;
				float2 UV11_g38 = vertexToFrag10_g38;
				float4 localSampleLightmapHD11_g38 = SampleLightmapHD11_g38( UV11_g38 );
				float4 localURPDecodeInstruction19_g38 = URPDecodeInstruction19_g38();
				float3 decodeLightMap6_g38 = DecodeLightmap(localSampleLightmapHD11_g38,localURPDecodeInstruction19_g38);
				float3 temp_output_369_0 = decodeLightMap6_g38;
				float3 clampResult437 = clamp( (( temp_output_369_0 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g35 = WorldPosition;
				float3 WorldPosition86_g35 = worldPosValue44_g35;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g35 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g35 = ScreenUV75_g35;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BumpNormal_ST);
				float2 uv_BumpNormal = IN.ase_texcoord8.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g35 = worldNormal209;
				float3 WorldNormal86_g35 = worldNormalValue50_g35;
				half2 LightmapUV1_g29 = temp_output_369_0.xy;
				half4 localCalculateShadowMask1_g29 = CalculateShadowMask1_g29( LightmapUV1_g29 );
				float4 shadowMaskValue33_g35 = localCalculateShadowMask1_g29;
				float4 ShadowMask86_g35 = shadowMaskValue33_g35;
				float3 localAdditionalLightsLambertMask14x86_g35 = AdditionalLightsLambertMask14x( WorldPosition86_g35 , ScreenUV86_g35 , WorldNormal86_g35 , ShadowMask86_g35 );
				float3 lambertResult38_g35 = localAdditionalLightsLambertMask14x86_g35;
				float3 break190 = lambertResult38_g35;
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
				float3 staticSwitch379 = temp_output_369_0;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float2 texCoord270 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float cos273 = cos( _ShadowPatternRotator );
				float sin273 = sin( _ShadowPatternRotator );
				float2 rotator273 = mul( ( texCoord270 * _ShadowPatternDensity ) - float2( 0.5,0.5 ) , float2x2( cos273 , -sin273 , sin273 , cos273 )) + float2( 0.5,0.5 );
				float2 uv275 = 0;
				float3 unityVoronoy275 = UnityVoronoi(rotator273,0.0,10.0,uv275);
				float4 temp_cast_6 = (unityVoronoy275.x).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = tex2D( _ShadowTexture, rotator273 );
				#else
				float4 staticSwitch448 = temp_cast_6;
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , _ShadowSoftness);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( staticSwitch388 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				
				float3 temp_cast_9 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch480.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_9;
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
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing


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
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
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
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;
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
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing


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
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing
			#pragma shader_feature_local _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTexture;
			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
			float4 SampleLightmapHD11_g38( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g38(  )
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
			
			half4 CalculateShadowMask1_g29( half2 LightmapUV )
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				
				float2 texCoord2_g38 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g38 = ( ( texCoord2_g38 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord4.zw = vertexToFrag10_g38;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord6.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord7.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord8.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				
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

				float3 vertexValue = staticSwitch534;

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

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord4.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 6, 2, float4( 0.2767295, 0.2741188, 0.2741188, 0.1000076 ), float4( 0.3207547, 0.3207547, 0.3207547, 0.4 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.6 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.8 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.9499962 ), float4( 1, 1, 1, 1 ), 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g38 = IN.ase_texcoord4.zw;
				float2 UV11_g38 = vertexToFrag10_g38;
				float4 localSampleLightmapHD11_g38 = SampleLightmapHD11_g38( UV11_g38 );
				float4 localURPDecodeInstruction19_g38 = URPDecodeInstruction19_g38();
				float3 decodeLightMap6_g38 = DecodeLightmap(localSampleLightmapHD11_g38,localURPDecodeInstruction19_g38);
				float3 temp_output_369_0 = decodeLightMap6_g38;
				float3 clampResult437 = clamp( (( temp_output_369_0 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g35 = WorldPosition;
				float3 WorldPosition86_g35 = worldPosValue44_g35;
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g35 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g35 = ScreenUV75_g35;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BumpNormal_ST);
				float2 uv_BumpNormal = IN.ase_texcoord4.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
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
				float3 worldNormalValue50_g35 = worldNormal209;
				float3 WorldNormal86_g35 = worldNormalValue50_g35;
				half2 LightmapUV1_g29 = temp_output_369_0.xy;
				half4 localCalculateShadowMask1_g29 = CalculateShadowMask1_g29( LightmapUV1_g29 );
				float4 shadowMaskValue33_g35 = localCalculateShadowMask1_g29;
				float4 ShadowMask86_g35 = shadowMaskValue33_g35;
				float3 localAdditionalLightsLambertMask14x86_g35 = AdditionalLightsLambertMask14x( WorldPosition86_g35 , ScreenUV86_g35 , WorldNormal86_g35 , ShadowMask86_g35 );
				float3 lambertResult38_g35 = localAdditionalLightsLambertMask14x86_g35;
				float3 break190 = lambertResult38_g35;
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
				float3 staticSwitch379 = temp_output_369_0;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float2 texCoord270 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float cos273 = cos( _ShadowPatternRotator );
				float sin273 = sin( _ShadowPatternRotator );
				float2 rotator273 = mul( ( texCoord270 * _ShadowPatternDensity ) - float2( 0.5,0.5 ) , float2x2( cos273 , -sin273 , sin273 , cos273 )) + float2( 0.5,0.5 );
				float2 uv275 = 0;
				float3 unityVoronoy275 = UnityVoronoi(rotator273,0.0,10.0,uv275);
				float4 temp_cast_6 = (unityVoronoy275.x).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = tex2D( _ShadowTexture, rotator273 );
				#else
				float4 staticSwitch448 = temp_cast_6;
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , _ShadowSoftness);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( staticSwitch388 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				

				float3 BaseColor = staticSwitch480.rgb;
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing
			#pragma shader_feature_local _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTexture;
			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
			float4 SampleLightmapHD11_g38( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g38(  )
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
			
			half4 CalculateShadowMask1_g29( half2 LightmapUV )
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				
				float2 texCoord2_g38 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g38 = ( ( texCoord2_g38 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord2.zw = vertexToFrag10_g38;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord7.xyz = objectSpaceLightDir;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
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

				float3 vertexValue = staticSwitch534;

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

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 6, 2, float4( 0.2767295, 0.2741188, 0.2741188, 0.1000076 ), float4( 0.3207547, 0.3207547, 0.3207547, 0.4 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.6 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.8 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.9499962 ), float4( 1, 1, 1, 1 ), 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g38 = IN.ase_texcoord2.zw;
				float2 UV11_g38 = vertexToFrag10_g38;
				float4 localSampleLightmapHD11_g38 = SampleLightmapHD11_g38( UV11_g38 );
				float4 localURPDecodeInstruction19_g38 = URPDecodeInstruction19_g38();
				float3 decodeLightMap6_g38 = DecodeLightmap(localSampleLightmapHD11_g38,localURPDecodeInstruction19_g38);
				float3 temp_output_369_0 = decodeLightMap6_g38;
				float3 clampResult437 = clamp( (( temp_output_369_0 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g35 = WorldPosition;
				float3 WorldPosition86_g35 = worldPosValue44_g35;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g35 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g35 = ScreenUV75_g35;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BumpNormal_ST);
				float2 uv_BumpNormal = IN.ase_texcoord2.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
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
				float3 worldNormalValue50_g35 = worldNormal209;
				float3 WorldNormal86_g35 = worldNormalValue50_g35;
				half2 LightmapUV1_g29 = temp_output_369_0.xy;
				half4 localCalculateShadowMask1_g29 = CalculateShadowMask1_g29( LightmapUV1_g29 );
				float4 shadowMaskValue33_g35 = localCalculateShadowMask1_g29;
				float4 ShadowMask86_g35 = shadowMaskValue33_g35;
				float3 localAdditionalLightsLambertMask14x86_g35 = AdditionalLightsLambertMask14x( WorldPosition86_g35 , ScreenUV86_g35 , WorldNormal86_g35 , ShadowMask86_g35 );
				float3 lambertResult38_g35 = localAdditionalLightsLambertMask14x86_g35;
				float3 break190 = lambertResult38_g35;
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
				float3 staticSwitch379 = temp_output_369_0;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float2 texCoord270 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float cos273 = cos( _ShadowPatternRotator );
				float sin273 = sin( _ShadowPatternRotator );
				float2 rotator273 = mul( ( texCoord270 * _ShadowPatternDensity ) - float2( 0.5,0.5 ) , float2x2( cos273 , -sin273 , sin273 , cos273 )) + float2( 0.5,0.5 );
				float2 uv275 = 0;
				float3 unityVoronoy275 = UnityVoronoi(rotator273,0.0,10.0,uv275);
				float4 temp_cast_6 = (unityVoronoy275.x).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = tex2D( _ShadowTexture, rotator273 );
				#else
				float4 staticSwitch448 = temp_cast_6;
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , _ShadowSoftness);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( staticSwitch388 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				

				float3 BaseColor = staticSwitch480.rgb;
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
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing


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
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing
			#pragma shader_feature_local _LIGHTINDDONE_ON
			#pragma shader_feature_local _FULLSHADINGHALFSHADING_ON
			#pragma shader_feature_local _BAKEDORRT_ON
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma shader_feature_local _COLORORTEX_ON
			#pragma shader_feature_local _SHADOWS_PROCEDURALORTEXTURE_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			sampler2D _MainTex;
			sampler2D _BumpNormal;
			sampler2D _ShadowTexture;
			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _BumpNormal_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

			
			float4 SampleLightmapHD11_g38( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g38(  )
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
			
			half4 CalculateShadowMask1_g29( half2 LightmapUV )
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_533_0 = v.vertex.xyz.z;
				float clampResult505 = clamp( ( temp_output_533_0 - _TopMask ) , 0.0 , 1.0 );
				float4 transform522 = mul(GetWorldToObjectMatrix(),float4( 0,0,0,1 ));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				
				float2 texCoord2_g38 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g38 = ( ( texCoord2_g38 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.zw = vertexToFrag10_g38;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord8.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 tex2DNode207 = tex2D( _MainTex, uv_MainTex );
				Gradient gradient203 = NewGradient( 1, 6, 2, float4( 0.2767295, 0.2741188, 0.2741188, 0.1000076 ), float4( 0.3207547, 0.3207547, 0.3207547, 0.4 ), float4( 0.3962264, 0.3962264, 0.3962264, 0.6 ), float4( 0.5031446, 0.5031446, 0.5031446, 0.8 ), float4( 0.6100628, 0.6100628, 0.6100628, 0.9499962 ), float4( 1, 1, 1, 1 ), 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g38 = IN.ase_texcoord8.zw;
				float2 UV11_g38 = vertexToFrag10_g38;
				float4 localSampleLightmapHD11_g38 = SampleLightmapHD11_g38( UV11_g38 );
				float4 localURPDecodeInstruction19_g38 = URPDecodeInstruction19_g38();
				float3 decodeLightMap6_g38 = DecodeLightmap(localSampleLightmapHD11_g38,localURPDecodeInstruction19_g38);
				float3 temp_output_369_0 = decodeLightMap6_g38;
				float3 clampResult437 = clamp( (( temp_output_369_0 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g35 = WorldPosition;
				float3 WorldPosition86_g35 = worldPosValue44_g35;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g35 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g35 = ScreenUV75_g35;
				float4 _BumpNormal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BumpNormal_ST);
				float2 uv_BumpNormal = IN.ase_texcoord8.xy * _BumpNormal_ST_Instance.xy + _BumpNormal_ST_Instance.zw;
				float3 unpack214 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack214.z = lerp( 1, unpack214.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal212 = unpack214;
				float3 worldNormal212 = normalize( float3(dot(tanToWorld0,tanNormal212), dot(tanToWorld1,tanNormal212), dot(tanToWorld2,tanNormal212)) );
				float3 worldNormal209 = worldNormal212;
				float3 worldNormalValue50_g35 = worldNormal209;
				float3 WorldNormal86_g35 = worldNormalValue50_g35;
				half2 LightmapUV1_g29 = temp_output_369_0.xy;
				half4 localCalculateShadowMask1_g29 = CalculateShadowMask1_g29( LightmapUV1_g29 );
				float4 shadowMaskValue33_g35 = localCalculateShadowMask1_g29;
				float4 ShadowMask86_g35 = shadowMaskValue33_g35;
				float3 localAdditionalLightsLambertMask14x86_g35 = AdditionalLightsLambertMask14x( WorldPosition86_g35 , ScreenUV86_g35 , WorldNormal86_g35 , ShadowMask86_g35 );
				float3 lambertResult38_g35 = localAdditionalLightsLambertMask14x86_g35;
				float3 break190 = lambertResult38_g35;
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
				float3 staticSwitch379 = temp_output_369_0;
				#endif
				float3 clampResult290 = clamp( (( staticSwitch379 * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float2 texCoord270 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float cos273 = cos( _ShadowPatternRotator );
				float sin273 = sin( _ShadowPatternRotator );
				float2 rotator273 = mul( ( texCoord270 * _ShadowPatternDensity ) - float2( 0.5,0.5 ) , float2x2( cos273 , -sin273 , sin273 , cos273 )) + float2( 0.5,0.5 );
				float2 uv275 = 0;
				float3 unityVoronoy275 = UnityVoronoi(rotator273,0.0,10.0,uv275);
				float4 temp_cast_6 = (unityVoronoy275.x).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch448 = tex2D( _ShadowTexture, rotator273 );
				#else
				float4 staticSwitch448 = temp_cast_6;
				#endif
				float smoothstepResult289 = smoothstep( clampResult290.x , staticSwitch448.r , _ShadowSoftness);
				float4 lerpResult266 = lerp( float4( hsvTorgb257 , 0.0 ) , staticSwitch219 , smoothstepResult289);
				#ifdef _FULLSHADINGHALFSHADING_ON
				float4 staticSwitch305 = lerpResult266;
				#else
				float4 staticSwitch305 = ( staticSwitch388 * lerpResult266 );
				#endif
				#ifdef _LIGHTINDDONE_ON
				float4 staticSwitch480 = staticSwitch305;
				#else
				float4 staticSwitch480 = tex2DNode207;
				#endif
				
				float3 temp_cast_9 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch480.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_9;
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
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
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
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma multi_compile_instancing


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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
			float3 _BaseVertexOffsetDelay;
			float3 _BaseVertexOffsetValue;
			float2 _TopVertexDelay;
			float2 _TopVertexOffsetValue;
			float2 _ShadowPatternDensity;
			float _TopMask;
			float _Cels_FallOffThreshold;
			float _Cels_LitThreshold;
			float _NormalScale;
			float _ShadingWhiteMult;
			float _Shadow_FallOffThreshold;
			float _Shadow_LitThreshold;
			float _ShadowPatternRotator;
			float _ShadowSoftness;
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

			UNITY_INSTANCING_BUFFER_START(SHR_3DMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_3DMaster)


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			
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
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_3DMaster,_BPM);
				float mulTime5_g43 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g43 = ( mulTime5_g43 - _TopVertexDelay.x );
				float temp_output_16_0_g43 = ( PI / 1.0 );
				float temp_output_19_0_g43 = cos( ( temp_output_52_0_g43 * temp_output_16_0_g43 ) );
				float saferPower20_g43 = abs( abs( temp_output_19_0_g43 ) );
				float mulTime5_g40 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g40 = ( mulTime5_g40 - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g40 = ( PI / 1.0 );
				float temp_output_19_0_g40 = cos( ( temp_output_52_0_g40 * temp_output_16_0_g40 ) );
				float saferPower20_g40 = abs( abs( temp_output_19_0_g40 ) );
				float mulTime5_g42 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g42 = ( mulTime5_g42 - _TopVertexDelay.y );
				float temp_output_16_0_g42 = ( PI / 1.0 );
				float temp_output_19_0_g42 = cos( ( temp_output_52_0_g42 * temp_output_16_0_g42 ) );
				float saferPower20_g42 = abs( abs( temp_output_19_0_g42 ) );
				float mulTime5_g41 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g41 = ( mulTime5_g41 - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g41 = ( PI / 1.0 );
				float temp_output_19_0_g41 = cos( ( temp_output_52_0_g41 * temp_output_16_0_g41 ) );
				float saferPower20_g41 = abs( abs( temp_output_19_0_g41 ) );
				float mulTime5_g39 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_52_0_g39 = ( mulTime5_g39 - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g39 = ( PI / 1.0 );
				float temp_output_19_0_g39 = cos( ( temp_output_52_0_g39 * temp_output_16_0_g39 ) );
				float saferPower20_g39 = abs( abs( temp_output_19_0_g39 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g43 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g40 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g42 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g41 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g39 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
				#ifdef _USING3DMOVEMENTS_ON
				float3 staticSwitch534 = appendResult485;
				#else
				float3 staticSwitch534 = float3( 0,0,0 );
				#endif
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = staticSwitch534;

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
Node;AmplifyShaderEditor.CommentaryNode;381;-3767.531,-3664.03;Inherit;False;1209;1283.536;;12;182;54;53;28;29;27;31;342;213;208;211;210;ShadingComponents;0.8509804,0.5254902,0.8373843,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;380;-289.0617,-2493.339;Inherit;False;2267.363;1540.534;;24;207;230;219;265;260;258;266;255;303;273;270;251;274;275;289;290;257;282;283;287;379;449;453;448;ShadowShading;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;302;-1714.032,-3649.264;Inherit;False;1827.19;1032.5;LitRT;24;193;190;188;186;191;194;189;202;201;246;185;56;184;187;203;196;248;183;192;328;423;430;445;446;CelShading;1,0.9921199,0.6635219,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-3717.531,-3260.238;Inherit;False;1109;303;;4;215;214;212;209;Normals;0.6117647,0.6408768,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;230;-219.1604,-2335.866;Inherit;False;Property;_BaseColor;BaseColor;14;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;215;-3667.531,-3162.238;Inherit;False;Property;_NormalScale;Normal Scale;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;-2851.533,-3210.238;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;212;-3091.531,-3210.238;Inherit;True;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;28;-3717.316,-2564.161;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;29;-3480.294,-2684.945;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;27;-3709.942,-2738.152;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-3351.861,-2686.189;Inherit;True;VS_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TangentVertexDataNode;342;-2902.934,-2807.608;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;213;-3596.728,-3502.531;Inherit;True;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-3311.342,-3553.439;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-3133.669,-3555.95;Inherit;True;mainLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-3411.381,-2936.291;Inherit;False;_Normalmap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;53;-3701.767,-2937.219;Inherit;True;Property;_Normal;Normal;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;214;-3395.531,-3210.238;Inherit;True;Property;_BumpNormal;BumpNormal;8;0;Create;True;0;0;0;False;0;False;-1;None;d21bc8946882b8e4fbfde16f49086ec9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;219;72.11066,-2155.81;Inherit;False;Property;_ColorOrTex;ColorOrTex?;12;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;248;-1415.944,-2993.09;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;211;-3583.609,-3613.314;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;189;-1303.243,-3246.167;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-1704.616,-3609.135;Inherit;True;209;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;246;-1697.427,-3363.558;Inherit;False;Shadow Mask;-1;;29;b50f5becdd6b8504a861ba5b9b861159;0;1;3;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-1701.931,-3275.132;Inherit;True;209;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;185;-1703.945,-3069.263;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;56;-1706.016,-2915.229;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;184;-1706.367,-2738.948;Inherit;False;210;mainLight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;194;-1519.453,-2762.129;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;191;-1340.608,-2863.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;430;-1072.569,-2709.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;192;-1019.33,-2861.683;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;207;-239.4277,-2154.862;Inherit;True;Property;_MainTex;Base Color;6;0;Create;False;0;0;0;False;0;False;-1;5814ca8d54113234e9a6debac2240083;5814ca8d54113234e9a6debac2240083;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HSVToRGBNode;257;1327.028,-2431.554;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;828.6957,-2326.799;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;379;126.3192,-1955.351;Inherit;False;Property;_BakedOrRT;BakedOrRT;25;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;403;2918.74,-2067.324;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;405;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;406;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;407;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;408;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;409;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;410;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;411;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;412;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;2510.428,-2066.773;Inherit;False;54;_Normalmap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;368;2512.23,-1986.158;Inherit;False;Constant;_Spec;Spec;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;305;2479.72,-2206.437;Inherit;False;Property;_FullShadingHalfShading;FullShading/HalfShading;24;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;436;-1196.954,-4158.301;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.12;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;437;-909.6068,-4163.178;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;391;-1069.68,-3799.597;Inherit;False;1;0;OBJECT;;False;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;387;-193.2821,-3852.369;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;439;-1427.471,-3768.165;Inherit;False;Property;_Cels_LitThreshold;Cels_LitThreshold;22;0;Create;True;0;0;0;False;0;False;0.42;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-1456.316,-4020.539;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;443;-1801.338,-3898.224;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;390;-1686.54,-2058.198;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;187;-1057.988,-3240.585;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;445;-1262.153,-3133.067;Inherit;False;Constant;_RT_SO;RT_SO;17;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;440;-1726.681,-3769.236;Inherit;False;Property;_Cels_FallOffThreshold;Cels_FallOffThreshold;20;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;196;-183.5516,-3568.108;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;328;-690.0486,-2995.565;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;201;-1470.911,-3500.657;Inherit;False;SRP Additional Light;-1;;35;6c86746ad131a0a408ca599df5f40861;7,6,1,9,1,23,0,27,1,25,1,24,1,26,1;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;1;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;190;-1240.687,-3507.106;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;193;-1028.855,-3506.683;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;188;-814.5481,-3488.468;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;423;-248.7339,-3235.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-421.6151,-3021.499;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;446;-526.7691,-3171.858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;266;1606.431,-2177.786;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;388;435.1264,-3599.708;Inherit;True;Property;_Keyword0;Keyword 0;25;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;379;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;339;2478.404,-1913.363;Inherit;False;Constant;_Smoothness;Smoothness;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;369;-2076.885,-3357.237;Inherit;True;FetchLightmapValue;4;;38;43de3d4ae59f645418fdd020d1b8e78e;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;260;634.5085,-2205.394;Inherit;False;Property;_ShadingWhiteMult;ShadingWhiteMult;17;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;258;326.0039,-2460.673;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;303;116.2158,-1577.341;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;273;358.3425,-1579.954;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-196.6017,-1609.417;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;453;-218.0284,-1479.815;Inherit;False;Property;_ShadowPatternDensity;ShadowPatternDensity;28;0;Create;True;0;0;0;False;0;False;10,10;10,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;274;73.48865,-1449.147;Inherit;False;Property;_ShadowPatternRotator;ShadowPatternRotator;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;449;680.1999,-1430.105;Inherit;True;Property;_ShadowTexture;ShadowTexture;27;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;448;971.4247,-1612.808;Inherit;False;Property;_Shadows_ProceduralOrTexture;Shadows_ProceduralOrTexture?;26;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;275;735.6671,-1696.94;Inherit;True;0;0;1;1;1;True;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;282;385.1659,-1712.612;Inherit;False;Property;_Shadow_LitThreshold;Shadow_LitThreshold;23;0;Create;True;0;0;0;False;0;False;0.42;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;283;93.73351,-1860.469;Inherit;False;Property;_Shadow_FallOffThreshold;Shadow_FallOffThreshold;21;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;425.3611,-1955.268;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;255;723.7082,-1954.843;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0.12;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;290;1012.787,-1954.519;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;289;1336.107,-1979.659;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;960.3063,-2025.272;Inherit;False;Property;_ShadowSoftness;ShadowSoftness;19;0;Create;True;0;0;0;False;0;False;1;-0.09;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;2207.397,-2445.005;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientNode;203;-1367.7,-3601.607;Inherit;False;1;6;2;0.2767295,0.2741188,0.2741188,0.1000076;0.3207547,0.3207547,0.3207547,0.4;0.3962264,0.3962264,0.3962264,0.6;0.5031446,0.5031446,0.5031446,0.8;0.6100628,0.6100628,0.6100628,0.9499962;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;2735.627,-2783.301;Inherit;False;Constant;_PourPasBrulerLesYeux;PourPasBrulerLesYeux;14;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;480;2752.331,-2536.748;Inherit;False;Property;_LightindDone;LightindDone?;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;404;3061.145,-2070.576;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;SHR_3DMaster;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;20;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;41;Workflow;0;638793705028820884;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;481;-85.30273,-996.9213;Inherit;False;2213.736;1069.384;;23;533;532;531;530;527;522;521;520;519;518;517;516;515;514;513;512;511;510;509;508;507;506;505;TopVertexOffset;1,0.3930817,0.6767163,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;482;-84.63379,139.9108;Inherit;False;2323.009;1021.379;;20;529;504;503;502;501;500;499;498;497;496;495;494;493;492;491;490;489;488;487;486;BaseVertexOffset;0.6469972,0.2421383,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;485;2663.656,-100.116;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;486;613.2573,1031.273;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;487;956.2252,940.0511;Inherit;False;SHF_Beat;1;;39;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;1422.812,1024.956;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;1770.842,938.6157;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;490;946.7623,395.2201;Inherit;False;SHF_Beat;1;;40;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WireNode;491;471.9734,519.4935;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;492;607.6892,732.9294;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;1392.607,465.0704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;494;1503.75,346.0169;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;1612.912,719.5707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;496;574.9224,537.7018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;497;1647.409,878.2595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;498;177.4612,675.9113;Inherit;False;Property;_BaseVertexOffsetValue;BaseVertexOffsetValue;7;0;Create;True;0;0;0;False;0;False;0,0,0;0.2,0.2,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;1651.93,442.137;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;500;1144.801,515.8256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;501;1379.586,725.8253;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;502;910.9103,630.6545;Inherit;False;SHF_Beat;1;;41;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WireNode;503;-34.63379,760.7128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;504;177.7554,869.2047;Inherit;False;Property;_BaseVertexOffsetDelay;BaseVertexOffsetDelay;9;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;505;1464.673,-507.1354;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;1709.468,-414.8771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;1340.238,-92.03217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;970.9253,-72.83456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;1203.098,-397.1669;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;510;505.9893,-249.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;981.3383,-272.5997;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;512;1213.513,-282.2012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;513;1625.514,-111.1624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;514;1980.056,-278.5837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;515;1982.432,-110.4632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;919.4702,-616.8812;Inherit;False;Property;_TopMask;TopMask;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;517;1150.457,-873.4573;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;518;1312.078,-715.6713;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;519;765.2012,-731.0012;Inherit;False;Property;_Float2;Float 2;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;520;901.3253,-946.9213;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;521;214.4202,-87.53604;Inherit;False;SHF_Beat;1;;42;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;522;210.6362,-433.6987;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;524;2541.287,-233.4567;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;525;2502.144,-79.58347;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;526;2595.091,868.8402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;527;219.5203,-243.2972;Inherit;False;SHF_Beat;1;;43;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;528;-529.8018,112.0417;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;529;1539.567,237.2827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;530;-35.30273,-178.4938;Inherit;False;Property;_TopVertexDelay;TopVertexDelay;16;1;[Header];Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;531;582.1323,-196.8904;Inherit;False;Property;_TopVertexOffsetValue;TopVertexOffset Value;15;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;532;572.4072,-49.37225;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;533;407.6492,-687.0852;Inherit;True;False;False;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;534;2816.424,-1548.688;Inherit;False;Property;_Using3DMovements;Using3DMovements?;30;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
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
WireConnection;219;1;230;0
WireConnection;219;0;207;0
WireConnection;248;0;185;0
WireConnection;248;1;56;0
WireConnection;189;0;202;0
WireConnection;189;1;248;0
WireConnection;246;3;369;0
WireConnection;194;0;184;0
WireConnection;191;0;194;0
WireConnection;191;1;194;1
WireConnection;430;0;194;2
WireConnection;192;0;191;0
WireConnection;192;1;430;0
WireConnection;257;0;258;1
WireConnection;257;1;258;2
WireConnection;257;2;265;0
WireConnection;265;0;258;3
WireConnection;265;1;260;0
WireConnection;379;1;390;0
WireConnection;379;0;423;0
WireConnection;305;1;197;0
WireConnection;305;0;266;0
WireConnection;436;0;438;0
WireConnection;436;2;439;0
WireConnection;437;0;436;0
WireConnection;391;0;203;0
WireConnection;387;0;391;0
WireConnection;387;1;437;0
WireConnection;438;0;443;0
WireConnection;438;1;440;0
WireConnection;443;0;369;0
WireConnection;390;0;369;0
WireConnection;187;0;189;0
WireConnection;187;1;445;1
WireConnection;187;2;445;2
WireConnection;196;0;203;0
WireConnection;196;1;423;0
WireConnection;328;0;188;0
WireConnection;328;1;192;0
WireConnection;201;11;183;0
WireConnection;201;32;246;0
WireConnection;190;0;201;0
WireConnection;193;0;190;0
WireConnection;193;1;190;1
WireConnection;188;0;193;0
WireConnection;188;1;190;2
WireConnection;423;0;328;0
WireConnection;423;1;186;0
WireConnection;186;0;446;0
WireConnection;186;1;328;0
WireConnection;446;0;187;0
WireConnection;266;0;257;0
WireConnection;266;1;219;0
WireConnection;266;2;289;0
WireConnection;388;1;387;0
WireConnection;388;0;196;0
WireConnection;258;0;219;0
WireConnection;303;0;270;0
WireConnection;303;1;453;0
WireConnection;273;0;303;0
WireConnection;273;2;274;0
WireConnection;449;1;273;0
WireConnection;448;1;275;0
WireConnection;448;0;449;0
WireConnection;275;0;273;0
WireConnection;251;0;379;0
WireConnection;251;2;283;0
WireConnection;255;0;251;0
WireConnection;255;2;282;0
WireConnection;290;0;255;0
WireConnection;289;0;287;0
WireConnection;289;1;290;0
WireConnection;289;2;448;0
WireConnection;197;0;388;0
WireConnection;197;1;266;0
WireConnection;480;1;207;0
WireConnection;480;0;305;0
WireConnection;404;0;480;0
WireConnection;404;9;368;0
WireConnection;404;4;339;0
WireConnection;404;8;534;0
WireConnection;485;0;524;0
WireConnection;485;1;525;0
WireConnection;485;2;526;0
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
WireConnection;514;0;506;0
WireConnection;514;1;499;0
WireConnection;515;0;513;0
WireConnection;515;1;495;0
WireConnection;517;0;520;0
WireConnection;518;0;533;0
WireConnection;518;1;516;0
WireConnection;520;0;533;0
WireConnection;520;1;519;0
WireConnection;521;54;530;2
WireConnection;524;0;514;0
WireConnection;525;0;515;0
WireConnection;526;0;489;0
WireConnection;527;54;530;1
WireConnection;529;0;528;1
WireConnection;532;0;521;33
WireConnection;533;0;528;3
WireConnection;534;0;485;0
ASEEND*/
//CHKSM=7883BEB6C15620D8DDA2EDFEC3847FC2B869A474