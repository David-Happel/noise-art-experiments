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

boolean recording = true;

int n = 100;
float rad = 10;

Field field;

void setup(){
  size(800, 800, P3D);
  result = new int[width*height][3];

  field = new Field();
}

void draw_(){
  camera(0, 0, 800, 0, 0, 0, 0, 1, 0);
  background(0);
  stroke(255);
  strokeWeight(2);

  rotateY(t*TWO_PI);
  rotateX(PI/10);

  // for(int x = -200; x < 200 ; x+=20){
  //   for(int y = -200; y < 200; y+=20){
  //     for(int z = -200; z<200; z+= 20){
  //       PVector vector = field.eval(x,y,z,t).mult(10);
  //       line(x, y,z, x+vector.x, y+vector.y, z+vector.z);
  //     }
      
  //   }
  // }
  for(int i = 0; i < n; i++){
    float angle = i*TWO_PI/n;
    float x = rad*cos(angle);
    float y = rad*sin(angle);
    float z = 0;
    for(int k = 0; k<100; k++){
      PVector vec = field.eval(x,y,z,t).mult(3);
      float newx = x + vec.x;
      float newy = y + vec.y;
      float newz = z + vec.z;
      stroke(255-k*2.5,0,250);
      line(x,y,z, newx,newy,newz);
      x = newx;
      y = newy;
      z = newz;
    }
  }

}

void vecRotate(PVector vec, float angleX, float angleY){
  vec.y = vec.y*cos(angleX) - (vec.z*sin(angleX));
  vec.z = vec.y * sin(angleX) + (vec.z * cos(angleX));

  vec.x = vec.x*cos(angleY) - vec.z*sin(angleY);
  vec.z = -vec.x*sin(angleY) + vec.z*cos(angleY);
}

class Field {
  OpenSimplexNoise noise = new OpenSimplexNoise();
  float xOff, yOff, zOff;
  float timeDiff = 0.5;
  float squish = 100;
  

  Field(){
    this.xOff = random(0,10000);
    this.yOff = random(0,10000);
    this.zOff = random(0,10000);
  }

  PVector eval(float x,float y,float z,float t){
    PVector pos = new PVector(x,y,z);
    PVector vector = PVector.sub(pos, new PVector(0, 0, 0)).normalize();

    x = x/squish;
    y = y/squish;
    z = z/squish;

    float loop = t;
    if(loop > 0.5){
      loop = 1 - loop;
    }

    float rotX = (float)noise.eval(x+xOff,y,z,loop*timeDiff)*PI;
    float rotY = (float)noise.eval(x+yOff,y,z,loop*timeDiff)*PI;
    vecRotate(vector,rotX,rotY);
    //System.out.println(vecX);
    return vector;
  }
}
