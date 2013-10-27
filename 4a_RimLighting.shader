Shader "unityCookie/tut/Beginner/4a_RimLighting" {
	Properties {
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", float) = 10
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1,10.0)) = 3.0
	}

	SubShader {
		Tags {"LightMode" = "ForwardBase"}
		
		Pass {
			CGPROGRAM
				//pragmas
				#pragma vertex vert
				#pragma fragment frag
				
				//user defined variables
				uniform float4 _Color;
				uniform float4 _SpecColor;
				uniform float4 _RimColor;
				uniform float _Shininess;
				uniform float _RimPower;
				
				//unity defined variables
				uniform float4 _LightColor0;
				
				//structs
				struct vertexInput {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
				
				};
				
				struct vertexOutput {
					float4 pos:SV_POSITION;
					float4 posWorld:TEXCOORD0;
					float3 normalDir:TEXCOORD1;
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.posWorld = mul(_Object2World, vi.vertex);
					o.normalDir = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					return o;
					
					
				}
				
				float4 frag(vertexOutput vo): COLOR
				{
					//vectors
					float3 normalDirection = vo.normalDir;
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - vo.posWorld.xyz);
					float atten = 1.0;
					
					//lighting
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
					float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb; 	
					
					return float4(lightFinal * _Color.rgb, 1.0);
				
				
				}
				
			ENDCG
		
		}
		
	}

}
