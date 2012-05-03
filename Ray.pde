class Ray {
  PVector direction = new PVector();
  PVector origin = new PVector();

  PVector getPoint(float t) {
    return PVector.add(origin, PVector.mult(direction, t));
  }

  void setDirection(PVector newDirection) {
    direction = newDirection;
    direction.normalize();
  }

  void setOrigin(PVector newOrigin) {
    origin = newOrigin;
  }

  String toString() {
    return "Origin:" + origin + ", Direction: " + direction;
  }
}
