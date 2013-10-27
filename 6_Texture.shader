Shader "unityCookie/tut/Beginner/6 Texture Map" {
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_SpecColor ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1,10.0)) = 3.0
		
	}

	SubShader {
		
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			
			CGPROGRAM
				//pragmas
				#pragma vertex vert
				#pragma fragment frag
				#pragma exclude_renderers flash
				
				//user defined variables
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
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
					float4 texcoord:TEXCOORD0;
				
				};
				
				struct vertexOutput {
					float4 pos:SV_POSITION;
					float4 tex: TEXCOORD0;
					float4 posWorld:TEXCOORD1;
					float3 normalDir:TEXCOORD2;
					
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.posWorld = mul(_Object2World, vi.vertex);
					o.normalDir = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					return o;
					
					
				}
				
				float4 frag(vertexOutput vo): COLOR
				{
					//vectors
					float3 normalDirection = vo.normalDir;
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - vo.posWorld.xyz);
					float atten;
					float3 lightDirection;
					
					if(_WorldSpaceLightPos0.w == 0.0){	//directional lights
						atten = 1.0;
						lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					
					} else {
						float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vo.posWorld.xyz;
						float distance = length(fragmentToLightSource);
						atten = 1.0/distance;
						lightDirection = normalize(fragmentToLightSource);
					}
					
					//lighting
					
					float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
					
					//rim lighting
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
					float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb; 	
					
					float4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					
					return float4(tex.xyz * lightFinal * _Color.xyz, 1.0);
				
				
				}
				
			ENDCG
		
		}
		
		
		Pass {
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
				//pragmas
				#pragma vertex vert
				#pragma fragment frag
				#pragma exclude_renderers flash
				
				//user defined variables
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
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
					float4 texcoord:TEXCOORD0;
				
				};
				
				struct vertexOutput {
					float4 pos:SV_POSITION;
					float4 tex: TEXCOORD0;
					float4 posWorld:TEXCOORD1;
					float3 normalDir:TEXCOORD2;
					
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.posWorld = mul(_Object2World, vi.vertex);
					o.normalDir = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					return o;
					
					
				}
				
				float4 frag(vertexOutput vo): COLOR
				{
					//vectors
					float3 normalDirection = vo.normalDir;
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - vo.posWorld.xyz);
					float atten;
					float3 lightDirection;
					
					if(_WorldSpaceLightPos0.w == 0.0){	//directional lights
						atten = 1.0;
						lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					
					} else {
						float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vo.posWorld.xyz;
						float distance = length(fragmentToLightSource);
						atten = 1.0/distance;
						lightDirection = normalize(fragmentToLightSource);
					}
					
					//lighting
					
					float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
					
					//rim lighting
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
					float3 lightFinal = rimLighting + diffuseReflection + specularReflection; 	
					
					float4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					
					return float4(tex.xyz * lightFinal * _Color.xyz, 1.0);
				
				
				}
				
			ENDCG
		
		}
	
		
	}

}
