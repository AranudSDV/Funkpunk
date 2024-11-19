using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Render.Universal;


public class cs_CustomPostProcessPass : ScriptableRenderPass
{
    private Material m_bloomMaterial;
    private Material m_compositeMaterial;

    // from bloom Package
    const int k_MaxPyramidSize = 16;
    private int[] _BloomMipUp;
    private int[] _BloomMipDown;
    private RTHandle[] m_bloomMipUp;
    private RTHandle[] m_bloomMipDown;
    private GraphicsFormat hdrFormat;



    public cs_CustomPostProcessPass(Material bloomMaterial, Material compositeMaterial)
    {
        m_bloomMaterial = bloomMaterial;
        m_compositeMaterial = compositeMaterial;

        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;


    }




    

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {

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
}
