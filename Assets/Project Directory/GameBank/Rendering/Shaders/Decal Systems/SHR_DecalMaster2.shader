// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader  "SHR_DecalMaster2"
{
	Properties
    {
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
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

				float2 texCoord11 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;

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
			
            Name "DecalScreenSpaceProjector"
            Tags { "LightMode"="DecalScreenSpaceProjector" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
			#define DECAL_ANGLE_FADE 1
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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
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

				float2 texCoord11 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;
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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
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

				float2 texCoord11 = texCoord0 * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;

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

            #include "../HLSL/HLSL_GraffitiDecal.hlsl"
            #pragma shader_feature_local _GAMEPLAYORENVIRO_ON
            #pragma shader_feature_local _WORLDPOSORSEED_ON
            #pragma shader_feature_local _WORLDZY_ON
            #pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
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

				float2 texCoord11 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;

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
            
			Name "DecalScreenSpaceMesh"
            Tags { "LightMode"="DecalScreenSpaceMesh" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off

			HLSLPROGRAM

			#define _MATERIAL_AFFECTS_ALBEDO 1
			#define _MATERIAL_AFFECTS_NORMAL 1
			#define _MATERIAL_AFFECTS_NORMAL_BLEND 1
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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
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

				float2 texCoord11 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;

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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
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

				float2 texCoord11 = packedInput.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				surfaceDescription.BaseColor = staticSwitch83.rgb;
				surfaceDescription.Alpha = staticSwitch83.a;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.NormalAlpha = staticSwitch83.a;

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

			#include "../HLSL/HLSL_GraffitiDecal.hlsl"
			#pragma shader_feature_local _GAMEPLAYORENVIRO_ON
			#pragma shader_feature_local _WORLDPOSORSEED_ON
			#pragma shader_feature_local _WORLDZY_ON
			#pragma shader_feature_local _XZORXY_ON


			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            CBUFFER_START(UnityPerMaterial)
			float _ErosionValue;
			float _SeedScale;
			float _SeedMultiplier;
			float _DrawOrder;
			float _DecalMeshBiasType;
			float _DecalMeshDepthBias;
			float _DecalMeshViewBias;
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

				packedOutput.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				packedOutput.ase_texcoord.zw = 0;

				float3 positionWS = TransformObjectToWorld(inputMesh.positionOS);
				packedOutput.positionCS = TransformWorldToHClip(positionWS);

				return packedOutput;
			}

			void Frag(PackedVaryings packedInput,
				out float4 outColor : SV_Target0
				
			)
			{
				float2 texCoord11 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult84 = smoothstep( _ErosionValue , ( _ErosionValue * 1.64 ) , ( 1.0 - (texCoord11).y ));
				float4 _tex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_tex_ST);
				float2 uv_tex = packedInput.ase_texcoord.xy * _tex_ST_Instance.xy + _tex_ST_Instance.zw;
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
				int _Seed_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_DecalMaster2,_Seed);
				float2 temp_cast_0 = _Seed_Instance;
				#ifdef _WORLDPOSORSEED_ON
				float2 staticSwitch105 = temp_cast_0;
				#else
				float2 staticSwitch105 = round( ( ( frac( ( staticSwitch73 * _SeedScale ) ) * _SeedMultiplier ) * 1000.0 ) );
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
				

				float3 BaseColor = staticSwitch83.rgb;

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
Node;AmplifyShaderEditor.CommentaryNode;99;-3216.099,629.1724;Inherit;False;533.1865;277;Tex;2;22;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-3895.702,-866.3997;Inherit;False;1907.109;420.5435;WorldSeed;12;79;60;21;73;26;70;27;76;74;28;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;84;-633.1157,-759.8284;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-848.3115,-593.9597;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;-1028.107,-465.7858;Inherit;True;Property;_TextureSample0;Texture Sample 0;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-454.2599,-494.1249;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-1230.449,-453.7798;Inherit;False;94;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FractNode;79;-2511.612,-652.7198;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2687.417,-655.3047;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2688.006,-562.6564;Inherit;False;Property;_SeedMultiplier;SeedMultiplier;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;73;-2927.241,-657.8936;Inherit;False;Property;_WorldZY;WorldZY;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2870.265,-558.5227;Inherit;False;Property;_SeedScale;SeedScale;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;70;-3146.258,-724.9647;Inherit;False;Property;_XZorXY;XZorXY;16;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;27;-3630.674,-764.7964;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;76;-3450.544,-631.5024;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;74;-3456.427,-816.3995;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-3451.01,-724.6396;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;78;-3845.702,-765.8398;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2391.042,-591.8341;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;98;-994.4935,-187.4476;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1555.982,-242.066;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;87;-1326.109,-753.4496;Inherit;True;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;22;-3166.099,679.1724;Inherit;True;Property;_tex;tex;0;0;Create;True;0;0;0;False;0;False;e0f0197ff3bc4454ca6cdb2f9fd73d47;e0f0197ff3bc4454ca6cdb2f9fd73d47;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-2924.913,694.5947;Inherit;False;MainTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1071.16,-575.4959;Inherit;False;Constant;_ErosionSmoothness;ErosionSmoothness;19;0;Create;True;0;0;0;False;0;False;1.64;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1060.707,-682.5248;Inherit;False;Property;_ErosionValue;ErosionValue;19;0;Create;True;0;0;0;False;0;False;0.31;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-1044.364,-754.1238;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferProjector;0;0;DBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;True;1;False;;False;False;False;True;True;True;True;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DBufferProjector;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalProjectorForwardEmissive;0;1;DecalProjectorForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalProjectorForwardEmissive;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferProjector;0;3;DecalGBufferProjector;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;True;1;False;;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalGBufferProjector;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DBufferMesh;0;4;DBufferMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;True;2;5;False;;10;False;;1;0;False;;10;False;;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;True;False;False;False;False;0;False;;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DBufferMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalMeshForwardEmissive;0;5;DecalMeshForwardEmissive;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;8;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalMeshForwardEmissive;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceMesh;0;6;DecalScreenSpaceMesh;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;1;LightMode=DecalScreenSpaceMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;477.6711,-3.971048;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;DecalGBufferMesh;0;7;DecalGBufferMesh;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;True;False;False;False;False;0;False;;False;True;True;True;True;False;0;False;;False;True;True;True;True;False;0;False;;False;False;False;True;2;False;;False;False;True;1;LightMode=DecalGBufferMesh;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;New Amplify Shader;c2a467ab6d5391a4ea692226d82ffefd;True;ScenePickingPass;0;8;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;181.1483,-12.13263;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StaticSwitch;83;-158.0605,-169.0718;Inherit;False;Property;_GameplayOrEnviro;GameplayOrEnviro;18;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;475.4376,-167.9221;Float;False;True;-1;2;UnityEditor.Rendering.Universal.DecalShaderGraphGUI;0;14;SHR_DecalMaster2;c2a467ab6d5391a4ea692226d82ffefd;True;DecalScreenSpaceProjector;0;2;DecalScreenSpaceProjector;9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;5;RenderPipeline=UniversalPipeline;PreviewType=Plane;DisableBatching=LODFading=DisableBatching;ShaderGraphShader=true;ShaderGraphTargetId=UniversalDecalSubTarget;True;3;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;2;False;;False;True;1;LightMode=DecalScreenSpaceProjector;False;True;4;d3d11;glcore;gles;gles3;0;;0;0;Standard;7;Affect BaseColor;1;0;Affect Normal;1;0;Blend;1;0;Affect MAOS;0;0;Affect Emission;0;0;Support LOD CrossFade;0;0;Angle Fade;1;0;0;9;True;False;True;True;True;False;True;True;True;False;;False;0
Node;AmplifyShaderEditor.StaticSwitch;105;-1543.886,-99.29153;Inherit;False;Property;_WorldPosOrSeed;WorldPosOrSeed;20;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-1235.902,-27.50539;Inherit;False;94;MainTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.IntNode;24;-1250.475,42.60843;Inherit;False;InstancedProperty;_NumGraffiti;NumGraffiti;5;0;Create;True;0;0;0;False;0;False;0;0;True;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;13;-1229.164,114.8668;Inherit;False;InstancedProperty;_AtlasCols;AtlasCols;1;0;Create;True;0;0;0;False;0;False;4;0;True;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;14;-1230.547,175.7831;Inherit;False;InstancedProperty;_AtlasRows;AtlasRows;2;0;Create;True;0;0;0;False;0;False;4;0;True;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1257.58,235.6556;Inherit;False;InstancedProperty;_MinScale_X;MinScale_X;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1260.046,297.9886;Inherit;False;InstancedProperty;_MaxScale_X;MaxScale_X;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1269.179,352.9888;Inherit;False;InstancedProperty;_MinScale_Y;MinScale_Y;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1264.313,419.7887;Inherit;False;InstancedProperty;_MaxScale_Y;MaxScale_Y;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1267.116,480.9797;Inherit;False;InstancedProperty;_MinRotation;MinRotation;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1267.371,547.5437;Inherit;False;InstancedProperty;_MaxRotation;MaxRotation;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1269.944,613.163;Inherit;False;InstancedProperty;_MinOffset_X;MinOffset_X;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1275.166,685.4144;Inherit;False;InstancedProperty;_MaxOffset_X;MaxOffset_X;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1273.929,753.4633;Inherit;False;InstancedProperty;_MinOffset_Y;MinOffset_Y;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1280.151,820.1722;Inherit;False;InstancedProperty;_MaxOffset_Y;MaxOffset_Y;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-2198.343,-36.07742;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2384.168,-11.51448;Inherit;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;0;False;0;False;1000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;104;-1909.858,-32.45593;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;106;-1902.265,43.67847;Inherit;False;InstancedProperty;_Seed;Seed;21;0;Create;True;0;0;0;False;0;False;0;0;True;0;1;INT;0
Node;AmplifyShaderEditor.CustomExpressionNode;25;-945.8432,-123.9968;Float;False;return tex2D(tex, uv)@;4;File;16;True;uv;FLOAT2;0,0;In;;Inherit;False;True;seed2D;FLOAT2;0,0;In;;Inherit;False;True;tex;SAMPLER2D;_Sampler210;In;;Inherit;False;True;NumGraffiti;FLOAT;0;In;;Inherit;False;True;AtlasCols;FLOAT;0;In;;Inherit;False;True;AtlasRows;FLOAT;0;In;;Inherit;False;True;MinScaleX;FLOAT;0;In;;Inherit;False;True;MaxScaleX;FLOAT;0;In;;Inherit;False;True;MinScaleY;FLOAT;0;In;;Inherit;False;True;MaxScaleY;FLOAT;0;In;;Inherit;False;True;MinRota;FLOAT;0;In;;Inherit;False;True;MaxRota;FLOAT;0;In;;Inherit;False;True;MinOffsetX;FLOAT;0;In;;Inherit;False;True;MaxOffsetX;FLOAT;0;In;;Inherit;False;True;MinOffsetY;FLOAT;0;In;;Inherit;False;True;MaxOffsetY;FLOAT;0;In;;Inherit;False;SampleGraffitis;False;False;0;6471f0035b765b445a9787e379b162a0;False;16;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;SAMPLER2D;_Sampler210;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;1;FLOAT4;0
WireConnection;84;0;91;0
WireConnection;84;1;86;0
WireConnection;84;2;90;0
WireConnection;90;0;86;0
WireConnection;90;1;85;0
WireConnection;89;0;96;0
WireConnection;88;0;84;0
WireConnection;88;1;89;0
WireConnection;79;0;60;0
WireConnection;60;0;73;0
WireConnection;60;1;26;0
WireConnection;73;1;70;0
WireConnection;73;0;76;0
WireConnection;70;1;74;0
WireConnection;70;0;28;0
WireConnection;27;0;78;0
WireConnection;76;0;27;2
WireConnection;76;1;27;1
WireConnection;74;0;27;0
WireConnection;74;1;27;2
WireConnection;28;0;27;0
WireConnection;28;1;27;1
WireConnection;77;0;79;0
WireConnection;77;1;21;0
WireConnection;98;0;11;0
WireConnection;87;0;11;0
WireConnection;94;0;22;0
WireConnection;91;0;87;0
WireConnection;9;0;83;0
WireConnection;83;1;88;0
WireConnection;83;0;25;0
WireConnection;2;0;83;0
WireConnection;2;1;9;3
WireConnection;2;3;9;3
WireConnection;105;1;104;0
WireConnection;105;0;106;0
WireConnection;102;0;77;0
WireConnection;102;1;103;0
WireConnection;104;0;102;0
WireConnection;25;0;98;0
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
ASEEND*/
//CHKSM=52F15F98CC682784BA4E63E0A7800FDE5F9371C8