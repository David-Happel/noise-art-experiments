from TreeGenerator import TreeGenerator
import TreeDrawer
import time
from LSystem import LSystem
from Turtle import Turtle
import pygame
clock = pygame.time.Clock()


pygame.init()
screen = pygame.display.set_mode((800, 800))
done = False

# turtle = Turtle(screen)
# turtle.draw(actions)


lsystem = LSystem("X", {"X": "F+[[X]-X]-F[-FX]+_", "F": "_F"},
                  {"F": ["Forward", 10], "-": ["Rotate", -25], "+": ["Rotate", 25], "[": ["Push"], "]": ["Pull"]})

generations = [0.5,0.7,1,2,3,4]
current_generation = 0

startGrow = time.time()
endGrow = time.time() + generations[current_generation]


while not done:
    for event in pygame.event.get():
        if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
            done = True
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_e:
                lsystem.evolve()
                startGrow = time.time()
                endGrow = time.time() + 3

    grown = (time.time()-startGrow)/(endGrow - startGrow)
    if grown <= 1:
        for node in lsystem.nodes:
            node.set_grown(grown)
    elif current_generation < len(generations)-1:
        current_generation += 1
        lsystem.evolve()
        startGrow = time.time()
        endGrow = time.time() + generations[current_generation]

    lsystem.draw(screen)

    pygame.display.flip()

    clock.tick(30)









