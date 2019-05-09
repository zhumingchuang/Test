// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//参考文档：https://blog.csdn.net/wanghaodiablo/article/details/52103132

Shader "My/SpriteCircleFill"
{
   Properties
   {
   	[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
   	_Color("Tint", Color) = (1,1,1,1)
   	[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
   	_Fill("Fill",Range(0,1)) = 0
   }

   	SubShader
   	{
   		Tags
   		{
   			"Queue" = "Transparent"
   			"IgnoreProjector" = "True"
   			"RenderType" = "Transparent"
   			"PreviewType" = "Plane"
   			"CanUseSpriteAtlas" = "True"
   		}

   		Cull Off
   		Lighting Off
   		ZWrite Off
   		Fog {Mode Off}
   		Blend SrcAlpha OneMinusSrcAlpha

   		Pass{
   		CGPROGRAM
   		#pragma vertex vert		 
   		#pragma fragment frag	
   		#pragma multi_compile DUMMY PIXELSNAP_ON
   		 #include "UnitySprites.cginc"
   		//#include "UnityCG.cginc"

   		/*
   	   struct appdata_t
   	   {
   		   float4 vertex:POSITION;
   		   float4 color:COLOR;
   		   float2 texcoord:TEXCOORD0;
   	   };
   	   */

   	   /*
   	  struct v2f
   	  {
   		  float4 vertex:SV_POSITION;
   		  fixed4 color:COLOR;
   		  half2 texcoord:TEXCOORD0;
   	  };
   	  */

   	  /*fixed4 _Color;*/


   	  /*sampler2D _MainTex;*/

     //很是奇怪，上述的都要注释，否则报错：重定义
     //但是 _Fill又不能注释，否则报错:未定义
     //补充：找到原因了，  #include "UnitySprites.cginc" 中应该已经定义了上述参数
   	  float _Fill;


   	  v2f vert(appdata_t IN)
   	  {
   		  v2f OUT;
   		  OUT.vertex = UnityObjectToClipPos(IN.vertex);
   		  OUT.texcoord = IN.texcoord;
   		  OUT.color = IN.color*_Color;
   		  #ifdef PIXELSNAP_ON
   		  OUT.vertex = UnityPixelSnap(OUT.vertex);
   		  #endif
   		  return OUT;
   	  }


   	  fixed4 frag(v2f IN) :COLOR
   	  {
   		  fixed4 result = tex2D(_MainTex,IN.texcoord)*IN.color;
   		  fixed2 p = fixed2(IN.texcoord.x - 0.5,IN.texcoord.y - 0.5);

   		  if (_Fill < 0.5)
   		  {
   			  float compare = (_Fill * 2 - 0.5)*3.1415926;
   			  float theta = atan(p.y / p.x);
   			  if (theta > compare)
   			  {
   				  result.a = 0;
   			  }
   			  if (p.x > 0)
   			  {
   			  result.a = 0;
   			  }
   		  }
   		  else
   		  {
   			  float compare = ((_Fill - 0.5) * 2 - 0.5)*3.1415926;
   			  float theta = atan(p.y / p.x);
   			  if (p.x > 0)
   			  {
   				  if (theta > compare)
   				  {
   				  result.a = 0;
   				  }
   			  }
   		  }
   		  return result;
   	  }
   	  ENDCG
   	  }
   	}
   		Fallback "Transparent/VertexLit"
}
