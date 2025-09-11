// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_2DMaster"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Toggle(_VFXORUI_ON)] _VFXorUI("VFXorUI ?", Float) = 0
		[Toggle(_SAMEORNOT_ON)] _SameOrNot("SameOrNot", Float) = 1
		_Curve_Weight("Curve_Weight", Float) = 10
		_Cycle_Curve("Cycle_Curve", Float) = 1
		_Cycle_Alternate("Cycle_Alternate", Float) = 0
		[Toggle(_SCALEISALTERNATED_ON)] _ScaleIsAlternated("ScaleIsAlternated", Float) = 1
		[Toggle(_USINGYSCALE_ON)] _UsingYScale("UsingYScale?", Float) = 1
		[Toggle(_USINGXSCALE_ON)] _UsingXScale("UsingXScale?", Float) = 1
		_Scale1("Scale1", Vector) = (1,1,1,1)
		_Scale2("Scale2", Vector) = (1,1,1,1)
		[Toggle(_OFFSETISALTERNATED_ON)] _OffsetIsAlternated("OffsetIsAlternated", Float) = 1
		[Toggle(_USINGYMOVE_ON)] _UsingYMove("UsingYMove ?", Float) = 1
		[Toggle(_USINGXMOVE_ON)] _UsingXMove("UsingXMove ?", Float) = 1
		_Offset1("Offset1", Vector) = (0,0,0,0)
		_Offset2("Offset2", Vector) = (0,0,0,0)
		[Toggle(_ROTATIONISALTERNATED_ON)] _RotationIsAlternated("RotationIsAlternated", Float) = 1
		_RotaPower("RotaPower", Vector) = (0,0,0,0)
		_Motion_Delay("Motion_Delay", Float) = 0.1
		_2ndMotion_Delay("2ndMotion_Delay", Float) = 0
		BckGrnd_BaseScale("BckGrnd_BaseScale", Float) = 1
		_BackGroundTex("BackGroundTex", 2D) = "white" {}
		_BackGroundColor("BackGroundColor", Color) = (0,0.06411219,1,0)
		_BackTex("BackTex", 2D) = "white" {}
		[HDR]_Back("Back", Color) = (0,1,0.7048147,0)
		[HDR]_Mid("Mid", Color) = (0.6812992,0,1,0)
		[HDR]_Front("Front", Color) = (1,0,0,0)
		_BaseScale("BaseScale", Float) = 1
		_MidTex("MidTex", 2D) = "white" {}
		[HDR]_Back02("Back02", Color) = (1,0,0,0)
		[HDR]_Mid02("Mid02", Color) = (0,1,0.9647675,0)
		[HDR]_Front02("Front02", Color) = (0,1,0.7048147,0)
		_FrontTex("FrontTex", 2D) = "white" {}
		[HDR]_Back03("Back03", Color) = (1,0.9882626,0,0)
		[HDR]_Mid03("Mid03", Color) = (0.6812992,0,1,0)
		[HDR]_Front03("Front03", Color) = (1,0,0.05845451,0)
		[Toggle(_ISVERTICALORLATERAL_ON)] _IsVerticalOrLateral("IsVerticalOrLateral", Float) = 0
		[Toggle(_UPLORDOWNR_ON)] _UpLorDownR("UpLorDownR", Float) = 0
		[Toggle(_2ALPHAS_ON)] _2Alphas("2Alphas?", Float) = 0
		_TransformedScaleX("TransformedScaleX", Float) = 0.8
		_TransformedScaleY("TransformedScaleY", Float) = 0.8
		_TransformedOffsetX("TransformedOffsetX", Float) = 0.8
		_TransformedRota("TransformedRota", Float) = 0.8
		_BckGrnd_TransformedScaleX("BckGrnd_TransformedScaleX", Float) = 0.8
		_BckGrnd_TransformedScaleY("BckGrnd_TransformedScaleY", Float) = 0.8
		_BckGrnd_TransformedRota("BckGrnd_TransformedRota", Float) = 0.8
		_BckGrnd_TransformedOffsetX("BckGrnd_TransformedOffsetX", Float) = 0.8
		_Offseter("Offseter", Range( -1 , 1)) = -0.07699616
		_BckGrnd_Offseter("BckGrnd_Offseter", Range( -1 , 1)) = -0.07699616
		_Scaler1("Scaler", Range( -1 , 1)) = 0
		_BckGrnd_Scaler("BckGrnd_Scaler", Range( -1 , 1)) = 0
		_Rotater("Rotater", Range( -1 , 1)) = -1
		_BckGrnd_Rotater("BckGrnd_Rotater", Range( -1 , 1)) = -1
		_R_Fadesmooth("R_Fadesmooth", Float) = 1.25
		_G_FadeSmooth("G_FadeSmooth", Float) = 1
		_NoColorsWhiteValue("NoColorsWhiteValue", Range( 0 , 1)) = 1
		[Toggle(_HANDLECOLORS_ON)] _HandleColors("HandleColors", Float) = 1
		_TransformedOffsetY("TransformedOffsetY", Float) = 0.8
		_BckGrnd_TransformedOffsetY("BckGrnd_TransformedOffsetY", Float) = 0.8
		[Toggle(_UI_AUTOORMANUAL_ON)] _UI_AutoOrManual("UI_AutoOrManual", Float) = 0
		_MainTexTiling("MainTexTiling", Vector) = (0,0,0,0)
		[HDR]_SubColor("SubColor", Color) = (2.670157,0,0,0)
		[HDR]_SubColor1("SubColor", Color) = (0,2.670157,1.011534,0)
		[HDR]_MainColor("MainColor", Color) = (2.670157,1.899221,0,0)
		_Tex_Nbr("Tex_Nbr", Int) = 3
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

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

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

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
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
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
			#pragma shader_feature_local _HANDLECOLORS_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 BackGroundTexColor205 = ( BackGroundTexAlpha211 * _BackGroundColor );
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 lerpResult246 = lerp( float4( 0,0,0,0 ) , _Back , tex2DNode97.r);
				float4 lerpResult247 = lerp( lerpResult246 , _Mid , tex2DNode97.g);
				float4 lerpResult248 = lerp( lerpResult247 , _Front , tex2DNode97.b);
				float4 BackTexColor201 = ( BackTexAlpha210 * lerpResult248 );
				float4 lerpResult264 = lerp( BackGroundTexColor205 , BackTexColor201 , BackTexAlpha210);
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 lerpResult252 = lerp( float4( 0,0,0,0 ) , _Back02 , tex2DNode150.r);
				float4 lerpResult253 = lerp( lerpResult252 , _Mid02 , tex2DNode150.g);
				float4 lerpResult254 = lerp( lerpResult253 , _Front02 , tex2DNode150.b);
				float4 MidTexColor199 = ( MidTexAlpha212 * lerpResult254 );
				float4 lerpResult270 = lerp( lerpResult264 , MidTexColor199 , MidTexAlpha212);
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float4 lerpResult261 = lerp( float4( 0,0,0,0 ) , _Back03 , tex2DNode161.r);
				float4 lerpResult260 = lerp( lerpResult261 , _Mid03 , tex2DNode161.g);
				float4 lerpResult262 = lerp( lerpResult260 , _Front03 , tex2DNode161.b);
				float4 FrontTexColor197 = ( FrontTexAlpha203 * lerpResult262 );
				float4 lerpResult271 = lerp( lerpResult270 , FrontTexColor197 , FrontTexAlpha203);
				float4 ifLocalVar988 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar988 = lerpResult271;
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar988 = lerpResult270;
				float4 Tex_NoColors310 = tex2DNode97;
				#ifdef _HANDLECOLORS_ON
				float4 staticSwitch309 = lerpResult264;
				#else
				float4 staticSwitch309 = ( Tex_NoColors310 * _NoColorsWhiteValue );
				#endif
				float4 ifLocalVar991 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar991 = ifLocalVar988;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar991 = staticSwitch309;
				float4 UI_Colors172 = ifLocalVar991;
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
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _VFXORUI_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
			sampler2D _BackTex;
			sampler2D _DissolveTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;


			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = UI_Alpha175;
				#else
				float staticSwitch108 = VFX_Alpha443;
				#endif
				

				float Alpha = staticSwitch108;
				float AlphaClipThreshold = _Alphacliptresh;
				float AlphaClipThresholdShadow = 0.5;

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
				return 0;
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
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
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
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
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
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
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
			#pragma shader_feature_local _SAMEORNOT_ON
			#pragma shader_feature_local _UI_AUTOORMANUAL_ON
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _SCALEISALTERNATED_ON
			#pragma shader_feature_local _ROTATIONISALTERNATED_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma shader_feature_local _OFFSETISALTERNATED_ON
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
			float4 _Offset2;
			float4 _Scale2;
			float4 _BackGroundColor;
			float4 _Back;
			float4 _Mid;
			float4 _Front;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front03;
			float4 _Scale1;
			float4 _SubColor1;
			float4 _SubColor;
			float4 _Offset1;
			float2 _RotaPower;
			float2 _MainTexTiling;
			float _BckGrnd_Rotater;
			float _NoColorsWhiteValue;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _BckGrnd_Offseter;
			float _BckGrnd_TransformedOffsetY;
			float _BckGrnd_TransformedOffsetX;
			float _BckGrnd_TransformedRota;
			float BckGrnd_BaseScale;
			float _BckGrnd_TransformedScaleY;
			int _Tex_Nbr;
			float _Motion_Delay;
			float _Cycle_Curve;
			float _Cycle_Alternate;
			float _Curve_Weight;
			float _BaseScale;
			float _TransformedScaleX;
			float _TransformedScaleY;
			float _Scaler1;
			float _TransformedRota;
			float _Rotater;
			float _TransformedOffsetX;
			float _TransformedOffsetY;
			float _Offseter;
			float _2ndMotion_Delay;
			float _G_BaseOpacity;
			float _BckGrnd_TransformedScaleX;
			float _BckGrnd_Scaler;
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

			float BPM1;
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
				#ifdef _USINGXSCALE_ON
				float staticSwitch570 = _Scale1.x;
				#else
				float staticSwitch570 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch569 = _Scale1.y;
				#else
				float staticSwitch569 = 1.0;
				#endif
				float2 appendResult577 = (float2(staticSwitch570 , staticSwitch569));
				#ifdef _USINGXSCALE_ON
				float staticSwitch567 = _Scale1.z;
				#else
				float staticSwitch567 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch568 = _Scale1.w;
				#else
				float staticSwitch568 = 1.0;
				#endif
				float2 appendResult578 = (float2(staticSwitch567 , staticSwitch568));
				float MotionDelay1823 = _Motion_Delay;
				float temp_output_18_0_g535 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g535 = clamp( ( ( fmod( floor( ( temp_output_18_0_g535 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1114 = ( clampResult166_g535 * appendResult578 );
				#else
				float2 staticSwitch1114 = appendResult578;
				#endif
				float clampResult116_g535 = clamp( pow( abs( sin( temp_output_18_0_g535 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult582 = lerp( appendResult577 , staticSwitch1114 , clampResult116_g535);
				float2 Scaling596 = lerpResult582;
				float2 texCoord41_g481 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g481 = float2( 0.5,0.5 );
				float temp_output_18_0_g533 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g533 = clamp( ( ( fmod( floor( ( temp_output_18_0_g533 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1118 = ( clampResult166_g533 * _RotaPower.x );
				#else
				float staticSwitch1118 = _RotaPower.x;
				#endif
				float clampResult116_g533 = clamp( pow( abs( sin( temp_output_18_0_g533 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult760 = lerp( 0.0 , staticSwitch1118 , clampResult116_g533);
				float Rotation605 = lerpResult760;
				float cos47_g481 = cos( Rotation605 );
				float sin47_g481 = sin( Rotation605 );
				float2 rotator47_g481 = mul( ( Scaling596 * ( texCoord41_g481 - temp_output_43_0_g481 ) ) - float2( 0,0 ) , float2x2( cos47_g481 , -sin47_g481 , sin47_g481 , cos47_g481 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch548 = _Offset1.x;
				#else
				float staticSwitch548 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch547 = _Offset1.y;
				#else
				float staticSwitch547 = 0.0;
				#endif
				float2 appendResult542 = (float2(staticSwitch548 , staticSwitch547));
				#ifdef _USINGXMOVE_ON
				float staticSwitch545 = _Offset1.z;
				#else
				float staticSwitch545 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch546 = _Offset1.w;
				#else
				float staticSwitch546 = 0.0;
				#endif
				float2 appendResult544 = (float2(staticSwitch545 , staticSwitch546));
				float temp_output_18_0_g538 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay1823 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g538 = clamp( ( ( fmod( floor( ( temp_output_18_0_g538 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1077 = ( clampResult166_g538 * appendResult544 );
				#else
				float2 staticSwitch1077 = appendResult544;
				#endif
				float clampResult116_g538 = clamp( pow( abs( sin( temp_output_18_0_g538 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult543 = lerp( appendResult542 , staticSwitch1077 , clampResult116_g538);
				float2 Movements563 = lerpResult543;
				float2 temp_cast_0 = (_BaseScale).xx;
				float2 appendResult628 = (float2(_TransformedScaleX , _TransformedScaleY));
				float2 lerpResult498 = lerp( temp_cast_0 , appendResult628 , _Scaler1);
				float2 texCoord41_g480 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g480 = float2( 0.5,0.5 );
				float lerpResult617 = lerp( 0.0 , _TransformedRota , _Rotater);
				float cos47_g480 = cos( lerpResult617 );
				float sin47_g480 = sin( lerpResult617 );
				float2 rotator47_g480 = mul( ( lerpResult498 * ( texCoord41_g480 - temp_output_43_0_g480 ) ) - float2( 0,0 ) , float2x2( cos47_g480 , -sin47_g480 , sin47_g480 , cos47_g480 )) + float2( 0,0 );
				float2 appendResult626 = (float2(_TransformedOffsetX , _TransformedOffsetY));
				float2 lerpResult615 = lerp( float2( 0,0 ) , appendResult626 , _Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch494 = ( ( rotator47_g480 + temp_output_43_0_g480 ) + lerpResult615 );
				#else
				float2 staticSwitch494 = ( ( rotator47_g481 + temp_output_43_0_g481 ) + Movements563 );
				#endif
				#ifdef _USINGXSCALE_ON
				float staticSwitch796 = _Scale2.x;
				#else
				float staticSwitch796 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch795 = _Scale2.y;
				#else
				float staticSwitch795 = 1.0;
				#endif
				float2 appendResult802 = (float2(staticSwitch796 , staticSwitch795));
				#ifdef _USINGXSCALE_ON
				float staticSwitch804 = _Scale2.z;
				#else
				float staticSwitch804 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch805 = _Scale2.w;
				#else
				float staticSwitch805 = 1.0;
				#endif
				float2 appendResult803 = (float2(staticSwitch804 , staticSwitch805));
				float MotionDelay2824 = _2ndMotion_Delay;
				float temp_output_18_0_g536 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g536 = clamp( ( ( fmod( floor( ( temp_output_18_0_g536 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _SCALEISALTERNATED_ON
				float2 staticSwitch1116 = ( clampResult166_g536 * appendResult803 );
				#else
				float2 staticSwitch1116 = appendResult803;
				#endif
				float clampResult116_g536 = clamp( pow( abs( sin( temp_output_18_0_g536 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult793 = lerp( appendResult802 , staticSwitch1116 , clampResult116_g536);
				float2 SecondScale810 = lerpResult793;
				float2 texCoord41_g524 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g524 = float2( 0.5,0.5 );
				float temp_output_18_0_g534 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g534 = clamp( ( ( fmod( floor( ( temp_output_18_0_g534 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _ROTATIONISALTERNATED_ON
				float staticSwitch1120 = ( _RotaPower.y * clampResult166_g534 );
				#else
				float staticSwitch1120 = _RotaPower.y;
				#endif
				float clampResult116_g534 = clamp( pow( abs( sin( temp_output_18_0_g534 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float lerpResult881 = lerp( 0.0 , staticSwitch1120 , clampResult116_g534);
				float SecondRotation883 = lerpResult881;
				float cos47_g524 = cos( SecondRotation883 );
				float sin47_g524 = sin( SecondRotation883 );
				float2 rotator47_g524 = mul( ( SecondScale810 * ( texCoord41_g524 - temp_output_43_0_g524 ) ) - float2( 0,0 ) , float2x2( cos47_g524 , -sin47_g524 , sin47_g524 , cos47_g524 )) + float2( 0,0 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch790 = _Offset2.x;
				#else
				float staticSwitch790 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch784 = _Offset2.y;
				#else
				float staticSwitch784 = 0.0;
				#endif
				float2 appendResult777 = (float2(staticSwitch790 , staticSwitch784));
				#ifdef _USINGXMOVE_ON
				float staticSwitch780 = _Offset2.z;
				#else
				float staticSwitch780 = 0.0;
				#endif
				#ifdef _USINGXMOVE_ON
				float staticSwitch783 = _Offset2.w;
				#else
				float staticSwitch783 = 0.0;
				#endif
				float2 appendResult779 = (float2(staticSwitch780 , staticSwitch783));
				float temp_output_18_0_g537 = ( ( ( _TimeParameters.x * ( 60.0 / 60.0 ) ) - MotionDelay2824 ) * ( _Cycle_Curve * PI ) );
				float clampResult166_g537 = clamp( ( ( fmod( floor( ( temp_output_18_0_g537 / ( _Cycle_Alternate * PI ) ) ) , 2.0 ) * 2.0 ) - 1.0 ) , -1.0 , 1.0 );
				#ifdef _OFFSETISALTERNATED_ON
				float2 staticSwitch1086 = ( clampResult166_g537 * appendResult779 );
				#else
				float2 staticSwitch1086 = appendResult779;
				#endif
				float clampResult116_g537 = clamp( pow( abs( sin( temp_output_18_0_g537 ) ) , _Curve_Weight ) , -1.0 , 1.0 );
				float2 lerpResult778 = lerp( appendResult777 , staticSwitch1086 , clampResult116_g537);
				float2 SecondMovements773 = lerpResult778;
				float2 temp_cast_1 = (BckGrnd_BaseScale).xx;
				float2 appendResult850 = (float2(_BckGrnd_TransformedScaleX , _BckGrnd_TransformedScaleY));
				float2 lerpResult848 = lerp( temp_cast_1 , appendResult850 , _BckGrnd_Scaler);
				float2 texCoord41_g411 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_43_0_g411 = float2( 0.5,0.5 );
				float lerpResult849 = lerp( 0.0 , _BckGrnd_TransformedRota , _BckGrnd_Rotater);
				float cos47_g411 = cos( lerpResult849 );
				float sin47_g411 = sin( lerpResult849 );
				float2 rotator47_g411 = mul( ( lerpResult848 * ( texCoord41_g411 - temp_output_43_0_g411 ) ) - float2( 0,0 ) , float2x2( cos47_g411 , -sin47_g411 , sin47_g411 , cos47_g411 )) + float2( 0,0 );
				float2 appendResult856 = (float2(_BckGrnd_TransformedOffsetX , _BckGrnd_TransformedOffsetY));
				float2 lerpResult851 = lerp( float2( 0,0 ) , appendResult856 , _BckGrnd_Offseter);
				#ifdef _UI_AUTOORMANUAL_ON
				float2 staticSwitch847 = ( ( rotator47_g411 + temp_output_43_0_g411 ) + lerpResult851 );
				#else
				float2 staticSwitch847 = ( ( rotator47_g524 + temp_output_43_0_g524 ) + SecondMovements773 );
				#endif
				#ifdef _SAMEORNOT_ON
				float2 staticSwitch1033 = staticSwitch847;
				#else
				float2 staticSwitch1033 = staticSwitch494;
				#endif
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, staticSwitch1033 ).a;
				float4 tex2DNode97 = tex2D( _BackTex, staticSwitch494 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 tex2DNode150 = tex2D( _MidTex, staticSwitch494 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 tex2DNode161 = tex2D( _FrontTex, staticSwitch494 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				float ifLocalVar993 = 0;
				if( _Tex_Nbr > 2.0 )
				ifLocalVar993 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				else if( _Tex_Nbr == 2.0 )
				ifLocalVar993 = temp_output_225_0;
				#ifdef _HANDLECOLORS_ON
				float staticSwitch313 = BackGroundTexAlpha211;
				#else
				float staticSwitch313 = 0.0;
				#endif
				float temp_output_224_0 = ( BackTexAlpha210 + staticSwitch313 );
				float ifLocalVar994 = 0;
				if( _Tex_Nbr > 1.0 )
				ifLocalVar994 = ifLocalVar993;
				else if( _Tex_Nbr == 1.0 )
				ifLocalVar994 = temp_output_224_0;
				float UI_Alpha175 = ifLocalVar994;
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
Node;AmplifyShaderEditor.CommentaryNode;608;-10988.61,925.5162;Inherit;False;4357.656;3329.448;;4;606;893;561;595;Beat Transforms;0.1698113,0.1698113,0.1698113,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;595;-10567.33,2616.067;Inherit;False;2035.538;1553.317;;5;1159;826;827;1132;1133;Scaler;0.02201257,0.1761006,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1133;-10254.89,3420.862;Inherit;False;1684.611;690.9563;Scale2;20;1178;889;1150;1177;1115;1116;805;804;803;1148;795;1176;1154;1170;802;810;793;1175;796;1185;;0,0.2515723,0.0971984,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1132;-10250.49,2687.169;Inherit;False;1639.808;653.7966;Scale1;20;596;582;1114;1113;578;1179;1169;1172;1173;1171;569;570;577;568;567;1155;1174;1167;1166;1184;;0.1846908,0.2704402,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;561;-9925.699,1090.748;Inherit;False;1980.634;1375.057;;10;825;1109;1089;1103;1083;1106;1110;828;774;527;Moving;0.3333333,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;879;-2287.547,1488.506;Inherit;False;2802.088;1339.908;;29;993;1009;1013;1032;988;994;991;1029;1030;1025;1006;1005;992;1004;1011;1015;1028;220;221;312;309;311;322;1003;1018;1019;1020;1026;1027;Assemble;0.4842767,0.4766622,0.4766622,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;368;-6408.438,937.6192;Inherit;False;7003.739;3252.216;;14;875;868;869;871;879;906;908;172;325;1017;1016;175;1033;873;UI;0.1635219,0.1635219,0.1635219,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1027;-2219.873,1581.569;Inherit;False;766.5518;311.3484;Alpha_1;5;222;314;224;223;313;;0.3459119,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1026;-891.2115,2477.239;Inherit;False;541.9011;304.3931;Color_3;3;271;266;273;;0,0.06323656,0.4276729,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1020;-836.5066,1662.119;Inherit;False;514.2423;335.5398;Alpha_3;5;230;232;231;229;233;;0,0.02204754,0.3584906,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1019;-1478.258,2448.507;Inherit;False;542.54;303.6667;Color_2;3;267;272;270;;0,0.2264151,0.005972143,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1018;-2106.11,2447.963;Inherit;False;574.6967;303.6667;Color_1;4;274;268;269;264;;0.3584906,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1003;-1424.446,1669.658;Inherit;False;548.1049;304.7107;Alpha_2;4;228;226;227;225;;0,0.2830189,0.0219734,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;908;-6323.719,1104.297;Inherit;False;1634.891;2788.846;;6;494;847;845;867;907;909;TimeManagement;0.1138008,0.1446127,0.2641509,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;909;-5756.739,2412.077;Inherit;False;622.2588;303.6667;OnBeat;4;896;620;597;564;;0.2327043,0.2327043,0.2327043,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;907;-5945.729,1154.297;Inherit;False;844.3833;305.3367;OnBeat;4;898;766;765;768;;0.245283,0.245283,0.245283,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;906;-4388.354,1081.387;Inherit;False;1273.098;339.0424;BackGround;5;205;179;211;180;178;;0.05031443,0,0.03764602,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;893;-10703.02,1126.212;Inherit;False;530.8477;292.8535;;4;771;824;823;820;DelayParameters;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;871;-4385.7,1466.944;Inherit;False;1801.775;893.1528;Back;16;142;141;140;831;837;834;249;836;247;246;310;97;201;210;182;248;;0.5220125,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;869;-4384.468,2387.144;Inherit;False;1816.809;833.2087;Mid;15;158;157;156;150;253;319;252;256;840;839;318;199;212;151;254;;0.01114827,0.5031446,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;868;-4378.224,3253.138;Inherit;False;1810.945;840.1016;Front;15;197;162;260;321;843;317;844;316;262;168;261;166;203;167;161;;0.0221966,0,0.58,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;867;-6273.719,1521.425;Inherit;False;1269.521;761.2765;Manual;17;862;852;853;858;859;857;854;855;861;856;850;849;848;865;866;851;895;;0.2704402,0.2704402,0.2704402,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;845;-6096.641,2728.174;Inherit;False;1126.236;790.0181;Manual;17;897;617;615;626;877;614;625;613;876;498;496;628;619;618;612;499;627;;0.3773585,0.3773585,0.3773585,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;606;-8311.321,2622.393;Inherit;False;1506.33;678.1455;;19;1117;1118;1120;881;1119;884;605;760;883;885;1134;1139;1140;1141;1145;1146;1147;1183;1182;Rotator;0,0.000678908,0.4402515,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;107;1520.725,-969.8881;Inherit;False;Property;_VFXorUI;VFXorUI ?;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1415.615,-599.0623;Inherit;False;Property;_Alphacliptresh;Alphacliptresh;70;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;108;1533.131,-823.3735;Inherit;False;Property;_VFXorUI1;VFXorUI ?;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;107;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;1340.735,-757.0334;Inherit;False;175;UI_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;1342.15,-835.7303;Inherit;False;443;VFX_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;462;-1318.037,-566.3159;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;442;1323.902,-1042.685;Inherit;False;441;VfxColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;14;-2028.562,-1407.01;Inherit;False;Property;_MainTexTiling;MainTexTiling;65;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;54;-2004.504,-1272.707;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;-425.5654,-530.0711;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;413;-842.3475,-105.0168;Inherit;False;Property;_G_BaseOpacity;G_BaseOpacity;73;0;Create;True;0;0;0;False;0;False;0.5109974;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;448;-819.1606,-392.3603;Inherit;False;SHF_VFX_Fades;37;;246;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;501;-982.1696,-1276.182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-1541.57,-2084.887;Inherit;False;Property;_MainColor;MainColor;68;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,1.899221,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;373;-1559.936,-1866.487;Inherit;False;Property;_SubColor;SubColor;66;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,0,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;456;-1572.684,-1618.964;Inherit;False;Property;_SubColor1;SubColor;67;1;[HDR];Create;True;0;0;0;False;0;False;0,2.670157,1.011534,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;463;-1276.348,-2109.786;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;451;-1266.501,-1725.942;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;377;-1003.592,-1891.054;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;503;-1205.187,-1507.616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;504;-980.4263,-1200.048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;505;-1233.916,-669.4098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;507;-1839.689,-262.4424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;506;-1897.38,-866.2743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-2262.321,-701.1569;Inherit;True;Property;_DissolveTex;DissolveTex;71;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;461;-2474.079,-679.4251;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;430;-131.8206,-546.206;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;405;-2503.743,-386.9624;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;436;-2260.993,-382.4208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;-2259.697,-305.3382;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-1328.349,-397.0139;Inherit;False;Property;_G_FadeSmooth;G_FadeSmooth;59;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;459;-725.9671,-1653.464;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-418.4314,-1236.692;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;447;-834.8542,-1176.183;Inherit;False;SHF_VFX_Fades;37;;247;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-828.3532,-980.4771;Inherit;False;Property;_R_BaseOpacity;R_BaseOpacity;72;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-1495.129,-1165.293;Inherit;False;Property;_R_Fadesmooth;R_Fadesmooth;58;0;Create;True;0;0;0;False;0;False;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2395.993,-1158.129;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;425;-2135.748,-1111.891;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;446;-2124.06,-1037.711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-1806.759,-1426.888;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-1566.118,-1366.487;Inherit;True;Property;_MainTex;MainTex;24;1;[HDR];Create;True;0;0;0;False;0;False;-1;b64acacdeb0e2454fa5f915d8f4cc0d4;d3cfaa263ab42814993310ce350e9955;True;0;False;white;Auto;False;Instance;97;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;527;-9643.938,1135.985;Inherit;False;1646.38;582.0895;Offset;19;563;543;1080;1081;1077;1064;544;545;546;542;548;813;1127;547;1099;540;1100;1108;1181;;1,0.2922183,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;1316.236,-953.6783;Inherit;False;172;UI_Colors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;719;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;720;1762.71,-953.0219;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;SHR_2DMaster;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;721;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;722;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;723;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;724;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;725;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;726;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;727;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;728;1762.71,-953.0219;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.CommentaryNode;774;-9642.528,1748.556;Inherit;False;1649.363;683.3032;Offset2;18;773;778;1128;1086;1085;779;783;780;784;1087;1088;777;790;1104;1105;1102;1101;1180;;1,0,0.3366632,1;0;0
Node;AmplifyShaderEditor.LerpOp;254;-3408.467,2963.144;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-3152.467,2931.144;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-3408.467,2531.144;Inherit;False;MidTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-2944.467,2931.144;Inherit;False;MidTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-3386.225,3381.138;Inherit;False;FrontTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;262;-3418.225,3829.138;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-3146.225,3813.138;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-2954.225,3813.138;Inherit;False;FrontTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;248;-3393.699,2074.944;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-3105.699,2042.944;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-3377.699,1610.944;Inherit;False;BackTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-2897.699,2042.944;Inherit;False;BackTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;823;-10423.83,1176.211;Inherit;False;MotionDelay1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;824;-10414.17,1306.4;Inherit;False;MotionDelay2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-3632.551,1140.147;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-3406.775,1140.797;Inherit;False;BackGroundTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;627;-6012.556,3122.049;Inherit;False;Property;_TransformedScaleY;TransformedScaleY;45;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;499;-6014.02,3046.885;Inherit;False;Property;_TransformedScaleX;TransformedScaleX;44;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;856;-5916.103,2022.944;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;850;-5922.621,1808.132;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;865;-5790.465,1934.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;866;-5794.738,2164.922;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;612;-5954.458,2969.958;Inherit;False;Property;_BaseScale;BaseScale;28;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;618;-6073.698,2889.156;Inherit;False;Property;_Rotater;Rotater;56;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;619;-6010.41,2821.406;Inherit;False;Property;_TransformedRota;TransformedRota;47;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;496;-6072.166,3194.802;Inherit;False;Property;_Scaler1;Scaler;54;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-6037.798,3290.068;Inherit;False;Property;_TransformedOffsetX;TransformedOffsetX;46;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;625;-6040.206,3358.615;Inherit;False;Property;_TransformedOffsetY;TransformedOffsetY;62;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;614;-6067.125,3429.942;Inherit;False;Property;_Offseter;Offseter;52;0;Create;True;0;0;0;False;0;False;-0.07699616;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;862;-6213.744,1667.857;Inherit;False;Property;_BckGrnd_Rotater;BckGrnd_Rotater;57;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;852;-6209.091,1599.841;Inherit;False;Property;_BckGrnd_TransformedRota;BckGrnd_TransformedRota;50;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;859;-6154.573,1736.318;Inherit;False;Property;BckGrnd_BaseScale;BckGrnd_BaseScale;21;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;857;-6220.497,1951.801;Inherit;False;Property;_BckGrnd_Scaler;BckGrnd_Scaler;55;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;861;-6215.444,2170.035;Inherit;False;Property;_BckGrnd_Offseter;BckGrnd_Offseter;53;0;Create;True;0;0;0;False;0;False;-0.07699616;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;855;-6224.186,2100.507;Inherit;False;Property;_BckGrnd_TransformedOffsetY;BckGrnd_TransformedOffsetY;63;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;854;-6225.721,2025.15;Inherit;False;Property;_BckGrnd_TransformedOffsetX;BckGrnd_TransformedOffsetX;51;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;853;-6223.929,1883.889;Inherit;False;Property;_BckGrnd_TransformedScaleY;BckGrnd_TransformedScaleY;49;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;858;-6219.471,1810.696;Inherit;False;Property;_BckGrnd_TransformedScaleX;BckGrnd_TransformedScaleX;48;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;849;-5740.073,1576.846;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;848;-5729.528,1739.303;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;851;-5751.115,1996.838;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;628;-5800.732,3046.583;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;876;-5636.481,3173.232;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;877;-5660.567,3434.109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;626;-5788.842,3288.536;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;895;-5347.52,1576.544;Inherit;True;SHF_TransformUV;-1;;411;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.GetLocalVarNode;766;-5770.07,1216.008;Inherit;False;883;SecondRotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;768;-5804.948,1366.635;Inherit;False;773;SecondMovements;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;765;-5777.834,1290.613;Inherit;False;810;SecondScale;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;847;-4978.276,1219.681;Inherit;False;Property;_UI_AutoOrMano1;UI_AutoOrMano;64;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;494;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;620;-5706.739,2463.907;Inherit;False;605;Rotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;316;-4010.224,3941.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;844;-4090.223,3925.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;317;-4042.224,3749.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;843;-3978.225,3765.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;161;-4346.224,3301.138;Inherit;True;Property;_FrontTex;FrontTex;33;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;7bc00bfbbf2254540a53064df3cfd095;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;318;-4096.467,3043.144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;839;-4032.467,3059.144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;840;-4048.467,2851.144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;256;-4000.467,2867.144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;252;-3936.467,2595.144;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;319;-4048.467,2691.144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;253;-3664.467,2787.144;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;261;-3930.225,3461.138;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;260;-3674.225,3653.138;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;321;-4026.224,3541.138;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;97;-4353.7,1514.944;Inherit;True;Property;_BackTex;BackTex;24;0;Create;True;0;0;0;False;0;False;-1;fc79c2d7bd6508145b8841ba2a15ec3c;b47ae78de3d3b7749a4836d0c15c157a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-3969.699,1514.944;Inherit;False;Tex_NoColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;246;-3905.699,1706.944;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;247;-3649.699,1898.944;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;836;-4001.699,2186.944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;249;-4049.699,2154.944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;834;-4033.699,1978.944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;837;-3985.699,1994.944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;831;-4017.699,1770.944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-4355.874,1169.8;Inherit;True;Property;_BackGroundTex;BackGroundTex;22;0;Create;True;0;0;0;False;0;False;-1;713f4997cbb93c8499a4fc331554b44a;713f4997cbb93c8499a4fc331554b44a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;180;-4007.983,1221.856;Inherit;False;Property;_BackGroundColor;BackGroundColor;23;0;Create;True;0;0;0;False;0;False;0,0.06411219,1,0;0.4179827,0.1317639,0.5943396,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-4022.533,1146.123;Inherit;False;BackGroundTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;771;-10653.02,1304.213;Inherit;False;Property;_2ndMotion_Delay;2ndMotion_Delay;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;820;-10641.23,1180.332;Inherit;False;Property;_Motion_Delay;Motion_Delay;19;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-1974.488,2161.092;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-2233.651,2162.07;Inherit;False;310;Tex_NoColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-2261.722,2220.286;Inherit;False;Property;_NoColorsWhiteValue;NoColorsWhiteValue;60;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;309;-431.7256,2172.908;Inherit;False;Property;_HandleColors;HandleColors;61;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;312;-925.6985,2342.225;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;264;-1814.18,2478.204;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-1471.895,2223.156;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;-2074.39,2476.509;Inherit;False;205;BackGroundTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;-2043.314,2543.748;Inherit;False;201;BackTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-2042.139,2612.661;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;270;-1157.917,2475.382;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;272;-1390.913,2626.969;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-1395.643,2545.941;Inherit;False;199;MidTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-854.6032,2649.282;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-857.6281,2578.24;Inherit;False;197;FrontTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-795.8965,2250.497;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1028;-1314.589,2290.212;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;271;-619.8854,2516.549;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1015;-468.0402,2307.027;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1011;-470.1478,2303.278;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-774.4012,1690.223;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-516.1602,1688.655;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-746.3804,1755.674;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-745.7423,1824.227;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;313;-1932.431,1612.667;Inherit;False;Property;_HandleColors1;HandleColors;61;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;309;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-1921.502,1714.994;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;224;-1659.517,1591.785;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;314;-2105.834,1613.323;Inherit;False;Constant;_NoBackGround;NoBackGround;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-2166.483,1708.515;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;278.7988,1547.117;Inherit;True;UI_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;225;-1112.572,1740.812;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-1373.736,1803.308;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-1399.592,1866.116;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-1363.446,1735.885;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1005;-189.6397,1867.049;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.ConditionalIfNode;994;87.41484,1573.199;Inherit;False;False;5;0;INT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;988;-216.0848,2411.993;Inherit;False;False;5;0;INT;0;False;1;FLOAT;2;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1017;-866.4092,1922.94;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1016;-852.8484,2006.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1032;-875.4878,1937.972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1004;-658.7407,2030.289;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1013;-660.0718,2037.489;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.ConditionalIfNode;993;-142.9699,2004.78;Inherit;False;False;5;0;INT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;992;-1072.59,2000.043;Inherit;False;Property;_Tex_Nbr;Tex_Nbr;69;0;Create;True;0;0;0;False;0;False;3;0;False;0;1;INT;0
Node;AmplifyShaderEditor.WireNode;1025;-443.8749,2037.813;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1006;-260.5655,2009.214;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1009;-653.4006,2034.455;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1030;-577.2017,2057.44;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.WireNode;1029;-575.8791,2062.73;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.ConditionalIfNode;991;97.57034,2329.6;Inherit;False;False;5;0;INT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;297.7115,2307.45;Inherit;True;UI_Colors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;140;-4257.7,1722.944;Inherit;False;Property;_Back;Back;25;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.7924528,0.2554455,0.2504449,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;141;-4257.7,1914.944;Inherit;False;Property;_Mid;Mid;26;1;[HDR];Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0.8867924,0.8867924,0.8867924,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;142;-4241.7,2106.944;Inherit;False;Property;_Front;Front;27;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;0,0.1984615,0.6886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;150;-4368.468,2435.144;Inherit;True;Property;_MidTex;MidTex;29;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;9cd71f3e555499d4bb26528953021f9e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;156;-4304.468,2627.144;Inherit;False;Property;_Back02;Back02;30;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0.043478,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;157;-4304.468,2803.144;Inherit;False;Property;_Mid02;Mid02;31;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.9647675,0;0.3710691,0.3167328,0.311558,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;158;-4304.468,2979.144;Inherit;False;Property;_Front02;Front02;32;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.3144653,0.3144653,0.3144653,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;168;-4314.224,3495.61;Inherit;False;Property;_Back03;Back03;34;1;[HDR];Create;True;0;0;0;False;0;False;1,0.9882626,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;167;-4314.224,3685.138;Inherit;False;Property;_Mid03;Mid03;35;1;[HDR];Create;True;0;0;0;False;0;False;0.6812992,0,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;166;-4314.224,3861.138;Inherit;False;Property;_Front03;Front03;36;1;[HDR];Create;False;0;0;0;False;0;False;1,0,0.05845451,0;0.1522287,0,0.2327043,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;441;-493.6378,-1654.402;Inherit;False;VfxColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;443;91.46284,-542.224;Inherit;False;VFX_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;399;-1652.833,-87.65472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;1033;-4632.584,1200.814;Inherit;False;Property;_SameOrNot;SameOrNot;1;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;873;-4653.917,1639.005;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;494;-4969.616,2458.745;Inherit;False;Property;_UI_AutoOrManual;UI_AutoOrManual;64;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;498;-5589.495,2965.845;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;615;-5593.926,3264.292;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;617;-5592.018,2790.375;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;897;-5287.25,2788.199;Inherit;True;SHF_TransformUV;-1;;480;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.GetLocalVarNode;564;-5706.468,2596.351;Inherit;False;563;Movements;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;597;-5706.549,2531.369;Inherit;False;596;Scaling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;896;-5413.814,2462.077;Inherit;True;SHF_TransformUV;-1;;481;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.WireNode;875;-4661.733,3270.771;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;828;-9889.083,1845.401;Inherit;False;824;MotionDelay2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1100;-9608.725,1509.433;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1099;-9615.412,1647.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1102;-9619.701,1801.904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1118;-7589.097,2741.941;Inherit;False;Property;_RotationIsAlternated;RotationIsAlternated;17;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;898;-5447.127,1221.533;Inherit;True;SHF_TransformUV;-1;;524;fd7ee613e318b9443957fee255345804;0;4;58;FLOAT;0;False;45;FLOAT2;1,1;False;52;FLOAT2;0,0;False;43;FLOAT2;0.5,0.5;False;1;FLOAT2;24
Node;AmplifyShaderEditor.StaticSwitch;1120;-7618.59,3005.746;Inherit;False;Property;_RotationIsAlternated1;RotationIsAlternated;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;1118;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;790;-9335.459,1793.137;Inherit;False;Property;_UsingXMove1;UsingXMove ?;14;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;548;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;777;-9068.422,1791.476;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1088;-9047.194,1895.537;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1087;-9021.667,1911.519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;784;-9328.208,1915.933;Inherit;False;Property;_UsingYMove1;UsingYMove ?;13;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;547;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;780;-9357.279,2195.265;Inherit;False;Property;_UsingX1;UsingX ?;14;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;548;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;783;-9350.563,2339.195;Inherit;False;Property;_UsingY1;UsingY ?;14;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;548;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;779;-9080.606,2195.09;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1085;-8937.259,2100.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1086;-8797.396,2192.798;Inherit;False;Property;_MotionIsAlternated1;MotionIsAlternated;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;1077;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;1128;-9619.919,2002.867;Inherit;False;Property;_Offset2;Offset2;16;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;778;-8494.53,1792.142;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;547;-9341.215,1312.901;Inherit;False;Property;_UsingYMove;UsingYMove ?;13;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;813;-9620.868,1339.766;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;548;-9341.248,1178.958;Inherit;False;Property;_UsingXMove;UsingXMove ?;14;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;542;-9061.049,1177.388;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;546;-9350.109,1601.009;Inherit;False;Property;_UsingY;UsingY ?;13;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;547;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;545;-9345.855,1489.194;Inherit;False;Property;_UsingX;UsingX ?;14;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;548;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;544;-9079.66,1489.898;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1064;-8924.059,1398.281;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1077;-8748.792,1489.009;Inherit;False;Property;_OffsetIsAlternated;OffsetIsAlternated;12;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1081;-9027.188,1295.173;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1080;-8990.457,1315.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;825;-9861.094,1234.082;Inherit;False;823;MotionDelay1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;543;-8438.115,1180.564;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;-8213.388,1182.589;Inherit;False;Movements;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;773;-8267.748,1793.575;Inherit;False;SecondMovements;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1140;-7700.74,2828.849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1139;-7745.313,2809.349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;885;-8301.098,2677.399;Inherit;False;823;MotionDelay1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;884;-8291.063,3174.724;Inherit;False;824;MotionDelay2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1117;-7733.014,2692.615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1119;-7757.503,3176.92;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1141;-7797.663,3141.102;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1147;-8016.808,3026.545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;567;-9961.992,3108.874;Inherit;False;Property;_UsingXScale1;UsingXScale?;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;570;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;568;-9963.476,3213.972;Inherit;False;Property;_UsingYScale1;UsingYScale?;8;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;569;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;577;-9630.293,2738.08;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;570;-9927.15,2736.504;Inherit;False;Property;_UsingXScale;UsingXScale?;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;569;-9929.138,2895.262;Inherit;False;Property;_UsingYScale;UsingYScale?;8;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1171;-9603.885,2892.113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1175;-9552.065,3654.631;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;793;-9026.915,3501.345;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;810;-8803.674,3501.857;Inherit;False;SecondScale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;802;-9638.037,3495.85;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1169;-10229.86,3255.235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1170;-10207.98,3472.465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1115;-9507.615,3835.599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1177;-10203.64,3912.765;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;889;-10199.18,4002.224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;827;-10493.39,2807.094;Inherit;False;823;MotionDelay1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;578;-9694.585,3147.991;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1113;-9529.359,3032.764;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1114;-9365.399,3147.333;Inherit;False;Property;_ScaleIsAlternated;ScaleIsAlternated;7;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;582;-9052.161,2738.357;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;596;-8824.335,2739.663;Inherit;False;Scaling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;1179;-10223.17,3145.881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1173;-10207.27,2922.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1172;-10208.48,2771.245;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;795;-9936.106,3625.869;Inherit;False;Property;_UsingYScale2;UsingYScale?;8;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;569;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;796;-9926.955,3491.468;Inherit;False;Property;_UsingXScale2;UsingXScale?;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;570;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1116;-9312.435,3928.909;Inherit;False;Property;_MotionIsAlternated3;MotionIsAlternated;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;1114;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;803;-9664.771,3933.015;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;804;-9943.902,3885.938;Inherit;False;Property;_UsingXScale3;UsingXScale?;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;570;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;805;-9944.584,3981.635;Inherit;False;Property;_UsingYScale3;UsingYScale?;8;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;569;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1182;-8048.226,2669.091;Inherit;False;SHF_Beat;2;;533;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.FunctionNode;1183;-8058.188,3176.115;Inherit;False;SHF_Beat;2;;534;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.FunctionNode;1184;-10208.91,2807.612;Inherit;False;SHF_Beat;2;;535;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.Vector2Node;1134;-8269.213,2866.176;Inherit;False;Property;_RotaPower;RotaPower;18;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1089;-9873.099,1691.868;Inherit;False;Constant;_offsetUnused;offsetUnused;81;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;1155;-10207.23,2963.567;Inherit;False;Property;_Scale1;Scale1;10;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;1148;-10215.71,3702.818;Inherit;False;Property;_Scale2;Scale2;11;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;1127;-9571.238,1355.248;Inherit;False;Property;_Offset1;Offset1;15;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;1146;-7870.409,2794.679;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;826;-10492.66,3546.375;Inherit;False;824;MotionDelay2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1185;-10210.92,3549.606;Inherit;False;SHF_Beat;2;;536;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.WireNode;1154;-10232.3,3654.237;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1159;-10470.72,3330.527;Inherit;False;Constant;_ScaleUnused;ScaleUnused;77;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1150;-10252.18,3884.723;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1178;-10247.33,3970.083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1176;-10263.47,3621.816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1174;-10259.82,3167.137;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1167;-10248.75,2950.89;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1166;-10240.56,2799.595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1083;-9649.515,2193.536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1104;-9604.13,2218.955;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1103;-9644.15,2268.555;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1105;-9609.762,2331.125;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1180;-9619.071,1842.154;Inherit;False;SHF_Beat;2;;537;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.WireNode;1101;-9608.932,1947.918;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1106;-9645.328,1918.582;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1110;-9646.755,1546.586;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1109;-9647.803,1360.114;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;540;-9613.892,1200.697;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1108;-9648.639,1215.638;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;881;-7278.372,3037.045;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1145;-7755.74,3118.146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;760;-7268.041,2750.693;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;605;-7026.779,2751.359;Inherit;False;Rotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;883;-7043.62,3035.844;Inherit;False;SecondRotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1181;-9628.211,1237.736;Inherit;False;SHF_Beat;2;;538;98b937ed0bb6230429680ab88ee4981b;0;1;99;FLOAT;0;False;2;FLOAT;131;FLOAT;165
Node;AmplifyShaderEditor.GetLocalVarNode;230;-749.476,1890.615;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;107;1;442;0
WireConnection;107;0;173;0
WireConnection;108;1;444;0
WireConnection;108;0;176;0
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
WireConnection;720;2;107;0
WireConnection;720;3;108;0
WireConnection;720;4;38;0
WireConnection;254;0;253;0
WireConnection;254;1;158;0
WireConnection;254;2;839;0
WireConnection;151;0;212;0
WireConnection;151;1;254;0
WireConnection;212;0;150;4
WireConnection;199;0;151;0
WireConnection;203;0;161;4
WireConnection;262;0;260;0
WireConnection;262;1;166;0
WireConnection;262;2;316;0
WireConnection;162;0;203;0
WireConnection;162;1;262;0
WireConnection;197;0;162;0
WireConnection;248;0;247;0
WireConnection;248;1;142;0
WireConnection;248;2;836;0
WireConnection;182;0;210;0
WireConnection;182;1;248;0
WireConnection;210;0;97;4
WireConnection;201;0;182;0
WireConnection;823;0;820;0
WireConnection;824;0;771;0
WireConnection;179;0;211;0
WireConnection;179;1;180;0
WireConnection;205;0;179;0
WireConnection;856;0;854;0
WireConnection;856;1;855;0
WireConnection;850;0;858;0
WireConnection;850;1;853;0
WireConnection;865;0;857;0
WireConnection;866;0;861;0
WireConnection;849;1;852;0
WireConnection;849;2;862;0
WireConnection;848;0;859;0
WireConnection;848;1;850;0
WireConnection;848;2;865;0
WireConnection;851;1;856;0
WireConnection;851;2;866;0
WireConnection;628;0;499;0
WireConnection;628;1;627;0
WireConnection;876;0;496;0
WireConnection;877;0;614;0
WireConnection;626;0;613;0
WireConnection;626;1;625;0
WireConnection;895;58;849;0
WireConnection;895;45;848;0
WireConnection;895;52;851;0
WireConnection;847;1;898;24
WireConnection;847;0;895;24
WireConnection;316;0;844;0
WireConnection;844;0;161;3
WireConnection;317;0;161;2
WireConnection;843;0;317;0
WireConnection;161;1;875;0
WireConnection;318;0;150;3
WireConnection;839;0;318;0
WireConnection;840;0;150;2
WireConnection;256;0;840;0
WireConnection;252;1;156;0
WireConnection;252;2;319;0
WireConnection;319;0;150;1
WireConnection;253;0;252;0
WireConnection;253;1;157;0
WireConnection;253;2;256;0
WireConnection;261;1;168;0
WireConnection;261;2;321;0
WireConnection;260;0;261;0
WireConnection;260;1;167;0
WireConnection;260;2;843;0
WireConnection;321;0;161;1
WireConnection;97;1;873;0
WireConnection;310;0;97;0
WireConnection;246;1;140;0
WireConnection;246;2;831;0
WireConnection;247;0;246;0
WireConnection;247;1;141;0
WireConnection;247;2;837;0
WireConnection;836;0;249;0
WireConnection;249;0;97;3
WireConnection;834;0;97;2
WireConnection;837;0;834;0
WireConnection;831;0;97;1
WireConnection;178;1;1033;0
WireConnection;211;0;178;4
WireConnection;322;0;311;0
WireConnection;322;1;325;0
WireConnection;309;1;322;0
WireConnection;309;0;1028;0
WireConnection;312;0;270;0
WireConnection;264;0;269;0
WireConnection;264;1;268;0
WireConnection;264;2;274;0
WireConnection;221;0;264;0
WireConnection;221;1;224;0
WireConnection;270;0;264;0
WireConnection;270;1;267;0
WireConnection;270;2;272;0
WireConnection;220;0;312;0
WireConnection;220;1;1017;0
WireConnection;1028;0;264;0
WireConnection;271;0;270;0
WireConnection;271;1;266;0
WireConnection;271;2;273;0
WireConnection;1015;0;1029;0
WireConnection;1011;0;1030;0
WireConnection;229;0;233;0
WireConnection;229;1;231;0
WireConnection;229;2;232;0
WireConnection;229;3;230;0
WireConnection;313;1;314;0
WireConnection;313;0;222;0
WireConnection;224;0;223;0
WireConnection;224;1;313;0
WireConnection;175;0;994;0
WireConnection;225;0;228;0
WireConnection;225;1;227;0
WireConnection;225;2;226;0
WireConnection;1005;0;1006;0
WireConnection;994;0;1005;0
WireConnection;994;2;993;0
WireConnection;994;3;224;0
WireConnection;988;0;1011;0
WireConnection;988;2;271;0
WireConnection;988;3;270;0
WireConnection;1017;0;225;0
WireConnection;1016;0;1032;0
WireConnection;1032;0;225;0
WireConnection;1004;0;992;0
WireConnection;1013;0;992;0
WireConnection;993;0;1025;0
WireConnection;993;2;229;0
WireConnection;993;3;1016;0
WireConnection;1025;0;992;0
WireConnection;1006;0;1004;0
WireConnection;1009;0;992;0
WireConnection;1030;0;1009;0
WireConnection;1029;0;1013;0
WireConnection;991;0;1015;0
WireConnection;991;2;988;0
WireConnection;991;3;309;0
WireConnection;172;0;991;0
WireConnection;150;1;494;0
WireConnection;441;0;459;0
WireConnection;443;0;430;0
WireConnection;1033;1;494;0
WireConnection;1033;0;847;0
WireConnection;873;0;494;0
WireConnection;494;1;896;24
WireConnection;494;0;897;24
WireConnection;498;0;612;0
WireConnection;498;1;628;0
WireConnection;498;2;876;0
WireConnection;615;1;626;0
WireConnection;615;2;877;0
WireConnection;617;1;619;0
WireConnection;617;2;618;0
WireConnection;897;58;617;0
WireConnection;897;45;498;0
WireConnection;897;52;615;0
WireConnection;896;58;620;0
WireConnection;896;45;597;0
WireConnection;896;52;564;0
WireConnection;875;0;494;0
WireConnection;1100;0;1110;0
WireConnection;1099;0;1089;0
WireConnection;1102;0;1089;0
WireConnection;1118;1;1146;0
WireConnection;1118;0;1117;0
WireConnection;898;58;766;0
WireConnection;898;45;765;0
WireConnection;898;52;768;0
WireConnection;1120;1;1147;0
WireConnection;1120;0;1119;0
WireConnection;790;1;1102;0
WireConnection;790;0;1128;1
WireConnection;777;0;790;0
WireConnection;777;1;784;0
WireConnection;1088;0;1180;165
WireConnection;1087;0;1088;0
WireConnection;784;1;1101;0
WireConnection;784;0;1128;2
WireConnection;780;1;1104;0
WireConnection;780;0;1128;3
WireConnection;783;1;1105;0
WireConnection;783;0;1128;4
WireConnection;779;0;780;0
WireConnection;779;1;783;0
WireConnection;1085;0;1087;0
WireConnection;1085;1;779;0
WireConnection;1086;1;779;0
WireConnection;1086;0;1085;0
WireConnection;778;0;777;0
WireConnection;778;1;1086;0
WireConnection;778;2;1180;131
WireConnection;547;1;813;0
WireConnection;547;0;1127;2
WireConnection;813;0;1109;0
WireConnection;548;1;540;0
WireConnection;548;0;1127;1
WireConnection;542;0;548;0
WireConnection;542;1;547;0
WireConnection;546;1;1099;0
WireConnection;546;0;1127;4
WireConnection;545;1;1100;0
WireConnection;545;0;1127;3
WireConnection;544;0;545;0
WireConnection;544;1;546;0
WireConnection;1064;0;1080;0
WireConnection;1064;1;544;0
WireConnection;1077;1;544;0
WireConnection;1077;0;1064;0
WireConnection;1081;0;1181;165
WireConnection;1080;0;1081;0
WireConnection;543;0;542;0
WireConnection;543;1;1077;0
WireConnection;543;2;1181;131
WireConnection;563;0;543;0
WireConnection;773;0;778;0
WireConnection;1140;0;1139;0
WireConnection;1139;0;1182;131
WireConnection;1117;0;1182;165
WireConnection;1117;1;1134;1
WireConnection;1119;0;1134;2
WireConnection;1119;1;1183;165
WireConnection;1141;0;1183;131
WireConnection;1147;0;1134;2
WireConnection;567;1;1179;0
WireConnection;567;0;1155;3
WireConnection;568;1;1169;0
WireConnection;568;0;1155;4
WireConnection;577;0;570;0
WireConnection;577;1;569;0
WireConnection;570;1;1172;0
WireConnection;570;0;1155;1
WireConnection;569;1;1173;0
WireConnection;569;0;1155;2
WireConnection;1171;0;1184;165
WireConnection;1175;0;1185;165
WireConnection;793;0;802;0
WireConnection;793;1;1116;0
WireConnection;793;2;1185;131
WireConnection;810;0;793;0
WireConnection;802;0;796;0
WireConnection;802;1;795;0
WireConnection;1169;0;1159;0
WireConnection;1170;0;1159;0
WireConnection;1115;0;1175;0
WireConnection;1115;1;803;0
WireConnection;1177;0;1150;0
WireConnection;889;0;1178;0
WireConnection;578;0;567;0
WireConnection;578;1;568;0
WireConnection;1113;0;1171;0
WireConnection;1113;1;578;0
WireConnection;1114;1;578;0
WireConnection;1114;0;1113;0
WireConnection;582;0;577;0
WireConnection;582;1;1114;0
WireConnection;582;2;1184;131
WireConnection;596;0;582;0
WireConnection;1179;0;1174;0
WireConnection;1173;0;1167;0
WireConnection;1172;0;1166;0
WireConnection;795;1;1154;0
WireConnection;795;0;1148;2
WireConnection;796;1;1170;0
WireConnection;796;0;1148;1
WireConnection;1116;1;803;0
WireConnection;1116;0;1115;0
WireConnection;803;0;804;0
WireConnection;803;1;805;0
WireConnection;804;1;1177;0
WireConnection;804;0;1148;3
WireConnection;805;1;889;0
WireConnection;805;0;1148;4
WireConnection;1182;99;885;0
WireConnection;1183;99;884;0
WireConnection;1184;99;827;0
WireConnection;1146;0;1134;1
WireConnection;1185;99;826;0
WireConnection;1154;0;1176;0
WireConnection;1150;0;1159;0
WireConnection;1178;0;1159;0
WireConnection;1176;0;1159;0
WireConnection;1174;0;1159;0
WireConnection;1167;0;1159;0
WireConnection;1166;0;1159;0
WireConnection;1083;0;1089;0
WireConnection;1104;0;1083;0
WireConnection;1103;0;1089;0
WireConnection;1105;0;1103;0
WireConnection;1180;99;828;0
WireConnection;1101;0;1106;0
WireConnection;1106;0;1089;0
WireConnection;1110;0;1089;0
WireConnection;1109;0;1089;0
WireConnection;540;0;1108;0
WireConnection;1108;0;1089;0
WireConnection;881;1;1120;0
WireConnection;881;2;1145;0
WireConnection;1145;0;1141;0
WireConnection;760;1;1118;0
WireConnection;760;2;1140;0
WireConnection;605;0;760;0
WireConnection;883;0;881;0
WireConnection;1181;99;825;0
ASEEND*/
//CHKSM=E3A3AA2491B971FC5F9ABE759D97C168E1F7E681