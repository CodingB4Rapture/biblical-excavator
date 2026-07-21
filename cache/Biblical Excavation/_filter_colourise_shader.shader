//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, 0.0, 1.0);
    gl_Position = object_space_pos;
        
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform vec2 gm_pSurfaceDimensions;
uniform float gm_pPreMultiplyAlpha;
uniform float g_Intensity;
uniform vec4 g_TintCol;

float YUVval(vec4 _rgb)
{
	return dot(vec3(0.299, 0.587, 0.114), _rgb.rgb);
}

void main()
{
	// Cheap colourisation effect		
	vec4 texcol = texture2D( gm_BaseTexture, v_vTexcoord);
	if (gm_pPreMultiplyAlpha > 0.0)
	{
		texcol.a += 0.001;
		texcol.rgb /= texcol.a;
	}
	
	float tintval = YUVval(g_TintCol);
	float texval = YUVval(texcol);
	
	vec4 outcol;
	if (texval < tintval)
	{
		outcol = mix(vec4(0.0, 0.0, 0.0, 1.0), g_TintCol, texval / tintval);
	}
	else if (texval < 1.0)
	{
		outcol = mix(g_TintCol, vec4(1.0, 1.0, 1.0, 1.0), (texval - tintval) / (1.0 - tintval));
	}
	else
	{
		outcol = vec4(1.0, 1.0, 1.0, 1.0);	
	}

	if (gm_pPreMultiplyAlpha > 0.0)
	{		
		outcol.rgb *= texcol.a;
		texcol.a -= 0.001;
	}
	
	outcol.a = texcol.a;	
	
	gl_FragColor = mix(texcol, outcol, g_Intensity);
}

