/**
 * Ugh... god dammit Java...
 * (We need this container to guarantee that we will not lose the reference when mutating a float as an "out" parameter)
 */
class MutableFloat {
    Float f;

    MutableFloat(Float _f) {
        f = _f;
    }

    MutableFloat(float _f) {
      f = new Float(_f);
    }

    void set(Float _f) {
      f = _f;
    }

    void set(float _f) {
      f = _f;
    }

    Float get() {
      return f;
    }

    float getFloatValue() {
      return f.floatValue();
    }

    String toString() {
      return f.toString();
    }
}
