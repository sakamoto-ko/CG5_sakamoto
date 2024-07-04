Shader "Unlit/08_GaussianBlur"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed Gaussian(float2 drawUV, float2 pickUV, float sigma)
            {
                float d = distance(drawUV,pickUV);
                return exp(-(d*d)/(2*sigma*sigma));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float totalWeight = 0, _Sigma = 0.005, _StepWidth = 0.001;

                fixed4 col = fixed4(0,0,0,0);
                float num=0;

                [loop]
                for(fixed py=-_Sigma*2;py<=_Sigma*2;py+=_StepWidth)
                {
                    [loop]
                    for(fixed px=-_Sigma*2;px<=_Sigma*2;px+=_StepWidth)
                    {
                        float2 pickUV=i.uv+float2(px,py);
                        fixed weight = Gaussian(i.uv,pickUV,_Sigma);
                        col+=tex2D(_MainTex,pickUV)*weight;
                        totalWeight+=weight;
                    }
                }
                
                col.rgb=col.rgb/totalWeight;
                col.a=1;

                return col;
            }
            ENDCG
        }
    }
}
