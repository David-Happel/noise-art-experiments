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
int numFrames = 170;
float shutterAngle = 0.7;

boolean recording = true;

float field(float x, float y){
  float scale = 0.01;
  float radius = 0.7;
  float v = (float)noise.eval(scale*x, scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return v;
}

float field2(float x, float y){
  float scale = 0.05;
  float radius = 0.5;
  float v = (float)noise.eval(100+ scale*x, 100+ scale*y, radius*cos(t*TWO_PI), radius*sin(t*TWO_PI));

  return v;
}

boolean treshold(float v1, float v2){
  return ((v1 > 0) ^ (v2 > 0));
}
//
// boolean treshold(float v1, float v2, float v3, float v4){
//   return ((v1 > 0) ^ (v2 > 0) ^ (v3 > 0) ^ (v4 > 0));
// }

OpenSimplexNoise noise;


void setup(){
  size(800, 800);
  result = new int[width*height][3];

  noise = new OpenSimplexNoise();
}

void draw_(){
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
