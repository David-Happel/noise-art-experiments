import time

import numpy as np
import pygame
import random
from noise import snoise2
from scipy.spatial import Voronoi, voronoi_plot_2d
from noise_loop import noise_loop

clock = pygame.time.Clock()

width = 800
height = 800

pygame.init()
screen = pygame.display.set_mode((width, height))
done = False

layers = 6

noise = [noise_loop(2, -400, width + 400, layer * 10, 100) for layer in range(layers)]


def draw(t):
    screen.fill(0)

    for layer in range(layers):

        points = np.array(
            [[noise[layer].eval(t, i), noise[layer].eval(t, i + 1000)] for i in range(20)])

        vor = Voronoi(points)

        for ridge in vor.ridge_vertices:
            ver2 = vor.vertices[ridge[1]]
            ver1 = None
            if ridge[0] == -1:
                distLeft = ver2[0]
                distRight = width - distLeft
                distTop = ver2[1]
                distBottom = height - distTop
                if distLeft < distRight and distLeft < distTop and distLeft < distBottom:
                    ver1 = np.array([0, ver2[1]])
                elif distRight < distLeft and distRight < distTop and distRight < distBottom:
                    ver1 = np.array([width, ver2[1]])
                elif distTop < distLeft and distTop < distRight and distTop < distBottom:
                    ver1 = np.array([ver2[0], 0])
                else:
                    ver1 = np.array([ver2[0], height])
            else:
                ver1 = vor.vertices[ridge[0]]

            pygame.draw.line(screen, (255 * (layer / layers), 0, 255 * (layer / layers)), ver1, ver2, 4)

        points = np.array(
            [[noise[layer].eval(t, i + 2000), noise[layer].eval(t, i + 3000)] for i in range(60)])

        vor = Voronoi(points)

        for ridge in vor.ridge_vertices:
            ver2 = vor.vertices[ridge[1]]
            ver1 = None
            if ridge[0] == -1:
                distLeft = ver2[0]
                distRight = width - distLeft
                distTop = ver2[1]
                distBottom = height - distTop
                if distLeft < distRight and distLeft < distTop and distLeft < distBottom:
                    ver1 = np.array([0, ver2[1]])
                elif distRight < distLeft and distRight < distTop and distRight < distBottom:
                    ver1 = np.array([width, ver2[1]])
                elif distTop < distLeft and distTop < distRight and distTop < distBottom:
                    ver1 = np.array([ver2[0], 0])
                else:
                    ver1 = np.array([ver2[0], height])
            else:
                ver1 = vor.vertices[ridge[0]]

            pygame.draw.line(screen, (0, 255 * (layer / layers), 0), ver1, ver2, 2)


rec_frames = 300
fps = 30

recording = True

frame = 0

while not done:
    for event in pygame.event.get():
        if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
            done = True

    if frame >= rec_frames:
        frame = 0
        recording = False

    t = frame/rec_frames

    draw(t)
    if recording:
        print("rec frame: " + str(frame))
        pygame.image.save(screen, "./out/img"+str(frame)+".png")

    pygame.display.flip()
    
    frame += 1

    clock.tick(fps)
