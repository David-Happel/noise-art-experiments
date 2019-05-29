import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class tresholdRain extends PApplet {

int[][] result;
float t, c;

public float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

public float ease(float p, float g) {
  if (p < 0.5f)
    return 0.5f * pow(2*p, g);
  else
    return 1 - 0.5f * pow(2*(1 - p), g);
}

float mn = .5f*sqrt(3), ia = atan(sqrt(.5f));

public void push() {
  pushMatrix();
  pushStyle();
}

public void pop() {
  popStyle();
  popMatrix();
}

public void draw() {

  if (!recording) {
    t = mouseX*1.0f/width;
    c = mouseY*1.0f/height;
    if (mousePressed)
      println(c);
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 |
        PApplet.parseInt(result[i][0]*1.0f/samplesPerFrame) << 16 |
        PApplet.parseInt(result[i][1]*1.0f/samplesPerFrame) << 8 |
        PApplet.parseInt(result[i][2]*1.0f/samplesPerFrame);
    updatePixels();

    saveFrame("output/fr###.png");
    println(frameCount,"/",numFrames);
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////

int samplesPerFrame = 1;
int numFrames = 170;
float shutterAngle = 0.7f;

boolean recording = true;

public float field(float x, float y){
  float scale = 0.01f;
  float radius = 0.7f;
  float v = (float)noise.eval(scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return v;
}

public float field2(float x, float y){
  float scale = 0.05f;
  float radius = 0.5f;
  float v = (float)noise.eval(100+ scale*x, 100+ scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return v;
}

public boolean treshold(float v1, float v2){
  return ((v1 > 0) ^ (v2 > 0));
}
//
// boolean treshold(float v1, float v2, float v3, float v4){
//   return ((v1 > 0) ^ (v2 > 0) ^ (v3 > 0) ^ (v4 > 0));
// }

OpenSimplexNoise noise;


public void setup(){
  
  result = new int[width*height][3];

  noise = new OpenSimplexNoise();
}

public void draw_(){
  background(0);
  strokeWeight(1);
  stroke(255);

  float ex = 1;
  float ey = 1;
  for(float x = 1;x<=width;x+=11){
    for(float y= 1;y<=height;y+=1){


      //float v1 = field(ex,0);
      float v2 = field(ey,100);
      // float v3 = field2(x+y,0);
      // float v4 = field2(x-y,100);

      boolean white = v2 > (0.6f*sin(t*TWO_PI));
      if(white){
        point(x,y);
      }
      ey += 0.2f;
      if(x%2 == 0){

      }
    }
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "tresholdRain" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
