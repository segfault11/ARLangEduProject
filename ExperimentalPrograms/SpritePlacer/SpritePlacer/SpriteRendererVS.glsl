//------------------------------------------------------------------------------
uniform float frameAspect;
attribute vec2 pos;
varying highp vec2 tc;
uniform int numFrames;
uniform int curFrame;
uniform mat4 P;
uniform mat4 V;
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

    highp vec4 h = P*V*vec4(
            size*pos.x + translation.x,
            translation.z,
            size*pos.y + translation.y,
            1.0
        );
    
    gl_Position = vec4(h.y, -h.x, h.z, h.w);
}
//------------------------------------------------------------------------------