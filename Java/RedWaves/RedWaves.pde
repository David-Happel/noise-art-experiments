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
int numFrames = 200;
float shutterAngle = 0.7;

boolean recording = false;

Line[] lines = new Line[10];

void setup(){
  size(800, 800, P3D);
  result = new int[width*height][3];
  for(int l = 0; l < lines.length; l++){
    lines[l] = new Line();
  }

}

void draw_(){
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
    speed = random(0.5,1.5);
    thickness = random(1,5);
    opp = random(0,255);
    noise = new NoiseLoop(1.5,-400,400,r,0,0);
  }

  void drawAt(float t){
    stroke(opp,0,0);
    strokeWeight(thickness);
    for(int i = 0; i < 400; i++){

      float off = noise.valueAt(((t*TWO_PI)+(i/800f)*speed));
      point((float)(400 + off), 800f/400f*i);
    }
  }
}
