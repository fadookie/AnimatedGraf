//TODO: merge to QEngine
class QMath {
  float machineEpsilon;
  /**
   * Approximate calculation of the machine epsilon
   * Adapted from http://en.wikipedia.org/wiki/Machine_epsilon#Approximation_using_Java
   */
  float getMachineEpsilonFloat() {
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
  boolean RayCast(Ray ray, MPolygon polygon, float tmax, MutableFloat t, PVector pt, PVector normal) {  
    t.set(Float.MAX_VALUE);  
    pt.x = ray.origin.x;  
    pt.y = ray.origin.y;  
    normal = ray.direction;  
      
    // temp holder for segment distance  
    MutableFloat distance = new MutableFloat(0);  
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
        if (distance.get() < t.get() && distance.get() <= tmax) {  
          //Preserve object references for "out" parameters we're modifying
          println("tPre: " + t + " hc: " + t.hashCode() + " ihc:" + System.identityHashCode(t));
          t.set(distance.get());
          println("tPost: " + t + " hc: " + t.hashCode() + " ihc:" + System.identityHashCode(t));
          PVector ptTemp = ray.getPoint(t.getFloatValue());  
          pt.x = ptTemp.x;
          pt.y = ptTemp.y;

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
  boolean RayIntersectsSegment(Ray ray, PVector pt0, PVector pt1, float tmax, MutableFloat t) {  
    PVector seg = PVector.sub(pt1, pt0);  
    PVector segPerp = LeftPerp(seg);  
    float perpDotd = PVector.dot(ray.direction, segPerp);  
    //TODO: "Please note that Epsilon is rarely the most appropriate tolerance value, but what is varies widely depending on your units and scaling and I found it was sufficient towards understanding the algorithm itself."
    if (dist(perpDotd, 0, 0.0f, 0) < getMachineEpsilonFloat()) { //Check distance between perpDotd and 0 is less than epsilon value
      t.set(Float.MAX_VALUE);  
      return false;  
    }  
  
    PVector d = PVector.sub(pt0, ray.origin);
  
    t.set(PVector.dot(segPerp, d) / perpDotd); //TODO: could change this to instance .dot() for one less new object if safe
    float s = LeftPerp(ray.direction).dot(d) / perpDotd;  
  
    return t.get() >= 0.0f && t.get() <= tmax && s >= 0.0f && s <= 1.0f;  
  }  

  PVector LeftPerp(PVector v) {  
    return new PVector(v.y, -v.x);  
  }  
  
  PVector RightPerp(PVector v) {  
    return new PVector(-v.y, v.x);  
  }  
    
}
