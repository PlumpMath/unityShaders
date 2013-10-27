Shader "unityCookie/tut/Beginner/8a Gloss Map" {
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(-2.0, 2.0)) = 1
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
				uniform sampler2D _BumpMap;
				uniform float4 _BumpMap_ST;
				uniform float4 _Color;
				uniform float4 _SpecColor;
				uniform float4 _RimColor;
				uniform float _Shininess;
				uniform float _RimPower;
				uniform float _BumpDepth;
				
				
				//unity defined variables
				uniform float4 _LightColor0;
				
				//structs
				struct vertexInput {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
					float4 tangent:TANGENT;
				
				};
				
				struct vertexOutput {
					float4 pos:SV_POSITION;
					float4 tex: TEXCOORD0;
					float4 posWorld:TEXCOORD1;
					float3 normalWorld:TEXCOORD2;
					float3 tangentWorld:TEXCOORD3;
					float3 binormalWorld:TEXCOORD4;
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.normalWorld = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.tangentWorld = normalize(mul(_Object2World, vi.tangent).xyz);
					o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * vi.tangent.w);
					
					o.posWorld = mul(_Object2World, vi.vertex);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					return o;
					
					
				}
				
				float4 frag(vertexOutput vo): COLOR
				{
					//vectors
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
					
					//texture maps
					float4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					float4 texN = tex2D(_BumpMap, vo.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
					
					//unpackNormal function
					float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
					localCoords.z = _BumpDepth;
					//localCoord.z = 1.0;
					//localCoord.z = 1.0 - 0.5 * dot(localCoords, localCoords);
				
					//normal transpose matrix
					float3x3 local2WorldTranspose = float3x3(vo.tangentWorld, vo.binormalWorld, vo.normalWorld);
					
					//calculate normal directions
					float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
					
					//lighting
					float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
					
					//rim lighting
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
					float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT + rimLighting + diffuseReflection + (specularReflection * tex.a); 	
					
					 
					
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
				uniform sampler2D _BumpMap;
				uniform float4 _BumpMap_ST;
				uniform float4 _Color;
				uniform float4 _SpecColor;
				uniform float4 _RimColor;
				uniform float _Shininess;
				uniform float _RimPower;
				uniform float _BumpDepth;
				
				
				//unity defined variables
				uniform float4 _LightColor0;
				
				//structs
				struct vertexInput {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
					float4 tangent:TANGENT;
				
				};
				
				struct vertexOutput {
					float4 pos:SV_POSITION;
					float4 tex: TEXCOORD0;
					float4 posWorld:TEXCOORD1;
					float3 normalWorld:TEXCOORD2;
					float3 tangentWorld:TEXCOORD3;
					float3 binormalWorld:TEXCOORD4;
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.normalWorld = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.tangentWorld = normalize(mul(_Object2World, vi.tangent).xyz);
					o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * vi.tangent.w);
					
					o.posWorld = mul(_Object2World, vi.vertex);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					return o;
					
					
				}
				
				float4 frag(vertexOutput vo): COLOR
				{
					//vectors
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
					
					//texture maps
					float4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					float4 texN = tex2D(_BumpMap, vo.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
					
					//unpackNormal function
					float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
					localCoords.z = _BumpDepth;
					//localCoord.z = 1.0;
					//localCoord.z = 1.0 - 0.5 * dot(localCoords, localCoords);
				
					//normal transpose matrix
					float3x3 local2WorldTranspose = float3x3(vo.tangentWorld, vo.binormalWorld, vo.normalWorld);
					
					//calculate normal directions
					float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
					
					//lighting
					float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
					
					//rim lighting
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
					float3 lightFinal = rimLighting + diffuseReflection + (specularReflection * tex.a); 	
					
					
					
					return float4(lightFinal * _Color.xyz, 1.0);
				
				
				}
				
			ENDCG
		
		}
		
		
	}

}
