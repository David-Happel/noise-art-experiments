from utils.point import Point
import os

import numpy as np
import pygame
from utils.noise_loop import noise_loop
from PIL import Image
from scipy.spatial import Voronoi


def points_for_voronoi(points: list[Point]) -> list[Point]:
    left_points = [point + Point(-width, 0) for point in points]
    top_left = [point + Point(-width, -height) for point in points]
    bottom_left = [point + Point(-width, height) for point in points]
    right_points = [point + Point(width, 0) for point in points]
    top_right = [point + Point(width, -height) for point in points]
    bottom_right = [point + Point(width, height) for point in points]
    top_points = [point + Point(0, -height) for point in points]
    bottom_points = [point + Point(0, height) for point in points]

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


clock = pygame.time.Clock()

width = 800
height = 800

pygame.init()
screen = pygame.display.set_mode((width, height))

done = False

layers = 8
colors = [(255, 0, 0, 255 * (l / layers)) for l in range(layers)]

n_points = 5

initial_points = [
    [Point.randspawn(0, width, 0, height) for i in range(n_points)]
    for l in range(layers)
]

noise = [noise_loop(1, 0, 5, layer * 100, 100) for layer in range(layers)]


transparent_black = (0, 0, 0, 0)


def draw(t):
    surface = pygame.Surface((width, height), pygame.SRCALPHA)

    for layer in range(layers):
        noise_offsets = [
            Point(
                (noise[layer].eval(t, i * 100)) % 1 * width,
                noise[layer].eval(t, (i * 100) + 10000) % 1 * height,
            )
            for i in range(n_points)
        ]

        moved_points = [p + o for p, o in zip(initial_points[layer], noise_offsets)]

        # for point in moved_points:
        #     pygame.draw.circle(
        #         surface, color=(255, 0, 255), center=point.to_tuple(), radius=3
        #     )

        vor = Voronoi([p.to_tuple() for p in points_for_voronoi(moved_points)])

        nodes: list[Point] = [Point(v[0], v[1]) for v in vor.vertices]
        # for ridge in vor.ridge_vertices:
        #     if (ridge[0] == -1) or (ridge[1] == -1):
        #         continue

        #     ver1 = vor.vertices[ridge[0]]
        #     ver2 = vor.vertices[ridge[1]]

        #     pygame.draw.line(surface, (255, 0, 255), ver1, ver2, 4)
        for node in nodes:
            pygame.draw.circle(
                surface,
                color=colors[layer],
                center=node.to_tuple(),
                radius=(5 * (layer / layers)) + 3,
            )
    surface = pygame.transform.gaussian_blur(surface=surface, radius=3)
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
