from Node import Node
import pygame.math as math

class TreeGenerator:
    def __init__(self):
        self.parent = Node(None, math.Vector2(0,0))
        self.pos = self.parent
        self.dir = math.Vector2(0, -1)
        self.stack = []

    def generate_tree_from_actions(self, actions):
        self.parent = Node(None, math.Vector2(0, 0))
        self.pos = self.parent
        self.dir = math.Vector2(0, -1)
        self.stack = []

        for action in actions:
            if action[0] == "Forward":
                self.forward(action[1])
            if action[0] == "Rotate":
                self.rotate(action[1])
            if action[0] == "Push":
                self.push()
            if action[0] == "Pull":
                self.pull()

        return self.parent

    def generate_tree_from_string(self, string, action_map):
        actions = []
        for char in string:
            if char in action_map:
                actions.append(action_map[char])
        return self.generate_tree_from_actions(actions)

    def forward(self, dist):
        relative_pos = (self.dir * float(dist))
        new_node = Node(self.pos, relative_pos)
        self.pos.children.append(new_node)
        self.pos = new_node

    def rotate(self, degrees):
        self.dir = self.dir.rotate(degrees)

    def push(self):
        self.stack.append((self.pos, self.dir))

    def pull(self):
        info = self.stack.pop()
        self.pos = info[0]
        self.dir = info[1]
