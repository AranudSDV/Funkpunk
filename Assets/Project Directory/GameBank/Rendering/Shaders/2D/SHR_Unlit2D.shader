// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_VFX_UnlitMaster"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR]_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_1TEX_ON)] _1Tex("1Tex?", Float) = 0
		[Toggle(_3TEX_ON)] _3Tex("3Tex?", Float) = 0
		[Toggle(_2TEX_ON)] _2Tex("2Tex?", Float) = 0
		_BackGroundTex("BackGroundTex", 2D) = "white" {}
		_BackTex("BackTex", 2D) = "white" {}
		_MidTex("MidTex", 2D) = "white" {}
		_FrontTex("FrontTex", 2D) = "white" {}
		_Back("Back", Color) = (1,0,0,0)
		_Back02("Back02", Color) = (0,1,0.7048147,0)
		_Back03("Back03", Color) = (1,0,0.05845451,0)
		_Mid("Mid", Color) = (0.6812992,0,1,0)
		_Mid02("Mid02", Color) = (0,1,0.9647675,0)
		_Mid03("Mid03", Color) = (0.6812992,0,1,0)
		_Front("Front", Color) = (0,1,0.7048147,0)
		_Front02("Front02", Color) = (1,0,0,0)
		_Front03("Front03", Color) = (1,0.9882626,0,0)
		[Toggle(_VFXORUI_ON)] _VFXorUI("VFXorUI ?", Float) = 1
		[Toggle(_USINGXSCALE_ON)] _UsingXScale("UsingXScale?", Float) = 1
		[Toggle(_USINGXSCALE1_ON)] _UsingXScale1("UsingXScale?", Float) = 1
		[Toggle(_USINGYSCALE_ON)] _UsingYScale("UsingYScale?", Float) = 1
		[Toggle(_USINGYSCALE1_ON)] _UsingYScale1("UsingYScale?", Float) = 1
		_MinSizeY("MinSizeY", Float) = 2
		_MinSizeY1("MinSizeY", Float) = 1.1
		_MinSizeX("MinSizeX", Float) = 2
		_MaxSizeX("MaxSizeX", Float) = 1.1
		_BPM("BPM", Float) = 60
		[Toggle(_USINGYMOVE_ON)] _UsingYMove("UsingYMove ?", Float) = 1
		[Toggle(_USINGXMOVE_ON)] _UsingXMove("UsingXMove ?", Float) = 1
		_MainTexTiling("MainTexTiling", Vector) = (0,0,0,0)
		[HDR]_MainColor("MainColor", Color) = (2,2,2,0)
		_Alphacliptresh("Alphacliptresh", Float) = 0
		_DissolveTex("DissolveTex", 2D) = "white" {}
		[Toggle(_ISVERTICALORLATERAL_ON)] _IsVerticalOrLateral("IsVerticalOrLateral", Float) = 0
		[Toggle(_UPLORDOWNR_ON)] _UpLorDownR("UpLorDownR", Float) = 0
		[Toggle(_2ALPHAS_ON)] _2Alphas("2Alphas?", Float) = 0
		_BaseOpacity("BaseOpacity", Range( 0 , 1)) = 1


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
			#pragma shader_feature_local _1TEX_ON
			#pragma shader_feature_local _USINGXMOVE_ON
			#pragma shader_feature_local _USINGYMOVE_ON
			#pragma multi_compile_instancing
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON
			#pragma shader_feature _2ALPHAS_ON
			#pragma shader_feature_local _UPLORDOWNR_ON
			#pragma shader_feature_local _ISVERTICALORLATERAL_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back;
			float4 _Front;
			float4 _Mid;
			float2 _MainTexTiling;
			float _BaseOpacity;
			float _MinSizeY1;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
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

			sampler2D _MainTex;
			sampler2D _BackGroundTex;
			sampler2D _BackTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			sampler2D _DissolveTex;
			UNITY_INSTANCING_BUFFER_START(SHR_VFX_UnlitMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_VFX_UnlitMaster)


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				
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
				float4 appendResult54 = (float4(texCoord44.x , texCoord44.y , 0.0 , 0.0));
				float2 texCoord53 = IN.ase_texcoord3.xy * _MainTexTiling + appendResult54.xy;
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g110 = -0.5;
				#else
				float staticSwitch21_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g110 = 0.0;
				#else
				float staticSwitch25_g110 = 0.0;
				#endif
				float2 appendResult15_g110 = (float2(staticSwitch21_g110 , staticSwitch25_g110));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g110 = 0.5;
				#else
				float staticSwitch23_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g110 = 0.0;
				#else
				float staticSwitch24_g110 = 0.0;
				#endif
				float2 appendResult16_g110 = (float2(staticSwitch23_g110 , staticSwitch24_g110));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_VFX_UnlitMaster,_BPM);
				float mulTime5_g111 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g111 = ( PI / 1.0 );
				float temp_output_18_0_g111 = ( mulTime5_g111 * temp_output_16_0_g111 );
				float saferPower20_g111 = abs( abs( cos( temp_output_18_0_g111 ) ) );
				float clampResult31_g111 = clamp( pow( saferPower20_g111 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult10_g110 = lerp( appendResult15_g110 , appendResult16_g110 , (0.0 + (( ( clampResult31_g111 - 0.5 ) * 2.0 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
				float2 texCoord52_g112 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g112 = _MinSizeX;
				#else
				float staticSwitch22_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g112 = _MinSizeY;
				#else
				float staticSwitch23_g112 = 1.0;
				#endif
				float2 appendResult27_g112 = (float2(staticSwitch22_g112 , staticSwitch23_g112));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g112 = _MaxSizeX;
				#else
				float staticSwitch46_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g112 = _MinSizeY1;
				#else
				float staticSwitch45_g112 = 1.0;
				#endif
				float2 appendResult49_g112 = (float2(staticSwitch46_g112 , staticSwitch45_g112));
				float mulTime5_g113 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g113 = ( PI / 1.0 );
				float temp_output_18_0_g113 = ( mulTime5_g113 * temp_output_16_0_g113 );
				float saferPower20_g113 = abs( abs( cos( temp_output_18_0_g113 ) ) );
				float clampResult31_g113 = clamp( pow( saferPower20_g113 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult56_g112 = lerp( appendResult27_g112 , appendResult49_g112 , clampResult31_g113);
				float2 temp_output_51_0_g112 = (texCoord52_g112*lerpResult56_g112 + ( lerpResult56_g112 + ( ( lerpResult56_g112 * -1.0 ) + ( ( lerpResult56_g112 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g110 = ( lerpResult10_g110 + temp_output_51_0_g112 );
				float2 temp_output_152_0 = temp_output_7_0_g110;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_152_0 ).a;
				float4 color180 = IsGammaSpace() ? float4(0,0.06411219,1,0) : float4(0,0.005327077,1,0);
				float4 BackGroundTexColor205 = ( BackGroundTexAlpha211 * color180 );
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_152_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float4 lerpResult246 = lerp( float4( 0,0,0,0 ) , _Front , tex2DNode97.r);
				float4 lerpResult247 = lerp( lerpResult246 , _Mid , tex2DNode97.g);
				float4 lerpResult248 = lerp( lerpResult247 , _Back , tex2DNode97.b);
				float4 BackTexColor201 = ( BackTexAlpha210 * lerpResult248 );
				float4 lerpResult264 = lerp( BackGroundTexColor205 , BackTexColor201 , BackTexAlpha210);
				float temp_output_224_0 = ( BackTexAlpha210 + BackGroundTexAlpha211 );
				#ifdef _1TEX_ON
				float4 staticSwitch187 = ( lerpResult264 * temp_output_224_0 );
				#else
				float4 staticSwitch187 = float4( 0,0,0,0 );
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_152_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float4 lerpResult252 = lerp( float4( 0,0,0,0 ) , _Front02 , tex2DNode150.b);
				float4 lerpResult253 = lerp( lerpResult252 , _Mid02 , tex2DNode150.g);
				float4 lerpResult254 = lerp( lerpResult253 , _Back02 , tex2DNode150.r);
				float4 MidTexColor199 = ( MidTexAlpha212 * lerpResult254 );
				float4 lerpResult270 = lerp( lerpResult264 , MidTexColor199 , MidTexAlpha212);
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float4 staticSwitch186 = ( lerpResult270 * temp_output_225_0 );
				#else
				float4 staticSwitch186 = staticSwitch187;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_152_0 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float4 lerpResult261 = lerp( float4( 0,0,0,0 ) , _Front03 , tex2DNode161.b);
				float4 lerpResult260 = lerp( lerpResult261 , _Mid03 , tex2DNode161.g);
				float4 lerpResult262 = lerp( lerpResult260 , _Back03 , tex2DNode161.r);
				float4 FrontTexColor197 = ( FrontTexAlpha203 * lerpResult262 );
				float4 lerpResult271 = lerp( lerpResult270 , FrontTexColor197 , FrontTexAlpha203);
				float temp_output_229_0 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#ifdef _3TEX_ON
				float4 staticSwitch185 = ( lerpResult271 * temp_output_229_0 );
				#else
				float4 staticSwitch185 = staticSwitch186;
				#endif
				float4 UITexture172 = staticSwitch185;
				#ifdef _VFXORUI_ON
				float4 staticSwitch107 = UITexture172;
				#else
				float4 staticSwitch107 = ( _MainColor * tex2DNode12.r );
				#endif
				
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch61 = (IN.ase_texcoord3.xy).x;
				#else
				float staticSwitch61 = (IN.ase_texcoord3.xy).y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch63 = ( 1.0 - staticSwitch61 );
				#else
				float staticSwitch63 = staticSwitch61;
				#endif
				float temp_output_30_0 = ( pow( staticSwitch63 , 0.3 ) - texCoord44.z );
				#ifdef _2ALPHAS_ON
				float staticSwitch80 = ( temp_output_30_0 * ( pow( ( 1.0 - staticSwitch63 ) , 0.3 ) - texCoord44.w ) );
				#else
				float staticSwitch80 = temp_output_30_0;
				#endif
				float smoothstepResult60 = smoothstep( 0.02 , tex2D( _DissolveTex, IN.ase_texcoord3.xy ).r , staticSwitch80);
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
				float staticSwitch189 = temp_output_229_0;
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float AlphaUITex175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = AlphaUITex175;
				#else
				float staticSwitch108 = ( ( tex2DNode12.a * smoothstepResult60 ) * _BaseOpacity );
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
			#pragma multi_compile_instancing
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back;
			float4 _Front;
			float4 _Mid;
			float2 _MainTexTiling;
			float _BaseOpacity;
			float _MinSizeY1;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
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

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			UNITY_INSTANCING_BUFFER_START(SHR_VFX_UnlitMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_VFX_UnlitMaster)


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
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
				float4 appendResult54 = (float4(texCoord44.x , texCoord44.y , 0.0 , 0.0));
				float2 texCoord53 = IN.ase_texcoord2.xy * _MainTexTiling + appendResult54.xy;
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch61 = (IN.ase_texcoord2.xy).x;
				#else
				float staticSwitch61 = (IN.ase_texcoord2.xy).y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch63 = ( 1.0 - staticSwitch61 );
				#else
				float staticSwitch63 = staticSwitch61;
				#endif
				float temp_output_30_0 = ( pow( staticSwitch63 , 0.3 ) - texCoord44.z );
				#ifdef _2ALPHAS_ON
				float staticSwitch80 = ( temp_output_30_0 * ( pow( ( 1.0 - staticSwitch63 ) , 0.3 ) - texCoord44.w ) );
				#else
				float staticSwitch80 = temp_output_30_0;
				#endif
				float smoothstepResult60 = smoothstep( 0.02 , tex2D( _DissolveTex, IN.ase_texcoord2.xy ).r , staticSwitch80);
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g110 = -0.5;
				#else
				float staticSwitch21_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g110 = 0.0;
				#else
				float staticSwitch25_g110 = 0.0;
				#endif
				float2 appendResult15_g110 = (float2(staticSwitch21_g110 , staticSwitch25_g110));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g110 = 0.5;
				#else
				float staticSwitch23_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g110 = 0.0;
				#else
				float staticSwitch24_g110 = 0.0;
				#endif
				float2 appendResult16_g110 = (float2(staticSwitch23_g110 , staticSwitch24_g110));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_VFX_UnlitMaster,_BPM);
				float mulTime5_g111 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g111 = ( PI / 1.0 );
				float temp_output_18_0_g111 = ( mulTime5_g111 * temp_output_16_0_g111 );
				float saferPower20_g111 = abs( abs( cos( temp_output_18_0_g111 ) ) );
				float clampResult31_g111 = clamp( pow( saferPower20_g111 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult10_g110 = lerp( appendResult15_g110 , appendResult16_g110 , (0.0 + (( ( clampResult31_g111 - 0.5 ) * 2.0 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
				float2 texCoord52_g112 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g112 = _MinSizeX;
				#else
				float staticSwitch22_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g112 = _MinSizeY;
				#else
				float staticSwitch23_g112 = 1.0;
				#endif
				float2 appendResult27_g112 = (float2(staticSwitch22_g112 , staticSwitch23_g112));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g112 = _MaxSizeX;
				#else
				float staticSwitch46_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g112 = _MinSizeY1;
				#else
				float staticSwitch45_g112 = 1.0;
				#endif
				float2 appendResult49_g112 = (float2(staticSwitch46_g112 , staticSwitch45_g112));
				float mulTime5_g113 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g113 = ( PI / 1.0 );
				float temp_output_18_0_g113 = ( mulTime5_g113 * temp_output_16_0_g113 );
				float saferPower20_g113 = abs( abs( cos( temp_output_18_0_g113 ) ) );
				float clampResult31_g113 = clamp( pow( saferPower20_g113 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult56_g112 = lerp( appendResult27_g112 , appendResult49_g112 , clampResult31_g113);
				float2 temp_output_51_0_g112 = (texCoord52_g112*lerpResult56_g112 + ( lerpResult56_g112 + ( ( lerpResult56_g112 * -1.0 ) + ( ( lerpResult56_g112 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g110 = ( lerpResult10_g110 + temp_output_51_0_g112 );
				float2 temp_output_152_0 = temp_output_7_0_g110;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_152_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_152_0 ).a;
				float temp_output_224_0 = ( BackTexAlpha210 + BackGroundTexAlpha211 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_152_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_152_0 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_229_0 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#ifdef _3TEX_ON
				float staticSwitch189 = temp_output_229_0;
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float AlphaUITex175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = AlphaUITex175;
				#else
				float staticSwitch108 = ( ( tex2DNode12.a * smoothstepResult60 ) * _BaseOpacity );
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
			#pragma multi_compile_instancing
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back;
			float4 _Front;
			float4 _Mid;
			float2 _MainTexTiling;
			float _BaseOpacity;
			float _MinSizeY1;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
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

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			UNITY_INSTANCING_BUFFER_START(SHR_VFX_UnlitMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_VFX_UnlitMaster)


			
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
				float4 appendResult54 = (float4(texCoord44.x , texCoord44.y , 0.0 , 0.0));
				float2 texCoord53 = IN.ase_texcoord.xy * _MainTexTiling + appendResult54.xy;
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch61 = (IN.ase_texcoord.xy).x;
				#else
				float staticSwitch61 = (IN.ase_texcoord.xy).y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch63 = ( 1.0 - staticSwitch61 );
				#else
				float staticSwitch63 = staticSwitch61;
				#endif
				float temp_output_30_0 = ( pow( staticSwitch63 , 0.3 ) - texCoord44.z );
				#ifdef _2ALPHAS_ON
				float staticSwitch80 = ( temp_output_30_0 * ( pow( ( 1.0 - staticSwitch63 ) , 0.3 ) - texCoord44.w ) );
				#else
				float staticSwitch80 = temp_output_30_0;
				#endif
				float smoothstepResult60 = smoothstep( 0.02 , tex2D( _DissolveTex, IN.ase_texcoord.xy ).r , staticSwitch80);
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g110 = -0.5;
				#else
				float staticSwitch21_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g110 = 0.0;
				#else
				float staticSwitch25_g110 = 0.0;
				#endif
				float2 appendResult15_g110 = (float2(staticSwitch21_g110 , staticSwitch25_g110));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g110 = 0.5;
				#else
				float staticSwitch23_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g110 = 0.0;
				#else
				float staticSwitch24_g110 = 0.0;
				#endif
				float2 appendResult16_g110 = (float2(staticSwitch23_g110 , staticSwitch24_g110));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_VFX_UnlitMaster,_BPM);
				float mulTime5_g111 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g111 = ( PI / 1.0 );
				float temp_output_18_0_g111 = ( mulTime5_g111 * temp_output_16_0_g111 );
				float saferPower20_g111 = abs( abs( cos( temp_output_18_0_g111 ) ) );
				float clampResult31_g111 = clamp( pow( saferPower20_g111 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult10_g110 = lerp( appendResult15_g110 , appendResult16_g110 , (0.0 + (( ( clampResult31_g111 - 0.5 ) * 2.0 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
				float2 texCoord52_g112 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g112 = _MinSizeX;
				#else
				float staticSwitch22_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g112 = _MinSizeY;
				#else
				float staticSwitch23_g112 = 1.0;
				#endif
				float2 appendResult27_g112 = (float2(staticSwitch22_g112 , staticSwitch23_g112));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g112 = _MaxSizeX;
				#else
				float staticSwitch46_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g112 = _MinSizeY1;
				#else
				float staticSwitch45_g112 = 1.0;
				#endif
				float2 appendResult49_g112 = (float2(staticSwitch46_g112 , staticSwitch45_g112));
				float mulTime5_g113 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g113 = ( PI / 1.0 );
				float temp_output_18_0_g113 = ( mulTime5_g113 * temp_output_16_0_g113 );
				float saferPower20_g113 = abs( abs( cos( temp_output_18_0_g113 ) ) );
				float clampResult31_g113 = clamp( pow( saferPower20_g113 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult56_g112 = lerp( appendResult27_g112 , appendResult49_g112 , clampResult31_g113);
				float2 temp_output_51_0_g112 = (texCoord52_g112*lerpResult56_g112 + ( lerpResult56_g112 + ( ( lerpResult56_g112 * -1.0 ) + ( ( lerpResult56_g112 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g110 = ( lerpResult10_g110 + temp_output_51_0_g112 );
				float2 temp_output_152_0 = temp_output_7_0_g110;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_152_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_152_0 ).a;
				float temp_output_224_0 = ( BackTexAlpha210 + BackGroundTexAlpha211 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_152_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_152_0 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_229_0 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#ifdef _3TEX_ON
				float staticSwitch189 = temp_output_229_0;
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float AlphaUITex175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = AlphaUITex175;
				#else
				float staticSwitch108 = ( ( tex2DNode12.a * smoothstepResult60 ) * _BaseOpacity );
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
			#pragma multi_compile_instancing
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back;
			float4 _Front;
			float4 _Mid;
			float2 _MainTexTiling;
			float _BaseOpacity;
			float _MinSizeY1;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
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

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			UNITY_INSTANCING_BUFFER_START(SHR_VFX_UnlitMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_VFX_UnlitMaster)


			
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
				float4 appendResult54 = (float4(texCoord44.x , texCoord44.y , 0.0 , 0.0));
				float2 texCoord53 = IN.ase_texcoord.xy * _MainTexTiling + appendResult54.xy;
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch61 = (IN.ase_texcoord.xy).x;
				#else
				float staticSwitch61 = (IN.ase_texcoord.xy).y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch63 = ( 1.0 - staticSwitch61 );
				#else
				float staticSwitch63 = staticSwitch61;
				#endif
				float temp_output_30_0 = ( pow( staticSwitch63 , 0.3 ) - texCoord44.z );
				#ifdef _2ALPHAS_ON
				float staticSwitch80 = ( temp_output_30_0 * ( pow( ( 1.0 - staticSwitch63 ) , 0.3 ) - texCoord44.w ) );
				#else
				float staticSwitch80 = temp_output_30_0;
				#endif
				float smoothstepResult60 = smoothstep( 0.02 , tex2D( _DissolveTex, IN.ase_texcoord.xy ).r , staticSwitch80);
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g110 = -0.5;
				#else
				float staticSwitch21_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g110 = 0.0;
				#else
				float staticSwitch25_g110 = 0.0;
				#endif
				float2 appendResult15_g110 = (float2(staticSwitch21_g110 , staticSwitch25_g110));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g110 = 0.5;
				#else
				float staticSwitch23_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g110 = 0.0;
				#else
				float staticSwitch24_g110 = 0.0;
				#endif
				float2 appendResult16_g110 = (float2(staticSwitch23_g110 , staticSwitch24_g110));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_VFX_UnlitMaster,_BPM);
				float mulTime5_g111 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g111 = ( PI / 1.0 );
				float temp_output_18_0_g111 = ( mulTime5_g111 * temp_output_16_0_g111 );
				float saferPower20_g111 = abs( abs( cos( temp_output_18_0_g111 ) ) );
				float clampResult31_g111 = clamp( pow( saferPower20_g111 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult10_g110 = lerp( appendResult15_g110 , appendResult16_g110 , (0.0 + (( ( clampResult31_g111 - 0.5 ) * 2.0 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
				float2 texCoord52_g112 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g112 = _MinSizeX;
				#else
				float staticSwitch22_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g112 = _MinSizeY;
				#else
				float staticSwitch23_g112 = 1.0;
				#endif
				float2 appendResult27_g112 = (float2(staticSwitch22_g112 , staticSwitch23_g112));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g112 = _MaxSizeX;
				#else
				float staticSwitch46_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g112 = _MinSizeY1;
				#else
				float staticSwitch45_g112 = 1.0;
				#endif
				float2 appendResult49_g112 = (float2(staticSwitch46_g112 , staticSwitch45_g112));
				float mulTime5_g113 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g113 = ( PI / 1.0 );
				float temp_output_18_0_g113 = ( mulTime5_g113 * temp_output_16_0_g113 );
				float saferPower20_g113 = abs( abs( cos( temp_output_18_0_g113 ) ) );
				float clampResult31_g113 = clamp( pow( saferPower20_g113 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult56_g112 = lerp( appendResult27_g112 , appendResult49_g112 , clampResult31_g113);
				float2 temp_output_51_0_g112 = (texCoord52_g112*lerpResult56_g112 + ( lerpResult56_g112 + ( ( lerpResult56_g112 * -1.0 ) + ( ( lerpResult56_g112 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g110 = ( lerpResult10_g110 + temp_output_51_0_g112 );
				float2 temp_output_152_0 = temp_output_7_0_g110;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_152_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_152_0 ).a;
				float temp_output_224_0 = ( BackTexAlpha210 + BackGroundTexAlpha211 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_152_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_152_0 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_229_0 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#ifdef _3TEX_ON
				float staticSwitch189 = temp_output_229_0;
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float AlphaUITex175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = AlphaUITex175;
				#else
				float staticSwitch108 = ( ( tex2DNode12.a * smoothstepResult60 ) * _BaseOpacity );
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
			#pragma multi_compile_instancing
			#pragma shader_feature_local _USINGXSCALE_ON
			#pragma shader_feature_local _USINGYSCALE_ON
			#pragma shader_feature_local _USINGXSCALE1_ON
			#pragma shader_feature_local _USINGYSCALE1_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _Back03;
			float4 _Mid03;
			float4 _Front03;
			float4 _Back02;
			float4 _Mid02;
			float4 _Front02;
			float4 _Back;
			float4 _Front;
			float4 _Mid;
			float2 _MainTexTiling;
			float _BaseOpacity;
			float _MinSizeY1;
			float _MaxSizeX;
			float _MinSizeY;
			float _MinSizeX;
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

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _BackTex;
			sampler2D _BackGroundTex;
			sampler2D _MidTex;
			sampler2D _FrontTex;
			UNITY_INSTANCING_BUFFER_START(SHR_VFX_UnlitMaster)
				UNITY_DEFINE_INSTANCED_PROP(float, _BPM)
			UNITY_INSTANCING_BUFFER_END(SHR_VFX_UnlitMaster)


			
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
				float4 appendResult54 = (float4(texCoord44.x , texCoord44.y , 0.0 , 0.0));
				float2 texCoord53 = IN.ase_texcoord1.xy * _MainTexTiling + appendResult54.xy;
				float4 tex2DNode12 = tex2D( _MainTex, texCoord53 );
				#ifdef _ISVERTICALORLATERAL_ON
				float staticSwitch61 = (IN.ase_texcoord1.xy).x;
				#else
				float staticSwitch61 = (IN.ase_texcoord1.xy).y;
				#endif
				#ifdef _UPLORDOWNR_ON
				float staticSwitch63 = ( 1.0 - staticSwitch61 );
				#else
				float staticSwitch63 = staticSwitch61;
				#endif
				float temp_output_30_0 = ( pow( staticSwitch63 , 0.3 ) - texCoord44.z );
				#ifdef _2ALPHAS_ON
				float staticSwitch80 = ( temp_output_30_0 * ( pow( ( 1.0 - staticSwitch63 ) , 0.3 ) - texCoord44.w ) );
				#else
				float staticSwitch80 = temp_output_30_0;
				#endif
				float smoothstepResult60 = smoothstep( 0.02 , tex2D( _DissolveTex, IN.ase_texcoord1.xy ).r , staticSwitch80);
				#ifdef _USINGXMOVE_ON
				float staticSwitch21_g110 = -0.5;
				#else
				float staticSwitch21_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch25_g110 = 0.0;
				#else
				float staticSwitch25_g110 = 0.0;
				#endif
				float2 appendResult15_g110 = (float2(staticSwitch21_g110 , staticSwitch25_g110));
				#ifdef _USINGXMOVE_ON
				float staticSwitch23_g110 = 0.5;
				#else
				float staticSwitch23_g110 = 0.0;
				#endif
				#ifdef _USINGYMOVE_ON
				float staticSwitch24_g110 = 0.0;
				#else
				float staticSwitch24_g110 = 0.0;
				#endif
				float2 appendResult16_g110 = (float2(staticSwitch23_g110 , staticSwitch24_g110));
				float _BPM_Instance = UNITY_ACCESS_INSTANCED_PROP(SHR_VFX_UnlitMaster,_BPM);
				float mulTime5_g111 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g111 = ( PI / 1.0 );
				float temp_output_18_0_g111 = ( mulTime5_g111 * temp_output_16_0_g111 );
				float saferPower20_g111 = abs( abs( cos( temp_output_18_0_g111 ) ) );
				float clampResult31_g111 = clamp( pow( saferPower20_g111 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult10_g110 = lerp( appendResult15_g110 , appendResult16_g110 , (0.0 + (( ( clampResult31_g111 - 0.5 ) * 2.0 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
				float2 texCoord52_g112 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _USINGXSCALE_ON
				float staticSwitch22_g112 = _MinSizeX;
				#else
				float staticSwitch22_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE_ON
				float staticSwitch23_g112 = _MinSizeY;
				#else
				float staticSwitch23_g112 = 1.0;
				#endif
				float2 appendResult27_g112 = (float2(staticSwitch22_g112 , staticSwitch23_g112));
				#ifdef _USINGXSCALE1_ON
				float staticSwitch46_g112 = _MaxSizeX;
				#else
				float staticSwitch46_g112 = 1.0;
				#endif
				#ifdef _USINGYSCALE1_ON
				float staticSwitch45_g112 = _MinSizeY1;
				#else
				float staticSwitch45_g112 = 1.0;
				#endif
				float2 appendResult49_g112 = (float2(staticSwitch46_g112 , staticSwitch45_g112));
				float mulTime5_g113 = _TimeParameters.x * ( _BPM_Instance / 60.0 );
				float temp_output_16_0_g113 = ( PI / 1.0 );
				float temp_output_18_0_g113 = ( mulTime5_g113 * temp_output_16_0_g113 );
				float saferPower20_g113 = abs( abs( cos( temp_output_18_0_g113 ) ) );
				float clampResult31_g113 = clamp( pow( saferPower20_g113 , 20.0 ) , 0.0 , 1.0 );
				float2 lerpResult56_g112 = lerp( appendResult27_g112 , appendResult49_g112 , clampResult31_g113);
				float2 temp_output_51_0_g112 = (texCoord52_g112*lerpResult56_g112 + ( lerpResult56_g112 + ( ( lerpResult56_g112 * -1.0 ) + ( ( lerpResult56_g112 / -2.0 ) + 0.5 ) ) ));
				float2 temp_output_7_0_g110 = ( lerpResult10_g110 + temp_output_51_0_g112 );
				float2 temp_output_152_0 = temp_output_7_0_g110;
				float4 tex2DNode97 = tex2D( _BackTex, temp_output_152_0 );
				float BackTexAlpha210 = tex2DNode97.a;
				float BackGroundTexAlpha211 = tex2D( _BackGroundTex, temp_output_152_0 ).a;
				float temp_output_224_0 = ( BackTexAlpha210 + BackGroundTexAlpha211 );
				#ifdef _1TEX_ON
				float staticSwitch190 = temp_output_224_0;
				#else
				float staticSwitch190 = 0.0;
				#endif
				float4 tex2DNode150 = tex2D( _MidTex, temp_output_152_0 );
				float MidTexAlpha212 = tex2DNode150.a;
				float temp_output_225_0 = ( BackTexAlpha210 + MidTexAlpha212 + BackGroundTexAlpha211 );
				#ifdef _2TEX_ON
				float staticSwitch188 = temp_output_225_0;
				#else
				float staticSwitch188 = staticSwitch190;
				#endif
				float4 tex2DNode161 = tex2D( _FrontTex, temp_output_152_0 );
				float FrontTexAlpha203 = tex2DNode161.a;
				float temp_output_229_0 = ( BackGroundTexAlpha211 + BackTexAlpha210 + MidTexAlpha212 + FrontTexAlpha203 );
				#ifdef _3TEX_ON
				float staticSwitch189 = temp_output_229_0;
				#else
				float staticSwitch189 = staticSwitch188;
				#endif
				float AlphaUITex175 = staticSwitch189;
				#ifdef _VFXORUI_ON
				float staticSwitch108 = AlphaUITex175;
				#else
				float staticSwitch108 = ( ( tex2DNode12.a * smoothstepResult60 ) * _BaseOpacity );
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
Node;AmplifyShaderEditor.Vector2Node;14;-1894.475,-801.2669;Inherit;False;Property;_MainTexTiling;MainTexTiling;48;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;54;-1859.865,-642.2606;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-2.261474,-496.8845;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.ColorNode;32;-351.312,-995.7258;Inherit;False;Property;_MainColor;MainColor;49;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,0;4,4,4,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-588.2754,-760.8757;Inherit;True;Property;_MainTex;MainTex;0;1;[HDR];Create;True;0;0;0;False;0;False;-1;d3cfaa263ab42814993310ce350e9955;d3cfaa263ab42814993310ce350e9955;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-1650.682,-752.4933;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;60;-594.4914,-506.3117;Inherit;True;3;0;FLOAT;1.25;False;1;FLOAT;0.02;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;52.88554,-746.8649;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;54.34462,-552.6642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-272.0556,-356.6643;Inherit;False;Property;_BaseOpacity;BaseOpacity;55;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-210.6921,-590.9621;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2138.847,-561.7706;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-1112.382,-691.6187;Inherit;True;Property;_DissolveTex;DissolveTex;51;0;Create;True;0;0;0;False;0;False;-1;2d6feab26a948a540b313c2253379a91;2d6feab26a948a540b313c2253379a91;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;93;-1437.852,-667.0807;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;80;-890.8466,-498.039;Inherit;False;Property;_2Alphas;2Alphas?;54;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-1249.29,-494.3608;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1033.74,-352.8437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;63;-2111.108,-372.0244;Inherit;False;Property;_UpLorDownR;UpLorDownR;53;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;-2288.988,-284.1242;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;61;-2576.931,-488.6625;Inherit;True;Property;_IsVerticalOrLateral;IsVerticalOrLateral;52;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-2820.487,-579.8698;Inherit;True;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;64;-2810.702,-327.7383;Inherit;True;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;57;-3095.932,-474.2282;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;83;-1684.125,-173.6632;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-1884.047,-177.8426;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-1369.539,-208.7085;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-1512.093,-415.0849;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2895.355,743.6398;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-2300.355,718.6398;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;-2588.771,632.0066;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1.5,1.5;False;1;FLOAT2;-0.25,-0.25;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;133;-2660.397,420.3103;Inherit;False;SHF_BeatScaling;18;;98;1f1f15f84ef3aaf4b94f2810f37733f5;0;0;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;135;-2320.603,418.309;Inherit;True;SHF_BeatMoving;30;;102;65813206edc57a749b6de4c0a25b7872;0;0;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;107;1402.294,-146.9305;Inherit;False;Property;_VFXorUI;VFXorUI ?;17;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1758.315,-28.92795;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;SHR_VFX_UnlitMaster;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638750638264268033;  Blend;0;638757509385679611;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638750638155477510;  Use Shadow Threshold;0;0;Receive Shadows;0;638750638186889437;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;0;638750638251761571;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1420.225,140.8963;Inherit;False;Property;_Alphacliptresh;Alphacliptresh;50;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;108;1399.617,-18.55121;Inherit;False;Property;_VFXorUI1;VFXorUI ?;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;107;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;1203.955,-110.7421;Inherit;False;172;UITexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.ColorNode;141;-535.9341,1168.37;Inherit;False;Property;_Mid;Mid;11;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;150;-619.4713,1535.504;Inherit;True;Property;_MidTex;MidTex;6;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;4b561bc26fed7cb438711e1c560265e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-594.501,812.9119;Inherit;True;Property;_BackTex;BackTex;5;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;4b561bc26fed7cb438711e1c560265e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;176;1131.936,39.16281;Inherit;False;175;AlphaUITex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;152;-1289.689,1568.469;Inherit;False;SHF_BeatMoving;30;;110;65813206edc57a749b6de4c0a25b7872;0;0;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;207;-1069.163,2324.602;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;208;-1159.076,751.3222;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;209;-1044.809,914.7875;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;366.8529,519.1486;Inherit;True;BackGroundTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;180;-596.431,642.145;Inherit;False;Constant;_BackGroundColor;BackGroundColor;33;0;Create;True;0;0;0;False;0;False;0,0.06411219,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;178;-632.1988,449.4861;Inherit;True;Property;_BackGroundTex;BackGroundTex;4;0;Create;True;0;0;0;False;0;False;-1;df2f166ffc872a54a9349544643cbe94;abf84c530bf23fd4fa90adc24c613dc5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-315.7521,485.4823;Inherit;False;BackGroundTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;18.20007,493.7736;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;161;-615.95,2320.135;Inherit;True;Property;_FrontTex;FrontTex;7;0;Create;True;0;0;0;False;0;False;-1;8d87401656d0ff64cb6e5a9ed9176d2a;4b561bc26fed7cb438711e1c560265e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;167;-570.9552,2706.547;Inherit;False;Property;_Mid03;Mid03;13;0;Create;True;0;0;0;False;0;False;0.6812992,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;142;-507.34,1346.448;Inherit;False;Property;_Back;Back;8;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;140;-536.8671,1022.249;Inherit;False;Property;_Front;Front;14;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;942.7945,1224.783;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;250;-282.7139,1220.053;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;247;313.04,1151.141;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;248;653.7065,1329.808;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;249;-244.7242,1411.983;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;246;-38.95996,913.1411;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;625.9348,797.6873;Inherit;False;BackTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;251;-291.3804,808.7197;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;1176.424,1227.547;Inherit;True;BackTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;156;-578.9708,1734.036;Inherit;False;Property;_Front02;Front02;15;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;157;-562.9406,1915.415;Inherit;False;Property;_Mid02;Mid02;12;0;Create;True;0;0;0;False;0;False;0,1,0.9647675,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;158;-540.3207,2087.49;Inherit;False;Property;_Back02;Back02;9;0;Create;True;0;0;0;False;0;False;0,1,0.7048147,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;256;-271.2544,1886.293;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;255;-243.8986,2144.39;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;374.371,1503.771;Inherit;False;MidTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;257;806.3267,1657.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;258;-300.9872,1558.023;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;824.4994,2041.371;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;1007.32,2056.505;Inherit;True;MidTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;259;-285.418,2298.748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;253;239.3291,1759.207;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;252;-73.89135,1616.567;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;254;509.188,2065.046;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;261;-35.14558,2337.268;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;262;459.0499,2907.506;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;264.2722,2262.75;Inherit;False;FrontTexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;168;-571.0927,2527.891;Inherit;False;Property;_Front03;Front03;16;0;Create;True;0;0;0;False;0;False;1,0.9882626,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;260;200.166,2698.037;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;992.489,2885.712;Inherit;True;FrontTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;731.0215,2915.972;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;166;-575.1025,2927.26;Inherit;False;Property;_Back03;Back03;10;0;Create;True;0;0;0;False;0;False;1,0,0.05845451,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;3873.672,1007.517;Inherit;True;AlphaUITex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;185;3632.511,1240.447;Inherit;False;Property;_3Tex;3Tex?;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;189;3616.846,979.4196;Inherit;False;Property;_3Tex1;3Tex?;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;185;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;3870.597,1234.783;Inherit;True;UITexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;3410.108,1462.181;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;236;3375.392,1084.124;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;270;2826.356,1731.481;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;2494.873,1849.893;Inherit;False;199;MidTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;272;2496.109,1920.086;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;271;3135.69,1735.481;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;2849.208,1939.81;Inherit;False;197;FrontTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;2844.233,2033.518;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;2846.385,2110.609;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;3128.324,2190.433;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;2876.176,2258.742;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;2884.55,2193.705;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;2885.733,2337.037;Inherit;False;203;FrontTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;2133.577,1716.405;Inherit;False;201;BackTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;2112.535,1643.243;Inherit;False;205;BackGroundTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;2141.15,1792.383;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;264;2409.805,1638.31;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;186;3196.755,1251.838;Inherit;False;Property;_2Tex;2Tex?;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;3045.688,1337.357;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;187;2866.937,1254.821;Inherit;False;Property;_1Tex;1Tex?;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;2692.978,1281.06;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;190;2594.051,963.4867;Inherit;False;Property;_1Tex1;1Tex?;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;187;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;235;3036.142,1182.319;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;225;2868.221,1368.123;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;188;3175.607,949.2889;Inherit;False;Property;_2Tex1;2Tex?;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;186;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;224;2346.291,1150.723;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;2324.551,1512.369;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;2355.209,1367.171;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;2339.367,1442.681;Inherit;False;212;MidTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;2069.56,1149.594;Inherit;False;210;BackTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;2054.354,1236.447;Inherit;False;211;BackGroundTexAlpha;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;54;0;44;1
WireConnection;54;1;44;2
WireConnection;12;1;53;0
WireConnection;53;0;14;0
WireConnection;53;1;54;0
WireConnection;60;0;80;0
WireConnection;60;2;59;1
WireConnection;33;0;32;0
WireConnection;33;1;12;1
WireConnection;94;0;29;0
WireConnection;94;1;95;0
WireConnection;29;0;12;4
WireConnection;29;1;60;0
WireConnection;59;1;93;0
WireConnection;80;1;30;0
WireConnection;80;0;85;0
WireConnection;30;0;36;0
WireConnection;30;1;44;3
WireConnection;85;0;30;0
WireConnection;85;1;81;0
WireConnection;63;1;61;0
WireConnection;63;0;65;0
WireConnection;65;0;61;0
WireConnection;61;1;21;0
WireConnection;61;0;64;0
WireConnection;21;0;57;0
WireConnection;64;0;57;0
WireConnection;83;0;79;0
WireConnection;79;0;63;0
WireConnection;81;0;83;0
WireConnection;81;1;44;4
WireConnection;36;0;63;0
WireConnection;96;0;103;0
WireConnection;107;1;33;0
WireConnection;107;0;173;0
WireConnection;1;2;107;0
WireConnection;1;3;108;0
WireConnection;1;4;38;0
WireConnection;108;1;94;0
WireConnection;108;0;176;0
WireConnection;150;1;152;0
WireConnection;97;1;209;0
WireConnection;207;0;152;0
WireConnection;208;0;152;0
WireConnection;209;0;152;0
WireConnection;205;0;179;0
WireConnection;178;1;208;0
WireConnection;211;0;178;4
WireConnection;179;0;211;0
WireConnection;179;1;180;0
WireConnection;161;1;207;0
WireConnection;182;0;210;0
WireConnection;182;1;248;0
WireConnection;250;0;97;2
WireConnection;247;0;246;0
WireConnection;247;1;141;0
WireConnection;247;2;250;0
WireConnection;248;0;247;0
WireConnection;248;1;142;0
WireConnection;248;2;249;0
WireConnection;249;0;97;3
WireConnection;246;1;140;0
WireConnection;246;2;97;1
WireConnection;210;0;251;0
WireConnection;251;0;97;4
WireConnection;201;0;182;0
WireConnection;256;0;150;2
WireConnection;255;0;150;1
WireConnection;212;0;258;0
WireConnection;257;0;212;0
WireConnection;258;0;150;4
WireConnection;151;0;257;0
WireConnection;151;1;254;0
WireConnection;199;0;151;0
WireConnection;259;0;161;4
WireConnection;253;0;252;0
WireConnection;253;1;157;0
WireConnection;253;2;256;0
WireConnection;252;1;156;0
WireConnection;252;2;150;3
WireConnection;254;0;253;0
WireConnection;254;1;158;0
WireConnection;254;2;255;0
WireConnection;261;1;168;0
WireConnection;261;2;161;3
WireConnection;262;0;260;0
WireConnection;262;1;166;0
WireConnection;262;2;161;1
WireConnection;203;0;259;0
WireConnection;260;0;261;0
WireConnection;260;1;167;0
WireConnection;260;2;161;2
WireConnection;197;0;162;0
WireConnection;162;0;203;0
WireConnection;162;1;262;0
WireConnection;175;0;189;0
WireConnection;185;1;186;0
WireConnection;185;0;171;0
WireConnection;189;1;188;0
WireConnection;189;0;236;0
WireConnection;172;0;185;0
WireConnection;171;0;271;0
WireConnection;171;1;229;0
WireConnection;236;0;229;0
WireConnection;270;0;264;0
WireConnection;270;1;267;0
WireConnection;270;2;272;0
WireConnection;271;0;270;0
WireConnection;271;1;266;0
WireConnection;271;2;273;0
WireConnection;229;0;233;0
WireConnection;229;1;231;0
WireConnection;229;2;232;0
WireConnection;229;3;230;0
WireConnection;264;0;269;0
WireConnection;264;1;268;0
WireConnection;264;2;274;0
WireConnection;186;1;187;0
WireConnection;186;0;220;0
WireConnection;220;0;270;0
WireConnection;220;1;225;0
WireConnection;187;0;221;0
WireConnection;221;0;264;0
WireConnection;221;1;224;0
WireConnection;190;0;224;0
WireConnection;235;0;225;0
WireConnection;225;0;228;0
WireConnection;225;1;227;0
WireConnection;225;2;226;0
WireConnection;188;1;190;0
WireConnection;188;0;235;0
WireConnection;224;0;223;0
WireConnection;224;1;222;0
ASEEND*/
//CHKSM=FF3C1D09525C49036F817BDFD39E630DDA9FF36D