// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_3DMaster"
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
		_OutlineWidth("Outline Width", Range( 0 , 0.1)) = 0.1
		_TimeDelay("TimeDelay", Float) = 0
		_DistanceCutoff("Distance Cutoff", Range( 0 , 100)) = 0
		_MainTex("Base Color", 2D) = "white" {}
		_BaseVertexOffsetValue("BaseVertexOffsetValue", Vector) = (0,0,0,0)
		_BaseVertexOffsetDelay("BaseVertexOffsetDelay", Vector) = (0,0,0,0)
		_TopMask("TopMask", Float) = 0
		_TopVertexOffsetValue("TopVertexOffset Value", Vector) = (0,0,0,0)
		_TopVertexDelay("TopVertexDelay", Vector) = (0,0,0,0)
		[Toggle(_USING3DMOVEMENTS_ON)] _Using3DMovements("Using3DMovements?", Float) = 0
		_FresnelErase("FresnelErase", Float) = 0.01
		[Toggle(_USINGTRIPLANAR1_ON)] _UsingTriplanar1("UsingTriplanar?", Float) = 0
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
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature_local _ISENNEMIES_ON
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;
			sampler2D _BumpNormal;
			sampler2D _MainTex;
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
			
			
			float4 SampleLightmapHD11_g185( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g185(  )
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
			
			half4 CalculateShadowMask1_g171( half2 LightmapUV )
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
					float2 voronoihash73_g170( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g170( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash73_g170( n + g );
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
			
			inline float4 TriplanarSampling81_g170( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
				
				float2 texCoord2_g185 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g185 = ( ( texCoord2_g185 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.xy = vertexToFrag10_g185;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.zw = v.texcoord.xy;
				
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

				Gradient gradient30_g170 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g185 = IN.ase_texcoord8.xy;
				float2 UV11_g185 = vertexToFrag10_g185;
				float4 localSampleLightmapHD11_g185 = SampleLightmapHD11_g185( UV11_g185 );
				float4 localURPDecodeInstruction19_g185 = URPDecodeInstruction19_g185();
				float3 decodeLightMap6_g185 = DecodeLightmap(localSampleLightmapHD11_g185,localURPDecodeInstruction19_g185);
				float3 Lightmaps28_g170 = decodeLightMap6_g185;
				float3 clampResult14_g170 = clamp( (( Lightmaps28_g170 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g173 = WorldPosition;
				float3 WorldPosition86_g173 = worldPosValue44_g173;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g173 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g173 = ScreenUV75_g173;
				float2 uv_BumpNormal = IN.ase_texcoord8.zw * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack55_g170 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g170.z = lerp( 1, unpack55_g170.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal44_g170 = unpack55_g170;
				float3 worldNormal44_g170 = normalize( float3(dot(tanToWorld0,tanNormal44_g170), dot(tanToWorld1,tanNormal44_g170), dot(tanToWorld2,tanNormal44_g170)) );
				float3 worldNormal43_g170 = worldNormal44_g170;
				float3 worldNormalValue50_g173 = worldNormal43_g170;
				float3 WorldNormal86_g173 = worldNormalValue50_g173;
				half2 LightmapUV1_g171 = Lightmaps28_g170.xy;
				half4 localCalculateShadowMask1_g171 = CalculateShadowMask1_g171( LightmapUV1_g171 );
				float4 shadowMaskValue33_g173 = localCalculateShadowMask1_g171;
				float4 ShadowMask86_g173 = shadowMaskValue33_g173;
				float3 localAdditionalLightsLambertMask14x86_g173 = AdditionalLightsLambertMask14x( WorldPosition86_g173 , ScreenUV86_g173 , WorldNormal86_g173 , ShadowMask86_g173 );
				float3 lambertResult38_g173 = localAdditionalLightsLambertMask14x86_g173;
				float3 break19_g170 = lambertResult38_g173;
				float3 mainLight52_g170 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g170 = mainLight52_g170;
				float temp_output_36_0_g170 = ( max( max( break19_g170.x , break19_g170.y ) , break19_g170.z ) + max( max( break9_g170.x , break9_g170.y ) , break9_g170.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult3_g170 = dot( worldNormal43_g170 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g170 = ( temp_output_36_0_g170 + ( (dotResult3_g170*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g170 ) );
				float2 uv_MainTex = IN.ase_texcoord8.zw * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_107_0_g170 = tex2D( _MainTex, uv_MainTex );
				float3 hsvTorgb58_g170 = RGBToHSV( temp_output_107_0_g170.rgb );
				float3 hsvTorgb57_g170 = HSVToRGB( float3(hsvTorgb58_g170.x,hsvTorgb58_g170.y,( hsvTorgb58_g170.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g170 = temp_output_24_0_g170;
				float3 clampResult61_g170 = clamp( (( ( Lightmaps28_g170 + RealtimeLights34_g170 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g170 = 0.0;
				float2 voronoiSmoothId73_g170 = 0;
				float voronoiSmooth73_g170 = 0.0;
				float2 texCoord70_g170 = IN.ase_texcoord8.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g170 = ( texCoord70_g170 * _ShadowPatternDensity );
				float2 coords73_g170 = temp_output_72_0_g170 * 1.0;
				float2 id73_g170 = 0;
				float2 uv73_g170 = 0;
				float voroi73_g170 = voronoi73_g170( coords73_g170, time73_g170, id73_g170, uv73_g170, voronoiSmooth73_g170, voronoiSmoothId73_g170 );
				float2 temp_cast_5 = (voroi73_g170).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g170 = half2(0,0);
				#else
				float2 staticSwitch74_g170 = temp_cast_5;
				#endif
				float2 temp_cast_6 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g170 = ( WorldPosition / _WorldPosDiv );
				float3 break92_g170 = temp_output_93_0_g170;
				float2 appendResult91_g170 = (float2(break92_g170.x , break92_g170.z));
				float4 triplanar81_g170 = TriplanarSampling81_g170( _ShadowTex, temp_output_93_0_g170, WorldNormal, 1.0, ( appendResult91_g170 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g170 = triplanar81_g170;
				#else
				float4 staticSwitch82_g170 = tex2D( _ShadowTex, temp_output_72_0_g170 );
				#endif
				float4 temp_cast_9 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g170 = pow( staticSwitch82_g170 , temp_cast_9 );
				#else
				float4 staticSwitch69_g170 = float4( pow( staticSwitch74_g170 , temp_cast_6 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g170 = smoothstep( clampResult61_g170.x , staticSwitch69_g170.r , 1.0);
				float4 lerpResult96_g170 = lerp( float4( hsvTorgb57_g170 , 0.0 ) , temp_output_107_0_g170 , smoothstepResult98_g170);
				float2 texCoord712 = IN.ase_texcoord8.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord8.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , ( simplePerlin2D728 * simplePerlin2D785 ));
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float temp_output_52_0_g63 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TimeDelay );
				float temp_output_16_0_g63 = ( PI / 1.0 );
				float temp_output_19_0_g63 = cos( ( temp_output_52_0_g63 * temp_output_16_0_g63 ) );
				float saferPower20_g63 = abs( abs( temp_output_19_0_g63 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g63 , 20.0 ));
				float fresnelNdotV707 = dot( half3(0,0,0), WorldViewDirection );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * 0.0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = ( ( SampleGradient( gradient30_g170, clampResult14_g170.x ) + SampleGradient( gradient30_g170, temp_output_24_0_g170 ) ) * lerpResult96_g170 );
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				
				float3 temp_cast_12 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch753.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_12;
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
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;


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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;


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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature_local _ISENNEMIES_ON
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;
			sampler2D _BumpNormal;
			sampler2D _MainTex;
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
			
			
			float4 SampleLightmapHD11_g185( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g185(  )
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
			
			half4 CalculateShadowMask1_g171( half2 LightmapUV )
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
					float2 voronoihash73_g170( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g170( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash73_g170( n + g );
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
			
			inline float4 TriplanarSampling81_g170( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
				
				float2 texCoord2_g185 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g185 = ( ( texCoord2_g185 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord4.xy = vertexToFrag10_g185;
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
				
				o.ase_texcoord4.zw = v.texcoord0.xy;
				
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

				Gradient gradient30_g170 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g185 = IN.ase_texcoord4.xy;
				float2 UV11_g185 = vertexToFrag10_g185;
				float4 localSampleLightmapHD11_g185 = SampleLightmapHD11_g185( UV11_g185 );
				float4 localURPDecodeInstruction19_g185 = URPDecodeInstruction19_g185();
				float3 decodeLightMap6_g185 = DecodeLightmap(localSampleLightmapHD11_g185,localURPDecodeInstruction19_g185);
				float3 Lightmaps28_g170 = decodeLightMap6_g185;
				float3 clampResult14_g170 = clamp( (( Lightmaps28_g170 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g173 = WorldPosition;
				float3 WorldPosition86_g173 = worldPosValue44_g173;
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g173 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g173 = ScreenUV75_g173;
				float2 uv_BumpNormal = IN.ase_texcoord4.zw * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack55_g170 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g170.z = lerp( 1, unpack55_g170.z, saturate(_NormalScale) );
				float3 ase_worldTangent = IN.ase_texcoord6.xyz;
				float3 ase_worldNormal = IN.ase_texcoord7.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord8.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal44_g170 = unpack55_g170;
				float3 worldNormal44_g170 = normalize( float3(dot(tanToWorld0,tanNormal44_g170), dot(tanToWorld1,tanNormal44_g170), dot(tanToWorld2,tanNormal44_g170)) );
				float3 worldNormal43_g170 = worldNormal44_g170;
				float3 worldNormalValue50_g173 = worldNormal43_g170;
				float3 WorldNormal86_g173 = worldNormalValue50_g173;
				half2 LightmapUV1_g171 = Lightmaps28_g170.xy;
				half4 localCalculateShadowMask1_g171 = CalculateShadowMask1_g171( LightmapUV1_g171 );
				float4 shadowMaskValue33_g173 = localCalculateShadowMask1_g171;
				float4 ShadowMask86_g173 = shadowMaskValue33_g173;
				float3 localAdditionalLightsLambertMask14x86_g173 = AdditionalLightsLambertMask14x( WorldPosition86_g173 , ScreenUV86_g173 , WorldNormal86_g173 , ShadowMask86_g173 );
				float3 lambertResult38_g173 = localAdditionalLightsLambertMask14x86_g173;
				float3 break19_g170 = lambertResult38_g173;
				float3 mainLight52_g170 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g170 = mainLight52_g170;
				float temp_output_36_0_g170 = ( max( max( break19_g170.x , break19_g170.y ) , break19_g170.z ) + max( max( break9_g170.x , break9_g170.y ) , break9_g170.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult3_g170 = dot( worldNormal43_g170 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g170 = ( temp_output_36_0_g170 + ( (dotResult3_g170*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g170 ) );
				float2 uv_MainTex = IN.ase_texcoord4.zw * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_107_0_g170 = tex2D( _MainTex, uv_MainTex );
				float3 hsvTorgb58_g170 = RGBToHSV( temp_output_107_0_g170.rgb );
				float3 hsvTorgb57_g170 = HSVToRGB( float3(hsvTorgb58_g170.x,hsvTorgb58_g170.y,( hsvTorgb58_g170.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g170 = temp_output_24_0_g170;
				float3 clampResult61_g170 = clamp( (( ( Lightmaps28_g170 + RealtimeLights34_g170 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g170 = 0.0;
				float2 voronoiSmoothId73_g170 = 0;
				float voronoiSmooth73_g170 = 0.0;
				float2 texCoord70_g170 = IN.ase_texcoord4.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g170 = ( texCoord70_g170 * _ShadowPatternDensity );
				float2 coords73_g170 = temp_output_72_0_g170 * 1.0;
				float2 id73_g170 = 0;
				float2 uv73_g170 = 0;
				float voroi73_g170 = voronoi73_g170( coords73_g170, time73_g170, id73_g170, uv73_g170, voronoiSmooth73_g170, voronoiSmoothId73_g170 );
				float2 temp_cast_5 = (voroi73_g170).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g170 = half2(0,0);
				#else
				float2 staticSwitch74_g170 = temp_cast_5;
				#endif
				float2 temp_cast_6 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g170 = ( WorldPosition / _WorldPosDiv );
				float3 break92_g170 = temp_output_93_0_g170;
				float2 appendResult91_g170 = (float2(break92_g170.x , break92_g170.z));
				float4 triplanar81_g170 = TriplanarSampling81_g170( _ShadowTex, temp_output_93_0_g170, ase_worldNormal, 1.0, ( appendResult91_g170 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g170 = triplanar81_g170;
				#else
				float4 staticSwitch82_g170 = tex2D( _ShadowTex, temp_output_72_0_g170 );
				#endif
				float4 temp_cast_9 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g170 = pow( staticSwitch82_g170 , temp_cast_9 );
				#else
				float4 staticSwitch69_g170 = float4( pow( staticSwitch74_g170 , temp_cast_6 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g170 = smoothstep( clampResult61_g170.x , staticSwitch69_g170.r , 1.0);
				float4 lerpResult96_g170 = lerp( float4( hsvTorgb57_g170 , 0.0 ) , temp_output_107_0_g170 , smoothstepResult98_g170);
				float2 texCoord712 = IN.ase_texcoord4.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord4.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , ( simplePerlin2D728 * simplePerlin2D785 ));
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float temp_output_52_0_g63 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TimeDelay );
				float temp_output_16_0_g63 = ( PI / 1.0 );
				float temp_output_19_0_g63 = cos( ( temp_output_52_0_g63 * temp_output_16_0_g63 ) );
				float saferPower20_g63 = abs( abs( temp_output_19_0_g63 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g63 , 20.0 ));
				float fresnelNdotV707 = dot( half3(0,0,0), ase_worldViewDir );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * 0.0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = ( ( SampleGradient( gradient30_g170, clampResult14_g170.x ) + SampleGradient( gradient30_g170, temp_output_24_0_g170 ) ) * lerpResult96_g170 );
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
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature_local _ISENNEMIES_ON
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;
			sampler2D _BumpNormal;
			sampler2D _MainTex;
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
			
			
			float4 SampleLightmapHD11_g185( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g185(  )
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
			
			half4 CalculateShadowMask1_g171( half2 LightmapUV )
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
					float2 voronoihash73_g170( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g170( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash73_g170( n + g );
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
			
			inline float4 TriplanarSampling81_g170( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
				
				float2 texCoord2_g185 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g185 = ( ( texCoord2_g185 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord2.xy = vertexToFrag10_g185;
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
				
				o.ase_texcoord2.zw = v.ase_texcoord.xy;
				
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

				Gradient gradient30_g170 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g185 = IN.ase_texcoord2.xy;
				float2 UV11_g185 = vertexToFrag10_g185;
				float4 localSampleLightmapHD11_g185 = SampleLightmapHD11_g185( UV11_g185 );
				float4 localURPDecodeInstruction19_g185 = URPDecodeInstruction19_g185();
				float3 decodeLightMap6_g185 = DecodeLightmap(localSampleLightmapHD11_g185,localURPDecodeInstruction19_g185);
				float3 Lightmaps28_g170 = decodeLightMap6_g185;
				float3 clampResult14_g170 = clamp( (( Lightmaps28_g170 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g173 = WorldPosition;
				float3 WorldPosition86_g173 = worldPosValue44_g173;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g173 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g173 = ScreenUV75_g173;
				float2 uv_BumpNormal = IN.ase_texcoord2.zw * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack55_g170 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g170.z = lerp( 1, unpack55_g170.z, saturate(_NormalScale) );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal44_g170 = unpack55_g170;
				float3 worldNormal44_g170 = normalize( float3(dot(tanToWorld0,tanNormal44_g170), dot(tanToWorld1,tanNormal44_g170), dot(tanToWorld2,tanNormal44_g170)) );
				float3 worldNormal43_g170 = worldNormal44_g170;
				float3 worldNormalValue50_g173 = worldNormal43_g170;
				float3 WorldNormal86_g173 = worldNormalValue50_g173;
				half2 LightmapUV1_g171 = Lightmaps28_g170.xy;
				half4 localCalculateShadowMask1_g171 = CalculateShadowMask1_g171( LightmapUV1_g171 );
				float4 shadowMaskValue33_g173 = localCalculateShadowMask1_g171;
				float4 ShadowMask86_g173 = shadowMaskValue33_g173;
				float3 localAdditionalLightsLambertMask14x86_g173 = AdditionalLightsLambertMask14x( WorldPosition86_g173 , ScreenUV86_g173 , WorldNormal86_g173 , ShadowMask86_g173 );
				float3 lambertResult38_g173 = localAdditionalLightsLambertMask14x86_g173;
				float3 break19_g170 = lambertResult38_g173;
				float3 mainLight52_g170 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g170 = mainLight52_g170;
				float temp_output_36_0_g170 = ( max( max( break19_g170.x , break19_g170.y ) , break19_g170.z ) + max( max( break9_g170.x , break9_g170.y ) , break9_g170.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord7.xyz;
				float dotResult3_g170 = dot( worldNormal43_g170 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g170 = ( temp_output_36_0_g170 + ( (dotResult3_g170*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g170 ) );
				float2 uv_MainTex = IN.ase_texcoord2.zw * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_107_0_g170 = tex2D( _MainTex, uv_MainTex );
				float3 hsvTorgb58_g170 = RGBToHSV( temp_output_107_0_g170.rgb );
				float3 hsvTorgb57_g170 = HSVToRGB( float3(hsvTorgb58_g170.x,hsvTorgb58_g170.y,( hsvTorgb58_g170.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g170 = temp_output_24_0_g170;
				float3 clampResult61_g170 = clamp( (( ( Lightmaps28_g170 + RealtimeLights34_g170 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g170 = 0.0;
				float2 voronoiSmoothId73_g170 = 0;
				float voronoiSmooth73_g170 = 0.0;
				float2 texCoord70_g170 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g170 = ( texCoord70_g170 * _ShadowPatternDensity );
				float2 coords73_g170 = temp_output_72_0_g170 * 1.0;
				float2 id73_g170 = 0;
				float2 uv73_g170 = 0;
				float voroi73_g170 = voronoi73_g170( coords73_g170, time73_g170, id73_g170, uv73_g170, voronoiSmooth73_g170, voronoiSmoothId73_g170 );
				float2 temp_cast_5 = (voroi73_g170).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g170 = half2(0,0);
				#else
				float2 staticSwitch74_g170 = temp_cast_5;
				#endif
				float2 temp_cast_6 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g170 = ( WorldPosition / _WorldPosDiv );
				float3 break92_g170 = temp_output_93_0_g170;
				float2 appendResult91_g170 = (float2(break92_g170.x , break92_g170.z));
				float4 triplanar81_g170 = TriplanarSampling81_g170( _ShadowTex, temp_output_93_0_g170, ase_worldNormal, 1.0, ( appendResult91_g170 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g170 = triplanar81_g170;
				#else
				float4 staticSwitch82_g170 = tex2D( _ShadowTex, temp_output_72_0_g170 );
				#endif
				float4 temp_cast_9 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g170 = pow( staticSwitch82_g170 , temp_cast_9 );
				#else
				float4 staticSwitch69_g170 = float4( pow( staticSwitch74_g170 , temp_cast_6 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g170 = smoothstep( clampResult61_g170.x , staticSwitch69_g170.r , 1.0);
				float4 lerpResult96_g170 = lerp( float4( hsvTorgb57_g170 , 0.0 ) , temp_output_107_0_g170 , smoothstepResult98_g170);
				float2 texCoord712 = IN.ase_texcoord2.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord2.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , ( simplePerlin2D728 * simplePerlin2D785 ));
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float temp_output_52_0_g63 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TimeDelay );
				float temp_output_16_0_g63 = ( PI / 1.0 );
				float temp_output_19_0_g63 = cos( ( temp_output_52_0_g63 * temp_output_16_0_g63 ) );
				float saferPower20_g63 = abs( abs( temp_output_19_0_g63 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g63 , 20.0 ));
				float fresnelNdotV707 = dot( half3(0,0,0), ase_worldViewDir );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * 0.0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = ( ( SampleGradient( gradient30_g170, clampResult14_g170.x ) + SampleGradient( gradient30_g170, temp_output_24_0_g170 ) ) * lerpResult96_g170 );
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
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;


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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#pragma shader_feature_local _ISOUTLINE_ON
			#pragma shader_feature_local _USING3DMOVEMENTS_ON
			#pragma shader_feature_local _ISENNEMIES_ON
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;
			sampler2D _BumpNormal;
			sampler2D _MainTex;
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
			
			
			float4 SampleLightmapHD11_g185( float2 UV )
			{
				return SAMPLE_TEXTURE2D( unity_Lightmap, samplerunity_Lightmap, UV );
			}
			
			float4 URPDecodeInstruction19_g185(  )
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
			
			half4 CalculateShadowMask1_g171( half2 LightmapUV )
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
					float2 voronoihash73_g170( float2 p )
					{
						p = p - 1 * floor( p / 1 );
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi73_g170( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
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
						 		float2 o = voronoihash73_g170( n + g );
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
			
			inline float4 TriplanarSampling81_g170( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
				
				float2 texCoord2_g185 = v.texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 vertexToFrag10_g185 = ( ( texCoord2_g185 * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
				o.ase_texcoord8.xy = vertexToFrag10_g185;
				float3 objectSpaceLightDir = mul( GetWorldToObjectMatrix(), _MainLightPosition ).xyz;
				o.ase_texcoord9.xyz = objectSpaceLightDir;
				
				o.ase_texcoord8.zw = v.texcoord.xy;
				
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

				Gradient gradient30_g170 = NewGradient( 1, 4, 2, float4( 0.5911949, 0.5818993, 0.5818993, 0.2 ), float4( 0.6918238, 0.6918238, 0.6918238, 0.4422675 ), float4( 0.8805031, 0.8805031, 0.8805031, 0.7632105 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 vertexToFrag10_g185 = IN.ase_texcoord8.xy;
				float2 UV11_g185 = vertexToFrag10_g185;
				float4 localSampleLightmapHD11_g185 = SampleLightmapHD11_g185( UV11_g185 );
				float4 localURPDecodeInstruction19_g185 = URPDecodeInstruction19_g185();
				float3 decodeLightMap6_g185 = DecodeLightmap(localSampleLightmapHD11_g185,localURPDecodeInstruction19_g185);
				float3 Lightmaps28_g170 = decodeLightMap6_g185;
				float3 clampResult14_g170 = clamp( (( Lightmaps28_g170 * _Cels_FallOffThreshold )*1.0 + _Cels_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float3 worldPosValue44_g173 = WorldPosition;
				float3 WorldPosition86_g173 = worldPosValue44_g173;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 ScreenUV75_g173 = (ase_screenPosNorm).xy;
				float2 ScreenUV86_g173 = ScreenUV75_g173;
				float2 uv_BumpNormal = IN.ase_texcoord8.zw * _BumpNormal_ST.xy + _BumpNormal_ST.zw;
				float3 unpack55_g170 = UnpackNormalScale( tex2D( _BumpNormal, uv_BumpNormal ), _NormalScale );
				unpack55_g170.z = lerp( 1, unpack55_g170.z, saturate(_NormalScale) );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal44_g170 = unpack55_g170;
				float3 worldNormal44_g170 = normalize( float3(dot(tanToWorld0,tanNormal44_g170), dot(tanToWorld1,tanNormal44_g170), dot(tanToWorld2,tanNormal44_g170)) );
				float3 worldNormal43_g170 = worldNormal44_g170;
				float3 worldNormalValue50_g173 = worldNormal43_g170;
				float3 WorldNormal86_g173 = worldNormalValue50_g173;
				half2 LightmapUV1_g171 = Lightmaps28_g170.xy;
				half4 localCalculateShadowMask1_g171 = CalculateShadowMask1_g171( LightmapUV1_g171 );
				float4 shadowMaskValue33_g173 = localCalculateShadowMask1_g171;
				float4 ShadowMask86_g173 = shadowMaskValue33_g173;
				float3 localAdditionalLightsLambertMask14x86_g173 = AdditionalLightsLambertMask14x( WorldPosition86_g173 , ScreenUV86_g173 , WorldNormal86_g173 , ShadowMask86_g173 );
				float3 lambertResult38_g173 = localAdditionalLightsLambertMask14x86_g173;
				float3 break19_g170 = lambertResult38_g173;
				float3 mainLight52_g170 = ( float3( 0,0,0 ) * _MainLightColor.rgb );
				float3 break9_g170 = mainLight52_g170;
				float temp_output_36_0_g170 = ( max( max( break19_g170.x , break19_g170.y ) , break19_g170.z ) + max( max( break9_g170.x , break9_g170.y ) , break9_g170.z ) );
				float3 objectSpaceLightDir = IN.ase_texcoord9.xyz;
				float dotResult3_g170 = dot( worldNormal43_g170 , ( SafeNormalize(_MainLightPosition.xyz) + objectSpaceLightDir ) );
				float2 _RT_SO = float2(0,0);
				float temp_output_24_0_g170 = ( temp_output_36_0_g170 + ( (dotResult3_g170*_RT_SO.x + _RT_SO.y) * temp_output_36_0_g170 ) );
				float2 uv_MainTex = IN.ase_texcoord8.zw * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_107_0_g170 = tex2D( _MainTex, uv_MainTex );
				float3 hsvTorgb58_g170 = RGBToHSV( temp_output_107_0_g170.rgb );
				float3 hsvTorgb57_g170 = HSVToRGB( float3(hsvTorgb58_g170.x,hsvTorgb58_g170.y,( hsvTorgb58_g170.z * _ShadingWhiteMult )) );
				float RealtimeLights34_g170 = temp_output_24_0_g170;
				float3 clampResult61_g170 = clamp( (( ( Lightmaps28_g170 + RealtimeLights34_g170 ) * float3( -1,-1,-1 ) * _Shadow_FallOffThreshold )*1.0 + _Shadow_LitThreshold) , float3( 0,0,0 ) , float3( 1,1,1 ) );
				float time73_g170 = 0.0;
				float2 voronoiSmoothId73_g170 = 0;
				float voronoiSmooth73_g170 = 0.0;
				float2 texCoord70_g170 = IN.ase_texcoord8.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_72_0_g170 = ( texCoord70_g170 * _ShadowPatternDensity );
				float2 coords73_g170 = temp_output_72_0_g170 * 1.0;
				float2 id73_g170 = 0;
				float2 uv73_g170 = 0;
				float voroi73_g170 = voronoi73_g170( coords73_g170, time73_g170, id73_g170, uv73_g170, voronoiSmooth73_g170, voronoiSmoothId73_g170 );
				float2 temp_cast_5 = (voroi73_g170).xx;
				#ifdef _USINGTRIPLANAR1_ON
				float2 staticSwitch74_g170 = half2(0,0);
				#else
				float2 staticSwitch74_g170 = temp_cast_5;
				#endif
				float2 temp_cast_6 = (_ShadowTex_Pow).xx;
				float3 temp_output_93_0_g170 = ( WorldPosition / _WorldPosDiv );
				float3 break92_g170 = temp_output_93_0_g170;
				float2 appendResult91_g170 = (float2(break92_g170.x , break92_g170.z));
				float4 triplanar81_g170 = TriplanarSampling81_g170( _ShadowTex, temp_output_93_0_g170, WorldNormal, 1.0, ( appendResult91_g170 * _ShadowPatternDensity ), 1.0, 0 );
				#ifdef _USINGTRIPLANAR_ON
				float4 staticSwitch82_g170 = triplanar81_g170;
				#else
				float4 staticSwitch82_g170 = tex2D( _ShadowTex, temp_output_72_0_g170 );
				#endif
				float4 temp_cast_9 = (_ShadowTex_Pow).xxxx;
				#ifdef _SHADOWS_PROCEDURALORTEXTURE_ON
				float4 staticSwitch69_g170 = pow( staticSwitch82_g170 , temp_cast_9 );
				#else
				float4 staticSwitch69_g170 = float4( pow( staticSwitch74_g170 , temp_cast_6 ), 0.0 , 0.0 );
				#endif
				float smoothstepResult98_g170 = smoothstep( clampResult61_g170.x , staticSwitch69_g170.r , 1.0);
				float4 lerpResult96_g170 = lerp( float4( hsvTorgb57_g170 , 0.0 ) , temp_output_107_0_g170 , smoothstepResult98_g170);
				float2 texCoord712 = IN.ase_texcoord8.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D728 = snoise( ( texCoord712 * float2( 0,40 ) )*5.0 );
				simplePerlin2D728 = simplePerlin2D728*0.5 + 0.5;
				float2 texCoord789 = IN.ase_texcoord8.zw * float2( 1,1 ) + ( _TimeParameters.x * float2( 0,0.001 ) );
				float simplePerlin2D785 = snoise( ( texCoord789 * float2( 0,40 ) )*5.0 );
				simplePerlin2D785 = simplePerlin2D785*0.5 + 0.5;
				float smoothstepResult805 = smoothstep( 0.1 , 1.0 , ( simplePerlin2D728 * simplePerlin2D785 ));
				float4 lerpResult802 = lerp( _OutlineColor , _OutlineColor2 , smoothstepResult805);
				float temp_output_52_0_g63 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TimeDelay );
				float temp_output_16_0_g63 = ( PI / 1.0 );
				float temp_output_19_0_g63 = cos( ( temp_output_52_0_g63 * temp_output_16_0_g63 ) );
				float saferPower20_g63 = abs( abs( temp_output_19_0_g63 ) );
				float lerpResult811 = lerp( ( _FresnelPower * 2.0 ) , _FresnelPower , pow( saferPower20_g63 , 20.0 ));
				float fresnelNdotV707 = dot( half3(0,0,0), WorldViewDirection );
				float fresnelNode707 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV707, lerpResult811 ) );
				float smoothstepResult718 = smoothstep( _FresnelErase , ( _FresnelErase * _FresnelErase_Smoothness ) , ( fresnelNode707 * 0.0 ));
				float smoothstepResult817 = smoothstep( 0.3 , ( 0.3 * 2.0 ) , fresnelNode707);
				float4 OutlineColors747 = _OutlineColor;
				float4 lerpResult824 = lerp( ( lerpResult802 * saturate( smoothstepResult718 ) ) , ( smoothstepResult817 * OutlineColors747 ) , smoothstepResult817);
				float4 FresnelEffects726 = lerpResult824;
				#ifdef _ISENNEMIES_ON
				float4 staticSwitch725 = FresnelEffects726;
				#else
				float4 staticSwitch725 = ( ( SampleGradient( gradient30_g170, clampResult14_g170.x ) + SampleGradient( gradient30_g170, temp_output_24_0_g170 ) ) * lerpResult96_g170 );
				#endif
				#ifdef _ISOUTLINE_ON
				float4 staticSwitch753 = OutlineColors747;
				#else
				float4 staticSwitch753 = staticSwitch725;
				#endif
				
				float3 temp_cast_12 = (0.0).xxx;
				

				float3 BaseColor = staticSwitch753.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = temp_cast_12;
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
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;


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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
			float4 _MainTex_ST;
			float4 _OutlineColor2;
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
			float _Shadow_LitThreshold;
			float _TopMask;
			float _ShadingWhiteMult;
			float _FresnelPower;
			float _NormalScale;
			float _Cels_LitThreshold;
			float _Cels_FallOffThreshold;
			float _DistanceCutoff;
			float _OutlineWidth;
			float _BPM;
			float _Shadow_FallOffThreshold;
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
			float UnscaledDT;


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
				float temp_output_52_0_g62 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.x );
				float temp_output_16_0_g62 = ( PI / 1.0 );
				float temp_output_19_0_g62 = cos( ( temp_output_52_0_g62 * temp_output_16_0_g62 ) );
				float saferPower20_g62 = abs( abs( temp_output_19_0_g62 ) );
				float temp_output_52_0_g60 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.x );
				float temp_output_16_0_g60 = ( PI / 1.0 );
				float temp_output_19_0_g60 = cos( ( temp_output_52_0_g60 * temp_output_16_0_g60 ) );
				float saferPower20_g60 = abs( abs( temp_output_19_0_g60 ) );
				float temp_output_52_0_g61 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _TopVertexDelay.y );
				float temp_output_16_0_g61 = ( PI / 1.0 );
				float temp_output_19_0_g61 = cos( ( temp_output_52_0_g61 * temp_output_16_0_g61 ) );
				float saferPower20_g61 = abs( abs( temp_output_19_0_g61 ) );
				float temp_output_52_0_g64 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.y );
				float temp_output_16_0_g64 = ( PI / 1.0 );
				float temp_output_19_0_g64 = cos( ( temp_output_52_0_g64 * temp_output_16_0_g64 ) );
				float saferPower20_g64 = abs( abs( temp_output_19_0_g64 ) );
				float temp_output_52_0_g59 = ( ( UnscaledDT * ( BPM / 60.0 ) ) - _BaseVertexOffsetDelay.z );
				float temp_output_16_0_g59 = ( PI / 1.0 );
				float temp_output_19_0_g59 = cos( ( temp_output_52_0_g59 * temp_output_16_0_g59 ) );
				float saferPower20_g59 = abs( abs( temp_output_19_0_g59 ) );
				float3 appendResult485 = (float3(( ( clampResult505 * ( transform522.x * ( pow( saferPower20_g62 , 20.0 ) * _TopVertexOffsetValue.x ) ) ) + ( v.vertex.xyz.x * ( pow( saferPower20_g60 , 20.0 ) * _BaseVertexOffsetValue.x ) ) ) , ( ( clampResult505 * ( transform522.y * ( pow( saferPower20_g61 , 20.0 ) * _TopVertexOffsetValue.y ) ) ) + ( v.vertex.xyz.y * ( pow( saferPower20_g64 , 20.0 ) * _BaseVertexOffsetValue.y ) ) ) , ( v.vertex.xyz.z * ( pow( saferPower20_g59 , 20.0 ) * _BaseVertexOffsetValue.z ) )));
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
Node;AmplifyShaderEditor.CommentaryNode;854;-413.0556,3926.71;Inherit;False;2826.863;1415.587;;39;707;708;712;801;713;728;785;811;722;800;823;798;789;788;724;809;802;804;784;848;812;732;791;795;783;726;717;829;828;827;825;817;814;824;718;723;805;787;747;OutlineShading;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;853;-369.9379,2315.409;Inherit;False;2448.865;1553.827;;24;780;765;757;766;767;775;769;771;770;763;758;759;760;762;761;781;774;830;831;832;835;836;837;834;OutlineVertex;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;756;-5375.165,-3905.862;Inherit;False;2980.416;1045.208;;30;646;670;668;669;654;647;649;655;643;650;648;684;685;686;667;641;682;681;651;652;659;660;666;662;661;658;657;653;671;754;TriplnarDots;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;481;-323.888,-327.3439;Inherit;False;2213.736;1069.384;;21;533;532;531;530;522;520;519;518;517;516;515;514;513;512;511;510;509;508;507;506;505;TopVertexOffset;1,0.3930817,0.6767163,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;482;-323.2193,771.636;Inherit;False;2323.009;1021.379;;17;529;504;503;501;500;499;498;497;496;495;494;493;492;491;489;488;486;BaseVertexOffset;0.6469972,0.2421383,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;515;1743.847,559.1142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;486;374.6719,1662.998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;1184.227,1656.681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;1532.257,1570.341;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;491;233.3878,1151.219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;492;369.1038,1364.655;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;1154.022,1096.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;494;1265.165,977.7419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;1374.327,1351.296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;496;336.3369,1169.427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;497;1408.824,1509.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;498;-61.12444,1307.637;Inherit;False;Property;_BaseVertexOffsetValue;BaseVertexOffsetValue;31;0;Create;True;0;0;0;False;0;False;0,0,0;0.2,0.2,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;1413.345,1073.862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;500;906.2154,1147.551;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;501;1141.001,1357.551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;503;-273.2193,1392.438;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;504;-60.83023,1500.93;Inherit;False;Property;_BaseVertexOffsetDelay;BaseVertexOffsetDelay;32;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;505;1226.088,162.4421;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;1470.883,254.7004;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;1101.653,577.5452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;732.3401,596.7429;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;964.5128,272.4106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;510;267.404,420.0134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;742.7531,396.9777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;512;974.9277,387.3762;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;513;1386.929,558.415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;680.885,52.69627;Inherit;False;Property;_TopMask;TopMask;33;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;517;911.8718,-203.8798;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;518;1073.493,-46.09374;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;519;526.616,-61.42362;Inherit;False;Property;_Float2;Float 2;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;520;662.7401,-277.3438;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;522;-27.94916,235.8788;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;529;1300.982,869.0081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;530;-273.8881,491.0836;Inherit;False;Property;_TopVertexDelay;TopVertexDelay;36;1;[Header];Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;531;343.547,472.687;Inherit;False;Property;_TopVertexOffsetValue;TopVertexOffset Value;35;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;514;1650.261,389.0531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;485;2143.432,524.8366;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;617;2311.111,525.059;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode;273;-1197.615,-390.1845;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-1443.25,-292.1817;Inherit;False;Property;_ShadowPatternRotator;ShadowPatternRotator;37;0;Create;True;0;0;0;False;0;False;12.48;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;533;-99.06578,-97.18044;Inherit;True;False;False;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;532;492.3669,616.6875;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;528;-587.4907,758.6886;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;403;3436.395,-2082.329;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;730;3240.327,-2190.673;Inherit;False;726;FresnelEffects;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;725;3504.915,-2295.023;Inherit;False;Property;_IsEnnemies;IsEnnemies;40;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;753;3716.537,-2293.083;Inherit;False;Property;_Keyword1;Keyword 1;43;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;750;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;752;3492.846,-2193.22;Inherit;False;747;OutlineColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;703;-2907.561,1970.125;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;384;3747.825,-2198.049;Inherit;False;-1;;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;404;4072.93,-2291.077;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;SHR_3DMaster;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;20;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;41;Workflow;0;638793705028820884;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;638833736281707076;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;638846249472107598;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;368;3752.651,-2145.322;Inherit;False;Constant;_Spec;Spec;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;3735.613,-2080.527;Inherit;False;Constant;_Smoothness;Smoothness;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;844;717.6396,1571.776;Inherit;False;SHF_Beat;27;;59;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;845;708.1767,1026.945;Inherit;False;SHF_Beat;27;;60;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;846;-24.16517,582.0414;Inherit;False;SHF_Beat;27;;61;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;847;-19.06507,426.2802;Inherit;False;SHF_Beat;27;;62;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;849;672.3246,1262.38;Inherit;False;SHF_Beat;27;;64;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;687;-2965.383,2117.333;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;688;-2957.976,2260.802;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TangentVertexDataNode;694;-3939.112,2372.007;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;695;-3935.668,2521.493;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;696;-3706.451,2488.998;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;697;-3481.871,2382.145;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;699;-3192.609,2384.639;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;698;-3687.205,2632.145;Inherit;False;Constant;_BiNormalSwitch;BiNormalSwitch;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;689;-2660.341,2116.06;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;690;-2414.163,2365.545;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;692;-2256.152,2365.467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;691;-2113.325,2125.008;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;693;-1958.508,2126.615;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;704;-1692.594,1976.239;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;705;-1477.949,1975.663;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;733;-1306.12,1976.715;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;405;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;406;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;407;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;408;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;409;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;410;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;411;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;412;2359.065,-2196.855;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.WireNode;646;-4553.581,-3571.77;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;670;-3231.212,-3617.716;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;668;-3234.235,-3493.625;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;669;-3232.862,-3379.674;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;654;-4010.287,-3719.546;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;647;-4238.479,-3551.058;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;649;-3715.964,-3545.77;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;655;-3723.839,-3681.115;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;643;-4247.842,-3683.647;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;650;-3707.75,-3813.745;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;648;-4270.023,-3811.101;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;684;-4493.719,-3596.288;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;685;-4505.813,-3767.337;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;686;-4506.963,-3682.004;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;667;-5043.76,-3855.862;Inherit;False;Property;_BlendPow;BlendPow;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;641;-4905.682,-3737.422;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;682;-5128.597,-3736.838;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;681;-5325.165,-3739.086;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;651;-3699.277,-3296.965;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-3699.277,-3184.965;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;659;-4147.277,-3200.965;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;660;-4147.277,-3280.965;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;666;-3699.277,-3408.964;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;662;-4815.542,-3356.672;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;661;-4148.807,-3363.001;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-4393.366,-3367.196;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;657;-4772.621,-3196.789;Inherit;False;Property;_TriplanarTiling;TriplanarTiling;24;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;653;-4398.44,-3161.653;Inherit;True;0;1;1;0;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleAddOpNode;671;-2894.019,-3522.241;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;754;-2668.753,-3510.557;Inherit;False;ShadowDot_Triplanar;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;207;2921.527,-2295.664;Inherit;True;Property;_MainTex;Base Color;30;0;Create;False;0;0;0;False;0;False;-1;5814ca8d54113234e9a6debac2240083;5814ca8d54113234e9a6debac2240083;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;750;3719.948,-1980.804;Inherit;False;Property;_IsOutline;IsOutline;43;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;618;3236.805,-1961.356;Inherit;False;617;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;534;3435.276,-1984.857;Inherit;False;Property;_Using3DMovements;Using3DMovements?;38;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;751;3471.996,-1859.711;Inherit;False;781;OutlineOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;780;601.316,2940.042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;765;1043.898,2514.159;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;757;660.8292,2593.245;Inherit;False;Property;_OutlineWidth;Outline Width;26;0;Create;True;0;0;0;False;0;False;0.1;0.005;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;766;772.9957,2714.637;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;10;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;767;512.7648,2702.633;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;775;342.0239,2497.483;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;769;127.3753,2503.071;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;771;-113.8108,2518.997;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;770;-306.0698,2641.263;Inherit;True;Property;_BPM;BPM;44;0;Create;True;0;0;0;False;0;False;60;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;758;1634.125,2495.218;Inherit;True;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;759;1173.571,2756.239;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;760;966.6514,2767.342;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;762;1486.172,2907.754;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;761;975.3456,2945.695;Inherit;False;Property;_DistanceCutoff;Distance Cutoff;29;0;Create;True;0;0;0;False;0;False;0;20;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;781;1836.928,2498.726;Inherit;False;OutlineOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;774;-319.9378,2519.784;Inherit;False;Constant;_Seconds;Seconds;46;0;Create;True;0;0;0;False;0;False;60;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;830;454.2353,3347.339;Inherit;True;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;831;699.4277,3314.736;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;832;923.9692,3329.469;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;835;988.4721,3534.121;Inherit;False;Constant;_Float4;Float 4;48;0;Create;True;0;0;0;False;0;False;0.19;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;836;977.6048,3654.211;Inherit;False;Constant;_Float5;Float 5;48;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;837;1156.711,3615.571;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;834;1414.904,3330.802;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;707;616.4957,4009.95;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;708;403.635,4008.923;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;712;298.4635,4215.853;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;801;151.2882,4242.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;544.6315,4220.819;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,40;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;728;684.2022,4222.396;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;785;717.5159,4467.994;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;811;417.2533,4075.377;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;722;1042.88,4744.458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;800;89.03088,4692.388;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;823;-165.1506,4686.146;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;798;-147.0781,4764.746;Inherit;False;Constant;_Vector5;Vector 4;46;0;Create;True;0;0;0;False;0;False;0,0.001;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;789;249.3779,4642.175;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;788;479.7213,4490.637;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,40;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;724;670.4676,4695.971;Inherit;False;Property;_FresnelErase;FresnelErase;39;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;809;1581.036,4604.565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;802;1373.913,4298.944;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;804;1714.258,4295.547;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;784;956.7439,4375.193;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;848;-4.174284,4084.139;Inherit;False;SHF_Beat;27;;63;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;812;187.9201,3976.71;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;726;2171.807,4863.622;Inherit;False;FresnelEffects;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;717;620.5106,4819.854;Inherit;False;Property;_FresnelErase_Smoothness;FresnelErase_Smoothness;41;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;829;654.9966,4949.135;Inherit;False;Constant;_Float1;Float 1;48;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;828;830.7235,5014.93;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;827;642.2105,5035.335;Inherit;False;Constant;_Float3;Float 3;48;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;825;798.6608,5222.601;Inherit;False;747;OutlineColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;817;1006.85,4929.315;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;814;1608.72,5088.633;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;824;1858.861,4895.289;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;718;1367.416,4670.105;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;723;974.0558,4002.337;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;805;1146.144,4416.29;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;747;125.1679,4418.489;Inherit;False;OutlineColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;732;-216.6104,3980.211;Inherit;False;Property;_FresnelPower;FresnelPower;42;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;791;-347.3989,4219.064;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;795;-363.0557,4291.942;Inherit;False;Constant;_Vector4;Vector 4;46;0;Create;True;0;0;0;False;0;False;0,0.001;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;783;-232.4555,4348.443;Inherit;False;Property;_OutlineColor;OutlineColor;45;1;[HDR];Create;True;0;0;0;False;0;False;0.9937374,1.498039,0,0;0.9937374,1.498039,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;787;-220.2022,4500.583;Inherit;False;Property;_OutlineColor2;OutlineColor2;46;1;[HDR];Create;True;0;0;0;False;0;False;0.4558116,0,1.498039,0;0.4558116,0,1.498039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;763;1061.779,2365.409;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;864;3236.796,-2297.73;Inherit;False;SHF_CelShading;0;;170;93dbdbe8226a5044aa915b6ef7341db4;0;2;146;FLOAT3;0,0,0;False;107;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;515;0;513;0
WireConnection;515;1;495;0
WireConnection;486;0;498;3
WireConnection;488;0;844;0
WireConnection;488;1;486;0
WireConnection;489;0;497;0
WireConnection;489;1;488;0
WireConnection;491;0;504;1
WireConnection;492;0;504;2
WireConnection;493;0;845;0
WireConnection;493;1;500;0
WireConnection;494;0;528;2
WireConnection;495;0;494;0
WireConnection;495;1;501;0
WireConnection;496;0;498;1
WireConnection;497;0;503;0
WireConnection;499;0;529;0
WireConnection;499;1;493;0
WireConnection;500;0;496;0
WireConnection;501;0;849;0
WireConnection;501;1;498;2
WireConnection;503;0;528;3
WireConnection;505;0;518;0
WireConnection;506;0;505;0
WireConnection;506;1;509;0
WireConnection;507;0;512;0
WireConnection;507;1;508;0
WireConnection;508;0;846;0
WireConnection;508;1;531;2
WireConnection;509;0;522;1
WireConnection;509;1;511;0
WireConnection;510;0;847;0
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
WireConnection;529;0;528;1
WireConnection;514;0;506;0
WireConnection;514;1;499;0
WireConnection;485;0;514;0
WireConnection;485;1;515;0
WireConnection;485;2;489;0
WireConnection;617;0;485;0
WireConnection;273;2;274;0
WireConnection;533;0;528;3
WireConnection;532;0;846;33
WireConnection;725;1;864;0
WireConnection;725;0;730;0
WireConnection;753;1;725;0
WireConnection;753;0;752;0
WireConnection;404;0;753;0
WireConnection;404;9;368;0
WireConnection;404;4;339;0
WireConnection;404;8;750;0
WireConnection;844;54;504;3
WireConnection;845;54;491;0
WireConnection;846;54;530;2
WireConnection;847;54;530;1
WireConnection;849;54;492;0
WireConnection;696;0;694;0
WireConnection;696;1;695;0
WireConnection;697;0;694;0
WireConnection;697;1;696;0
WireConnection;697;2;698;0
WireConnection;699;0;697;0
WireConnection;689;0;687;0
WireConnection;689;1;688;0
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
WireConnection;750;1;534;0
WireConnection;750;0;751;0
WireConnection;534;0;618;0
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
WireConnection;831;0;830;0
WireConnection;832;0;831;0
WireConnection;832;1;766;0
WireConnection;837;0;835;0
WireConnection;837;1;836;0
WireConnection;834;0;832;0
WireConnection;834;1;835;0
WireConnection;834;2;837;0
WireConnection;707;0;708;0
WireConnection;707;3;811;0
WireConnection;712;1;801;0
WireConnection;801;0;791;0
WireConnection;801;1;795;0
WireConnection;713;0;712;0
WireConnection;728;0;713;0
WireConnection;785;0;788;0
WireConnection;811;0;812;0
WireConnection;811;1;732;0
WireConnection;811;2;848;0
WireConnection;722;0;724;0
WireConnection;722;1;717;0
WireConnection;800;0;823;0
WireConnection;800;1;798;0
WireConnection;789;1;800;0
WireConnection;788;0;789;0
WireConnection;809;0;718;0
WireConnection;802;0;783;0
WireConnection;802;1;787;0
WireConnection;802;2;805;0
WireConnection;804;0;802;0
WireConnection;804;1;809;0
WireConnection;784;0;728;0
WireConnection;784;1;785;0
WireConnection;812;0;732;0
WireConnection;726;0;824;0
WireConnection;828;0;829;0
WireConnection;828;1;827;0
WireConnection;817;0;707;0
WireConnection;817;1;829;0
WireConnection;817;2;828;0
WireConnection;814;0;817;0
WireConnection;814;1;825;0
WireConnection;824;0;804;0
WireConnection;824;1;814;0
WireConnection;824;2;817;0
WireConnection;718;0;723;0
WireConnection;718;1;724;0
WireConnection;718;2;722;0
WireConnection;723;0;707;0
WireConnection;805;0;784;0
WireConnection;747;0;783;0
WireConnection;864;107;207;0
ASEEND*/
//CHKSM=D59BDA8482E0B6D54A12E14DF8F72EB638818128