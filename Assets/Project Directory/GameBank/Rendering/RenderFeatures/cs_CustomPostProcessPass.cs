
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering.Universal;

public class cs_CustomPostProcessPass : ScriptableRenderPass
{
    private Material m_bloomMaterial;
    private Material m_compositeMaterial;

    // from bloom Package
    const int k_MaxPyramidSize = 16;
    private int[] _BloomMipUp;
    private int[] _BloomMipDown;
    private RTHandle[] m_BloomMipUp;
    private RTHandle[] m_BloomMipDown;
    private GraphicsFormat hdrFormat;



    public cs_CustomPostProcessPass(Material bloomMaterial, Material compositeMaterial)
    {
        m_bloomMaterial = bloomMaterial;
        m_compositeMaterial = compositeMaterial;

        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        _BloomMipUp = new int[k_MaxPyramidSize];
        _BloomMipDown = new int[k_MaxPyramidSize];

        m_BloomMipUp = new RTHandle[k_MaxPyramidSize];
        m_BloomMipDown = new RTHandle[k_MaxPyramidSize];
        
        for (int i = 0; i < k_MaxPyramidSize; i++)
        {
            _BloomMipUp[i] = Shader.PropertyToID("_BloomMipUp" + 1);
            _BloomMipDown[i] = Shader.PropertyToID("_BloomMipDown" + 1);

            m_BloomMipUp[i] = RTHandles.Alloc(_BloomMipUp[i], name: "_BloomMipUp"+ 1);
            m_BloomMipDown[i] = RTHandles.Alloc(_BloomMipDown[i], name: "_BloomMipDown"+ 1);
        }

        const FormatUsage usage = FormatUsage.Linear | FormatUsage.Render;
        if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, usage)) //HDR fallback
        {
            hdrFormat = GraphicsFormat.B10G11R11_UFloatPack32;
        }
        else{
            hdrFormat = QualitySettings.activeColorSpace = ColorSpace.Linear
            ? GraphicsFormat.R8G8B8A8_SRGB
            : GraphicsFormat.R8G8B8A8_UNorm;
        }
    }   
    

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)  
    {
        VolumeStack stack = VolumeManager.instance.stack;
        m_BloomEffect = stack.GetComponent<HijackBloomComponent>();

        CommandBuffer cmd = CommandBufferPool.Get();

        using (new ProfilingScope(cmd, new ProfilingSampler("Custom Post Process Effects")))
        {
            // Do bloom pass here
            SetupBloom(cmd, m_CameraColorTarget);
        }
    }



    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        m_Descriptor = renderingData.cameraData.cameraTargetDescriptor;
    }

    public void SetTarget(RTHandle cameraColorTargetHandle, RTHandle cameraDepthTargetHandle)
    {
        m_CameraColorTarget = cameraColorTargetHandle;
        m_CameraDepthTarget = cameraDepthTargetHandle;
    }




    public void SetupBloom(CommandBuffer cmd, RTHandle source)
    {
        //Start at halfres
        int downres = 1;
        int iTexWidth = m_Descriptor.width >> downres;
        int iTexHeight = m_Descriptor.height >> downres;

        // determine iterations count
        int iMaxSize = Mathf.Max(iTexWidth, iTexHeight);
        int iIterations = Mathf.FloorToInt(Mathf.Log(iMaxSize, 2f) -1);
        int iMipCount = Mathf.Clamp(iIterations, 1, m_BloomEffect.maxIterations.value);

        // Param prefilters
        float clamp = m_BloomEffect.clamp.value;
        float threshold = Mathf.GammaToLinearSpace(m_BloomEffect.threshold.value);
        float thresholdKnee = threshold * 0.5f; // Hardcoded

        //Mat setup
        float scatter = Mathf.Lerp(0.05f, 0.95f, m_BloomEffect.treshold.value);
        var bloomMaterial = m_bloomMaterial;

        bloomMaterial.SetVector("_Params", new Vector4(scatter, clamp, threshold, thresholdKnee));

        //prefilter
        var desc = GetCompatibleDescriptor(iTexWidth, iTexHeight, hdrFormat);
        for (int i = 0; i < iMipCount; i++)
        {
            RenderingUtils.ReAllocateIfNeeded(ref m_BloomMipUp[i], desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: m_BloomMipUp[i].name);
            RenderingUtils.ReAllocateIfNeeded(ref m_BloomMipDown[i], desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: m_BloomMipDown[i].name).

            desc.width = Mathf.Max(1, desc.width >> 1);
            desc.height = Mathf.Max(1, desc.height >> 1);
        
        }
    
        Blitter.BlitCameraTexture(cmd, source, m_BloomMipDown[0], RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store, bloomMaterial, 0);

    }
}
