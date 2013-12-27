//------------------------------------------------------------------------------
uniform float frameAspect;
attribute vec2 pos;
varying highp vec2 tc;
uniform int numFrames;
uniform int curFrame;
//------------------------------------------------------------------------------
void main()
{
    gl_PointSize = 10.0;
    
    tc.x = (pos.x + 1.0)/(2.0*float(numFrames))+ float(curFrame)/float(numFrames);
    tc.y = 1.0 - (pos.y + 1.0)/2.0;
    
    highp float x = 0.5*pos.x*frameAspect;
    highp float y = 0.5*pos.y;
    
    gl_Position = vec4(x, y, 0.0, 1.0);
}
//------------------------------------------------------------------------------