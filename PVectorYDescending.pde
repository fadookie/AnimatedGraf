class PVectorYDescending implements Comparator {
  int compare(Object _vect1, Object _vect2) {
   PVector vect1 = (PVector) _vect1;
   PVector vect2 = (PVector) _vect2;
   return floor(vect1.y - vect2.y);
  }
}
