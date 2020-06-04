Shader "Custom/FakeLambert_Rim"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_AmbientColor("Ambient Color", Color) = (1,1,1,1)
		_LightWorldDirection("Light World Direction", Vector) = (0.3, 1, 0.3, 1)
		_LightColor("Light Color", Color) = (1,1,1,1)
		_LightIntensity("Light Intensity", Range(0, 10)) = 1
		//_LightCutoff("Light Cutoff", Range(0, 1)) = 0.5
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimIntensity("Rim Intensity", Range(0, 5)) = 1
		//_RimCutoff("Rim Cutoff", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }
		
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			fixed4 _AmbientColor;

			fixed4 _RimColor;
			float _RimIntensity;
			//float _RimCutoff;

			float3 _LightWorldDirection;
			fixed4 _LightColor;
			float _LightIntensity;
			//float _LightCutoff;

			struct v2f
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 normal : NORMAL;
			};

			v2f vert(appdata_full i)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(i.vertex);
				o.texcoord = i.texcoord;
				o.viewDir = ObjSpaceViewDir(i.vertex);
				o.normal = i.normal;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				fixed4 c = tex * _Color;

				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				float3 lightDir = mul(unity_WorldToObject, normalize(_LightWorldDirection));

				// Fake light
				float ldn = dot(lightDir, normal);
				fixed3 lightColor = _LightColor.rgb * _LightIntensity;
				fixed3 shadedColor = c.rgb * _AmbientColor;
				fixed3 litColor = (c.rgb * _AmbientColor) + (c.rgb * lightColor);
				float light = saturate(ldn);
				c.rgb = lerp(shadedColor, litColor, light);

				// Rim
				float vdn = dot(viewDir, normal);
				float rim = min((1 - saturate(vdn)) * _RimIntensity, 1);
				c.rgb = lerp(c.rgb, _RimColor.rgb, rim);

				return c;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
