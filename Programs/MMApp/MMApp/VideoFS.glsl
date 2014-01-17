//------------------------------------------------------------------------------
varying highp vec2 tc;
uniform sampler2D luminance;
uniform sampler2D chrominance;
//------------------------------------------------------------------------------
void main()
{
    
    highp float Y = texture2D(luminance, tc).r;
    highp float Cb = texture2D(chrominance, tc).r;
    highp float Cr = texture2D(chrominance, tc).g;
    
    Y *= 255.0;
    Cb *= 255.0;
    Cr *= 255.0;
    
    highp float r = Y + 1.402*(Cr - 128.0);
    highp float g = Y - 0.34414*(Cb - 128.0) - 0.71414*(Cr - 128.0);
    highp float b = Y + 1.772*(Cb - 128.0);
    
    gl_FragColor = 1.0/255.0*vec4(r, g, b, 255.0);
}
//------------------------------------------------------------------------------