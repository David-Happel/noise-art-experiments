from dataclasses import dataclass
from random import Random


@dataclass
class Point:
    x: float
    y: float

    def __mult__(self, other: "Point") -> "Point":
        return Point(self.x * other.x, self.y * other.y)

    def __add__(self, other: "Point") -> "Point":
        return Point(self.x + other.x, self.y + other.y)

    def __repr__(self) -> str:
        return f"Point({self.x}, {self.y})"

    def to_tuple(self) -> tuple[float, float]:
        return (self.x, self.y)

    @staticmethod
    def randspawn(min_x: float, max_x: float, min_y: float, max_y: float) -> "Point":
        random = Random()

        return Point(
            (random.random() * (max_x - min_x)) + min_x,
            (random.random() * (max_y - min_y)) + min_y,
        )
