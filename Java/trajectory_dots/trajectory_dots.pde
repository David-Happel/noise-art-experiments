import java.util.*;

int[][] result;
float t, c;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5)
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3), ia = atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
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
        int(result[i][0]*1.0/samplesPerFrame) << 16 |
        int(result[i][1]*1.0/samplesPerFrame) << 8 |
        int(result[i][2]*1.0/samplesPerFrame);
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
float shutterAngle = 0.2;

boolean recording = true;

int n = 1000;
Dot[] dots = new Dot[n];

PVector field(float x, float y){
  float amount = 10;
  float scale = 0.01;
  float radius = 1;
  float dx = (float)noise.eval(scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));
  float dy = (float)noise.eval(1000 + scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return new PVector(amount*dx, amount*dy);
}

OpenSimplexNoise noise;


void setup(){
  size(800, 800);
  result = new int[width*height][3];

  for(int i = 0; i < n; i++){
    dots[i] = new Dot();
  }

  noise = new OpenSimplexNoise();
}

void draw_(){
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
      res.mult(0.3);

      PVector away = PVector.sub(pos, center);
      float dist = away.mag();
      res.add(away.normalize().mult((float)(20/Math.sqrt(dist))*0.2));

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
  float radius = 0.7;

  OpenSimplexNoise noise;

  Dot(){
    noise = new OpenSimplexNoise(new Random().nextLong());
  }


  PVector getPos(float t){
    float x = (float)noise.eval(100, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
    x = map(x,-1,1,200,width-200);
    float y = (float)noise.eval(1000, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
    y = map(y,-1,1,200,height-200);
    return new PVector(x,y);
  }
}
