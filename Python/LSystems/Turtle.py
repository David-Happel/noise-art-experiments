# np is an alias pointing to numpy library
import numpy as np
import pygame
import pygame.math as math


class Turtle:
    def __init__(self, screen):
        self.pos = math.Vector2(400, 800)
        self.dir = math.Vector2(0, -1)
        self.stack = []
        self.screen = screen
        self.depth = 0
        self.max_depth = 0

    def draw(self, actions):
        self.screen.fill((0, 0, 0))
        self.pos = math.Vector2(400, 800)
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

    def draw_nodes(self, action_map, nodes, start_pos, start_angle):
        self.screen.fill((0, 0, 0))
        self.pos = start_pos
        self.dir = math.Vector2(0, -1).rotate(start_angle)
        self.depth = 0
        self.stack = []
        self.max_depth = 0

        temp_depth = 0
        for node in nodes:
            if node.sign in action_map:
                action = action_map[node.sign]
                if action[0] == "Push":
                    temp_depth += 1
                    if temp_depth > self.max_depth:
                        self.max_depth = temp_depth
                if action[0] == "Pull":
                    temp_depth -= 1


        for node in nodes:
            if node.sign in action_map:
                action = action_map[node.sign]

                if action[0] == "Forward":
                    self.forward(action[1] * node.grown)
                if action[0] == "Rotate":
                    self.rotate(action[1] * node.grown)
                if action[0] == "Push":
                    self.push()
                if action[0] == "Pull":
                    self.pull()

    def forward(self, dist):
        new_pos = self.pos + (self.dir * float(dist))
        green = math.Vector3(0,255,0)
        brown = math.Vector3(128, 74, 43)
        depth = (self.max_depth-self.depth)/10
        pygame.draw.line(self.screen, green.lerp(brown, depth), self.pos, new_pos, max(1,int(depth*3)))
        self.pos = new_pos

    def rotate(self, degrees):
        self.dir = self.dir.rotate(degrees)

    def push(self):
        self.depth += 1
        self.stack.append((self.pos, self.dir))

    def pull(self):
        self.depth -= 1
        info = self.stack.pop()
        self.pos = info[0]
        self.dir = info[1]
