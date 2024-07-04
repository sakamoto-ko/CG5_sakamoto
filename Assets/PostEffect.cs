using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffect : MonoBehaviour
{
    public Shader grayScaleShader;
    public Shader gaussianBlurShader;
    public Shader bloomShader;
    public Shader crossFilterShader;
    private Material grayScaleMat;
    private Material gaussianBlurMat;
    private Material bloomBlurMat;
    private Material crossFilterMat;

    private void Awake()
    {
        grayScaleMat = new Material(grayScaleShader);
        gaussianBlurMat = new Material(gaussianBlurShader);
        bloomBlurMat = new Material(bloomShader);
        crossFilterMat = new Material(crossFilterShader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CameraScript.count == 0)
        {
            //GrayScale
            Graphics.Blit(source, destination, grayScaleMat);

        }
        else if (CameraScript.count == 1)
        {
            //GaussianBlur
            RenderTexture buf1 = RenderTexture.GetTemporary(source.width / 2, source.height / 2, 0, source.format);
            RenderTexture buf2 = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
            RenderTexture buf3 = RenderTexture.GetTemporary(source.width / 8, source.height / 8, 0, source.format);

            RenderTexture blurTex = RenderTexture.GetTemporary(buf3.width, buf3.height, 0, buf3.format);

            Graphics.Blit(source, buf1);
            Graphics.Blit(buf1, buf2);
            Graphics.Blit(buf2, buf3);

            Graphics.Blit(buf2, blurTex, gaussianBlurMat);

            Graphics.Blit(buf3, buf2);
            Graphics.Blit(buf2, buf1);
            Graphics.Blit(buf1, destination);

            RenderTexture.ReleaseTemporary(buf1);
            RenderTexture.ReleaseTemporary(buf2);
            RenderTexture.ReleaseTemporary(buf3);

        }
        else if (CameraScript.count == 2)
        {
            //Bloom
            RenderTexture highLumiTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            RenderTexture bloomBlurTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

            Graphics.Blit(source, highLumiTex, bloomBlurMat, 0);
            Graphics.Blit(highLumiTex, bloomBlurTex, bloomBlurMat, 1);
            bloomBlurMat.SetTexture("_HighLumi", bloomBlurTex);
            Graphics.Blit(source, destination, bloomBlurMat, 2);

            RenderTexture.ReleaseTemporary(highLumiTex);
            RenderTexture.ReleaseTemporary(bloomBlurTex);
        }
        else if (CameraScript.count == 3)
        {

            //CrossFilter
            RenderTexture crossHighLumiTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            RenderTexture blurTex0 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            RenderTexture blurTex1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            RenderTexture buffTex = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

            Graphics.Blit(source, crossHighLumiTex, crossFilterMat, 0);
            crossFilterMat.SetFloat("_AngleDeg", 45);
            Graphics.Blit(crossHighLumiTex, blurTex0, crossFilterMat, 1);

            crossFilterMat.SetFloat("_AngleDeg", 135);
            Graphics.Blit(crossHighLumiTex, blurTex1, crossFilterMat, 1);

            crossFilterMat.SetTexture("_BlurTex", blurTex0);
            Graphics.Blit(source, buffTex, crossFilterMat, 2);

            crossFilterMat.SetTexture("_BlurTex", blurTex1);
            Graphics.Blit(buffTex, destination, crossFilterMat, 2);

            RenderTexture.ReleaseTemporary(crossHighLumiTex);
            RenderTexture.ReleaseTemporary(blurTex0);
            RenderTexture.ReleaseTemporary(blurTex1);
            RenderTexture.ReleaseTemporary(buffTex);

        }
        else
        {
            CameraScript.count = 0;
        }
    }
}
