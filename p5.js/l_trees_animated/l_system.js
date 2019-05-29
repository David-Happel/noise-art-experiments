class L_System {
  constructor(rules, actions, initial, color) {
    this.rules = rules;
    this.actions = actions;
    this.treeString = initial;
    this.turtle = new Turtle();
    this.color = color;
  }

  evolve(){
    let evolved = "";
    this.treeString.split('').forEach(function(c) {
      evolved += this.evolveChar(c)
    }.bind(this));
    this.treeString = evolved;
    this.calcInstrucitons();
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

  calcInstrucitons(){
    this.turtle = new Turtle();
    this.treeString.split('').forEach(function(c) {
      this.executeInstruction(c);
    }.bind(this))
    console.log(this.turtle.stages);
  }

  decode(c){
    for(let i = 0; i < this.actions.length; i++){
      let instr = actions[i];
      if(c == instr[0]){
        return instr.slice(1);
      }
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
              this.turtle.forward(5, this.color);
              break;
            }
            case "push": this.turtle.push(); break;
            case "pop": this.turtle.pop(); break;
            case "turn": {
              this.turtle.turn(parseInt(ins[1]));
              break;
            }
          }
        }
      }
    }
  }
}
