import collections

from Node import Node
from Turtle import Turtle
import pygame.math as math

def flatten(x):
    if isinstance(x, collections.Iterable):
        return [a for i in x for a in flatten(i)]
    else:
        return [x]


class LSystem:

    def __init__(self, axiom, rules, action_map):
        self.axiom = axiom
        self.rules = rules
        self.action_map = action_map
        self.nodes = []
        self.nodes.append(Node(axiom))

    def evolve(self):
        new_nodes = map(self.evolve_node, self.nodes)
        self.nodes = flatten(new_nodes)

    def evolve_node(self, node):
        if node.sign in self.rules:
            new_string = self.rules[node.sign]
            result = []
            for sign in new_string:
                if sign == '_':
                    result.append(node)
                else:
                    result.append(Node(sign))
            return result

        return node

    def draw(self, screen):
        turtle = Turtle(screen)
        turtle.draw_nodes(self.action_map, self.nodes, math.Vector2(400,800), 0)

    def __str__(self):
        return str(self.nodes)
