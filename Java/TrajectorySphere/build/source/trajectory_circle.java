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

public class trajectory_circle extends PApplet {

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
float shutterAngle = 0.7f;

boolean recording = true;

int n = 500;
float rad = 300;

public PVector field(float x, float y){
  float amount = -1;
  float scale = 0.01f;
  float radius = 0.7f;
  PVector pos = new PVector(x,y);

  PVector vector = PVector.sub(pos, new PVector(width/2, height/2)).normalize();
  float rotation = (float)noise.eval(scale*x, scale*y, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
  rotation = map(rotation, -1,1,-PI/1.5f,PI/1.5f);

  return vector.rotate(rotation).mult(amount);
}

OpenSimplexNoise noise;


public void setup(){
  
  result = new int[width*height][3];

  noise = new OpenSimplexNoise();
}

public void draw_(){
  background(0);
  stroke(255);
  strokeWeight(1);

  for(int i = 0; i < n; i++){
    float angle = i*TWO_PI/n;
    float x = width/2 + rad*cos(angle);
    float y = height/2 + rad*sin(angle);
    point(x,y);
    for(int k = 0; k<400; k++){
      PVector field = field(x,y);
      x += field.x;
      y += field.y;
      point(x,y);
    }
  }

  // for(int x = 5; x < width ; x+=10){
  //   for(int y = 5; y < height; y+=10){
  //     PVector vector = field(x,y);
  //     line(x, y, x+vector.x, y+vector.y);
  //   }
  // }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "trajectory_circle" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
