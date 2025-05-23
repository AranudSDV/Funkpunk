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
		[Toggle(_VFXORUI_ON)] _VFXorUI("VFXorUI ?", Float) = 0
		[HDR]_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_1TEX_ON)] _1Tex("1Tex?", Float) = 0
		[Toggle(_3TEX_ON)] _3Tex("3Tex?", Float) = 0
		[Toggle(_2TEX_ON)] _2Tex("2Tex?", Float) = 0
		_BackGroundTex("BackGroundTex", 2D) = "white" {}
		_BackGroundColor("BackGroundColor", Color) = (0,0.06411219,1,0)
		_BackTex("BackTex", 2D) = "white" {}
		_Back("Back", Color) = (0,1,0.7048147,0)
		_Mid("Mid", Color) = (0.6812992,0,1,0)
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
		_R_Fadesmooth("R_Fadesmooth", Float) = 1.25
		_G_FadeSmooth("G_FadeSmooth", Float) = 1
		_NoColorsWhiteValue("NoColorsWhiteValue", Range( 0 , 1)) = 1
		[Toggle(_HANDLECOLORS_ON)] _HandleColors("HandleColors", Float) = 1
		_RotaPower("RotaPower", Float) = 0.05
		[Toggle(_USINGYMOVE_ON)] _UsingYMove("UsingYMove ?", Float) = 1
		[Toggle(_USINGXMOVE_ON)] _UsingXMove("UsingXMove ?", Float) = 1
		_MainTexTiling("MainTexTiling", Vector) = (0,0,0,0)
		[HDR]_SubColor("SubColor", Color) = (2.670157,0,0,0)
		[HDR]_MainColor("MainColor", Color) = (2.670157,1.899221,0,0)
		_Alphacliptresh("Alphacliptresh", Float) = 0.1
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_R_BaseOpacity("R_BaseOpacity", Range( 0 , 1)) = 1
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

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
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
			float4 _Mid;
			float4 _SubColor;
			float4 _MainColor;
			float4 _Front03;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front02;
			float4 _Mid02;
			float4 _Back02;
			float4 _Front;
			float4 _BackGroundColor;
			float4 _Back;
			float2 _MainTexTiling;
			float _NoColorsWhiteValue;
			float _MaxSizeY;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _G_BaseOpacity;
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
			sampler2D _MainTex;
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
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				float4 lerpResult377 = lerp( ( tex2DNode12.g * _SubColor ) , ( _MainColor * tex2DNode12.r ) , tex2DNode12.r);
				float4 VfxColors441 = lerpResult377;
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g188 = 0.0;
				#else
				float staticSwitch21_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g188 = 0.0;
				#else
				float staticSwitch25_g188 = 0.0;
				#endif
				float2 appendResult15_g188 = (float2(staticSwitch21_g188 , staticSwitch25_g188));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g188 = 0.05;
				#else
				float staticSwitch23_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g188 = 0.05;
				#else
				float staticSwitch24_g188 = 0.0;
				#endif
				float2 appendResult16_g188 = (float2(staticSwitch23_g188 , staticSwitch24_g188));
				float mulTime5_g195 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g195 = ( mulTime5_g195 - _TimeDelay );
				float temp_output_289_34 = ( ( cos( ( ( ( temp_output_52_0_g195 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g188 = lerp( appendResult15_g188 , appendResult16_g188 , temp_output_289_34);
				float2 texCoord308 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g198 = cos( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float sin3_g198 = sin( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float2 rotator3_g198 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g198 , -sin3_g198 , sin3_g198 , cos3_g198 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g196 = _MinSizeX;
				#else
				float staticSwitch22_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g196 = _MinSizeY;
				#else
				float staticSwitch23_g196 = 1.0;
				#endif
				float2 appendResult27_g196 = (float2(staticSwitch22_g196 , staticSwitch23_g196));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g196 = _MaxSizeX;
				#else
				float staticSwitch46_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g196 = _MaxSizeY;
				#else
				float staticSwitch45_g196 = 1.0;
				#endif
				float2 appendResult49_g196 = (float2(staticSwitch46_g196 , staticSwitch45_g196));
				float mulTime5_g197 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g197 = ( mulTime5_g197 - _TimeDelay );
				float temp_output_16_0_g197 = ( PI / 1.0 );
				float temp_output_19_0_g197 = cos( ( temp_output_52_0_g197 * temp_output_16_0_g197 ) );
				float saferPower20_g197 = abs( abs( temp_output_19_0_g197 ) );
				float2 lerpResult56_g196 = lerp( appendResult27_g196 , appendResult49_g196 , pow( saferPower20_g197 , 20.0 ));
				float2 temp_output_51_0_g196 = (rotator3_g198*lerpResult56_g196 + ( lerpResult56_g196 + ( ( lerpResult56_g196 * -1.0 ) + ( ( lerpResult56_g196 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g188 = ( lerpResult10_g188 + temp_output_51_0_g196 );
				float2 temp_output_296_0 = temp_output_7_0_g188;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_296_0 );
				float4 Tex_NoColors310 = tex2DNode97;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_296_0 ).a;
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
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_296_0 );
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
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_296_0 );
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
				
				float4 tex2DNode59 = tex2D( _DissolveTex, IN.ase_texcoord3.xy );
				float temp_output_20_0_g223 = tex2DNode59.r;
				float2 break10_g223 = IN.ase_texcoord3.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g223 = break10_g223.x;
				#else
				float staticSwitch8_g223 = break10_g223.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g223 = ( 1.0 - staticSwitch8_g223 );
				#else
				float staticSwitch9_g223 = staticSwitch8_g223;
				#endif
				float temp_output_11_0_g223 = ( staticSwitch9_g223 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g223 = ( temp_output_11_0_g223 * ( ( 1.0 - staticSwitch9_g223 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g223 = temp_output_11_0_g223;
				#endif
				float smoothstepResult3_g223 = smoothstep( temp_output_20_0_g223 , ( temp_output_20_0_g223 * _R_Fadesmooth ) , staticSwitch5_g223);
				float temp_output_20_0_g224 = tex2DNode59.r;
				float2 break10_g224 = IN.ase_texcoord3.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g224 = break10_g224.x;
				#else
				float staticSwitch8_g224 = break10_g224.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g224 = ( 1.0 - staticSwitch8_g224 );
				#else
				float staticSwitch9_g224 = staticSwitch8_g224;
				#endif
				float4 texCoord405 = IN.ase_texcoord5;
				texCoord405.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g224 = ( staticSwitch9_g224 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g224 = ( temp_output_11_0_g224 * ( ( 1.0 - staticSwitch9_g224 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g224 = temp_output_11_0_g224;
				#endif
				float smoothstepResult3_g224 = smoothstep( temp_output_20_0_g224 , ( temp_output_20_0_g224 * _G_FadeSmooth ) , staticSwitch5_g224);
				float VFX_Alpha443 = ( ( ( tex2DNode12.r * smoothstepResult3_g223 ) * _R_BaseOpacity ) + ( ( tex2DNode12.g * smoothstepResult3_g224 ) * _G_BaseOpacity ) );
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
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
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
			float4 _Mid;
			float4 _SubColor;
			float4 _MainColor;
			float4 _Front03;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front02;
			float4 _Mid02;
			float4 _Back02;
			float4 _Front;
			float4 _BackGroundColor;
			float4 _Back;
			float2 _MainTexTiling;
			float _NoColorsWhiteValue;
			float _MaxSizeY;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _G_BaseOpacity;
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
			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
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
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				float4 tex2DNode59 = tex2D( _DissolveTex, IN.ase_texcoord2.xy );
				float temp_output_20_0_g223 = tex2DNode59.r;
				float2 break10_g223 = IN.ase_texcoord2.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g223 = break10_g223.x;
				#else
				float staticSwitch8_g223 = break10_g223.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g223 = ( 1.0 - staticSwitch8_g223 );
				#else
				float staticSwitch9_g223 = staticSwitch8_g223;
				#endif
				float temp_output_11_0_g223 = ( staticSwitch9_g223 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g223 = ( temp_output_11_0_g223 * ( ( 1.0 - staticSwitch9_g223 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g223 = temp_output_11_0_g223;
				#endif
				float smoothstepResult3_g223 = smoothstep( temp_output_20_0_g223 , ( temp_output_20_0_g223 * _R_Fadesmooth ) , staticSwitch5_g223);
				float temp_output_20_0_g224 = tex2DNode59.r;
				float2 break10_g224 = IN.ase_texcoord2.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g224 = break10_g224.x;
				#else
				float staticSwitch8_g224 = break10_g224.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g224 = ( 1.0 - staticSwitch8_g224 );
				#else
				float staticSwitch9_g224 = staticSwitch8_g224;
				#endif
				float4 texCoord405 = IN.ase_texcoord4;
				texCoord405.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g224 = ( staticSwitch9_g224 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g224 = ( temp_output_11_0_g224 * ( ( 1.0 - staticSwitch9_g224 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g224 = temp_output_11_0_g224;
				#endif
				float smoothstepResult3_g224 = smoothstep( temp_output_20_0_g224 , ( temp_output_20_0_g224 * _G_FadeSmooth ) , staticSwitch5_g224);
				float VFX_Alpha443 = ( ( ( tex2DNode12.r * smoothstepResult3_g223 ) * _R_BaseOpacity ) + ( ( tex2DNode12.g * smoothstepResult3_g224 ) * _G_BaseOpacity ) );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g188 = 0.0;
				#else
				float staticSwitch21_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g188 = 0.0;
				#else
				float staticSwitch25_g188 = 0.0;
				#endif
				float2 appendResult15_g188 = (float2(staticSwitch21_g188 , staticSwitch25_g188));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g188 = 0.05;
				#else
				float staticSwitch23_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g188 = 0.05;
				#else
				float staticSwitch24_g188 = 0.0;
				#endif
				float2 appendResult16_g188 = (float2(staticSwitch23_g188 , staticSwitch24_g188));
				float mulTime5_g195 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g195 = ( mulTime5_g195 - _TimeDelay );
				float temp_output_289_34 = ( ( cos( ( ( ( temp_output_52_0_g195 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g188 = lerp( appendResult15_g188 , appendResult16_g188 , temp_output_289_34);
				float2 texCoord308 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g198 = cos( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float sin3_g198 = sin( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float2 rotator3_g198 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g198 , -sin3_g198 , sin3_g198 , cos3_g198 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g196 = _MinSizeX;
				#else
				float staticSwitch22_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g196 = _MinSizeY;
				#else
				float staticSwitch23_g196 = 1.0;
				#endif
				float2 appendResult27_g196 = (float2(staticSwitch22_g196 , staticSwitch23_g196));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g196 = _MaxSizeX;
				#else
				float staticSwitch46_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g196 = _MaxSizeY;
				#else
				float staticSwitch45_g196 = 1.0;
				#endif
				float2 appendResult49_g196 = (float2(staticSwitch46_g196 , staticSwitch45_g196));
				float mulTime5_g197 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g197 = ( mulTime5_g197 - _TimeDelay );
				float temp_output_16_0_g197 = ( PI / 1.0 );
				float temp_output_19_0_g197 = cos( ( temp_output_52_0_g197 * temp_output_16_0_g197 ) );
				float saferPower20_g197 = abs( abs( temp_output_19_0_g197 ) );
				float2 lerpResult56_g196 = lerp( appendResult27_g196 , appendResult49_g196 , pow( saferPower20_g197 , 20.0 ));
				float2 temp_output_51_0_g196 = (rotator3_g198*lerpResult56_g196 + ( lerpResult56_g196 + ( ( lerpResult56_g196 * -1.0 ) + ( ( lerpResult56_g196 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g188 = ( lerpResult10_g188 + temp_output_51_0_g196 );
				float2 temp_output_296_0 = temp_output_7_0_g188;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_296_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_296_0 ).a;
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
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_296_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_296_0 );
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
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
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
			float4 _Mid;
			float4 _SubColor;
			float4 _MainColor;
			float4 _Front03;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front02;
			float4 _Mid02;
			float4 _Back02;
			float4 _Front;
			float4 _BackGroundColor;
			float4 _Back;
			float2 _MainTexTiling;
			float _NoColorsWhiteValue;
			float _MaxSizeY;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _G_BaseOpacity;
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
			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
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
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				float4 tex2DNode59 = tex2D( _DissolveTex, IN.ase_texcoord.xy );
				float temp_output_20_0_g223 = tex2DNode59.r;
				float2 break10_g223 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g223 = break10_g223.x;
				#else
				float staticSwitch8_g223 = break10_g223.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g223 = ( 1.0 - staticSwitch8_g223 );
				#else
				float staticSwitch9_g223 = staticSwitch8_g223;
				#endif
				float temp_output_11_0_g223 = ( staticSwitch9_g223 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g223 = ( temp_output_11_0_g223 * ( ( 1.0 - staticSwitch9_g223 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g223 = temp_output_11_0_g223;
				#endif
				float smoothstepResult3_g223 = smoothstep( temp_output_20_0_g223 , ( temp_output_20_0_g223 * _R_Fadesmooth ) , staticSwitch5_g223);
				float temp_output_20_0_g224 = tex2DNode59.r;
				float2 break10_g224 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g224 = break10_g224.x;
				#else
				float staticSwitch8_g224 = break10_g224.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g224 = ( 1.0 - staticSwitch8_g224 );
				#else
				float staticSwitch9_g224 = staticSwitch8_g224;
				#endif
				float4 texCoord405 = IN.ase_texcoord2;
				texCoord405.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g224 = ( staticSwitch9_g224 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g224 = ( temp_output_11_0_g224 * ( ( 1.0 - staticSwitch9_g224 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g224 = temp_output_11_0_g224;
				#endif
				float smoothstepResult3_g224 = smoothstep( temp_output_20_0_g224 , ( temp_output_20_0_g224 * _G_FadeSmooth ) , staticSwitch5_g224);
				float VFX_Alpha443 = ( ( ( tex2DNode12.r * smoothstepResult3_g223 ) * _R_BaseOpacity ) + ( ( tex2DNode12.g * smoothstepResult3_g224 ) * _G_BaseOpacity ) );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g188 = 0.0;
				#else
				float staticSwitch21_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g188 = 0.0;
				#else
				float staticSwitch25_g188 = 0.0;
				#endif
				float2 appendResult15_g188 = (float2(staticSwitch21_g188 , staticSwitch25_g188));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g188 = 0.05;
				#else
				float staticSwitch23_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g188 = 0.05;
				#else
				float staticSwitch24_g188 = 0.0;
				#endif
				float2 appendResult16_g188 = (float2(staticSwitch23_g188 , staticSwitch24_g188));
				float mulTime5_g195 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g195 = ( mulTime5_g195 - _TimeDelay );
				float temp_output_289_34 = ( ( cos( ( ( ( temp_output_52_0_g195 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g188 = lerp( appendResult15_g188 , appendResult16_g188 , temp_output_289_34);
				float2 texCoord308 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g198 = cos( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float sin3_g198 = sin( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float2 rotator3_g198 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g198 , -sin3_g198 , sin3_g198 , cos3_g198 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g196 = _MinSizeX;
				#else
				float staticSwitch22_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g196 = _MinSizeY;
				#else
				float staticSwitch23_g196 = 1.0;
				#endif
				float2 appendResult27_g196 = (float2(staticSwitch22_g196 , staticSwitch23_g196));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g196 = _MaxSizeX;
				#else
				float staticSwitch46_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g196 = _MaxSizeY;
				#else
				float staticSwitch45_g196 = 1.0;
				#endif
				float2 appendResult49_g196 = (float2(staticSwitch46_g196 , staticSwitch45_g196));
				float mulTime5_g197 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g197 = ( mulTime5_g197 - _TimeDelay );
				float temp_output_16_0_g197 = ( PI / 1.0 );
				float temp_output_19_0_g197 = cos( ( temp_output_52_0_g197 * temp_output_16_0_g197 ) );
				float saferPower20_g197 = abs( abs( temp_output_19_0_g197 ) );
				float2 lerpResult56_g196 = lerp( appendResult27_g196 , appendResult49_g196 , pow( saferPower20_g197 , 20.0 ));
				float2 temp_output_51_0_g196 = (rotator3_g198*lerpResult56_g196 + ( lerpResult56_g196 + ( ( lerpResult56_g196 * -1.0 ) + ( ( lerpResult56_g196 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g188 = ( lerpResult10_g188 + temp_output_51_0_g196 );
				float2 temp_output_296_0 = temp_output_7_0_g188;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_296_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_296_0 ).a;
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
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_296_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_296_0 );
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
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
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
			float4 _Mid;
			float4 _SubColor;
			float4 _MainColor;
			float4 _Front03;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front02;
			float4 _Mid02;
			float4 _Back02;
			float4 _Front;
			float4 _BackGroundColor;
			float4 _Back;
			float2 _MainTexTiling;
			float _NoColorsWhiteValue;
			float _MaxSizeY;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _G_BaseOpacity;
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
			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
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
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				float4 tex2DNode59 = tex2D( _DissolveTex, IN.ase_texcoord.xy );
				float temp_output_20_0_g223 = tex2DNode59.r;
				float2 break10_g223 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g223 = break10_g223.x;
				#else
				float staticSwitch8_g223 = break10_g223.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g223 = ( 1.0 - staticSwitch8_g223 );
				#else
				float staticSwitch9_g223 = staticSwitch8_g223;
				#endif
				float temp_output_11_0_g223 = ( staticSwitch9_g223 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g223 = ( temp_output_11_0_g223 * ( ( 1.0 - staticSwitch9_g223 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g223 = temp_output_11_0_g223;
				#endif
				float smoothstepResult3_g223 = smoothstep( temp_output_20_0_g223 , ( temp_output_20_0_g223 * _R_Fadesmooth ) , staticSwitch5_g223);
				float temp_output_20_0_g224 = tex2DNode59.r;
				float2 break10_g224 = IN.ase_texcoord.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g224 = break10_g224.x;
				#else
				float staticSwitch8_g224 = break10_g224.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g224 = ( 1.0 - staticSwitch8_g224 );
				#else
				float staticSwitch9_g224 = staticSwitch8_g224;
				#endif
				float4 texCoord405 = IN.ase_texcoord2;
				texCoord405.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g224 = ( staticSwitch9_g224 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g224 = ( temp_output_11_0_g224 * ( ( 1.0 - staticSwitch9_g224 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g224 = temp_output_11_0_g224;
				#endif
				float smoothstepResult3_g224 = smoothstep( temp_output_20_0_g224 , ( temp_output_20_0_g224 * _G_FadeSmooth ) , staticSwitch5_g224);
				float VFX_Alpha443 = ( ( ( tex2DNode12.r * smoothstepResult3_g223 ) * _R_BaseOpacity ) + ( ( tex2DNode12.g * smoothstepResult3_g224 ) * _G_BaseOpacity ) );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g188 = 0.0;
				#else
				float staticSwitch21_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g188 = 0.0;
				#else
				float staticSwitch25_g188 = 0.0;
				#endif
				float2 appendResult15_g188 = (float2(staticSwitch21_g188 , staticSwitch25_g188));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g188 = 0.05;
				#else
				float staticSwitch23_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g188 = 0.05;
				#else
				float staticSwitch24_g188 = 0.0;
				#endif
				float2 appendResult16_g188 = (float2(staticSwitch23_g188 , staticSwitch24_g188));
				float mulTime5_g195 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g195 = ( mulTime5_g195 - _TimeDelay );
				float temp_output_289_34 = ( ( cos( ( ( ( temp_output_52_0_g195 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g188 = lerp( appendResult15_g188 , appendResult16_g188 , temp_output_289_34);
				float2 texCoord308 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g198 = cos( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float sin3_g198 = sin( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float2 rotator3_g198 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g198 , -sin3_g198 , sin3_g198 , cos3_g198 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g196 = _MinSizeX;
				#else
				float staticSwitch22_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g196 = _MinSizeY;
				#else
				float staticSwitch23_g196 = 1.0;
				#endif
				float2 appendResult27_g196 = (float2(staticSwitch22_g196 , staticSwitch23_g196));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g196 = _MaxSizeX;
				#else
				float staticSwitch46_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g196 = _MaxSizeY;
				#else
				float staticSwitch45_g196 = 1.0;
				#endif
				float2 appendResult49_g196 = (float2(staticSwitch46_g196 , staticSwitch45_g196));
				float mulTime5_g197 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g197 = ( mulTime5_g197 - _TimeDelay );
				float temp_output_16_0_g197 = ( PI / 1.0 );
				float temp_output_19_0_g197 = cos( ( temp_output_52_0_g197 * temp_output_16_0_g197 ) );
				float saferPower20_g197 = abs( abs( temp_output_19_0_g197 ) );
				float2 lerpResult56_g196 = lerp( appendResult27_g196 , appendResult49_g196 , pow( saferPower20_g197 , 20.0 ));
				float2 temp_output_51_0_g196 = (rotator3_g198*lerpResult56_g196 + ( lerpResult56_g196 + ( ( lerpResult56_g196 * -1.0 ) + ( ( lerpResult56_g196 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g188 = ( lerpResult10_g188 + temp_output_51_0_g196 );
				float2 temp_output_296_0 = temp_output_7_0_g188;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_296_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_296_0 ).a;
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
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_296_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_296_0 );
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
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
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
			float4 _Mid;
			float4 _SubColor;
			float4 _MainColor;
			float4 _Front03;
			float4 _Mid03;
			float4 _Back03;
			float4 _Front02;
			float4 _Mid02;
			float4 _Back02;
			float4 _Front;
			float4 _BackGroundColor;
			float4 _Back;
			float2 _MainTexTiling;
			float _NoColorsWhiteValue;
			float _MaxSizeY;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
			float _RotaPower;
			float _TimeDelay;
			float _R_Fadesmooth;
			float _R_BaseOpacity;
			float _G_FadeSmooth;
			float _G_BaseOpacity;
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
			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
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
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				float4 tex2DNode59 = tex2D( _DissolveTex, IN.ase_texcoord1.xy );
				float temp_output_20_0_g223 = tex2DNode59.r;
				float2 break10_g223 = IN.ase_texcoord1.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g223 = break10_g223.x;
				#else
				float staticSwitch8_g223 = break10_g223.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g223 = ( 1.0 - staticSwitch8_g223 );
				#else
				float staticSwitch9_g223 = staticSwitch8_g223;
				#endif
				float temp_output_11_0_g223 = ( staticSwitch9_g223 - ( 1.0 - texCoord44.z ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g223 = ( temp_output_11_0_g223 * ( ( 1.0 - staticSwitch9_g223 ) - ( 1.0 - texCoord44.w ) ) );
				#else
				float staticSwitch5_g223 = temp_output_11_0_g223;
				#endif
				float smoothstepResult3_g223 = smoothstep( temp_output_20_0_g223 , ( temp_output_20_0_g223 * _R_Fadesmooth ) , staticSwitch5_g223);
				float temp_output_20_0_g224 = tex2DNode59.r;
				float2 break10_g224 = IN.ase_texcoord1.xy;
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch8_g224 = break10_g224.x;
				#else
				float staticSwitch8_g224 = break10_g224.y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch9_g224 = ( 1.0 - staticSwitch8_g224 );
				#else
				float staticSwitch9_g224 = staticSwitch8_g224;
				#endif
				float4 texCoord405 = IN.ase_texcoord3;
				texCoord405.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_11_0_g224 = ( staticSwitch9_g224 - ( 1.0 - texCoord405.x ) );
				#ifdef _2ALPHAS_ON
				float staticSwitch5_g224 = ( temp_output_11_0_g224 * ( ( 1.0 - staticSwitch9_g224 ) - ( 1.0 - texCoord405.y ) ) );
				#else
				float staticSwitch5_g224 = temp_output_11_0_g224;
				#endif
				float smoothstepResult3_g224 = smoothstep( temp_output_20_0_g224 , ( temp_output_20_0_g224 * _G_FadeSmooth ) , staticSwitch5_g224);
				float VFX_Alpha443 = ( ( ( tex2DNode12.r * smoothstepResult3_g223 ) * _R_BaseOpacity ) + ( ( tex2DNode12.g * smoothstepResult3_g224 ) * _G_BaseOpacity ) );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g188 = 0.0;
				#else
				float staticSwitch21_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g188 = 0.0;
				#else
				float staticSwitch25_g188 = 0.0;
				#endif
				float2 appendResult15_g188 = (float2(staticSwitch21_g188 , staticSwitch25_g188));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g188 = 0.05;
				#else
				float staticSwitch23_g188 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g188 = 0.05;
				#else
				float staticSwitch24_g188 = 0.0;
				#endif
				float2 appendResult16_g188 = (float2(staticSwitch23_g188 , staticSwitch24_g188));
				float mulTime5_g195 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g195 = ( mulTime5_g195 - _TimeDelay );
				float temp_output_289_34 = ( ( cos( ( ( ( temp_output_52_0_g195 * 1.5 ) - 0.5 ) * ( 2.0 * PI ) ) ) - 0.5 ) * 4.0 );
				float2 lerpResult10_g188 = lerp( appendResult15_g188 , appendResult16_g188 , temp_output_289_34);
				float2 texCoord308 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3_g198 = cos( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float sin3_g198 = sin( ( ( temp_output_289_34 * _RotaPower ) * PI ) );
				float2 rotator3_g198 = mul( texCoord308 - float2( 0.5,0.5 ) , float2x2( cos3_g198 , -sin3_g198 , sin3_g198 , cos3_g198 )) + float2( 0.5,0.5 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g196 = _MinSizeX;
				#else
				float staticSwitch22_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g196 = _MinSizeY;
				#else
				float staticSwitch23_g196 = 1.0;
				#endif
				float2 appendResult27_g196 = (float2(staticSwitch22_g196 , staticSwitch23_g196));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g196 = _MaxSizeX;
				#else
				float staticSwitch46_g196 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g196 = _MaxSizeY;
				#else
				float staticSwitch45_g196 = 1.0;
				#endif
				float2 appendResult49_g196 = (float2(staticSwitch46_g196 , staticSwitch45_g196));
				float mulTime5_g197 = _TimeParameters.x * ( BPM / 60.0 );
				float temp_output_52_0_g197 = ( mulTime5_g197 - _TimeDelay );
				float temp_output_16_0_g197 = ( PI / 1.0 );
				float temp_output_19_0_g197 = cos( ( temp_output_52_0_g197 * temp_output_16_0_g197 ) );
				float saferPower20_g197 = abs( abs( temp_output_19_0_g197 ) );
				float2 lerpResult56_g196 = lerp( appendResult27_g196 , appendResult49_g196 , pow( saferPower20_g197 , 20.0 ));
				float2 temp_output_51_0_g196 = (rotator3_g198*lerpResult56_g196 + ( lerpResult56_g196 + ( ( lerpResult56_g196 * -1.0 ) + ( ( lerpResult56_g196 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g188 = ( lerpResult10_g188 + temp_output_51_0_g196 );
				float2 temp_output_296_0 = temp_output_7_0_g188;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_296_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_296_0 ).a;
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
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_296_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_296_0 );
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
Node;AmplifyShaderEditor.CommentaryNode;368;-7332.645,1467.613;Inherit;False;6925.187;2770.153;;103;141;150;97;207;208;178;179;161;167;182;247;248;249;210;201;157;212;257;258;151;199;259;254;262;203;260;197;162;205;168;156;140;166;158;142;180;301;296;221;233;231;232;230;229;312;187;220;228;225;227;226;211;224;223;222;314;270;267;272;271;273;266;264;269;268;274;172;185;188;189;190;175;235;236;186;209;315;308;304;289;297;316;317;261;318;253;256;252;319;246;250;320;321;311;322;325;309;310;327;251;313;307;328;RGBMasking;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;141;-5148.225,2236.497;Inherit;False;Property;_Mid;Mid;21;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0.8867924,0.8867924,0.8867924,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;150;-5231.762,2603.631;Inherit;True;Property;_MidTex;MidTex;23;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;9cd71f3e555499d4bb26528953021f9e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-5206.792,1881.039;Inherit;True;Property;_BackTex;BackTex;19;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;b47ae78de3d3b7749a4836d0c15c157a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;207;-5681.454,3392.729;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;208;-5771.367,1819.449;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;178;-5244.49,1517.613;Inherit;True;Property;_BackGroundTex;BackGroundTex;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-4594.091,1561.9;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;161;-5228.241,3388.262;Inherit;True;Property;_FrontTex;FrontTex;27;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;7bc00bfbbf2254540a53064df3cfd095;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;167;-5183.246,3774.674;Inherit;False;Property;_Mid03;Mid03;29;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-3669.496,2292.91;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;247;-4299.25,2219.268;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;248;-3958.584,2397.935;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;249;-4857.015,2480.11;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-3986.356,1865.814;Inherit;False;BackTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-3435.867,2295.674;Inherit;True;BackTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-4237.92,2571.898;Inherit;False;MidTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;257;-3805.964,2726.058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;258;-4913.278,2626.15;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-3787.792,3109.498;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-3604.971,3124.632;Inherit;True;MidTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;259;-4897.709,3366.875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;254;-4103.103,3133.173;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;262;-4153.241,3975.633;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-4348.019,3330.877;Inherit;False;FrontTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;260;-4412.125,3766.164;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-3619.802,3953.839;Inherit;True;FrontTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-3881.269,3984.099;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-4282.047,1571.585;Inherit;False;BackGroundTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;168;-5183.383,3596.018;Inherit;False;Property;_Back03;Back03;28;0;Create;True;0;0;0;False;0;False;1,0.9882626,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;156;-5191.261,2802.163;Inherit;False;Property;_Back02;Back02;24;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0.043478,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;140;-5149.158,2090.376;Inherit;False;Property;_Back;Back;20;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.7924528,0.2554455,0.2504449,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;166;-5187.393,3995.387;Inherit;False;Property;_Front03;Front03;30;0;Create;False;0;0;0;False;0;False;1,0,0.05845451,0;0.1522287,0,0.2327043,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;158;-5152.612,3155.617;Inherit;False;Property;_Front02;Front02;26;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0.3144653,0.3144653,0.3144653,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;142;-5119.63,2414.575;Inherit;False;Property;_Front;Front;22;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0.1984615,0.6886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;180;-5208.722,1710.272;Inherit;False;Property;_BackGroundColor;BackGroundColor;18;0;Create;True;0;0;0;False;0;False;0,0.06411219,1,0;0.4179827,0.1317639,0.5943396,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;301;-6316.492,2816.6;Inherit;False;Constant;_Vector0;Vector 0;36;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;296;-6093.262,2424.166;Inherit;False;SHF_BeatMoving;48;;188;65813206edc57a749b6de4c0a25b7872;0;3;93;FLOAT;0;False;94;FLOAT;0;False;63;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-2174.527,2330.615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-1741.194,2507.493;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1712.03,2574.087;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1710.249,2641.496;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-1708.694,2709.791;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-1477.625,2569.72;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;312;-1820.685,2461.9;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;187;-1755.322,2293.114;Inherit;False;Property;_1Tex;1Tex?;14;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
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
Node;AmplifyShaderEditor.StaticSwitch;185;-992.6428,2201.818;Inherit;False;Property;_3Tex;3Tex?;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;188;-1493.916,2005.784;Inherit;False;Property;_2Tex1;2Tex?;16;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;186;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;189;-872.8444,1996.24;Inherit;False;Property;_3Tex1;3Tex?;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;185;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;190;-2263.069,2004.386;Inherit;False;Property;_1Tex1;1Tex?;14;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;187;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;235;-1772.631,2115.012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;236;-1258.552,2151.301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;186;-1208.926,2201.138;Inherit;False;Property;_2Tex;2Tex?;16;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;209;-5310.16,2359.938;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;315;-5321.854,2489.923;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;308;-6885.397,2541.601;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-7033.971,2649.331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;289;-7282.645,2415.583;Inherit;False;SHF_Beat;10;;195;98b937ed0bb6230429680ab88ee4981b;0;1;54;FLOAT;0;False;3;FLOAT;33;FLOAT;34;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;297;-6328.552,2593.156;Inherit;False;SHF_BeatScaling;31;;196;1f1f15f84ef3aaf4b94f2810f37733f5;0;2;79;FLOAT2;0,0;False;72;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;316;-4912.938,4075.687;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;317;-4894.666,3874.699;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;261;-4700.079,3581.573;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;318;-4865.263,3209.402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;253;-4380.396,2952.892;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;256;-4884.372,3048.588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;252;-4688.66,2782.166;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;319;-4905.739,2916.986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;246;-4639.974,2075.991;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;250;-4866.813,2299.456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;320;-4877.803,2194.972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;321;-4915.53,3686.815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-2250.55,1619.594;Inherit;False;310;Tex_NoColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-1838.517,1739.674;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-2180.248,1811.544;Inherit;False;Property;_NoColorsWhiteValue;NoColorsWhiteValue;45;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;309;-1553.196,2201.741;Inherit;False;Property;_HandleColors;HandleColors;46;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-4807.471,1724.974;Inherit;False;Tex_NoColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;327;-4806.053,1803.559;Inherit;False;Tex_NoColors_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;251;-4851.004,1891.513;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;313;-2768.105,2127.939;Inherit;False;Property;_HandleColors1;HandleColors;46;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;309;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;307;-6629.116,2595.187;Inherit;True;SHF_BeatRotza;0;;198;7604ce8e2d38f1141bf05ecac26f9e0c;0;3;13;FLOAT2;0.5,0.5;False;12;FLOAT2;0,0;False;11;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-7252.029,2716.699;Inherit;False;Property;_RotaPower;RotaPower;47;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;-5242.343,2974.594;Inherit;False;Property;_Mid02;Mid02;25;0;Create;True;0;0;0;False;0;False;0,1,0.9647675,0;0.3710691,0.3167328,0.311558,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-97.01104,-568.7534;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;399;-1652.833,-87.65472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.StaticSwitch;108;1401.131,-808.3735;Inherit;False;Property;_VFXorUI1;VFXorUI ?;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;107;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;-441.5178,-336.364;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-811.3342,-494.0239;Inherit;False;Property;_R_BaseOpacity;R_BaseOpacity;73;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-424.7047,-650.7112;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;430;-122.5134,-646.2131;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;93;-2407.321,-504.5164;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;1429.615,-699.0623;Inherit;False;Property;_Alphacliptresh;Alphacliptresh;71;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-2204.629,-520.3921;Inherit;True;Property;_DissolveTex;DissolveTex;72;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;405;-1887.952,-383.8567;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-1517.563,-910.1761;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;413;-816.7144,-99.10143;Inherit;False;Property;_G_BaseOpacity;G_BaseOpacity;74;0;Create;True;0;0;0;False;0;False;0.5109974;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-1111.233,-395.5566;Inherit;False;Property;_G_FadeSmooth;G_FadeSmooth;44;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-1293.253,-928.1375;Inherit;True;Property;_MainTex;MainTex;13;1;[HDR];Create;True;0;0;0;False;0;False;-1;b64acacdeb0e2454fa5f915d8f4cc0d4;d3cfaa263ab42814993310ce350e9955;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;400;-958.4464,-1743.501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;373;-1221.988,-1673.958;Inherit;False;Property;_SubColor;SubColor;69;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,0,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-569.2421,-1720.677;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;401;-930.165,-1540.501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-567.4312,-1931.695;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-1223.611,-1930.279;Inherit;False;Property;_MainColor;MainColor;70;1;[HDR];Create;True;0;0;0;False;0;False;2.670157,1.899221,0,0;766.9962,766.9962,766.9962,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;377;-163.2606,-1745.849;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;107;1520.725,-969.8881;Inherit;False;Property;_VFXorUI;VFXorUI ?;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;441;255.9732,-1734.082;Inherit;False;VfxColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1766.109,-846.5352;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;SHR_2DMaster;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638836061583144832;  Blend;0;638757509385679611;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638750638155477510;  Use Shadow Threshold;0;0;Receive Shadows;0;638750638186889437;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;1,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;0;638750638251761571;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;443;172.9299,-551.9199;Inherit;False;VFX_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;1197.735,-743.0334;Inherit;False;175;UI_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-649.4576,1990.898;Inherit;True;UI_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;1188.15,-817.7303;Inherit;False;443;VFX_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-801.0934,2196.336;Inherit;True;UI_Colors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;442;1341.235,-990.6847;Inherit;False;441;VfxColors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;1342.397,-912.8566;Inherit;False;172;UI_Colors;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;436;-1350.541,-402.2899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;-1349.245,-325.2072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-1229.665,-1033.496;Inherit;False;Property;_R_Fadesmooth;R_Fadesmooth;43;0;Create;True;0;0;0;False;0;False;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2397.986,-857.5511;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;14;-1731.881,-983.8733;Inherit;False;Property;_MainTexTiling;MainTexTiling;68;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;54;-1707.822,-849.5704;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;425;-2033.182,-744.7808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;446;-2021.493,-670.6008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;440;-1372.099,-566.0184;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;447;-890.0452,-788.4253;Inherit;False;SHF_VFX_Fades;3;;223;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;448;-809.3016,-339.1222;Inherit;False;SHF_VFX_Fades;3;;224;257959e4c62260d4288cb487d2292aab;0;6;29;FLOAT;0;False;1;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT2;0,0;False;1;FLOAT;0
WireConnection;150;1;315;0
WireConnection;97;1;209;0
WireConnection;207;0;296;0
WireConnection;208;0;296;0
WireConnection;178;1;208;0
WireConnection;179;0;211;0
WireConnection;179;1;180;0
WireConnection;161;1;207;0
WireConnection;182;0;210;0
WireConnection;182;1;248;0
WireConnection;247;0;246;0
WireConnection;247;1;141;0
WireConnection;247;2;250;0
WireConnection;248;0;247;0
WireConnection;248;1;142;0
WireConnection;248;2;249;0
WireConnection;249;0;97;3
WireConnection;210;0;251;0
WireConnection;201;0;182;0
WireConnection;212;0;258;0
WireConnection;257;0;212;0
WireConnection;258;0;150;4
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
WireConnection;205;0;179;0
WireConnection;296;94;289;34
WireConnection;296;63;297;0
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
WireConnection;188;1;190;0
WireConnection;188;0;235;0
WireConnection;189;1;188;0
WireConnection;189;0;236;0
WireConnection;190;0;224;0
WireConnection;235;0;225;0
WireConnection;236;0;229;0
WireConnection;186;1;309;0
WireConnection;186;0;220;0
WireConnection;209;0;296;0
WireConnection;315;0;296;0
WireConnection;304;0;289;34
WireConnection;304;1;328;0
WireConnection;297;79;307;0
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
WireConnection;246;1;140;0
WireConnection;246;2;320;0
WireConnection;250;0;97;2
WireConnection;320;0;97;1
WireConnection;321;0;161;1
WireConnection;322;0;311;0
WireConnection;322;1;325;0
WireConnection;309;1;322;0
WireConnection;309;0;187;0
WireConnection;310;0;97;0
WireConnection;327;0;97;4
WireConnection;251;0;97;4
WireConnection;313;1;314;0
WireConnection;313;0;222;0
WireConnection;307;12;308;0
WireConnection;307;11;304;0
WireConnection;108;1;444;0
WireConnection;108;0;176;0
WireConnection;412;0;448;0
WireConnection;412;1;413;0
WireConnection;94;0;447;0
WireConnection;94;1;95;0
WireConnection;430;0;94;0
WireConnection;430;1;412;0
WireConnection;59;1;93;0
WireConnection;53;0;14;0
WireConnection;53;1;54;0
WireConnection;12;1;53;0
WireConnection;400;0;12;1
WireConnection;371;0;401;0
WireConnection;371;1;373;0
WireConnection;401;0;12;2
WireConnection;33;0;32;0
WireConnection;33;1;400;0
WireConnection;377;0;371;0
WireConnection;377;1;33;0
WireConnection;377;2;12;1
WireConnection;107;1;442;0
WireConnection;107;0;173;0
WireConnection;441;0;377;0
WireConnection;1;2;107;0
WireConnection;1;3;108;0
WireConnection;1;4;38;0
WireConnection;443;0;430;0
WireConnection;175;0;189;0
WireConnection;172;0;185;0
WireConnection;436;0;405;1
WireConnection;445;0;405;2
WireConnection;54;0;44;1
WireConnection;54;1;44;2
WireConnection;425;0;44;3
WireConnection;446;0;44;4
WireConnection;447;29;434;0
WireConnection;447;1;425;0
WireConnection;447;19;446;0
WireConnection;447;20;59;1
WireConnection;447;21;12;1
WireConnection;447;22;440;0
WireConnection;448;29;435;0
WireConnection;448;1;436;0
WireConnection;448;19;445;0
WireConnection;448;20;59;1
WireConnection;448;21;12;2
WireConnection;448;22;440;0
ASEEND*/
//CHKSM=F0E19F6FCD5F4CBEDA3ADFEA9B31874FD227568C