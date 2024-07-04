Shader "Unlit/BloomShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
    }
    SubShader
    {
        CGINCLUDE
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
            sampler2D _HighLumi;
            float4 _HighLumi_ST;
            
            fixed Gaussian(float2 drawUV, float2 pickUV, float sigma)
            {
                float d = distance(drawUV,pickUV);
                return exp(-(d*d)/(2*sigma*sigma));
            }
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
        ENDCG

        Pass
        {
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                fixed grayScale=col.r*0.299+col.g*0.587+col.b*0.114;
                fixed extract = smoothstep(0.6,0.9,grayScale);
                return col*extract; 
            }
            ENDCG
        }

        Pass{
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                float totalWeight = 0, _Sigma = 0.005, _StepWidth = 0.001;

                fixed4 col = fixed4(0,0,0,0);

                for(fixed py=-_Sigma*2;py<=_Sigma*2;py+=_StepWidth)
                {
                    for(fixed px=-_Sigma*2;px<=_Sigma*2;px+=_StepWidth)
                    {
                        float2 pickUV=i.uv+float2(px,py);
                        fixed weight = Gaussian(i.uv,pickUV,_Sigma);
                        col+=tex2D(_MainTex,pickUV)*weight;
                        totalWeight+=weight;
                    }
                }
                
                col.rgb=col.rgb/totalWeight;

                return col;
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                fixed4 highlight = tex2D(_HighLumi,i.uv);

                return col + highlight;
            }
            ENDCG
        }

    }
}