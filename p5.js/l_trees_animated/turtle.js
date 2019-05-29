class Turtle{
  constructor(){
    this.pos = createVector(0,0);
    this.direction = createVector(0,-1);
    this.stack = [];
    this.stages = [[]];
    this.currentStage = 0;
  }

  forward(amount){
    let prevPos = this.pos.copy();
    this.pos.add(p5.Vector.mult(this.direction, amount));
    //console.log(prevPos, this.pos);
    this.stages[this.currentStage].push(["Line", prevPos.x, prevPos.y, this.pos.x, this.pos.y]);
  }

  turn(angle){
    this.direction.rotate(angle);
    this.direction.normalize();
  }

  push(){
    this.currentStage++;
    if(!this.stages[this.currentStage]){
      this.stages.push([]);
    }
    this.stack.push([this.pos.copy(), this.direction.copy()]);
  }

  pop(){
    this.currentStage--;
    let popped = this.stack.pop();
    this.pos = popped[0];
    this.direction = popped[1];
  }

  draw(percentage){
    for(let stageI = 0; stageI < this.stages.length; stageI++){
      let stage = this.stages[stageI];
      stroke(0,255,0)
      for(let i = 0; i < stage.length; i++){
        let inst = stage[i];
        switch(inst[0]){
          case "Line": {
            let x1 = inst[1];
            let y1 = inst[2];
            let x2 = lerp(x1, inst[3], percentage);
            let y2 = lerp(y1,inst[4], percentage);
            line(x1,y1,x2,y2);
            break;
          }
        }
      }
    }
  }
}
