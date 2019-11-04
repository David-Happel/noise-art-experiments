import math
from noise import snoise3


class noise_loop:
    def __init__(self, rad, min, max, cx, cy):
        self.rad = rad
        self.min = min
        self.max = max
        self.cx = cx
        self.cy = cy

    def eval(self, t, z):
        x = ((self.rad * math.cos(t*math.pi*2)) + self.cx)/100
        y = ((self.rad * math.sin(t*math.pi*2)) + self.cy)/100

        res = snoise3(x, y, z)

        bound_len = self.max - self.min
        res = (res + 1) * bound_len/2 + self.min
        return res






