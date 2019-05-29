import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class trajectory_dots extends PApplet {



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

int samplesPerFrame = 5;
int numFrames = 150;
float shutterAngle = 0.2f;

boolean recording = true;

int n = 1000;
Dot[] dots = new Dot[n];

public PVector field(float x, float y){
  float amount = 10;
  float scale = 0.01f;
  float radius = 1;
  float dx = (float)noise.eval(scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));
  float dy = (float)noise.eval(1000 + scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return new PVector(amount*dx, amount*dy);
}

OpenSimplexNoise noise;


public void setup(){
  
  result = new int[width*height][3];

  for(int i = 0; i < n; i++){
    dots[i] = new Dot();
  }

  noise = new OpenSimplexNoise();
}

public void draw_(){
  background(0);
  strokeWeight(2);
  stroke(255, 15);
  // for(int i = 0; i < n; i++){
  //   PVector pos = dots[i].getPos(t);
  //   point(pos.x, pos.y);
  // }
  PVector center = new PVector(width/2, height/2);
  for(int i = 0; i < n; i++){
    PVector pos = dots[i].getPos(t);
    noFill();

    float x = pos.x;
    float y = pos.y;

    // PVector f = field(x,y);,-1,1,0,height);
    // PVector away = PVector.sub(here, center);
    // float dist = away.mag();
    // f.add(away.normalize().mult((float)(20/Math.sqrt(dist))));
    // line(x,y,x+f.x,y+f.y);

    point(x,y);
    for(int k=0;k<200;k++){
      PVector res = field(x,y);
      res.mult(0.3f);

      PVector away = PVector.sub(pos, center);
      float dist = away.mag();
      res.add(away.normalize().mult((float)(20/Math.sqrt(dist))*0.2f));

      x += res.x;
      y += res.y;
      point(x,y);
    }
    //endShape();
  }


  //  PVector center = new PVector(width/2, height/2);
  // for(float i = 300;i<=width-300;i+=10){
  //   for(float j=300;j<=height-300;j+=10){
  //     stroke(255);    long seed =
  //     noFill();
  //
  //     float x = i;
  //     float y = j;
  //     PVector here = new PVector(x, y);
  //
  //     // PVector f = field(x,y);
  //     // PVector away = PVector.sub(here, center);
  //     // float dist = away.mag();
  //     // f.add(away.normalize().mult((float)(20/Math.sqrt(dist))));
  //     // line(x,y,x+f.x,y+f.y);
  //
  //     point(x,y);
  //     for(int k=0;k<200;k++){
  //       PVector res = field(x,y);
  //       res.mult(0.3);
  //       PVector away = PVector.sub(here, center);,-1,1,0,height);
  //       float dist = away.mag();
  //       res.add(away.normalize().mult((float)(20/Math.sqrt(dist))*0.2));
  //       x += res.x;
  //       y += res.y;
  //       point(x,y);
  //     }
  //     point(x,y);
  //   }
  // }
}

class Dot{
  float radius = 0.7f;

  OpenSimplexNoise noise;

  Dot(){
    noise = new OpenSimplexNoise(new Random().nextLong());
  }


  public PVector getPos(float t){
    float x = (float)noise.eval(100, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
    x = map(x,-1,1,200,width-200);
    float y = (float)noise.eval(1000, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
    y = map(y,-1,1,200,height-200);
    return new PVector(x,y);
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "trajectory_dots" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
