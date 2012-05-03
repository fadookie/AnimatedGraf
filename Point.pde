class Point extends PVector {
  boolean isOnHull = false;

  Point(float _x, float _y) {
    super (_x, _y);
  }

  boolean equals(float _x, float _y) {
    return ((this.x == _x) && (this.y == _y));
  }
}
