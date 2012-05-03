//TODO: merge to QEngine
static class QMath {
  static float machineEpsilon;
  /**
   * Approximate calculation of the machine epsilon
   * Adapted from http://en.wikipedia.org/wiki/Machine_epsilon#Approximation_using_Java
   */
  static float getMachineEpsilonFloat() {
    float machEps = 0.0f;

    if (machineEpsilon == 0.0f) {
      machEps = 1.0f;

      do {
         machEps /= 2.0f;
      }
      while ((float)(1.0 + (machEps/2.0)) != 1.0);
    } else {
      machEps = machineEpsilon;
    }

    return machEps;
  }

  /**
   * @param Float t Out param
   * @param PVector pt Out param
   * @param PVector normal Out param
   */
  static boolean RayCast(Ray ray, MPolygon polygon, float tmax, Float t, PVector pt, PVector normal) {  
    t = Float.MAX_VALUE;  
    pt = ray.origin;  
    normal = ray.direction;  
      
    // temp holder for segment distance  
    Float distance = new Float(0);  
    int crossings = 0;  

    //Some reusable PVectors to save on garbage creation
    PVector workVectorA = new PVector();
    PVector workVectorB = new PVector();

    float[][] polyCoords = polygon.getCoords();
    for (int j = polyCoords.length - 1, i = 0; i < polyCoords.length; j = i, i++) {  
      workVectorA.x = polyCoords[j][0];
      workVectorA.y = polyCoords[j][1];
      workVectorB.x = polyCoords[i][0];
      workVectorB.y = polyCoords[i][1];
      if (RayIntersectsSegment(ray, workVectorA, workVectorB, Float.MAX_VALUE, distance)) {  
        crossings++;  
        if (distance < t && distance <= tmax) {  
          t = distance;  
          try {
            pt = ray.getPoint(t);  
          } catch (UnsupportedOperationException e) {
            println(e.getMessage());
          }

          PVector edge = PVector.sub(workVectorA, workVectorB);  
          // We would use LeftPerp() if the polygon was  
          // in clock wise order  
          normal = RightPerp(edge);
          normal.normalize();
          //no reflection here
        }  
      }  
    }  
    return crossings > 0 && crossings % 2 == 0;  
  }  

  /**
   * @param Float t Out param
   */
  static boolean RayIntersectsSegment(Ray ray, PVector pt0, PVector pt1, float tmax, Float t) {  
    PVector seg = PVector.sub(pt1, pt0);  
    PVector segPerp = LeftPerp(seg);  
    float perpDotd = PVector.dot(ray.direction, segPerp);  
    //TODO: "Please note that Epsilon is rarely the most appropriate tolerance value, but what is varies widely depending on your units and scaling and I found it was sufficient towards understanding the algorithm itself."
    if (dist(perpDotd, 0, 0.0f, 0) < getMachineEpsilonFloat()) { //Check distance between perpDotd and 0 is less than epsilon value
      t = Float.MAX_VALUE;  
      return false;  
    }  
  
    PVector d = PVector.sub(pt0, ray.origin);
  
    t = PVector.dot(segPerp, d) / perpDotd; //TODO: could change this to instance .dot() for one less new object if safe
    float s = LeftPerp(ray.direction).dot(d) / perpDotd;  
  
    return t >= 0.0f && t <= tmax && s >= 0.0f && s <= 1.0f;  
  }  

  static PVector LeftPerp(PVector v) {  
    return new PVector(v.y, -v.x);  
  }  
  
  static PVector RightPerp(PVector v) {  
    return new PVector(-v.y, v.x);  
  }  
    
}
