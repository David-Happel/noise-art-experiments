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

  float valueAt(float a){
    return valueAt(a, z);
  }

  float valueAt(float a,float nz){
    float nx = map(cos(a),-1,1,this.x,this.x+this.width);
    float ny = map(sin(a),-1,1,this.y,this.y+this.width);
    return map((float)noise.eval(nx, ny, nz),-1,1,this.min,this.max);
  }

  void addZ(float amount){
    this.z += amount;
  }
}
