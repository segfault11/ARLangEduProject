//------------------------------------------------------------------------------
uniform float frameAspect;
attribute vec2 pos;
varying highp vec2 tc;
uniform int numFrames;
uniform int curFrame;
uniform mat4 P;
uniform mat4 V;
uniform mat4 R;
uniform float size;
uniform vec3 translation;
//------------------------------------------------------------------------------
void main()
{
    gl_PointSize = 10.0;
    
    tc.x = (pos.x + 1.0)/(2.0*float(numFrames)) +
        float(curFrame)/float(numFrames);
    tc.y = 1.0 - (pos.y + 1.0)/2.0;
    
    highp float x = 0.5*pos.x*frameAspect;
    highp float y = 0.5*pos.y;

    highp vec4 h = R*vec4(
            size*pos.x,
            0.0,
            size*pos.y,
            1.0
        );
    
    h.x += translation.x;
    h.y += translation.y;
    h.z += translation.z;
    
    h = P*V*h;
    
    gl_Position = vec4(h.y, -h.x, h.z, h.w);
}
//------------------------------------------------------------------------------