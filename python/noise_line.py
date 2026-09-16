from utils.point import Point
import os

import numpy as np
import pygame
from utils.noise_loop import noise_loop
from PIL import Image

clock = pygame.time.Clock()
pygame.init()


width = 800
height = 50
screen = pygame.display.set_mode((width, height))

n_points = 100
noise = noise_loop(300, 0, height, 0, 0)

t_offset = 0.01


def draw(t):
    surface = pygame.Surface((width, height), pygame.SRCALPHA)

    points = [
        Point(800 * (i / (n_points - 1)), (noise.eval(t - (i * t_offset), 0.005 * i)))
        for i in range(n_points)
    ]
    # for point in points:
    #     pygame.draw.circle(
    #         surface, color=(255, 0, 255), center=point.to_tuple(), radius=3
    #     )

    for i in range(n_points - 1):
        p1 = points[i]
        p2 = points[i + 1]
        pygame.draw.aaline(
            surface=surface,
            color=(0, 255, 0),
            start_pos=p1.to_tuple(),
            end_pos=p2.to_tuple(),
        )

    screen.fill((0, 0, 0, 0))
    screen.blit(surface, (0, 0))
    return surface


rec_frames = 200
fps = 20

recording = True

frame = 0
img_files = []
done = False
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
