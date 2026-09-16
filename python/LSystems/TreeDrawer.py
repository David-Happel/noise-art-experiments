import pygame.math as math
import pygame


def draw_tree(screen, tree):
    screen.fill((0, 0, 0))
    draw_node(screen, math.Vector2(400, 800), tree)


def draw_node(screen, start_pos, node):
    new_pos = start_pos + node.get_relative_pos()
    pygame.draw.line(screen, (0, 255, 0), start_pos, new_pos)
    for child in node.children:
        draw_node(screen, new_pos, child)
