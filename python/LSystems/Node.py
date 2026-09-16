class Node:
    def __init__(self, sign):
        self.sign = sign
        self.grown = 0

    def set_grown(self, grown):
        if self.grown < grown:
            self.grown = grown

    def __repr__(self):
        return self.sign + " : " + str(self.grown)
