class NoiseLoop{
  constructor(width, min, max, x, y, z){
    this.width = width;
    this.x = x;
    this.y = y;
    this.z = z;
    this.min = min;
    this.max = max;
  }

  valueAt(a, nz){
    let z = nz;
    if(!nz){
      z = this.z;
    }
    let nx = map(cos(a),-1,1,this.x,this.x+this.width);
    let ny = map(sin(a),-1,1,this.y,this.y+this.width);
    return map(noise(nx, ny, z),0,1,this.min,this.max);
  }

  addZ(amount){
    this.z += amount;
  }
}
