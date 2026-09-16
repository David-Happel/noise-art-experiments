import os

import numpy as np
import pygame
from noise_loop import noise_loop
from PIL import Image
from scipy.spatial import Voronoi

clock = pygame.time.Clock()

width = 800
height = 800

pygame.init()
screen = pygame.display.set_mode((width, height))

done = False

layers = 1

noise = [noise_loop(1, 0, 5, layer * 100, 100) for layer in range(layers)]


def points_for_voronoi(points):
    left_points = [[point[0] - width, point[1]] for point in points]
    top_left = [[point[0] - width, point[1] - height] for point in points]
    bottom_left = [[point[0] - width, point[1] + height] for point in points]
    right_points = [[point[0] + width, point[1]] for point in points]
    top_right = [[point[0] + width, point[1] - height] for point in points]
    bottom_right = [[point[0] + width, point[1] + height] for point in points]
    top_points = [[point[0], point[1] - height] for point in points]
    bottom_points = [[point[0], point[1] + height] for point in points]

    return [
        *points,
        *right_points,
        *left_points,
        *top_points,
        *bottom_points,
        *top_left,
        *top_right,
        *bottom_left,
        *bottom_right,
    ]


transparent_black = (0, 0, 0, 0)


def draw(t):
    surface = pygame.Surface((width, height), pygame.SRCALPHA)

    for layer in range(layers):
        points = np.array(
            [
                [
                    (noise[layer].eval(t, i * 100)) % 1 * width,
                    noise[layer].eval(t, (i * 100) + 10000) % 1 * height,
                ]
                for i in range(20)
            ]
        )

        for point in points:
            pygame.draw.circle(surface, color=(255, 0, 255), center=point, radius=3)

        vor = Voronoi(points_for_voronoi(points))

        for ridge in vor.ridge_vertices:
            ver2 = vor.vertices[ridge[1]]
            ver1 = None
            if ridge[0] == -1:
                distLeft = ver2[0]
                distRight = width - distLeft
                distTop = ver2[1]
                distBottom = height - distTop
                if (
                    distLeft < distRight
                    and distLeft < distTop
                    and distLeft < distBottom
                ):
                    ver1 = np.array([0, ver2[1]])
                elif (
                    distRight < distLeft
                    and distRight < distTop
                    and distRight < distBottom
                ):
                    ver1 = np.array([width, ver2[1]])
                elif (
                    distTop < distLeft and distTop < distRight and distTop < distBottom
                ):
                    ver1 = np.array([ver2[0], 0])
                else:
                    ver1 = np.array([ver2[0], height])
            else:
                ver1 = vor.vertices[ridge[0]]

            pygame.draw.line(surface, (255, 0, 255), ver1, ver2, 4)

    screen.fill((0, 0, 0, 0))
    screen.blit(surface, (0, 0))
    return surface


rec_frames = 200
fps = 20

recording = True

frame = 0
img_files = []
while not done:
    for event in pygame.event.get():
        if event.type == pygame.QUIT or (
            event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE
        ):
            done = True

    if frame >= rec_frames:
        frame = 0
        if recording:
            img, *imgs = [Image.open(f) for f in img_files]
            img.save(
                fp="./out/img" + str(frame) + ".gif",
                format="GIF",
                append_images=imgs,
                save_all=True,
                duration=(1 / fps) * 1000,
                loop=0,
                transparency=0,
                optimize=True,
                disposal=2,
            )

            recording = False

    t = frame / rec_frames

    surface = draw(t)
    if recording:
        os.makedirs("./out", exist_ok=True)
        print("rec frame: " + str(frame))
        path = "./out/img" + str(frame) + ".png"

        pygame.image.save(surface, path)
        img_files.append(path)

    pygame.display.flip()

    frame += 1

    clock.tick(fps)
