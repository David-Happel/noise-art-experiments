class L_System {
  constructor(rules, actions, initial, colors) {
    this.rules = rules;
    this.actions = actions;
    this.treeString = initial;
    this.turtle = new Turtle();
    this.colors = colors;
    this.noiseAngle = 0;
    this.noiseSpace = 0;
    this.colorLerp = 0;
  }

  evolve(){
    let evolved = "";
    this.treeString.split('').forEach(function(c) {
      evolved += this.evolveChar(c)
    }.bind(this));
    this.treeString = evolved;
    console.log("new String: ", evolved);
  }

  evolveChar(c){
    for(let ruleI = 0; ruleI < this.rules.length; ruleI++){
      let rule = rules[ruleI];
      if(c == rule[0]){
        return rule[1];
      }
    }
    return c;
  }

  draw(){
    this.colorLerp = 0;
    this.noiseSpace = 0;
    this.nx = map(sin(this.noiseAngle),-1,1,0,1);
    this.ny = map(cos(this.noiseAngle), -1,1,0,1);
    this.turtle = new Turtle();
    this.treeString.split('').forEach(function(c) {
      this.executeInstruction(c);
    }.bind(this))
  }

  decode(c){
    for(let i = 0; i < this.actions.length; i++){
      let instr = actions[i];
      if(c == instr[0]){
        return instr.slice(1);
      }    color = lerp()
    }
  }

  executeInstruction(c){
    let instrs = this.decode(c);
    if(instrs){
      for(let i = 0; i < instrs.length; i++){
        let instr = instrs[i];
        let ins = instr.split(" ");
        if(ins[0]){
          switch(ins[0]){
            case "forward": {
              let col = lerpColor(this.colors[0],this.colors[1], this.colorLerp);
              if(this.colorLerp < 1){
                this.colorLerp += 0.0005;
              }
              this.turtle.forward(5, col);
              break;
            }
            case "push": this.turtle.push(); break;
            case "pop": this.turtle.pop(); break;
            case "turn": {
              this.noiseSpace += 1;
              let offset = map(noise(this.nx,this.ny, this.noiseSpace),0,1,-10,10);
              this.turtle.turn(parseInt(ins[1]) + offset);
              break;
            }
          }
        }
      }
    }
  }
}
