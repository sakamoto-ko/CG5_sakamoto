Shader "Unlit/CrossShader"
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
            sampler2D _BlurTex;
            float4 _BlurTex_ST;
            
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
            
            float _AngleDeg;
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
                float totalWeight = 0;
                float4 color = fixed4(0,0,0,0);
                float2 pickUV = float2(0,0);
                float pickRange = 0.06;
                float angleRad = _AngleDeg * 3.14159 / 180;

                [loop]
                for(fixed j = -pickRange; j <= pickRange; j += 0.005)
                {
                    float x = cos(angleRad) * j;
                    float y = sin(angleRad) * j;
                    pickUV = i.uv + float2(x,y);

                    fixed weight = Gaussian(i.uv,pickUV,pickRange);
                    color += tex2D(_MainTex,pickUV)*weight;
                    totalWeight += weight;
                }
                
                color = color / totalWeight;

                return color;
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv) + tex2D(_BlurTex, i.uv);

                return col;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 st = i.uv / _ScreenParams.x * 20;
                st = frac(st * _ScreenParams.xy);
                fixed l = distance(st, fixed2(0.5,0.5));
                return fixed4(1,1,1,1) * 1 - step(0.3,l);
            }
            ENDCG
        }

    }
}