Shader "unityCookie/tut/Beginner/9 - Optimized" {
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_EmitMap ("Emission Texture", 2D) = "black" {}
		_BumpDepth ("Bump Depth", Range(0.0, 1.0)) = 0.5
		_SpecColor ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1,10.0)) = 3.0
		_EmitStrength ("Emit Strength", Range(0, 2.0)) = 0
		
	}

	SubShader {
		
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
				//pragmas
				#pragma vertex vert
				#pragma fragment frag
			//	#pragma exclude_renderers flash
				
				//user defined variables
				uniform sampler2D _MainTex;
				uniform half4 _MainTex_ST;
				uniform sampler2D _BumpMap;
				uniform half4 _BumpMap_ST;
				uniform sampler2D _EmitMap;
				uniform half4 _EmitMap_ST;
				uniform fixed4 _Color;
				uniform fixed4 _SpecColor;
				uniform fixed4 _RimColor;
				uniform half _Shininess;
				uniform half _RimPower;
				uniform fixed _BumpDepth;
				uniform fixed _EmitStrength;
				
				
				//unity defined variables
				uniform half4 _LightColor0;
				
				//structs
				struct vertexInput {
					half4 vertex:POSITION;
					half3 normal:NORMAL;
					half4 texcoord:TEXCOORD0;
					half4 tangent:TANGENT;
				
				};
				
				struct vertexOutput {
					half4 pos:SV_POSITION;
					half4 tex: TEXCOORD0;
					half4 lightDirection:TEXCOORD1;
					fixed3 viewDirection:TEXCOORD2;
					fixed3 normalWorld:TEXCOORD3;
					fixed3 tangentWorld:TEXCOORD4;
					fixed3 binormalWorld:TEXCOORD5;
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.normalWorld = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.tangentWorld = normalize(mul(_Object2World, vi.tangent).xyz);
					o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * vi.tangent.w);
					
					half4 posWorld = mul(_Object2World, vi.vertex);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					
					//vectors
					o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
					half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
	
	
					o.lightDirection = fixed4(
						normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
						lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
					);
					
					return o;
					
					
				}
				
				fixed4 frag(vertexOutput vo): COLOR
				{
					
					//texture maps
					fixed4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					fixed4 texN = tex2D(_BumpMap, vo.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
					fixed4 texE = tex2D(_EmitMap, vo.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw);
					
					//unpackNormal function
					fixed3 localCoords = fixed3(2.0 * texN.ag - float2(1.0,1.0), _BumpDepth);
					//localCoords.z = _BumpDepth;
					//localCoord.z = 1.0;
					//localCoord.z = 1.0 - 0.5 * dot(localCoords, localCoords);
				
					//normal transpose matrix
					half3x3 local2WorldTranspose = fixed3x3(vo.tangentWorld, vo.binormalWorld, vo.normalWorld);
					
					//calculate normal directions
					fixed3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
					
					//nDotL
					fixed nDotL = saturate(dot(normalDirection, vo.lightDirection.xyz));
					
					//lighting
					fixed3 diffuseReflection = vo.lightDirection.w * _LightColor0.xyz * nDotL;
					fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow(saturate(dot(reflect(-vo.lightDirection.xyz, normalDirection), vo.viewDirection)), _Shininess);
					
					//rim lighting
					fixed rim = 1 - nDotL;
					fixed3 rimLighting = nDotL *  _RimColor.xyz * _LightColor0.xyz  * pow(rim, _RimPower);
					
					float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + rimLighting + diffuseReflection + (specularReflection * tex.a) + (texE.xyz * _EmitStrength); 	
					
					 
					
					return fixed4(tex.xyz * lightFinal * _Color.xyz, 1.0);
				
				
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
			//	#pragma exclude_renderers flash
				
				//user defined variables
				uniform sampler2D _MainTex;
				uniform half4 _MainTex_ST;
				uniform sampler2D _BumpMap;
				uniform half4 _BumpMap_ST;
				uniform sampler2D _EmitMap;
				uniform half4 _EmitMap_ST;
				uniform fixed4 _Color;
				uniform fixed4 _SpecColor;
				uniform fixed4 _RimColor;
				uniform half _Shininess;
				uniform half _RimPower;
				uniform fixed _BumpDepth;
				uniform fixed _EmitStrength;
				
				
				//unity defined variables
				uniform half4 _LightColor0;
				
				//structs
				struct vertexInput {
					half4 vertex:POSITION;
					half3 normal:NORMAL;
					half4 texcoord:TEXCOORD0;
					half4 tangent:TANGENT;
				
				};
				
				struct vertexOutput {
					half4 pos:SV_POSITION;
					half4 tex: TEXCOORD0;
					half4 lightDirection:TEXCOORD1;
					fixed3 viewDirection:TEXCOORD2;
					fixed3 normalWorld:TEXCOORD3;
					fixed3 tangentWorld:TEXCOORD4;
					fixed3 binormalWorld:TEXCOORD5;
				};
				
				vertexOutput vert(vertexInput vi)
				{
					vertexOutput o;
					
					o.normalWorld = normalize(mul(float4(vi.normal,0.0), _World2Object).xyz);
					o.tangentWorld = normalize(mul(_Object2World, vi.tangent).xyz);
					o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * vi.tangent.w);
					
					half4 posWorld = mul(_Object2World, vi.vertex);
					o.pos = mul(UNITY_MATRIX_MVP, vi.vertex);
					o.tex = vi.texcoord;
					
					//vectors
					o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
					half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
	
	
					o.lightDirection = fixed4(
						normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
						lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
					);
					
					return o;
					
					
				}
				
				fixed4 frag(vertexOutput vo): COLOR
				{
					
					//texture maps
					fixed4 tex = tex2D(_MainTex, vo.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
					fixed4 texN = tex2D(_BumpMap, vo.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
					
					//unpackNormal function
					fixed3 localCoords = fixed3(2.0 * texN.ag - float2(1.0,1.0), _BumpDepth);
					//localCoords.z = _BumpDepth;
					//localCoord.z = 1.0;
					//localCoord.z = 1.0 - 0.5 * dot(localCoords, localCoords);
				
					//normal transpose matrix
					half3x3 local2WorldTranspose = fixed3x3(vo.tangentWorld, vo.binormalWorld, vo.normalWorld);
					
					//calculate normal directions
					fixed3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
					
					//nDotL
					fixed nDotL = saturate(dot(normalDirection, vo.lightDirection.xyz));
					
					//lighting
					fixed3 diffuseReflection = vo.lightDirection.w * _LightColor0.xyz * nDotL;
					fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow(saturate(dot(reflect(-vo.lightDirection.xyz, normalDirection), vo.viewDirection)), _Shininess);
					
					//rim lighting
					fixed rim = 1 - nDotL;
					fixed3 rimLighting = nDotL *  _RimColor.xyz * _LightColor0.xyz  * pow(rim, _RimPower);
					
					fixed3 lightFinal = rimLighting + diffuseReflection + (specularReflection * tex.a); 	
					
					 
					
					return fixed4( lightFinal, 1.0);
				
				
				}
				
			ENDCG
		
		}
			
		
	}

}
