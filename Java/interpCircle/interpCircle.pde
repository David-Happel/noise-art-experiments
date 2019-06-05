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

int samplesPerFrame = 1;
int numFrames = 150;
float shutterAngle = 0.7;

boolean recording = true;

OpenSimplexNoise noise;
Path[] paths;
int pathi = 50;

void setup(){
  size(800, 800);
  result = new int[width*height][3];

  noise = new OpenSimplexNoise();

  paths = new Path[pathi];
  for(int i = 0; i < pathi; i++){
    paths[i] = new Path(400,400,i*(TWO_PI/pathi), 300, i*100);
  }

}

void draw_(){
  background(0);
  strokeWeight(2);
  stroke(255);
  for(int i = 0; i < pathi; i++){
    paths[i].draw(t);
  }
}

class Path {
  float x1, y1, a, r, off;
  CircularNoise cn = new CircularNoise(0.7, 1, -1,1);
  CircularNoise bright = new CircularNoise(2, 1, 100,255);

  float[] dots;

  Path(int x1, int y1, float a, float r, float off){
    this.x1 = x1;
    this.y1 = y1;
    this.a = a;
    this.r = r;
    this.off = off;
    dots = new float[30];
    for(int i = 0; i < dots.length; i++){
      dots[i] = random(1);
    }
  }

  PVector at(float p, float t){
    float a = this.a + cn.eval(t - (0.5 * p), off);
    float x2 = x1+ r*cos(a);
    float y2 = y1 + r*sin(a);
    float x = lerp(x1,x2,p);
    float y = lerp(y1,y2,p);
    return new PVector(x,y);
  }

  void draw(float t){
    for(int i = 0; i < dots.length; i++){
      float per = dots[i];
      float p = (t+per)%1;
      float s = bright.eval(t,p*20);
      if(p>0.7){
        stroke(map(p,0.7,1,s,0));
      }else{
        stroke(s);
      }

      PVector pos = this.at(p, t);
      point(pos.x, pos.y);
      point(400,400);
    }
  }
}

class CircularNoise{
  float radius, min, max;
  int p;

  OpenSimplexNoise noise;

  CircularNoise(float radius, int p, float min, float max){
    this.radius = radius;
    this.p = p;
    this.min = min;
    this.max = max;
    noise = new OpenSimplexNoise();
  }

  float eval(float t, float off){
    t = t*p;
    float val = (float)noise.eval(off, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
    return map(val, -1,1,min,max);
  }
}
