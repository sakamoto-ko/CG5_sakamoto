Shader"Unlit/12_Dissolve"
{
    Properties
    {
        _MaskTex ("Texture", 2D) = "black" {}
        _Dissolve ("dissolve", Range (0.0, 1.0)) = 0.3
    }
    SubShader
    {
        Tags{
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        CGINCLUDE
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

        sampler2D _MaskTex;
        float4 _MaskTex_ST;
        float _Dissolve;

        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }
        ENDCG

        Pass
        {
            Cull front
            CGPROGRAM

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex, i.uv);
                clip(mask.r - _Dissolve);
                return fixed4(0,1,1,1);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex, i.uv);
                clip(mask.r - _Dissolve);
                return mask;
            }
            ENDCG
        }
    }
}
