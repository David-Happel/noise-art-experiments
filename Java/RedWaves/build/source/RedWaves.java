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

public class RedWaves extends PApplet {

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
int numFrames = 200;
float shutterAngle = 0.7f;

boolean recording = false;

Line[] lines = new Line[10];

public void setup(){
  
  result = new int[width*height][3];
  for(int l = 0; l < lines.length; l++){
    lines[l] = new Line();
  }

}

public void draw_(){
  background(0);
  for(int l = 0; l < lines.length; l++){
    lines[l].drawAt(t);
  }
}

class Line {
  NoiseLoop noise;
  float speed;
  float thickness;
  float opp;

  Line(){
    float r = random(-10000, 10000);
    speed = random(0.5f,1.5f);
    thickness = random(1,5);
    opp = random(0,255);
    noise = new NoiseLoop(1.5f,-400,400,r,0,0);
  }

  public void drawAt(float t){
    stroke(opp,0,0);
    strokeWeight(thickness);
    for(int i = 0; i < 400; i++){

      float off = noise.valueAt(((t*TWO_PI)+(i/800f)*speed));
      point((float)(400 + off), 800f/400f*i);
    }
  }
}
class NoiseLoop{
  float width, min, max, x, y, z;
  OpenSimplexNoise noise = new OpenSimplexNoise();

  NoiseLoop(float width,float min, float max,float x,float y,float z){
    this.width = width;
    this.x = x;
    this.y = y;
    this.z = z;
    this.min = min;
    this.max = max;
  }

  public float valueAt(float a){
    return valueAt(a, z);
  }

  public float valueAt(float a,float nz){
    float nx = map(cos(a),-1,1,this.x,this.x+this.width);
    float ny = map(sin(a),-1,1,this.y,this.y+this.width);
    return map((float)noise.eval(nx, ny, nz),-1,1,this.min,this.max);
  }

  public void addZ(float amount){
    this.z += amount;
  }
}
  public void settings() {  size(800, 800, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RedWaves" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
