//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
    public float x, y;

    public Vec2() {
        this.x = 0;
        this.y = 0;
    }

    public Vec2(float x, float y){
        this.x = x;
        this.y = y;
    }

    public String toString(){
        return "(" + x+ "," + y +")";
    }

    public float length(){
        return sqrt(x*x+y*y);
    }

    public Vec2 plus(Vec2 rhs){
        return new Vec2(x+rhs.x, y+rhs.y);
    }

    public void add(Vec2 rhs){
        x += rhs.x;
        y += rhs.y;
    }

    public Vec2 minus(Vec2 rhs){
        return new Vec2(x-rhs.x, y-rhs.y);
    }

    public void subtract(Vec2 rhs){
        x -= rhs.x;
        y -= rhs.y;
    }

    public Vec2 times(float rhs){
        return new Vec2(x*rhs, y*rhs);
    }

    public void mul(float rhs){
        x *= rhs;
        y *= rhs;
    }

    public void clampToLength(float maxL){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude > maxL){
            if (magnitude < 1e-15) {
                this.x = 0; this.y = 0;
                return;
            }
            x *= maxL/magnitude;
            y *= maxL/magnitude;
        }
    }

    public void setToLength(float newL){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15) {
            this.x = 0; this.y = 0;
            return;
        }
        x *= newL/magnitude;
        y *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15) {
            this.x = 0; this.y = 0;
            return;
        }
        x /= magnitude;
        y /= magnitude;
    }

    public Vec2 normalized(){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15) {
            return new Vec2();
        }
        return new Vec2(x/magnitude, y/magnitude);
    }

    public float distanceTo(Vec2 rhs){
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        return sqrt(dx*dx + dy*dy);
    }

    public void rotated(float rad) {
        x = cos(rad)*x-sin(rad)*y;
        y = sin(rad)*x+cos(rad)*y;
    }

    public Vec2 rotate(float rad) {
        float newx = cos(rad)*x-sin(rad)*y;
        float newy = sin(rad)*x+cos(rad)*y;
        return new Vec2(newx, newy);
    }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
