"													\n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
													\n\
#ifdef GL_ES										\n\
varying mediump vec2 v_texCoord;					\n\
#else												\n\
varying vec2 v_texCoord;							\n\
#endif												\n\
													\n\
void main()											\n\
{													\n\
    gl_Position = CC_MVPMatrix * a_position;		\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
";
