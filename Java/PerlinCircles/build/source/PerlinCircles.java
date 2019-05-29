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

public class PerlinCircles extends PApplet {

int width = 800;
int height = 800;

float noiseAmount = 6;
float morphspeed = 0.001f;

int steps = 300;
int fps = 30;

boolean record = false;

NoiseLoop[] loops = new NoiseLoop[30];

public void settings(){
    size(width,height);
}

public void setup() {
  frameRate(fps);
  float z = 0;
  for(int i = 0; i < loops.length; i++){
    z+= 0.1f;
    loops[i] = new NoiseLoop(noiseAmount, (i*15f),(float)(10+(i*30)+Math.sqrt(i)), 0,0,z);
  }
}

public void draw(){
  background(0);
  translate(width/2, height/2);
  stroke(255);
  noFill();
  for(int i = 0; i < loops.length; i++){

    loops[i].addZ(0.002f);
    beginShape();

    for(float a = 0; a < TWO_PI; a+=TWO_PI/steps) {
      float r = loops[i].valueAt(a);
      float x = r * cos(a);
      float y = r * sin(a);
      vertex(x,y);
    }
    endShape(CLOSE);
  }
  if(record &&frameCount < 600){
    saveFrame("output/frame-######.png");
  }
}

public void mousePressed(){
  record = true;
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PerlinCircles" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
