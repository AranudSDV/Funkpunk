// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHR_Grid"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR][NoScaleOffset]_InteractiveGrid("InteractiveGrid", 2D) = "white" {}
		_SquareSize("SquareSize", Float) = 1.18
		_SquareSmoothing("SquareSmoothing", Float) = 2.58
		_DiagSize("DiagSize", Float) = 1
		_DiagSmoothing("DiagSmoothing", Float) = 3.54
		_Alpha("Alpha", Float) = 0.1
		_Alphaclip("Alphaclip", Float) = 0.01
		[HDR]_GridColor("GridColor", Color) = (0,0,0,0)
		_GridStyle("GridStyle", Range( 1 , 3)) = 1
		_GridTex("GridTex", 2D) = "white" {}
		_GridTexDensity("GridTexDensity", Vector) = (10,10,0,0)
		_GridSmoothing("GridSmoothing", Float) = 0
		[HDR]_IllumColor("IllumColor", Color) = (0,1,0.7394278,0)
		_IllumStyle("IllumStyle", Range( 1 , 3)) = 1
		_IllumTex("IllumTex", 2D) = "white" {}
		_IllumTexDensity("IllumTexDensity", Vector) = (10,10,0,0)
		_IllumSmoothing("IllumSmoothing", Float) = 0
		_ColliderStyle("ColliderStyle", Range( 1 , 3)) = 1
		_ColliderTex("ColliderTex", 2D) = "white" {}
		_ColliderTexDensity("ColliderTexDensity", Vector) = (10,10,0,0)
		_ColliderSmoothing("ColliderSmoothing", Float) = 0
		_VisibilityStyle("VisibilityStyle", Range( 1 , 3)) = 1
		_VisibilityTex("VisibilityTex", 2D) = "white" {}
		_VisibilityTexDensity("VisibilityTexDensity", Vector) = (10,10,0,0)
		_VisibilitySmoothing("VisibilitySmoothing", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _IllumTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;
			sampler2D _GridTex;
			sampler2D _VisibilityTex;


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
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
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

				float2 appendResult451 = (float2(_IllumTexDensity.x , _IllumTexDensity.y));
				float2 appendResult452 = (float2(_IllumTexDensity.z , _IllumTexDensity.w));
				float2 texCoord450 = IN.ase_texcoord3.xy * appendResult451 + appendResult452;
				float4 tex2DNode446 = tex2D( _IllumTex, texCoord450 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord3.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float PlayerIllum456 = tex2DNode228.r;
				float smoothstepResult449 = smoothstep( tex2DNode446.r , ( tex2DNode446.r + _IllumSmoothing ) , PlayerIllum456);
				float2 uv510 = 0;
				float3 unityVoronoy510 = UnityVoronoi(texCoord450,0.0,1.0,uv510);
				float smoothstepResult512 = smoothstep( unityVoronoy510.x , ( unityVoronoy510.x + _IllumSmoothing ) , PlayerIllum456);
				float ifLocalVar508 = 0;
				if( _IllumStyle > 2.0 )
				ifLocalVar508 = smoothstepResult449;
				else if( _IllumStyle == 2.0 )
				ifLocalVar508 = PlayerIllum456;
				else if( _IllumStyle < 2.0 )
				ifLocalVar508 = smoothstepResult512;
				float IllumFinal514 = ifLocalVar508;
				float4 lerpResult241 = lerp( _GridColor , _IllumColor , IllumFinal514);
				float4 color574 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord3.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				float4 lerpResult566 = lerp( lerpResult241 , color574 , ColliderFinal535);
				
				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord3.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord3.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord3.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord3.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult566.rgb;
				float Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				float AlphaClipThreshold = _Alphaclip;
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
			#define _SURFACE_TYPE_TRANSPARENT 1
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
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _GridTex;
			sampler2D _VisibilityTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;


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
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
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

				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord2.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord2.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord2.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord2.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord2.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord2.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				

				float Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				float AlphaClipThreshold = _Alphaclip;
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
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _GridTex;
			sampler2D _VisibilityTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;


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

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
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

				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord2.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord2.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord2.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord2.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord2.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord2.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				

				float Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				float AlphaClipThreshold = _Alphaclip;

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
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _GridTex;
			sampler2D _VisibilityTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;


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

				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				

				surfaceDescription.Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				surfaceDescription.AlphaClipThreshold = _Alphaclip;

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
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _GridTex;
			sampler2D _VisibilityTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;


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

				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				

				surfaceDescription.Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				surfaceDescription.AlphaClipThreshold = _Alphaclip;

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
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GridColor;
			float4 _VisibilityTexDensity;
			float4 _ColliderTexDensity;
			float4 _GridTexDensity;
			float4 _IllumColor;
			float4 _IllumTexDensity;
			float _IllumSmoothing;
			float _ColliderStyle;
			float _IllumStyle;
			float _ColliderSmoothing;
			float _GridStyle;
			float _Alpha;
			float _GridSmoothing;
			float _SquareSize;
			float _SquareSmoothing;
			float _DiagSize;
			float _DiagSmoothing;
			float _VisibilityStyle;
			float _VisibilitySmoothing;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _GridTex;
			sampler2D _VisibilityTex;
			sampler2D _InteractiveGrid;
			sampler2D _ColliderTex;


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

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 appendResult558 = (float2(_GridTexDensity.x , _GridTexDensity.y));
				float2 appendResult559 = (float2(_GridTexDensity.z , _GridTexDensity.w));
				float2 texCoord551 = IN.ase_texcoord1.xy * appendResult558 + appendResult559;
				float4 tex2DNode560 = tex2D( _GridTex, texCoord551 );
				float3 ase_parentObjectScale = ( 1.0 / float3( length( GetWorldToObjectMatrix()[ 0 ].xyz ), length( GetWorldToObjectMatrix()[ 1 ].xyz ), length( GetWorldToObjectMatrix()[ 2 ].xyz ) ) );
				float2 appendResult218 = (float2(ase_parentObjectScale.x , ase_parentObjectScale.y));
				float2 texCoord204 = IN.ase_texcoord1.xy * appendResult218 + float2( 0,0 );
				float2 temp_output_207_0 = ( ( frac( texCoord204 ) * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break162 = temp_output_207_0;
				float temp_output_479_0 = max( length( break162.x ) , length( break162.y ) );
				float temp_output_497_0 = sign( 0.0 );
				float smoothstepResult483 = smoothstep( _SquareSize , ( _SquareSize + _SquareSmoothing ) , ( temp_output_479_0 * distance( temp_output_479_0 , temp_output_497_0 ) ));
				float2 texCoord133 = IN.ase_texcoord1.xy * appendResult218 + float2( 0,0 );
				float cos151 = cos( radians( 45.0 ) );
				float sin151 = sin( radians( 45.0 ) );
				float2 rotator151 = mul( frac( texCoord133 ) - float2( 0.5,0.5 ) , float2x2( cos151 , -sin151 , sin151 , cos151 )) + float2( 0.5,0.5 );
				float2 temp_output_161_0 = ( ( rotator151 * float2( 2,2 ) ) - float2( 1,1 ) );
				float2 break208 = temp_output_161_0;
				float temp_output_480_0 = max( length( break208.x ) , length( break208.y ) );
				float smoothstepResult490 = smoothstep( _DiagSize , ( _DiagSize + _DiagSmoothing ) , ( distance( temp_output_480_0 , temp_output_497_0 ) * temp_output_480_0 ));
				float Shape502 = max( smoothstepResult483 , smoothstepResult490 );
				float smoothstepResult553 = smoothstep( tex2DNode560.r , ( tex2DNode560.r + _GridSmoothing ) , Shape502);
				float2 uv555 = 0;
				float3 unityVoronoy555 = UnityVoronoi(texCoord551,0.0,1.0,uv555);
				float smoothstepResult556 = smoothstep( unityVoronoy555.x , ( unityVoronoy555.x + _GridSmoothing ) , Shape502);
				float ifLocalVar557 = 0;
				if( _GridStyle > 2.0 )
				ifLocalVar557 = smoothstepResult553;
				else if( _GridStyle == 2.0 )
				ifLocalVar557 = Shape502;
				else if( _GridStyle < 2.0 )
				ifLocalVar557 = smoothstepResult556;
				float ShapeFinal564 = ifLocalVar557;
				float2 appendResult515 = (float2(_VisibilityTexDensity.x , _VisibilityTexDensity.y));
				float2 appendResult516 = (float2(_VisibilityTexDensity.z , _VisibilityTexDensity.w));
				float2 texCoord519 = IN.ase_texcoord1.xy * appendResult515 + appendResult516;
				float4 tex2DNode520 = tex2D( _VisibilityTex, texCoord519 );
				float2 uv_InteractiveGrid228 = IN.ase_texcoord1.xy;
				float4 tex2DNode228 = tex2D( _InteractiveGrid, uv_InteractiveGrid228 );
				float Visibility457 = tex2DNode228.g;
				float smoothstepResult522 = smoothstep( tex2DNode520.r , ( tex2DNode520.r + _VisibilitySmoothing ) , Visibility457);
				float2 uv526 = 0;
				float3 unityVoronoy526 = UnityVoronoi(texCoord519,0.0,1.0,uv526);
				float smoothstepResult527 = smoothstep( unityVoronoy526.x , ( unityVoronoy526.x + _VisibilitySmoothing ) , Visibility457);
				float ifLocalVar528 = 0;
				if( _VisibilityStyle > 2.0 )
				ifLocalVar528 = smoothstepResult522;
				else if( _VisibilityStyle == 2.0 )
				ifLocalVar528 = Visibility457;
				else if( _VisibilityStyle < 2.0 )
				ifLocalVar528 = smoothstepResult527;
				float VisibilityFinal529 = ifLocalVar528;
				float2 appendResult546 = (float2(_ColliderTexDensity.x , _ColliderTexDensity.y));
				float2 appendResult547 = (float2(_ColliderTexDensity.z , _ColliderTexDensity.w));
				float2 texCoord537 = IN.ase_texcoord1.xy * appendResult546 + appendResult547;
				float4 tex2DNode549 = tex2D( _ColliderTex, texCoord537 );
				float Colliders458 = tex2DNode228.b;
				float smoothstepResult539 = smoothstep( tex2DNode549.r , ( tex2DNode549.r + _ColliderSmoothing ) , Colliders458);
				float2 uv541 = 0;
				float3 unityVoronoy541 = UnityVoronoi(texCoord537,0.0,1.0,uv541);
				float smoothstepResult542 = smoothstep( unityVoronoy541.x , ( unityVoronoy541.x + _ColliderSmoothing ) , Colliders458);
				float ifLocalVar543 = 0;
				if( _ColliderStyle > 2.0 )
				ifLocalVar543 = smoothstepResult539;
				else if( _ColliderStyle == 2.0 )
				ifLocalVar543 = Colliders458;
				else if( _ColliderStyle < 2.0 )
				ifLocalVar543 = smoothstepResult542;
				float ColliderFinal535 = ifLocalVar543;
				

				surfaceDescription.Alpha = ( ( ShapeFinal564 * VisibilityFinal529 * _Alpha ) - ColliderFinal535 );
				surfaceDescription.AlphaClipThreshold = _Alphaclip;

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
Node;AmplifyShaderEditor.CommentaryNode;532;-1777.434,-1970.964;Inherit;False;2008.823;910.8511;;15;518;519;521;522;525;526;527;528;524;517;515;516;523;529;520;Visibility;0,0.3207547,0.01103212,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;531;313.6822,-3004.389;Inherit;False;2059.125;854.1912;;15;451;452;450;447;449;504;513;510;512;508;453;448;446;509;514;Illum;0.2641509,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;501;-1739.364,-4214.048;Inherit;False;3665.154;1068.758;;40;502;495;218;492;500;497;489;488;499;490;487;484;485;498;483;486;479;477;162;207;204;212;206;475;208;161;160;151;214;173;209;133;480;217;0;507;570;571;572;573;OctogonalShape;0.1389921,0,0.2327043,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;507;-1025.718,-3824.817;Inherit;False;598.8516;297.1965;;4;228;457;456;458;RenderTex;0.7215686,0.5940759,0,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-802.7013,-3237.686;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;480;56.12967,-3470.199;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;133;-1156.416,-3371.503;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;209;-975.1212,-3229.2;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-1163.668,-3231.332;Inherit;False;Constant;_Float4;Float 3;0;0;Create;True;0;0;0;False;0;False;45;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;214;-921.71,-3368.877;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;151;-789.7756,-3367.939;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.125;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-587.4984,-3367.408;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;161;-424.8252,-3369.674;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-778.6791,-4084.088;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;212;-930.4083,-4084.969;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;204;-1165.611,-4087.114;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;207;-562.1189,-4088.229;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;479;-55.32386,-4087.127;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;486;1067.187,-3953.48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;483;1196.537,-4084.571;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;514.0776,-4088.415;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;487;1072.784,-3361.87;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;490;1202.134,-3492.962;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;500;303.7388,-3652.506;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;492;214.1274,-3971.806;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;218;-1342.54,-3684.974;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;495;1453.416,-3751.097;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;546.1596,-3490.362;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;457;-670.4031,-3707.538;Inherit;False;Visibility;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;458;-668.8636,-3640.719;Inherit;False;Colliders;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;456;-671.4827,-3774.818;Inherit;False;PlayerIllum;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;451;610.1775,-2669.898;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;452;616.6665,-2545.508;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;450;805.6093,-2646.041;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;447;1386.566,-2754.919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;449;1609.378,-2877.184;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;1388.947,-2619.233;Inherit;False;456;PlayerIllum;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;513;1392.038,-2518.026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;512;1608.608,-2483.376;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;508;1947.197,-2923.756;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;453;363.6822,-2663.837;Inherit;False;Property;_IllumTexDensity;IllumTexDensity;15;0;Create;True;0;0;0;False;0;False;10,10,0,0;10,10,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;448;1115.461,-2633.795;Inherit;False;Property;_IllumSmoothing;IllumSmoothing;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;509;1602.723,-2954.389;Inherit;False;Property;_IllumStyle;IllumStyle;13;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;514;2130.807,-2922.66;Inherit;False;IllumFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;162;-289.6525,-4090.144;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.AbsOpNode;475;-290.0056,-3367.98;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;208;-151.128,-3473.411;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SignOpNode;497;62.49916,-3738.815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;510;1074.025,-2451.198;Inherit;True;0;0;1;2;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;-10.61087,-1834.043;Inherit;False;VisibilityFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;519;-1336.225,-1555.956;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;521;-755.267,-1664.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;522;-532.456,-1787.099;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;525;-749.795,-1427.941;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;526;-1067.809,-1361.113;Inherit;True;0;0;1;2;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SmoothstepOpNode;527;-533.225,-1393.291;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;528;-194.636,-1833.671;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;-752.8859,-1529.148;Inherit;False;457;Visibility;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;515;-1508.654,-1581.166;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;516;-1504.871,-1455.423;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;534;401.3753,-1995.804;Inherit;False;2008.823;910.8511;;15;549;548;547;546;545;544;543;542;541;540;539;538;537;536;535;Collider;0,0.02717464,0.3215686,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;537;842.5853,-1580.796;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;538;1423.542,-1689.674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;539;1646.353,-1811.939;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;540;1429.014,-1452.781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;541;1111,-1385.953;Inherit;True;0;0;1;2;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SmoothstepOpNode;542;1645.583,-1418.131;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;543;1984.172,-1858.511;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;546;670.1561,-1606.006;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;547;673.9391,-1480.263;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;544;1426.789,-1553.988;Inherit;False;458;Colliders;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;548;1152.436,-1568.55;Inherit;False;Property;_ColliderSmoothing;ColliderSmoothing;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;545;451.3755,-1593.837;Inherit;False;Property;_ColliderTexDensity;ColliderTexDensity;19;0;Create;True;0;0;0;False;0;False;10,10,0,0;10,10,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;535;2168.199,-1858.883;Inherit;False;ColliderFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;550;-1770.988,-3011.652;Inherit;False;2008.823;910.8511;;15;565;564;563;562;561;560;559;558;557;556;555;554;553;552;551;Grid;0.3144653,0.3144653,0.3144653,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;551;-1329.777,-2596.645;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;552;-748.8207,-2705.523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;553;-526.0098,-2827.788;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;554;-743.3488,-2468.631;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;555;-1061.363,-2401.802;Inherit;True;0;0;1;2;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SmoothstepOpNode;556;-526.7788,-2433.98;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;557;-188.1901,-2874.359;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;558;-1502.207,-2621.855;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;559;-1498.424,-2496.112;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;-4.163723,-2874.731;Inherit;False;ShapeFinal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;228;-975.7171,-3754.621;Inherit;True;Property;_InteractiveGrid;InteractiveGrid;0;2;[HDR];[NoScaleOffset];Create;True;0;0;0;True;0;False;-1;3b5a8f3bdc928d94ab140bad48ca053d;3b5a8f3bdc928d94ab140bad48ca053d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;560;-1089.749,-2828.563;Inherit;True;Property;_GridTex;GridTex;9;0;Create;True;0;0;0;False;0;False;-1;1b8eb9a6dc68a9f4eaff42068bb79eee;1b8eb9a6dc68a9f4eaff42068bb79eee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;520;-1096.195,-1788.541;Inherit;True;Property;_VisibilityTex;VisibilityTex;22;0;Create;True;0;0;0;False;0;False;-1;1b8eb9a6dc68a9f4eaff42068bb79eee;1b8eb9a6dc68a9f4eaff42068bb79eee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;549;1082.614,-1812.714;Inherit;True;Property;_ColliderTex;ColliderTex;18;0;Create;True;0;0;0;False;0;False;-1;1b8eb9a6dc68a9f4eaff42068bb79eee;1b8eb9a6dc68a9f4eaff42068bb79eee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;2265.889,-3439.619;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;1999.48,-3372.65;Inherit;False;529;VisibilityFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;2063.684,-3301.728;Inherit;False;Property;_Alpha;Alpha;5;0;Create;True;0;0;0;False;0;False;0.1;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;2151.74,-3643.734;Inherit;False;514;IllumFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;241;2491.834,-3708.612;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;250;2522.796,-3491.354;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;2028.718,-3438.79;Inherit;False;564;ShapeFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;561;-739.367,-2579.588;Inherit;False;502;Shape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;502;1668.058,-3751.571;Inherit;False;Shape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3051.361,-3471.52;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;SHR_Grid;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;1;638760089737395429;  Blend;0;638796515255660564;Two Sided;1;0;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;638798776018827474;  Phong;0;638798775793944862;  Strength;0.5,False,;0;  Type;0;0;  Tess;1,False,;638798775913661033;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;221;2607.449,-3346.072;Inherit;False;Property;_Alphaclip;Alphaclip;6;0;Create;True;0;0;0;False;0;False;0.01;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;485;831.0656,-3929.933;Inherit;False;Property;_SquareSmoothing;SquareSmoothing;2;0;Create;True;0;0;0;False;0;False;2.58;2.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;484;858.4011,-4028.432;Inherit;False;Property;_SquareSize;SquareSize;1;0;Create;True;0;0;0;False;0;False;1.18;1.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;489;849.1959,-3333.988;Inherit;False;Property;_DiagSmoothing;DiagSmoothing;4;0;Create;True;0;0;0;False;0;False;3.54;3.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;799.8732,-3429.263;Inherit;False;Property;_DiagSize;DiagSize;3;0;Create;True;0;0;0;False;0;False;1;1.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-1026.373,-1543.71;Inherit;False;Property;_VisibilitySmoothing;VisibilitySmoothing;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;517;-1727.434,-1568.997;Inherit;False;Property;_VisibilityTexDensity;VisibilityTexDensity;23;0;Create;True;0;0;0;False;0;False;10,10,0,0;10,10,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectScaleNode;217;-1689.363,-3711.93;Inherit;False;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;563;-1720.987,-2609.686;Inherit;False;Property;_GridTexDensity;GridTexDensity;10;0;Create;True;0;0;0;False;0;False;10,10,0,0;10,10,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;477;-406.2783,-4083.197;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;570;-178.8305,-4143.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;571;-193.5423,-3984.132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;572;-62.8309,-3536.545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;573;-77.54269,-3376.976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;565;-494.8921,-2963.061;Inherit;False;Property;_GridStyle;GridStyle;8;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;566;2846.025,-3722.844;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;562;-1019.927,-2584.399;Inherit;False;Property;_GridSmoothing;GridSmoothing;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;446;1045.638,-2877.958;Inherit;True;Property;_IllumTex;IllumTex;14;0;Create;True;0;0;0;False;0;False;-1;1b8eb9a6dc68a9f4eaff42068bb79eee;1b8eb9a6dc68a9f4eaff42068bb79eee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;225;2135.074,-3984.112;Inherit;False;Property;_GridColor;GridColor;7;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;2,2,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;254;2142.725,-3822.002;Inherit;False;Property;_IllumColor;IllumColor;12;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0.7394278,0;0,1,0.7394278,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;464;2263.254,-3230.331;Inherit;False;535;ColliderFinal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;574;2537.624,-3901.424;Inherit;False;Constant;_ColliderColor;ColliderColor;24;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;536;1677.471,-1945.804;Inherit;False;Property;_ColliderStyle;ColliderStyle;17;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;-501.3381,-1920.964;Inherit;False;Property;_VisibilityStyle;VisibilityStyle;21;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
WireConnection;480;0;572;0
WireConnection;480;1;573;0
WireConnection;133;0;218;0
WireConnection;209;0;173;0
WireConnection;214;0;133;0
WireConnection;151;0;214;0
WireConnection;151;2;209;0
WireConnection;160;0;151;0
WireConnection;161;0;160;0
WireConnection;206;0;212;0
WireConnection;212;0;204;0
WireConnection;204;0;218;0
WireConnection;207;0;206;0
WireConnection;479;0;570;0
WireConnection;479;1;571;0
WireConnection;486;0;484;0
WireConnection;486;1;485;0
WireConnection;483;0;498;0
WireConnection;483;1;484;0
WireConnection;483;2;486;0
WireConnection;498;0;479;0
WireConnection;498;1;492;0
WireConnection;487;0;488;0
WireConnection;487;1;489;0
WireConnection;490;0;499;0
WireConnection;490;1;488;0
WireConnection;490;2;487;0
WireConnection;500;0;480;0
WireConnection;500;1;497;0
WireConnection;492;0;479;0
WireConnection;492;1;497;0
WireConnection;218;0;217;1
WireConnection;218;1;217;2
WireConnection;495;0;483;0
WireConnection;495;1;490;0
WireConnection;499;0;500;0
WireConnection;499;1;480;0
WireConnection;457;0;228;2
WireConnection;458;0;228;3
WireConnection;456;0;228;1
WireConnection;451;0;453;1
WireConnection;451;1;453;2
WireConnection;452;0;453;3
WireConnection;452;1;453;4
WireConnection;450;0;451;0
WireConnection;450;1;452;0
WireConnection;447;0;446;1
WireConnection;447;1;448;0
WireConnection;449;0;504;0
WireConnection;449;1;446;1
WireConnection;449;2;447;0
WireConnection;513;0;510;0
WireConnection;513;1;448;0
WireConnection;512;0;504;0
WireConnection;512;1;510;0
WireConnection;512;2;513;0
WireConnection;508;0;509;0
WireConnection;508;2;449;0
WireConnection;508;3;504;0
WireConnection;508;4;512;0
WireConnection;514;0;508;0
WireConnection;162;0;207;0
WireConnection;475;0;161;0
WireConnection;208;0;161;0
WireConnection;510;0;450;0
WireConnection;529;0;528;0
WireConnection;519;0;515;0
WireConnection;519;1;516;0
WireConnection;521;0;520;1
WireConnection;521;1;523;0
WireConnection;522;0;524;0
WireConnection;522;1;520;1
WireConnection;522;2;521;0
WireConnection;525;0;526;0
WireConnection;525;1;523;0
WireConnection;526;0;519;0
WireConnection;527;0;524;0
WireConnection;527;1;526;0
WireConnection;527;2;525;0
WireConnection;528;0;518;0
WireConnection;528;2;522;0
WireConnection;528;3;524;0
WireConnection;528;4;527;0
WireConnection;515;0;517;1
WireConnection;515;1;517;2
WireConnection;516;0;517;3
WireConnection;516;1;517;4
WireConnection;537;0;546;0
WireConnection;537;1;547;0
WireConnection;538;0;549;1
WireConnection;538;1;548;0
WireConnection;539;0;544;0
WireConnection;539;1;549;1
WireConnection;539;2;538;0
WireConnection;540;0;541;0
WireConnection;540;1;548;0
WireConnection;541;0;537;0
WireConnection;542;0;544;0
WireConnection;542;1;541;0
WireConnection;542;2;540;0
WireConnection;543;0;536;0
WireConnection;543;2;539;0
WireConnection;543;3;544;0
WireConnection;543;4;542;0
WireConnection;546;0;545;1
WireConnection;546;1;545;2
WireConnection;547;0;545;3
WireConnection;547;1;545;4
WireConnection;535;0;543;0
WireConnection;551;0;558;0
WireConnection;551;1;559;0
WireConnection;552;0;560;1
WireConnection;552;1;562;0
WireConnection;553;0;561;0
WireConnection;553;1;560;1
WireConnection;553;2;552;0
WireConnection;554;0;555;0
WireConnection;554;1;562;0
WireConnection;555;0;551;0
WireConnection;556;0;561;0
WireConnection;556;1;555;0
WireConnection;556;2;554;0
WireConnection;557;0;565;0
WireConnection;557;2;553;0
WireConnection;557;3;561;0
WireConnection;557;4;556;0
WireConnection;558;0;563;1
WireConnection;558;1;563;2
WireConnection;559;0;563;3
WireConnection;559;1;563;4
WireConnection;564;0;557;0
WireConnection;560;1;551;0
WireConnection;520;1;519;0
WireConnection;549;1;537;0
WireConnection;222;0;503;0
WireConnection;222;1;461;0
WireConnection;222;2;223;0
WireConnection;241;0;225;0
WireConnection;241;1;254;0
WireConnection;241;2;530;0
WireConnection;250;0;222;0
WireConnection;250;1;464;0
WireConnection;502;0;495;0
WireConnection;1;2;566;0
WireConnection;1;3;250;0
WireConnection;1;4;221;0
WireConnection;477;0;207;0
WireConnection;570;0;162;0
WireConnection;571;0;162;1
WireConnection;572;0;208;0
WireConnection;573;0;208;1
WireConnection;566;0;241;0
WireConnection;566;1;574;0
WireConnection;566;2;464;0
WireConnection;446;1;450;0
ASEEND*/
//CHKSM=2D7A557189B5D2B4B40EAC6869C6F2442879A615