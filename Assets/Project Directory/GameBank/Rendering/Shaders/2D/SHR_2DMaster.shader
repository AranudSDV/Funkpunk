// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_2DMaster"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Toggle(_ISVERTICALORLATERAL_ON)] _IsVerticalOrLateral("IsVerticalOrLateral", Float) = 0
		[Toggle(_UPLORDOWNR_ON)] _UpLorDownR("UpLorDownR", Float) = 0
		[Toggle(_2ALPHAS_ON)] _2Alphas("2Alphas?", Float) = 0
		_TimeDelay("TimeDelay", Float) = 0
		[Toggle(_DEBUG_ON)] _Debug("Debug", Float) = 0
		[Toggle(_VFXORUI_ON)] _VFXorUI("VFXorUI ?", Float) = 0
		[Toggle(_1TEX_ON)] _1Tex("1Tex?", Float) = 0
		[Toggle(_3TEX_ON)] _3Tex("3Tex?", Float) = 0
		[Toggle(_2TEX_ON)] _2Tex("2Tex?", Float) = 0
		_BackGroundTex("BackGroundTex", 2D) = "white" {}
		_BackGroundColor("BackGroundColor", Color) = (0,0.06411219,1,0)
		_BackTex("BackTex", 2D) = "white" {}
		_Back("Back", Color) = (0,1,0.7048147,0)
		_Mid("Mid", Color) = (0.6812992,0,1,0)
		_BaseScale("BaseScale", Float) = 1
		_Front("Front", Color) = (1,0,0,0)
		_MidTex("MidTex", 2D) = "white" {}
		_Back02("Back02", Color) = (1,0,0,0)
		_Mid02("Mid02", Color) = (0,1,0.9647675,0)
		_Front02("Front02", Color) = (0,1,0.7048147,0)
		_FrontTex("FrontTex", 2D) = "white" {}
		_Back03("Back03", Color) = (1,0.9882626,0,0)
		_Mid03("Mid03", Color) = (0.6812992,0,1,0)
		_Front03("Front03", Color) = (1,0,0.05845451,0)
		[Toggle(_USINGXSCALE_ON)] _UsingXScale("UsingXScale?", Float) = 1
		[Toggle(_USINGXSCALE1_ON)] _UsingXScale1("UsingXScale?", Float) = 1
		[Toggle(_USINGYSCALE_ON)] _UsingYScale("UsingYScale?", Float) = 1
		[Toggle(_USINGYSCALE1_ON)] _UsingYScale1("UsingYScale?", Float) = 1
		_MinSizeY("MinSizeY", Range( 0 , 2)) = 2
		_MaxSizeY("MaxSizeY", Range( 0 , 2)) = 1
		_MinSizeX("MinSizeX", Range( 0 , 2)) = 2
		_MaxSizeX("MaxSizeX", Range( 0 , 2)) = 1
		_TransformedScaleX("TransformedScaleX", Float) = 0.8
		_TransformedScaleY("TransformedScaleY", Float) = 0.8
		_TransformedRota("TransformedRota", Float) = 0.8
		_TransformedOffsetX("TransformedOffsetX", Float) = 0.8
		_Offseter("Offseter", Range( -1 , 1)) = 0
		_Scaler1("Scaler", Range( -1 , 1)) = 0
		_Rotater("Rotater", Range( -1 , 1)) = 0
		_R_Fadesmooth("R_Fadesmooth", Float) = 1.25
		_G_FadeSmooth("G_FadeSmooth", Float) = 1
		_NoColorsWhiteValue("NoColorsWhiteValue", Range( 0 , 1)) = 1
		[Toggle(_HANDLECOLORS_ON)] _HandleColors("HandleColors", Float) = 1
		_TransformedOffsetY("TransformedOffsetY", Float) = 0.8
		[Toggle(_UI_MANUALORPROCEDURAL_ON)] _UI_ManualOrProcedural("UI_ManualOrProcedural", Float) = 1
		_RotaPower("RotaPower", Float) = 0.05
		[Toggle(_USINGYMOVE_ON)] _UsingYMove("UsingYMove ?", Float) = 1
		[Toggle(_USINGXMOVE_ON)] _UsingXMove("UsingXMove ?", Float) = 1
		_MainTexTiling("MainTexTiling", Vector) = (0,0,0,0)
		[HDR]_SubColor("SubColor", Color) = (2.670157,0,0,0)
		[HDR]_SubColor1("SubColor", Color) = (0,2.670157,1.011534,0)
		[HDR]_MainColor("MainColor", Color) = (2.670157,1.899221,0,0)
		_Alphacliptresh("Alphacliptresh", Float) = 0.1
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_R_BaseOpacity("R_BaseOpacity", Range( 0 , 1)) = 0
		_G_BaseOpacity("G_BaseOpacity", Range( 0 , 1)) = 0.5109974


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Back
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
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, Zero OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature_local _3TEX_ON
			#pragma shader_feature_local _2TEX_ON
			#pragma shader_feature_local _HANDLECOLORS_ON
			#pragma shader_feature_local _UI_MANUALORPROCEDURAL_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _BackGroundColor;
			float2 _MainTexTiling;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _NoColorsWhiteValue;
			float _MaxSizeX;
			float _G_BaseOpacity;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _Offseter;
			float _TransformedOffsetY;
			float _TransformedOffsetX;
			float _Rotater;
			float _TransformedRota;
			float _Scaler1;
			float _TransformedScaleY;
			float _TransformedScaleX;
			float _BaseScale;
			float _MaxSizeY;
			float _Alphacliptresh;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float BPM;
			sampler2D _BackTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			sampler2D _DissolveTex;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
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
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
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

				float4 texCoord44 = IN.ase_texcoord4;
				texCoord44.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult54 = (float2(texCoord44.x , texCoord44.y));
				float2 texCoord53 = IN.ase_texcoord3.xy * _MainTexTiling + appendResult54;
				float4 tex2DNode12 = tex2D( _BackTex, texCoord53 );
				float4 lerpResult463 = lerp( float4( 0,0,0,0 ) , _MainColor , tex2DNode12.r);
				float4 lerpResult377 = lerp( lerpResult463 , _SubColor , tex2DNode12.g);
				float4 lerpResult459 = lerp( lerpResult377 , _SubColor1 , tex2DNode12.b);
				float4 VfxColors441 = lerpResult459;
				float2 texCoord41_g256 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g256 = float2( 0.5,0.5 );
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g256 = cos( lerpResult617 );
				float sin47_g256 = sin( lerpResult617 );
				float2 rotator47_g256 = mul( ( ( texCoord41_g256 - temp_output_43_0_g256 ) * lerpResult498 ) - temp_output_43_0_g256 , float2x2( cos47_g256 , -sin47_g256 , sin47_g256 , cos47_g256 )) + temp_output_43_0_g256;
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				float2 temp_output_53_0_g256 = ( ( rotator47_g256 + temp_output_43_0_g256 ) + lerpResult615 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g263 = 0.0;
				#else
				float staticSwitch21_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g263 = 0.0;
				#else
				float staticSwitch25_g263 = 0.0;
				#endif
				float2 appendResult15_g263 = (float2(staticSwitch21_g263 , staticSwitch25_g263));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g263 = 0.05;
				#else
				float staticSwitch23_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g263 = 0.05;
				#else
				float staticSwitch24_g263 = 0.0;
				#endif
				float2 appendResult16_g263 = (float2(staticSwitch23_g263 , staticSwitch24_g263));
				#ifdef _DEBUG_ON
				float staticSwitch56_g245 = BPM;
				#else
				float staticSwitch56_g245 = 60.0;
				#endif
				float mulTime5_g245 = _TimeParameters.x * ( staticSwitch56_g245 / 60.0 );
				float temp_output_52_0_g245 = ( mulTime5_g245 - _TimeDelay );
				float temp_output_474_34 = ( ( cos( ( ( ( temp_output_52_0_g245 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g263 = lerp( appendResult15_g263 , appendResult16_g263 , temp_output_474_34);
				float2 texCoord308 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g269 = cos( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float sin3_g269 = sin( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float2 rotator3_g269 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g269 , -sin3_g269 , sin3_g269 , cos3_g269 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g267 = _MinSizeX;
				#else
				float staticSwitch22_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g267 = _MinSizeY;
				#else
				float staticSwitch23_g267 = 1.0;
				#endif
				float2 appendResult27_g267 = (float2(staticSwitch22_g267 , staticSwitch23_g267));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g267 = _MaxSizeX;
				#else
				float staticSwitch46_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g267 = _MaxSizeY;
				#else
				float staticSwitch45_g267 = 1.0;
				#endif
				float2 appendResult49_g267 = (float2(staticSwitch46_g267 , staticSwitch45_g267));
				#ifdef _DEBUG_ON
				float staticSwitch56_g268 = BPM;
				#else
				float staticSwitch56_g268 = 60.0;
				#endif
				float mulTime5_g268 = _TimeParameters.x * ( staticSwitch56_g268 / 60.0 );
				float temp_output_52_0_g268 = ( mulTime5_g268 - _TimeDelay );
				float temp_output_16_0_g268 = ( PI / 1.0 );
				float temp_output_19_0_g268 = cos( ( temp_output_52_0_g268 * temp_output_16_0_g268 ) );
				float saferPower20_g268 = abs( abs( temp_output_19_0_g268 ) );
				float2 lerpResult56_g267 = lerp( appendResult27_g267 , appendResult49_g267 , pow( saferPower20_g268 , 20.0 ));
				float2 temp_output_51_0_g267 = (rotator3_g269*lerpResult56_g267 + ( lerpResult56_g267 + ( ( lerpResult56_g267 * -1.0 ) + ( ( lerpResult56_g267 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g263 = ( lerpResult10_g263 + temp_output_51_0_g267 );
				#ifdef _UI_MANUALORPROCEDURAL_ON
				float2 staticSwitch494 = temp_output_7_0_g263;
				#else
				float2 staticSwitch494 = temp_output_53_0_g256;
				#endif
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float4 Tex_NoColors310 = tex2DNode97;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch494 ).a;
				float4 BackGroundTexColor205 = ( BackGroundTexAlpha211 * _BackGroundColor );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 lerpResult246 = lerp( float4( 0,0,0,0 ) , _Back , tex2DNode97.r);
				float4 lerpResult247 = lerp( lerpResult246 , _Mid , tex2DNode97.g);
				float4 lerpResult248 = lerp( lerpResult247 , _Front , tex2DNode97.b);
				float4 BackTexColor201 = ( BackTexAlpha210 * lerpResult248 );
				float4 lerpResult264 = lerp( BackGroundTexColor205 , BackTexColor201 , BackTexAlpha210);
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				#ifdef _1TEX_ON
				float4 staticSwitch187 = ( lerpResult264 * temp_output_224_0 );
				#else
				float4 staticSwitch187 = float4( 0,0,0,0 );
				#endif
				#ifdef _HANDLECOLORS_ON
				float4 staticSwitch309 = staticSwitch187;
				#else
				float4 staticSwitch309 = ( Tex_NoColors310 * _NoColorsWhiteValue );
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 lerpResult252 = lerp( float4( 0,0,0,0 ) , _Back02 , tex2DNode150.r);
				float4 lerpResult253 = lerp( lerpResult252 , _Mid02 , tex2DNode150.g);
				float4 lerpResult254 = lerp( lerpResult253 , _Front02 , tex2DNode150.b);
				float4 MidTexColor199 = ( MidTexAlpha212 * lerpResult254 );
				float4 lerpResult270 = lerp( lerpResult264 , MidTexColor199 , MidTexAlpha212);
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float4 staticSwitch186 = ( lerpResult270 * temp_output_225_0 );
				#else
				float4 staticSwitch186 = staticSwitch309;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float4 lerpResult261 = lerp( float4( 0,0,0,0 ) , _Back03 , tex2DNode161.r);
				float4 lerpResult260 = lerp( lerpResult261 , _Mid03 , tex2DNode161.g);
				float4 lerpResult262 = lerp( lerpResult260 , _Front03 , tex2DNode161.b);
				float4 FrontTexColor197 = ( FrontTexAlpha203 * lerpResult262 );
				float4 lerpResult271 = lerp( lerpResult270 , FrontTexColor197 , FrontTexAlpha203);
				#ifdef _3TEX_ON
				float4 staticSwitch185 = lerpResult271;
				#else
				float4 staticSwitch185 = staticSwitch186;
				#endif
				float4 UI_Colors172 = staticSwitch185;
				#ifdef _VFXORUI_ON
				float4 staticSwitch107 = UI_Colors172;
				#else
				float4 staticSwitch107 = VfxColors441;
				#endif
				
				float2 texCoord461 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode59 = tex2D( _DissolveTex, texCoord461 );
				float temp_output_20_0_g247 = tex2DNode59.r;
				float2 break10_g247 = IN.ase_texcoord3.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g247 = break10_g247.x;
				#else
				float staticSwitch8_g247 = break10_g247.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g247 = ( 1.0 - staticSwitch8_g247 );
				#else
				float staticSwitch9_g247 = staticSwitch8_g247;
				#endif
				float temp_output_11_0_g247 = ( staticSwitch9_g247 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g247 = ( temp_output_11_0_g247 * ( ( 1.0 - staticSwitch9_g247 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g247 = temp_output_11_0_g247;
				#endif
				float smoothstepResult3_g247 = smoothstep( temp_output_20_0_g247 , ( temp_output_20_0_g247 * _R_Fadesmooth ) , staticSwitch5_g247);
				float smoothstepResult31_g247 = smoothstep( smoothstepResult3_g247 , ( smoothstepResult3_g247 * 1.0 ) , tex2DNode12.r);
				float temp_output_20_0_g246 = tex2DNode59.r;
				float2 break10_g246 = IN.ase_texcoord3.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g246 = break10_g246.x;
				#else
				float staticSwitch8_g246 = break10_g246.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g246 = ( 1.0 - staticSwitch8_g246 );
				#else
				float staticSwitch9_g246 = staticSwitch8_g246;
				#endif
				float4 texCoord405 = IN.ase_texcoord5;
				texCoord405.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g246 = ( staticSwitch9_g246 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g246 = ( temp_output_11_0_g246 * ( ( 1.0 - staticSwitch9_g246 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g246 = temp_output_11_0_g246;
				#endif
				float smoothstepResult3_g246 = smoothstep( temp_output_20_0_g246 , ( temp_output_20_0_g246 * _G_FadeSmooth ) , staticSwitch5_g246);
				float smoothstepResult31_g246 = smoothstep( smoothstepResult3_g246 , ( smoothstepResult3_g246 * 1.0 ) , tex2DNode12.g);
				float VFX_Alpha443 = ( ( tex2DNode12.a * smoothstepResult31_g247 * _R_BaseOpacity ) + ( tex2DNode12.a * smoothstepResult31_g246 * _G_BaseOpacity ) );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				#ifdef _3TEX_ON
				float staticSwitch189 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float UI_Alpha175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch107.rgb;
				float Alpha = staticSwitch108;
				float AlphaClipThreshold = _Alphacliptresh;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON
			#pragma shader_feature_local _3TEX_ON
			#pragma shader_feature_local _2TEX_ON
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature_local _UI_MANUALORPROCEDURAL_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature_local _HANDLECOLORS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _BackGroundColor;
			float2 _MainTexTiling;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _NoColorsWhiteValue;
			float _MaxSizeX;
			float _G_BaseOpacity;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _Offseter;
			float _TransformedOffsetY;
			float _TransformedOffsetX;
			float _Rotater;
			float _TransformedRota;
			float _Scaler1;
			float _TransformedScaleY;
			float _TransformedScaleX;
			float _BaseScale;
			float _MaxSizeY;
			float _Alphacliptresh;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float BPM;
			sampler2D _BackTex;
			sampler2D _DissolveTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_texcoord4 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

				o.clipPos = TransformWorldToHClip( positionWS );
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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float4 texCoord44 = IN.ase_texcoord3;
				texCoord44.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult54 = (float2(texCoord44.x , texCoord44.y));
				float2 texCoord53 = IN.ase_texcoord2.xy * _MainTexTiling + appendResult54;
				float4 tex2DNode12 = tex2D( _BackTex, texCoord53 );
				float2 texCoord461 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode59 = tex2D( _DissolveTex, texCoord461 );
				float temp_output_20_0_g247 = tex2DNode59.r;
				float2 break10_g247 = IN.ase_texcoord2.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g247 = break10_g247.x;
				#else
				float staticSwitch8_g247 = break10_g247.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g247 = ( 1.0 - staticSwitch8_g247 );
				#else
				float staticSwitch9_g247 = staticSwitch8_g247;
				#endif
				float temp_output_11_0_g247 = ( staticSwitch9_g247 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g247 = ( temp_output_11_0_g247 * ( ( 1.0 - staticSwitch9_g247 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g247 = temp_output_11_0_g247;
				#endif
				float smoothstepResult3_g247 = smoothstep( temp_output_20_0_g247 , ( temp_output_20_0_g247 * _R_Fadesmooth ) , staticSwitch5_g247);
				float smoothstepResult31_g247 = smoothstep( smoothstepResult3_g247 , ( smoothstepResult3_g247 * 1.0 ) , tex2DNode12.r);
				float temp_output_20_0_g246 = tex2DNode59.r;
				float2 break10_g246 = IN.ase_texcoord2.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g246 = break10_g246.x;
				#else
				float staticSwitch8_g246 = break10_g246.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g246 = ( 1.0 - staticSwitch8_g246 );
				#else
				float staticSwitch9_g246 = staticSwitch8_g246;
				#endif
				float4 texCoord405 = IN.ase_texcoord4;
				texCoord405.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g246 = ( staticSwitch9_g246 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g246 = ( temp_output_11_0_g246 * ( ( 1.0 - staticSwitch9_g246 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g246 = temp_output_11_0_g246;
				#endif
				float smoothstepResult3_g246 = smoothstep( temp_output_20_0_g246 , ( temp_output_20_0_g246 * _G_FadeSmooth ) , staticSwitch5_g246);
				float smoothstepResult31_g246 = smoothstep( smoothstepResult3_g246 , ( smoothstepResult3_g246 * 1.0 ) , tex2DNode12.g);
				float VFX_Alpha443 = ( ( tex2DNode12.a * smoothstepResult31_g247 * _R_BaseOpacity ) + ( tex2DNode12.a * smoothstepResult31_g246 * _G_BaseOpacity ) );
				float2 texCoord41_g256 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g256 = float2( 0.5,0.5 );
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g256 = cos( lerpResult617 );
				float sin47_g256 = sin( lerpResult617 );
				float2 rotator47_g256 = mul( ( ( texCoord41_g256 - temp_output_43_0_g256 ) * lerpResult498 ) - temp_output_43_0_g256 , float2x2( cos47_g256 , -sin47_g256 , sin47_g256 , cos47_g256 )) + temp_output_43_0_g256;
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				float2 temp_output_53_0_g256 = ( ( rotator47_g256 + temp_output_43_0_g256 ) + lerpResult615 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g263 = 0.0;
				#else
				float staticSwitch21_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g263 = 0.0;
				#else
				float staticSwitch25_g263 = 0.0;
				#endif
				float2 appendResult15_g263 = (float2(staticSwitch21_g263 , staticSwitch25_g263));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g263 = 0.05;
				#else
				float staticSwitch23_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g263 = 0.05;
				#else
				float staticSwitch24_g263 = 0.0;
				#endif
				float2 appendResult16_g263 = (float2(staticSwitch23_g263 , staticSwitch24_g263));
				#ifdef _DEBUG_ON
				float staticSwitch56_g245 = BPM;
				#else
				float staticSwitch56_g245 = 60.0;
				#endif
				float mulTime5_g245 = _TimeParameters.x * ( staticSwitch56_g245 / 60.0 );
				float temp_output_52_0_g245 = ( mulTime5_g245 - _TimeDelay );
				float temp_output_474_34 = ( ( cos( ( ( ( temp_output_52_0_g245 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g263 = lerp( appendResult15_g263 , appendResult16_g263 , temp_output_474_34);
				float2 texCoord308 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g269 = cos( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float sin3_g269 = sin( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float2 rotator3_g269 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g269 , -sin3_g269 , sin3_g269 , cos3_g269 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g267 = _MinSizeX;
				#else
				float staticSwitch22_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g267 = _MinSizeY;
				#else
				float staticSwitch23_g267 = 1.0;
				#endif
				float2 appendResult27_g267 = (float2(staticSwitch22_g267 , staticSwitch23_g267));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g267 = _MaxSizeX;
				#else
				float staticSwitch46_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g267 = _MaxSizeY;
				#else
				float staticSwitch45_g267 = 1.0;
				#endif
				float2 appendResult49_g267 = (float2(staticSwitch46_g267 , staticSwitch45_g267));
				#ifdef _DEBUG_ON
				float staticSwitch56_g268 = BPM;
				#else
				float staticSwitch56_g268 = 60.0;
				#endif
				float mulTime5_g268 = _TimeParameters.x * ( staticSwitch56_g268 / 60.0 );
				float temp_output_52_0_g268 = ( mulTime5_g268 - _TimeDelay );
				float temp_output_16_0_g268 = ( PI / 1.0 );
				float temp_output_19_0_g268 = cos( ( temp_output_52_0_g268 * temp_output_16_0_g268 ) );
				float saferPower20_g268 = abs( abs( temp_output_19_0_g268 ) );
				float2 lerpResult56_g267 = lerp( appendResult27_g267 , appendResult49_g267 , pow( saferPower20_g268 , 20.0 ));
				float2 temp_output_51_0_g267 = (rotator3_g269*lerpResult56_g267 + ( lerpResult56_g267 + ( ( lerpResult56_g267 * -1.0 ) + ( ( lerpResult56_g267 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g263 = ( lerpResult10_g263 + temp_output_51_0_g267 );
				#ifdef _UI_MANUALORPROCEDURAL_ON
				float2 staticSwitch494 = temp_output_7_0_g263;
				#else
				float2 staticSwitch494 = temp_output_53_0_g256;
				#endif
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch494 ).a;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				#ifdef _3TEX_ON
				float staticSwitch189 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float UI_Alpha175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				

				float Alpha = staticSwitch108;
				float AlphaClipThreshold = _Alphacliptresh;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON
			#pragma shader_feature_local _3TEX_ON
			#pragma shader_feature_local _2TEX_ON
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature_local _UI_MANUALORPROCEDURAL_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature_local _HANDLECOLORS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _BackGroundColor;
			float2 _MainTexTiling;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _NoColorsWhiteValue;
			float _MaxSizeX;
			float _G_BaseOpacity;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _Offseter;
			float _TransformedOffsetY;
			float _TransformedOffsetX;
			float _Rotater;
			float _TransformedRota;
			float _Scaler1;
			float _TransformedScaleY;
			float _TransformedScaleX;
			float _BaseScale;
			float _MaxSizeY;
			float _Alphacliptresh;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float BPM;
			sampler2D _BackTex;
			sampler2D _DissolveTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;


			
			int _ObjectId;
			int _PassValue;

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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float4 texCoord44 = IN.ase_texcoord1;
				texCoord44.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult54 = (float2(texCoord44.x , texCoord44.y));
				float2 texCoord53 = IN.ase_texcoord.xy * _MainTexTiling + appendResult54;
				float4 tex2DNode12 = tex2D( _BackTex, texCoord53 );
				float2 texCoord461 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode59 = tex2D( _DissolveTex, texCoord461 );
				float temp_output_20_0_g247 = tex2DNode59.r;
				float2 break10_g247 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g247 = break10_g247.x;
				#else
				float staticSwitch8_g247 = break10_g247.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g247 = ( 1.0 - staticSwitch8_g247 );
				#else
				float staticSwitch9_g247 = staticSwitch8_g247;
				#endif
				float temp_output_11_0_g247 = ( staticSwitch9_g247 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g247 = ( temp_output_11_0_g247 * ( ( 1.0 - staticSwitch9_g247 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g247 = temp_output_11_0_g247;
				#endif
				float smoothstepResult3_g247 = smoothstep( temp_output_20_0_g247 , ( temp_output_20_0_g247 * _R_Fadesmooth ) , staticSwitch5_g247);
				float smoothstepResult31_g247 = smoothstep( smoothstepResult3_g247 , ( smoothstepResult3_g247 * 1.0 ) , tex2DNode12.r);
				float temp_output_20_0_g246 = tex2DNode59.r;
				float2 break10_g246 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g246 = break10_g246.x;
				#else
				float staticSwitch8_g246 = break10_g246.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g246 = ( 1.0 - staticSwitch8_g246 );
				#else
				float staticSwitch9_g246 = staticSwitch8_g246;
				#endif
				float4 texCoord405 = IN.ase_texcoord2;
				texCoord405.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g246 = ( staticSwitch9_g246 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g246 = ( temp_output_11_0_g246 * ( ( 1.0 - staticSwitch9_g246 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g246 = temp_output_11_0_g246;
				#endif
				float smoothstepResult3_g246 = smoothstep( temp_output_20_0_g246 , ( temp_output_20_0_g246 * _G_FadeSmooth ) , staticSwitch5_g246);
				float smoothstepResult31_g246 = smoothstep( smoothstepResult3_g246 , ( smoothstepResult3_g246 * 1.0 ) , tex2DNode12.g);
				float VFX_Alpha443 = ( ( tex2DNode12.a * smoothstepResult31_g247 * _R_BaseOpacity ) + ( tex2DNode12.a * smoothstepResult31_g246 * _G_BaseOpacity ) );
				float2 texCoord41_g256 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g256 = float2( 0.5,0.5 );
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g256 = cos( lerpResult617 );
				float sin47_g256 = sin( lerpResult617 );
				float2 rotator47_g256 = mul( ( ( texCoord41_g256 - temp_output_43_0_g256 ) * lerpResult498 ) - temp_output_43_0_g256 , float2x2( cos47_g256 , -sin47_g256 , sin47_g256 , cos47_g256 )) + temp_output_43_0_g256;
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				float2 temp_output_53_0_g256 = ( ( rotator47_g256 + temp_output_43_0_g256 ) + lerpResult615 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g263 = 0.0;
				#else
				float staticSwitch21_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g263 = 0.0;
				#else
				float staticSwitch25_g263 = 0.0;
				#endif
				float2 appendResult15_g263 = (float2(staticSwitch21_g263 , staticSwitch25_g263));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g263 = 0.05;
				#else
				float staticSwitch23_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g263 = 0.05;
				#else
				float staticSwitch24_g263 = 0.0;
				#endif
				float2 appendResult16_g263 = (float2(staticSwitch23_g263 , staticSwitch24_g263));
				#ifdef _DEBUG_ON
				float staticSwitch56_g245 = BPM;
				#else
				float staticSwitch56_g245 = 60.0;
				#endif
				float mulTime5_g245 = _TimeParameters.x * ( staticSwitch56_g245 / 60.0 );
				float temp_output_52_0_g245 = ( mulTime5_g245 - _TimeDelay );
				float temp_output_474_34 = ( ( cos( ( ( ( temp_output_52_0_g245 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g263 = lerp( appendResult15_g263 , appendResult16_g263 , temp_output_474_34);
				float2 texCoord308 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g269 = cos( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float sin3_g269 = sin( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float2 rotator3_g269 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g269 , -sin3_g269 , sin3_g269 , cos3_g269 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g267 = _MinSizeX;
				#else
				float staticSwitch22_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g267 = _MinSizeY;
				#else
				float staticSwitch23_g267 = 1.0;
				#endif
				float2 appendResult27_g267 = (float2(staticSwitch22_g267 , staticSwitch23_g267));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g267 = _MaxSizeX;
				#else
				float staticSwitch46_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g267 = _MaxSizeY;
				#else
				float staticSwitch45_g267 = 1.0;
				#endif
				float2 appendResult49_g267 = (float2(staticSwitch46_g267 , staticSwitch45_g267));
				#ifdef _DEBUG_ON
				float staticSwitch56_g268 = BPM;
				#else
				float staticSwitch56_g268 = 60.0;
				#endif
				float mulTime5_g268 = _TimeParameters.x * ( staticSwitch56_g268 / 60.0 );
				float temp_output_52_0_g268 = ( mulTime5_g268 - _TimeDelay );
				float temp_output_16_0_g268 = ( PI / 1.0 );
				float temp_output_19_0_g268 = cos( ( temp_output_52_0_g268 * temp_output_16_0_g268 ) );
				float saferPower20_g268 = abs( abs( temp_output_19_0_g268 ) );
				float2 lerpResult56_g267 = lerp( appendResult27_g267 , appendResult49_g267 , pow( saferPower20_g268 , 20.0 ));
				float2 temp_output_51_0_g267 = (rotator3_g269*lerpResult56_g267 + ( lerpResult56_g267 + ( ( lerpResult56_g267 * -1.0 ) + ( ( lerpResult56_g267 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g263 = ( lerpResult10_g263 + temp_output_51_0_g267 );
				#ifdef _UI_MANUALORPROCEDURAL_ON
				float2 staticSwitch494 = temp_output_7_0_g263;
				#else
				float2 staticSwitch494 = temp_output_53_0_g256;
				#endif
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch494 ).a;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				#ifdef _3TEX_ON
				float staticSwitch189 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float UI_Alpha175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				

				surfaceDescription.Alpha = staticSwitch108;
				surfaceDescription.AlphaClipThreshold = _Alphacliptresh;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON
			#pragma shader_feature_local _3TEX_ON
			#pragma shader_feature_local _2TEX_ON
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature_local _UI_MANUALORPROCEDURAL_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature_local _HANDLECOLORS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _BackGroundColor;
			float2 _MainTexTiling;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _NoColorsWhiteValue;
			float _MaxSizeX;
			float _G_BaseOpacity;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _Offseter;
			float _TransformedOffsetY;
			float _TransformedOffsetX;
			float _Rotater;
			float _TransformedRota;
			float _Scaler1;
			float _TransformedScaleY;
			float _TransformedScaleX;
			float _BaseScale;
			float _MaxSizeY;
			float _Alphacliptresh;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float BPM;
			sampler2D _BackTex;
			sampler2D _DissolveTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;


			
			float4 _SelectionID;


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

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float4 texCoord44 = IN.ase_texcoord1;
				texCoord44.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult54 = (float2(texCoord44.x , texCoord44.y));
				float2 texCoord53 = IN.ase_texcoord.xy * _MainTexTiling + appendResult54;
				float4 tex2DNode12 = tex2D( _BackTex, texCoord53 );
				float2 texCoord461 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode59 = tex2D( _DissolveTex, texCoord461 );
				float temp_output_20_0_g247 = tex2DNode59.r;
				float2 break10_g247 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g247 = break10_g247.x;
				#else
				float staticSwitch8_g247 = break10_g247.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g247 = ( 1.0 - staticSwitch8_g247 );
				#else
				float staticSwitch9_g247 = staticSwitch8_g247;
				#endif
				float temp_output_11_0_g247 = ( staticSwitch9_g247 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g247 = ( temp_output_11_0_g247 * ( ( 1.0 - staticSwitch9_g247 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g247 = temp_output_11_0_g247;
				#endif
				float smoothstepResult3_g247 = smoothstep( temp_output_20_0_g247 , ( temp_output_20_0_g247 * _R_Fadesmooth ) , staticSwitch5_g247);
				float smoothstepResult31_g247 = smoothstep( smoothstepResult3_g247 , ( smoothstepResult3_g247 * 1.0 ) , tex2DNode12.r);
				float temp_output_20_0_g246 = tex2DNode59.r;
				float2 break10_g246 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g246 = break10_g246.x;
				#else
				float staticSwitch8_g246 = break10_g246.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g246 = ( 1.0 - staticSwitch8_g246 );
				#else
				float staticSwitch9_g246 = staticSwitch8_g246;
				#endif
				float4 texCoord405 = IN.ase_texcoord2;
				texCoord405.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g246 = ( staticSwitch9_g246 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g246 = ( temp_output_11_0_g246 * ( ( 1.0 - staticSwitch9_g246 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g246 = temp_output_11_0_g246;
				#endif
				float smoothstepResult3_g246 = smoothstep( temp_output_20_0_g246 , ( temp_output_20_0_g246 * _G_FadeSmooth ) , staticSwitch5_g246);
				float smoothstepResult31_g246 = smoothstep( smoothstepResult3_g246 , ( smoothstepResult3_g246 * 1.0 ) , tex2DNode12.g);
				float VFX_Alpha443 = ( ( tex2DNode12.a * smoothstepResult31_g247 * _R_BaseOpacity ) + ( tex2DNode12.a * smoothstepResult31_g246 * _G_BaseOpacity ) );
				float2 texCoord41_g256 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g256 = float2( 0.5,0.5 );
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g256 = cos( lerpResult617 );
				float sin47_g256 = sin( lerpResult617 );
				float2 rotator47_g256 = mul( ( ( texCoord41_g256 - temp_output_43_0_g256 ) * lerpResult498 ) - temp_output_43_0_g256 , float2x2( cos47_g256 , -sin47_g256 , sin47_g256 , cos47_g256 )) + temp_output_43_0_g256;
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				float2 temp_output_53_0_g256 = ( ( rotator47_g256 + temp_output_43_0_g256 ) + lerpResult615 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g263 = 0.0;
				#else
				float staticSwitch21_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g263 = 0.0;
				#else
				float staticSwitch25_g263 = 0.0;
				#endif
				float2 appendResult15_g263 = (float2(staticSwitch21_g263 , staticSwitch25_g263));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g263 = 0.05;
				#else
				float staticSwitch23_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g263 = 0.05;
				#else
				float staticSwitch24_g263 = 0.0;
				#endif
				float2 appendResult16_g263 = (float2(staticSwitch23_g263 , staticSwitch24_g263));
				#ifdef _DEBUG_ON
				float staticSwitch56_g245 = BPM;
				#else
				float staticSwitch56_g245 = 60.0;
				#endif
				float mulTime5_g245 = _TimeParameters.x * ( staticSwitch56_g245 / 60.0 );
				float temp_output_52_0_g245 = ( mulTime5_g245 - _TimeDelay );
				float temp_output_474_34 = ( ( cos( ( ( ( temp_output_52_0_g245 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g263 = lerp( appendResult15_g263 , appendResult16_g263 , temp_output_474_34);
				float2 texCoord308 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g269 = cos( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float sin3_g269 = sin( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float2 rotator3_g269 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g269 , -sin3_g269 , sin3_g269 , cos3_g269 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g267 = _MinSizeX;
				#else
				float staticSwitch22_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g267 = _MinSizeY;
				#else
				float staticSwitch23_g267 = 1.0;
				#endif
				float2 appendResult27_g267 = (float2(staticSwitch22_g267 , staticSwitch23_g267));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g267 = _MaxSizeX;
				#else
				float staticSwitch46_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g267 = _MaxSizeY;
				#else
				float staticSwitch45_g267 = 1.0;
				#endif
				float2 appendResult49_g267 = (float2(staticSwitch46_g267 , staticSwitch45_g267));
				#ifdef _DEBUG_ON
				float staticSwitch56_g268 = BPM;
				#else
				float staticSwitch56_g268 = 60.0;
				#endif
				float mulTime5_g268 = _TimeParameters.x * ( staticSwitch56_g268 / 60.0 );
				float temp_output_52_0_g268 = ( mulTime5_g268 - _TimeDelay );
				float temp_output_16_0_g268 = ( PI / 1.0 );
				float temp_output_19_0_g268 = cos( ( temp_output_52_0_g268 * temp_output_16_0_g268 ) );
				float saferPower20_g268 = abs( abs( temp_output_19_0_g268 ) );
				float2 lerpResult56_g267 = lerp( appendResult27_g267 , appendResult49_g267 , pow( saferPower20_g268 , 20.0 ));
				float2 temp_output_51_0_g267 = (rotator3_g269*lerpResult56_g267 + ( lerpResult56_g267 + ( ( lerpResult56_g267 * -1.0 ) + ( ( lerpResult56_g267 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g263 = ( lerpResult10_g263 + temp_output_51_0_g267 );
				#ifdef _UI_MANUALORPROCEDURAL_ON
				float2 staticSwitch494 = temp_output_7_0_g263;
				#else
				float2 staticSwitch494 = temp_output_53_0_g256;
				#endif
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch494 ).a;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				#ifdef _3TEX_ON
				float staticSwitch189 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float UI_Alpha175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				

				surfaceDescription.Alpha = staticSwitch108;
				surfaceDescription.AlphaClipThreshold = _Alphacliptresh;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON
			#pragma shader_feature_local _3TEX_ON
			#pragma shader_feature_local _2TEX_ON
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature_local _UI_MANUALORPROCEDURAL_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature _DEBUG_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature_local _HANDLECOLORS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _BackGroundColor;
			float2 _MainTexTiling;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _NoColorsWhiteValue;
			float _MaxSizeX;
			float _G_BaseOpacity;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _Offseter;
			float _TransformedOffsetY;
			float _TransformedOffsetX;
			float _Rotater;
			float _TransformedRota;
			float _Scaler1;
			float _TransformedScaleY;
			float _TransformedScaleX;
			float _BaseScale;
			float _MaxSizeY;
			float _Alphacliptresh;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			float BPM;
			sampler2D _BackTex;
			sampler2D _DissolveTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;


			
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

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 texCoord44 = IN.ase_texcoord2;
				texCoord44.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult54 = (float2(texCoord44.x , texCoord44.y));
				float2 texCoord53 = IN.ase_texcoord1.xy * _MainTexTiling + appendResult54;
				float4 tex2DNode12 = tex2D( _BackTex, texCoord53 );
				float2 texCoord461 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode59 = tex2D( _DissolveTex, texCoord461 );
				float temp_output_20_0_g247 = tex2DNode59.r;
				float2 break10_g247 = IN.ase_texcoord1.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g247 = break10_g247.x;
				#else
				float staticSwitch8_g247 = break10_g247.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g247 = ( 1.0 - staticSwitch8_g247 );
				#else
				float staticSwitch9_g247 = staticSwitch8_g247;
				#endif
				float temp_output_11_0_g247 = ( staticSwitch9_g247 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g247 = ( temp_output_11_0_g247 * ( ( 1.0 - staticSwitch9_g247 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g247 = temp_output_11_0_g247;
				#endif
				float smoothstepResult3_g247 = smoothstep( temp_output_20_0_g247 , ( temp_output_20_0_g247 * _R_Fadesmooth ) , staticSwitch5_g247);
				float smoothstepResult31_g247 = smoothstep( smoothstepResult3_g247 , ( smoothstepResult3_g247 * 1.0 ) , tex2DNode12.r);
				float temp_output_20_0_g246 = tex2DNode59.r;
				float2 break10_g246 = IN.ase_texcoord1.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g246 = break10_g246.x;
				#else
				float staticSwitch8_g246 = break10_g246.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g246 = ( 1.0 - staticSwitch8_g246 );
				#else
				float staticSwitch9_g246 = staticSwitch8_g246;
				#endif
				float4 texCoord405 = IN.ase_texcoord3;
				texCoord405.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g246 = ( staticSwitch9_g246 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g246 = ( temp_output_11_0_g246 * ( ( 1.0 - staticSwitch9_g246 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g246 = temp_output_11_0_g246;
				#endif
				float smoothstepResult3_g246 = smoothstep( temp_output_20_0_g246 , ( temp_output_20_0_g246 * _G_FadeSmooth ) , staticSwitch5_g246);
				float smoothstepResult31_g246 = smoothstep( smoothstepResult3_g246 , ( smoothstepResult3_g246 * 1.0 ) , tex2DNode12.g);
				float VFX_Alpha443 = ( ( tex2DNode12.a * smoothstepResult31_g247 * _R_BaseOpacity ) + ( tex2DNode12.a * smoothstepResult31_g246 * _G_BaseOpacity ) );
				float2 texCoord41_g256 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g256 = float2( 0.5,0.5 );
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g256 = cos( lerpResult617 );
				float sin47_g256 = sin( lerpResult617 );
				float2 rotator47_g256 = mul( ( ( texCoord41_g256 - temp_output_43_0_g256 ) * lerpResult498 ) - temp_output_43_0_g256 , float2x2( cos47_g256 , -sin47_g256 , sin47_g256 , cos47_g256 )) + temp_output_43_0_g256;
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				float2 temp_output_53_0_g256 = ( ( rotator47_g256 + temp_output_43_0_g256 ) + lerpResult615 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g263 = 0.0;
				#else
				float staticSwitch21_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g263 = 0.0;
				#else
				float staticSwitch25_g263 = 0.0;
				#endif
				float2 appendResult15_g263 = (float2(staticSwitch21_g263 , staticSwitch25_g263));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g263 = 0.05;
				#else
				float staticSwitch23_g263 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g263 = 0.05;
				#else
				float staticSwitch24_g263 = 0.0;
				#endif
				float2 appendResult16_g263 = (float2(staticSwitch23_g263 , staticSwitch24_g263));
				#ifdef _DEBUG_ON
				float staticSwitch56_g245 = BPM;
				#else
				float staticSwitch56_g245 = 60.0;
				#endif
				float mulTime5_g245 = _TimeParameters.x * ( staticSwitch56_g245 / 60.0 );
				float temp_output_52_0_g245 = ( mulTime5_g245 - _TimeDelay );
				float temp_output_474_34 = ( ( cos( ( ( ( temp_output_52_0_g245 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g263 = lerp( appendResult15_g263 , appendResult16_g263 , temp_output_474_34);
				float2 texCoord308 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g269 = cos( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float sin3_g269 = sin( ( ( temp_output_474_34 * _RotaPower ) * PI ) );
				float2 rotator3_g269 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g269 , -sin3_g269 , sin3_g269 , cos3_g269 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g267 = _MinSizeX;
				#else
				float staticSwitch22_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g267 = _MinSizeY;
				#else
				float staticSwitch23_g267 = 1.0;
				#endif
				float2 appendResult27_g267 = (float2(staticSwitch22_g267 , staticSwitch23_g267));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g267 = _MaxSizeX;
				#else
				float staticSwitch46_g267 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g267 = _MaxSizeY;
				#else
				float staticSwitch45_g267 = 1.0;
				#endif
				float2 appendResult49_g267 = (float2(staticSwitch46_g267 , staticSwitch45_g267));
				#ifdef _DEBUG_ON
				float staticSwitch56_g268 = BPM;
				#else
				float staticSwitch56_g268 = 60.0;
				#endif
				float mulTime5_g268 = _TimeParameters.x * ( staticSwitch56_g268 / 60.0 );
				float temp_output_52_0_g268 = ( mulTime5_g268 - _TimeDelay );
				float temp_output_16_0_g268 = ( PI / 1.0 );
				float temp_output_19_0_g268 = cos( ( temp_output_52_0_g268 * temp_output_16_0_g268 ) );
				float saferPower20_g268 = abs( abs( temp_output_19_0_g268 ) );
				float2 lerpResult56_g267 = lerp( appendResult27_g267 , appendResult49_g267 , pow( saferPower20_g268 , 20.0 ));
				float2 temp_output_51_0_g267 = (rotator3_g269*lerpResult56_g267 + ( lerpResult56_g267 + ( ( lerpResult56_g267 * -1.0 ) + ( ( lerpResult56_g267 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g263 = ( lerpResult10_g263 + temp_output_51_0_g267 );
				#ifdef _UI_MANUALORPROCEDURAL_ON
				float2 staticSwitch494 = temp_output_7_0_g263;
				#else
				float2 staticSwitch494 = temp_output_53_0_g256;
				#endif
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch494 ).a;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				#ifdef _3TEX_ON
				float staticSwitch189 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float UI_Alpha175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				

				surfaceDescription.Alpha = staticSwitch108;
				surfaceDescription.AlphaClipThreshold = _Alphacliptresh;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;608;-11573.13,760.5139;Inherit;False;4117.769;3449.136;;7;598;583;588;538;561;595;606;Beat Transforms;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;606;-8910.908,2617.119;Inherit;False;901.127;334.8118;a;5;602;603;604;605;630;Rotator;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;595;-11387.27,2838.358;Inherit;False;2051.434;1068.11;;18;565;566;571;573;575;576;579;580;581;582;585;589;590;591;592;593;594;596;Scaler;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;561;-10754.56,1051.046;Inherit;False;2623.104;1240.361;;4;527;528;560;563;Moving;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;368;-7332.645,1467.613;Inherit;False;6925.187;2770.153;;113;141;150;97;178;179;161;167;182;247;248;249;210;201;157;212;257;258;151;199;259;254;262;203;260;197;162;205;168;156;140;166;158;142;180;221;233;231;232;230;229;312;187;220;228;225;227;226;211;224;223;222;314;270;267;272;271;273;266;264;269;268;274;172;185;188;189;190;175;235;236;186;308;304;316;317;261;318;253;256;252;319;246;250;320;321;311;322;325;309;310;251;313;328;496;498;499;494;510;509;564;597;612;613;614;615;617;618;619;620;625;626;627;628;UI;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;150;-5231.762,2603.631;Inherit;True;Property;_MidTex;MidTex;47;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;9cd71f3e555499d4bb26528953021f9e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-4594.091,1561.9;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;161;-5228.241,3388.262;Inherit;True;Property;_FrontTex;FrontTex;51;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;7bc00bfbbf2254540a53064df3cfd095;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;167;-5183.246,3774.674;Inherit;False;Property;_Mid03;Mid03;53;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-3669.496,2292.91;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-3435.867,2295.674;Inherit;True;BackTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-3787.792,3109.498;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-3604.971,3124.632;Inherit;True;MidTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;259;-4897.709,3366.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;254;-4103.103,3133.173;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;262;-4153.241,3975.633;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-4348.019,3330.877;Inherit;False;FrontTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;260;-4412.125,3766.164;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-3619.802,3953.839;Inherit;True;FrontTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-3881.269,3984.099;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;168;-5183.383,3596.018;Inherit;False;Property;_Back03;Back03;52;0;Create;True;0;0;0;False;0;False;1,0.9882626,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;156;-5191.261,2802.163;Inherit;False;Property;_Back02;Back02;48;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0.043478,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;166;-5187.393,3995.387;Inherit;False;Property;_Front03;Front03;54;0;Create;False;0;0;0;False;0;False;1,0,0.05845451,0;0.1522287,0,0.2327043,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;158;-5152.612,3155.617;Inherit;False;Property;_Front02;Front02;50;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.3144653,0.3144653,0.3144653,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;180;-5208.722,1710.272;Inherit;False;Property;_BackGroundColor;BackGroundColor;38;0;Create;True;0;0;0;False;0;False;0,0.06411219,1,0;0.4179827,0.1317639,0.5943396,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-2174.527,2330.615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-1741.194,2507.493;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1712.03,2574.087;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1710.249,2641.496;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-1708.694,2709.791;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-1477.625,2569.72;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;312;-1820.685,2461.9;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;187;-1755.322,2293.114;Inherit;False;Property;_1Tex;1Tex?;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-1433.44,2396.394;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-2180.978,2428.236;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;225;-1944.661,2429.28;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-2181.518,2497.051;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-2208.766,2569.608;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-4943.376,1562.276;Inherit;False;BackGroundTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;224;-2512.941,2128.657;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-2743.672,2272.194;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-3016.211,2269.047;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;314;-3022.173,2127.929;Inherit;False;Constant;_NoBackGround7;NoBackGround7;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;270;-2005.645,2749.887;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-2236.185,2815.623;Inherit;False;199;MidTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;272;-2235.615,2885.149;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;271;-1260.385,2749.167;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-1487.083,2881.094;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-1490.108,2810.052;Inherit;False;197;FrontTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;264;-2483.155,2754.919;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-2745.852,2757.382;Inherit;False;205;BackGroundTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;-2714.776,2824.621;Inherit;False;201;BackTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-2713.601,2893.534;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;185;-992.6428,2201.818;Inherit;False;Property;_3Tex;3Tex?;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;235;-1772.631,2115.012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;236;-1258.552,2151.301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;186;-1208.926,2201.138;Inherit;False;Property;_2Tex;2Tex?;34;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;308;-6885.397,2541.601;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-7033.971,2649.331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;316;-4912.938,4075.687;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;317;-4894.666,3874.699;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;261;-4700.079,3581.573;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;318;-4865.263,3209.402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;253;-4380.396,2952.892;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;256;-4884.372,3048.588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;252;-4688.66,2782.166;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;319;-4905.739,2916.986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;321;-4915.53,3686.815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;309;-1553.196,2201.741;Inherit;False;Property;_HandleColors;HandleColors;80;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;251;-4851.004,1891.513;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;313;-2768.105,2127.939;Inherit;False;Property;_HandleColors1;HandleColors;80;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;309;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;-5242.343,2974.594;Inherit;False;Property;_Mid02;Mid02;49;0;Create;True;0;0;0;False;0;False;0,1,0.9647675,0;0.3710691,0.3167328,0.311558,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;107;1520.725,-969.8881;Inherit;False;Property;_VFXorUI;VFXorUI ?;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1766.109,-846.5352;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;SHR_2DMaster;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;True;True;0;1;False;;1;False;;1;0;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638837645195071408;  Blend;0;638837652209777018;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638750638155477510;  Use Shadow Threshold;0;0;Receive Shadows;0;638750638186889437;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;0;638750638251761571;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-801.0934,2196.336;Inherit;True;UI_Colors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-811.7353,1984.471;Inherit;True;UI_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;189;-1086.537,1988.207;Inherit;False;Property;_3Tex1;3Tex?;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;185;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;188;-1493.916,2002.451;Inherit;False;Property;_2Tex1;2Tex?;34;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;186;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;190;-2194.344,2000.091;Inherit;False;Property;_1Tex1;1Tex?;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;187;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-1894.356,1810.547;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-2264.006,1921.074;Inherit;False;Property;_NoColorsWhiteValue;NoColorsWhiteValue;79;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-2248.402,1812.883;Inherit;False;310;Tex_NoColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-4371.369,1559.217;Inherit;False;BackGroundTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-4286.57,2649.736;Inherit;False;MidTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;258;-4923.008,2669.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;257;-3847.315,2789.302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1415.615,-599.0623;Inherit;False;Property;_Alphacliptresh;Alphacliptresh;111;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;108;1533.131,-823.3735;Inherit;False;Property;_VFXorUI1;VFXorUI ?;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;107;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;1340.735,-757.0334;Inherit;False;175;UI_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;1342.15,-835.7303;Inherit;False;443;VFX_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-97.01104,-568.7534;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;399;-1652.833,-87.65472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;462;-1318.037,-566.3159;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;474;-7282.645,2415.583;Inherit;False;SHF_Beat;26;;245;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-5246.5,1498.187;Inherit;True;Property;_BackGroundTex;BackGroundTex;37;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;141;-5148.225,2236.497;Inherit;False;Property;_Mid;Mid;42;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0.8867924,0.8867924,0.8867924,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;247;-4299.25,2219.268;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;248;-3958.584,2397.935;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;249;-4857.015,2480.11;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;140;-5149.158,2090.376;Inherit;False;Property;_Back;Back;40;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.7924528,0.2554455,0.2504449,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;142;-5119.63,2414.575;Inherit;False;Property;_Front;Front;46;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0.1984615,0.6886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;246;-4639.974,2075.991;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;250;-4866.813,2299.456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;320;-4877.803,2194.972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;483;-1245.447,-2668.2;Inherit;False;Property;_Mid1;Mid;43;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0.8867924,0.8867924,0.8867924,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;476;-1625.227,-2685.583;Inherit;True;Property;_TextureSample2;Texture Sample 2;43;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;97;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;488;-1269.932,-2430.118;Inherit;False;Property;_Front1;Front;45;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0.1984615,0.6886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;487;-1216.378,-3052.031;Inherit;False;Property;_Back1;Back;41;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.7924528,0.2554455,0.2504449,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;492;-1340.283,-2273.411;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;493;-1358.745,-2924.223;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;489;-951.8253,-3075.647;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;484;-678.0284,-2678.506;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;485;-397.3664,-2467.529;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;442;1323.902,-1042.685;Inherit;False;441;VfxColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;482;-158.8215,-2465.553;Inherit;False;UI_ManualColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;479;-2305.438,-2675.926;Inherit;False;Constant;_BaseScale;BaseScale;43;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;481;-2306.034,-2508.463;Inherit;False;Property;_Scaler;Scaler;69;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;478;-2071.656,-2626.732;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-2328.229,-2595.399;Inherit;False;Property;_TransformedScale;TransformedScale;68;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;961.14,-840.0126;Inherit;False;172;UI_Colors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;97;-5603.524,1773.606;Inherit;True;Property;_BackTex;BackTex;39;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;b47ae78de3d3b7749a4836d0c15c157a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;494;-5775.067,2477.19;Inherit;False;Property;_UI_ManualOrProcedural;UI_ManualOrProcedural;82;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-4835.329,1759.162;Inherit;False;Tex_NoColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-3941.371,1866.683;Inherit;False;BackTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;14;-2028.562,-1407.01;Inherit;False;Property;_MainTexTiling;MainTexTiling;107;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;54;-2004.504,-1272.707;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;-425.5654,-530.0711;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;413;-842.3475,-105.0168;Inherit;False;Property;_G_BaseOpacity;G_BaseOpacity;114;0;Create;True;0;0;0;False;0;False;0.5109974;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;448;-819.1606,-392.3603;Inherit;False;SHF_VFX_Fades;14;;246;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;501;-982.1696,-1276.182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-1541.57,-2084.887;Inherit;False;Property;_MainColor;MainColor;110;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,1.899221,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;373;-1559.936,-1866.487;Inherit;False;Property;_SubColor;SubColor;108;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,0,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;456;-1572.684,-1618.964;Inherit;False;Property;_SubColor1;SubColor;109;1;[HDR];Create;True;0;0;0;False;0;False;0,2.670157,1.011534,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;463;-1276.348,-2109.786;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;451;-1266.501,-1725.942;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;377;-1003.592,-1891.054;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;503;-1205.187,-1507.616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;504;-980.4263,-1200.048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;505;-1233.916,-669.4098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;507;-1839.689,-262.4424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;506;-1897.38,-866.2743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-2262.321,-701.1569;Inherit;True;Property;_DissolveTex;DissolveTex;112;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;461;-2474.079,-679.4251;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;430;-131.8206,-546.206;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;405;-2503.743,-386.9624;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;436;-2260.993,-382.4208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;-2259.697,-305.3382;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-1328.349,-397.0139;Inherit;False;Property;_G_FadeSmooth;G_FadeSmooth;78;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;459;-725.9671,-1653.464;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;441;-493.6378,-1654.402;Inherit;False;VfxColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-418.4314,-1236.692;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;447;-834.8542,-1176.183;Inherit;False;SHF_VFX_Fades;14;;247;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-828.3532,-980.4771;Inherit;False;Property;_R_BaseOpacity;R_BaseOpacity;113;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-1495.129,-1165.293;Inherit;False;Property;_R_Fadesmooth;R_Fadesmooth;77;0;Create;True;0;0;0;False;0;False;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2395.993,-1158.129;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;425;-2135.748,-1111.891;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;446;-2124.06,-1037.711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-1806.759,-1426.888;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-1566.118,-1366.487;Inherit;True;Property;_MainTex;MainTex;39;1;[HDR];Create;True;0;0;0;False;0;False;-1;b64acacdeb0e2454fa5f915d8f4cc0d4;d3cfaa263ab42814993310ce350e9955;True;0;False;white;Auto;False;Instance;97;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;443;91.46284,-542.224;Inherit;False;VFX_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;508;-1849.197,-2664.473;Inherit;False;SHF_TransformUV;9;;254;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.CommentaryNode;527;-10409.77,1101.046;Inherit;False;1669.125;580.7198;FirstMovement;16;555;554;553;552;551;550;549;548;547;546;545;544;543;542;541;540;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;528;-9850.583,1689.472;Inherit;False;1669.125;580.7198;SecondMovement;15;559;558;557;556;539;537;536;535;534;533;532;531;530;529;562;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;565;-11090.84,3384.444;Inherit;False;682.4111;356.7962;Max;5;584;578;574;568;567;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;566;-11089.72,2991.031;Inherit;False;696.1697;381.4802;Min;6;587;586;577;572;570;569;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;510;-6164.856,1904.123;Inherit;True;SHF_TransformUV;9;;258;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.GetLocalVarNode;597;-6547.087,1915.656;Inherit;False;596;Scaling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;529;-9069.633,1994.03;Inherit;False;Property;_UsingX1;UsingX ?;4;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;-1;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;530;-9070.657,2090.686;Inherit;False;Property;_UsingY1;UsingY ?;5;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;-1;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;531;-9076.468,1893.849;Inherit;False;Property;_UsingYMove1;UsingYMove ?;32;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;532;-8738.285,1803.615;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;533;-8764.036,1925.324;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;535;-9822.148,1992.728;Inherit;False;Constant;_IfNotUsed1;IfNotUsed;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;536;-9590.17,1853.178;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;537;-9073.425,1786.318;Inherit;False;Property;_UsingXMove1;UsingXMove ?;36;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-9569.211,1928.661;Inherit;False;Constant;_StartPosY1;StartPosY;1;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;540;-10072.38,1151.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;541;-10030.03,1525.684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;542;-9224.101,1191.695;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;543;-9002.65,1225.648;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;544;-9249.852,1313.405;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;545;-9555.448,1382.111;Inherit;False;Property;_UsingX;UsingX ?;6;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;-1;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;547;-9562.283,1281.929;Inherit;False;Property;_UsingYMove;UsingYMove ?;30;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;548;-9559.24,1174.397;Inherit;False;Property;_UsingXMove;UsingXMove ?;35;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;551;-10055.26,1265.438;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;555;-9251.288,1548.609;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;556;-9844.721,2178.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;557;-9588.217,2104.443;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;558;-9567.764,2142.562;Inherit;False;Constant;_MovingUpValue1;MovingUpValue;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;560;-10704.56,1580.63;Inherit;False;SHF_Beat;26;;260;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;538;-8324.981,1547.087;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;559;-8411.607,2177.021;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;562;-8585.679,1770.28;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;567;-10801.74,3439.822;Inherit;False;Property;_UsingXScale1;UsingXScale?;12;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;568;-10794.14,3587.822;Inherit;False;Property;_UsingYScale1;UsingYScale?;21;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;569;-10820.46,3199.921;Inherit;False;Property;_UsingYScale;UsingYScale?;13;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;570;-10816.32,3058.321;Inherit;False;Property;_UsingXScale;UsingXScale?;11;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;571;-11090.79,3088.154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;572;-11077.42,3230.48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;573;-11132.48,3601.67;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;574;-11073.25,3438.179;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;575;-11337.27,3279.89;Inherit;False;Constant;_SizeUnuzed;SizeUnuzed;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;576;-11121.68,3746.468;Inherit;False;SHF_Beat;26;;261;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;577;-10563.62,3111.93;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;578;-10550.1,3498.289;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;579;-10350.56,3276.55;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;580;-10349.8,3367.256;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;581;-9744.873,3133.652;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;582;-10352.09,3059.734;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;584;-11065.99,3654.394;Inherit;False;Property;_MaxSizeY;MaxSizeY;23;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-11093.67,3499.701;Inherit;False;Property;_MaxSizeX;MaxSizeX;25;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-11066.77,3127.051;Inherit;False;Property;_MinSizeX;MinSizeX;24;0;Create;True;0;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;587;-11071.65,3280.072;Inherit;False;Property;_MinSizeY;MinSizeY;22;0;Create;True;0;0;0;False;0;False;2;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;589;-9862.035,3249.973;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;590;-10076.4,3250.704;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;591;-9984.063,3339.811;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;593;-10150.48,3344.225;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;594;-10053.2,3165.569;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;592;-10196.15,3499.421;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;596;-10034.75,3062.748;Inherit;False;Scaling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;602;-8860.908,2667.119;Inherit;False;SHF_Beat;26;;262;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;588;-10099.95,2612.431;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;583;-9752.563,2542.39;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;598;-10277.24,2628.152;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;-8722.599,1219.586;Inherit;False;Movements;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;609;-6093.262,2424.166;Inherit;False;SHF_BeatMoving;85;;263;65813206edc57a749b6de4c0a25b7872;0;3;93;FLOAT;0;False;94;FLOAT;0;False;63;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;610;-6328.552,2593.156;Inherit;False;SHF_BeatScaling;55;;267;1f1f15f84ef3aaf4b94f2810f37733f5;0;2;79;FLOAT2;0,0;False;72;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;611;-6627.783,2595.187;Inherit;True;SHF_BeatRotza;0;;269;7604ce8e2d38f1141bf05ecac26f9e0c;0;3;13;FLOAT2;0.5,0.5;False;12;FLOAT2;0,0;False;11;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;498;-6483.807,3060.673;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;617;-6501.456,2864.578;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-7252.029,2716.699;Inherit;False;Property;_RotaPower;RotaPower;83;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;628;-6826.921,3144.25;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;564;-6549.681,2001.185;Inherit;False;563;Movements;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;509;-6292.463,3040.993;Inherit;True;SHF_TransformUV;9;;256;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.LerpOp;615;-6447.36,3254.72;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-10358.82,1379.657;Inherit;False;Property;_IfNotUsed;IfNotUsed;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;552;-10055.98,1190.534;Inherit;False;Property;_StartPosX;StartPosX;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;553;-10055.26,1319.102;Inherit;False;Property;_StartPosY;StartPosY;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;546;-9559.325,1515.845;Inherit;False;Property;_UsingY;UsingY ?;7;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;-1;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;-10038.66,1453.23;Inherit;False;Property;_OffsetX_Power;OffsetX_Power;7;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;550;-10041.09,1554.161;Inherit;False;Property;_OffsetY_Power;OffsetY_Power;6;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;-6799.654,2962.521;Inherit;False;Property;_Rotater;Rotater;76;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;619;-7041.329,2888.786;Inherit;False;Property;_TransformedRota;TransformedRota;72;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;499;-7049.671,3142.659;Inherit;False;Property;_TransformedScaleX;TransformedScaleX;70;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;627;-7048.207,3217.823;Inherit;False;Property;_TransformedScaleY;TransformedScaleY;71;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;612;-7047.862,3062.108;Inherit;False;Property;_BaseScale;BaseScale;44;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-7055.449,3385.843;Inherit;False;Property;_TransformedOffsetX;TransformedOffsetX;73;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;625;-7056.524,3481.722;Inherit;False;Property;_TransformedOffsetY;TransformedOffsetY;81;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;614;-7034.433,3576.384;Inherit;False;Property;_Offseter;Offseter;74;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;626;-6803.693,3386.044;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;496;-7035.89,3298.147;Inherit;False;Property;_Scaler1;Scaler;75;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;534;-9572.469,1761.006;Inherit;False;Constant;_StartPosX1;StartPosX;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-8578.208,2688.93;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;630;-8795.913,2863.095;Inherit;False;Property;_RotaPower1;RotaPower;84;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;603;-8798.415,2783.785;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;605;-8338.125,2686.591;Inherit;False;Rotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;620;-6543.191,1840.119;Inherit;False;605;Rotation;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;150;1;494;0
WireConnection;179;0;211;0
WireConnection;179;1;180;0
WireConnection;161;1;494;0
WireConnection;182;0;210;0
WireConnection;182;1;248;0
WireConnection;201;0;182;0
WireConnection;151;0;257;0
WireConnection;151;1;254;0
WireConnection;199;0;151;0
WireConnection;259;0;161;4
WireConnection;254;0;253;0
WireConnection;254;1;158;0
WireConnection;254;2;318;0
WireConnection;262;0;260;0
WireConnection;262;1;166;0
WireConnection;262;2;316;0
WireConnection;203;0;259;0
WireConnection;260;0;261;0
WireConnection;260;1;167;0
WireConnection;260;2;317;0
WireConnection;197;0;162;0
WireConnection;162;0;203;0
WireConnection;162;1;262;0
WireConnection;221;0;264;0
WireConnection;221;1;224;0
WireConnection;229;0;233;0
WireConnection;229;1;231;0
WireConnection;229;2;232;0
WireConnection;229;3;230;0
WireConnection;312;0;270;0
WireConnection;187;0;221;0
WireConnection;220;0;312;0
WireConnection;220;1;225;0
WireConnection;225;0;228;0
WireConnection;225;1;227;0
WireConnection;225;2;226;0
WireConnection;211;0;178;4
WireConnection;224;0;223;0
WireConnection;224;1;313;0
WireConnection;270;0;264;0
WireConnection;270;1;267;0
WireConnection;270;2;272;0
WireConnection;271;0;270;0
WireConnection;271;1;266;0
WireConnection;271;2;273;0
WireConnection;264;0;269;0
WireConnection;264;1;268;0
WireConnection;264;2;274;0
WireConnection;185;1;186;0
WireConnection;185;0;271;0
WireConnection;235;0;225;0
WireConnection;236;0;229;0
WireConnection;186;1;309;0
WireConnection;186;0;220;0
WireConnection;304;0;474;34
WireConnection;304;1;328;0
WireConnection;316;0;161;3
WireConnection;317;0;161;2
WireConnection;261;1;168;0
WireConnection;261;2;321;0
WireConnection;318;0;150;3
WireConnection;253;0;252;0
WireConnection;253;1;157;0
WireConnection;253;2;256;0
WireConnection;256;0;150;2
WireConnection;252;1;156;0
WireConnection;252;2;319;0
WireConnection;319;0;150;1
WireConnection;321;0;161;1
WireConnection;309;1;322;0
WireConnection;309;0;187;0
WireConnection;251;0;97;4
WireConnection;313;1;314;0
WireConnection;313;0;222;0
WireConnection;107;1;442;0
WireConnection;107;0;173;0
WireConnection;1;2;107;0
WireConnection;1;3;108;0
WireConnection;1;4;38;0
WireConnection;172;0;185;0
WireConnection;175;0;189;0
WireConnection;189;1;188;0
WireConnection;189;0;236;0
WireConnection;188;1;190;0
WireConnection;188;0;235;0
WireConnection;190;0;224;0
WireConnection;322;0;311;0
WireConnection;322;1;325;0
WireConnection;205;0;179;0
WireConnection;212;0;258;0
WireConnection;258;0;150;4
WireConnection;257;0;212;0
WireConnection;108;1;444;0
WireConnection;108;0;176;0
WireConnection;178;1;494;0
WireConnection;247;0;246;0
WireConnection;247;1;141;0
WireConnection;247;2;250;0
WireConnection;248;0;247;0
WireConnection;248;1;142;0
WireConnection;248;2;249;0
WireConnection;249;0;97;3
WireConnection;246;1;140;0
WireConnection;246;2;320;0
WireConnection;250;0;97;2
WireConnection;320;0;97;1
WireConnection;476;1;508;24
WireConnection;492;0;476;3
WireConnection;493;0;476;1
WireConnection;489;1;487;0
WireConnection;489;2;493;0
WireConnection;484;0;489;0
WireConnection;484;1;483;0
WireConnection;484;2;476;2
WireConnection;485;0;484;0
WireConnection;485;1;488;0
WireConnection;485;2;492;0
WireConnection;482;0;485;0
WireConnection;478;0;479;0
WireConnection;478;1;480;0
WireConnection;478;2;481;0
WireConnection;97;1;494;0
WireConnection;494;1;509;24
WireConnection;494;0;609;0
WireConnection;310;0;97;0
WireConnection;210;0;251;0
WireConnection;54;0;44;1
WireConnection;54;1;44;2
WireConnection;412;0;505;0
WireConnection;412;1;448;0
WireConnection;412;2;413;0
WireConnection;448;29;435;0
WireConnection;448;1;436;0
WireConnection;448;19;445;0
WireConnection;448;20;507;0
WireConnection;448;21;504;0
WireConnection;448;22;462;0
WireConnection;501;0;12;1
WireConnection;463;1;32;0
WireConnection;463;2;12;1
WireConnection;451;0;12;2
WireConnection;377;0;463;0
WireConnection;377;1;373;0
WireConnection;377;2;451;0
WireConnection;503;0;12;3
WireConnection;504;0;12;2
WireConnection;505;0;12;4
WireConnection;507;0;59;1
WireConnection;506;0;59;1
WireConnection;59;1;461;0
WireConnection;430;0;94;0
WireConnection;430;1;412;0
WireConnection;436;0;405;1
WireConnection;445;0;405;2
WireConnection;459;0;377;0
WireConnection;459;1;456;0
WireConnection;459;2;503;0
WireConnection;441;0;459;0
WireConnection;94;0;12;4
WireConnection;94;1;447;0
WireConnection;94;2;95;0
WireConnection;447;29;434;0
WireConnection;447;1;425;0
WireConnection;447;19;446;0
WireConnection;447;20;506;0
WireConnection;447;21;501;0
WireConnection;447;22;462;0
WireConnection;425;0;44;3
WireConnection;446;0;44;4
WireConnection;53;0;14;0
WireConnection;53;1;54;0
WireConnection;12;1;53;0
WireConnection;443;0;430;0
WireConnection;508;45;478;0
WireConnection;510;58;620;0
WireConnection;510;45;597;0
WireConnection;510;52;564;0
WireConnection;529;1;535;0
WireConnection;530;1;557;0
WireConnection;530;0;558;0
WireConnection;531;1;536;0
WireConnection;531;0;539;0
WireConnection;532;0;537;0
WireConnection;532;1;531;0
WireConnection;533;0;529;0
WireConnection;533;1;530;0
WireConnection;536;0;535;0
WireConnection;537;0;534;0
WireConnection;540;0;549;0
WireConnection;541;0;549;0
WireConnection;542;0;548;0
WireConnection;542;1;547;0
WireConnection;543;0;542;0
WireConnection;543;1;544;0
WireConnection;543;2;555;0
WireConnection;544;0;545;0
WireConnection;544;1;546;0
WireConnection;545;1;549;0
WireConnection;545;0;554;0
WireConnection;547;1;551;0
WireConnection;547;0;553;0
WireConnection;548;1;540;0
WireConnection;548;0;552;0
WireConnection;551;0;549;0
WireConnection;555;0;560;34
WireConnection;556;0;560;0
WireConnection;557;0;535;0
WireConnection;538;0;543;0
WireConnection;538;1;562;0
WireConnection;538;2;559;0
WireConnection;559;0;556;0
WireConnection;562;0;532;0
WireConnection;562;1;533;0
WireConnection;562;2;560;34
WireConnection;567;1;574;0
WireConnection;567;0;585;0
WireConnection;568;1;573;0
WireConnection;568;0;584;0
WireConnection;569;1;572;0
WireConnection;569;0;587;0
WireConnection;570;1;571;0
WireConnection;570;0;586;0
WireConnection;571;0;575;0
WireConnection;572;0;575;0
WireConnection;573;0;575;0
WireConnection;574;0;575;0
WireConnection;577;0;570;0
WireConnection;577;1;569;0
WireConnection;578;0;567;0
WireConnection;578;1;568;0
WireConnection;581;0;594;0
WireConnection;581;1;589;0
WireConnection;582;0;577;0
WireConnection;582;1;578;0
WireConnection;589;0;590;0
WireConnection;589;1;591;0
WireConnection;590;0;582;0
WireConnection;590;1;579;0
WireConnection;591;0;593;0
WireConnection;591;1;592;0
WireConnection;593;0;582;0
WireConnection;593;1;580;0
WireConnection;594;0;582;0
WireConnection;596;0;582;0
WireConnection;583;0;588;0
WireConnection;583;1;598;0
WireConnection;583;2;581;0
WireConnection;598;0;582;0
WireConnection;563;0;543;0
WireConnection;609;94;474;34
WireConnection;609;63;610;0
WireConnection;610;79;611;0
WireConnection;611;12;308;0
WireConnection;611;11;304;0
WireConnection;498;0;612;0
WireConnection;498;1;628;0
WireConnection;498;2;496;0
WireConnection;617;1;619;0
WireConnection;617;2;618;0
WireConnection;628;0;499;0
WireConnection;628;1;627;0
WireConnection;509;58;617;0
WireConnection;509;45;498;0
WireConnection;509;52;615;0
WireConnection;615;1;626;0
WireConnection;615;2;614;0
WireConnection;546;1;541;0
WireConnection;546;0;550;0
WireConnection;626;0;613;0
WireConnection;626;1;625;0
WireConnection;604;0;602;34
WireConnection;604;1;603;0
WireConnection;604;2;630;0
WireConnection;605;0;604;0
ASEEND*/
//CHKSM=01CDF0A4222A5B4679D2B662955C46BBA8A10A80