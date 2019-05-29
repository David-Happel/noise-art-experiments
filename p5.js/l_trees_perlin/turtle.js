class Turtle{
  constructor(){
    this.pos = createVector(0,0);
    this.direction = createVector(0,-1);
    this.stack = [];
  }

  forward(amount, color){
    strokeWeight(3);
    stroke(color);
    let prevPos = this.pos.copy();
    this.pos.add(p5.Vector.mult(this.direction, amount));
    //console.log(prevPos, this.pos);
    line(prevPos.x, prevPos.y, this.pos.x, this.pos.y)
  }

  turn(angle){
    this.direction.rotate(angle);
    this.direction.normalize();
  }

  push(){
    this.stack.push([this.pos.copy(), this.direction.copy()]);
  }

  pop(){
    let popped = this.stack.pop();
    this.pos = popped[0];
    this.direction = popped[1];
  }
}
