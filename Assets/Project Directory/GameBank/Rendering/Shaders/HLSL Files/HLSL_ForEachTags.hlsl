float4 ForEachGraffiti(float2 uv, int NumGraffiti)
{
    float4 col = float4(0, 0, 0, 0);
    for (int i = 0; i < NumGraffiti; i++)
    {
        float4 p = _GraffitiParams[i]; // Global Array Node
        float2 uvT = TransformUV(uv, 0.5, p.x, p.y, p.zw);
        col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvT);
    }
    return col;
}