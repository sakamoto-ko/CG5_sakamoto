Shader"Unlit/11_TransparencyMask"
{
    Properties
    {
        _MainTex (" MainTexture", 2D) = "white" {}
        _MaskTex (" MaskTexture", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

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
        sampler2D _MaskTex;
        float4 _MainTex_ST;
                    
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

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
            CGPROGRAM
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv);
                
                clip(0.5 - mask.r);

                return col;
            }
            ENDCG
        }       
    }
}