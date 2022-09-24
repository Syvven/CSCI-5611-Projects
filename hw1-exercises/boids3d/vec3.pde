////////////////////////////////////////////////////////////////////////////////

// CSCI 5611 Vector 3 Library
// Noah J Hendrickson <hend0800@umn.edu>

public class Vec3 {
    public float x, y, z;

    public Vec3(float x, float y, float z){
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public String toString(){
        return "(" + x + "," + y + "," + z + ")";
    }

    public float length(){
        return sqrt(x*x+y*y+z*z);
    }

    public float lengthSqr() {
        return x*x+y*y+z*z;
    }

    public Vec3 plus(Vec3 rhs){
        return new Vec3(x+rhs.x, y+rhs.y, z+rhs.z);
    }

    public void add(Vec3 rhs){
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
    }

    public Vec3 minus(Vec3 rhs){
        return new Vec3(x-rhs.x, y-rhs.y, z-rhs.z);
    }

    public void subtract(Vec3 rhs){
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
    }

    public Vec3 times(float rhs){
        return new Vec3(x*rhs, y*rhs, z*rhs);
    }

    public void mul(float rhs){
        x *= rhs;
        y *= rhs;
        z *= rhs;
    }

    public void clampToLength(float maxL){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > maxL){
            x *= maxL/magnitude;
            y *= maxL/magnitude;
            z *= maxL/magnitude;
        }
    }

    public void setToLength(float newL){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude <= epsilon) return;
        x *= newL/magnitude;
        y *= newL/magnitude;
        z *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > epsilon) {
            x /= magnitude;
            y /= magnitude;
            z /= magnitude;
        }
    }

    public Vec3 normalized(){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > epsilon) return new Vec3(x/magnitude, y/magnitude, z/magnitude);
        return new Vec3(x,y,z);
    }

    public float distanceTo(Vec3 rhs){
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        float dz = rhs.z - z;
        return sqrt(dx*dx + dy*dy + dz*dz);
    }

    public void rotateAroundZ(float rad) {
        x = cos(rad)*x-sin(rad)*y;
        y = sin(rad)*x+cos(rad)*y;
        z = z;
    }

    public void rotateAroundY(float rad) {
        x = cos(rad)*x+sin(rad)*z;
        y = y;
        z = -sin(rad)*x+cos(rad)*z;
    }

    public void rotateAroundX(float rad) {
        x = x;
        y = cos(rad)*y-sin(rad)*z;
        z = sin(rad)*y+cos(rad)*z;
    }

    public Vec3 rotatedAroundZ(float rad) {
        float newx = cos(rad)*x-sin(rad)*y;
        float newy = sin(rad)*x+cos(rad)*y;
        float newz = z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundY(float rad) {
        float newx = cos(rad)*x+sin(rad)*z;
        float newy = y;
        float newz = -sin(rad)*x+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundX(float rad) {
        float newx = x;
        float newy = cos(rad)*y-sin(rad)*z;
        float newz = sin(rad)*y+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}

Vec3 cross(Vec3 a, Vec3 b) {
    float newx = a.y*b.z - a.z*b.y;
    float newy = a.z*b.x - a.x*b.z;
    float newz = a.x*b.y - a.y*b.x;

    return new Vec3(newx, newy, newz);
}

Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(a.x*b.x + a.y*b.y + a.z*b.z);
}

float rotateTo(Vec3 a, Vec3 b) {
    Vec3 cross = cross(a, b);
    float first = cross.x+cross.y+cross.z;
    return atan2(first, dot(a,b));
}

// for detecting the edges of the area
float rayIntersectPlaneTime(Vec3 normal, Vec3 normPoint, Vec3 origin, Vec3 ray) {
    float denom = dot(normal, ray);
    if (denom > epsilon) {
        Vec3 pl = normPoint.minus(origin);
        float t = dot(pl, normal) / denom;
        if (t >= 0) return t;
        return Float.NaN;
    }
    return Float.NaN;
}

// for detecting collisions between other keewers
float rayIntersectSphereTime(Vec3 center, float radius, Vec3 origin, Vec3 ray) {
    Vec3 toCircle = center.minus(origin);

    float a = ray.length()*ray.length(); // square the length of the ray
    float b = -2*dot(ray, toCircle); // 2*dot between ray and dir from pos to center of circle
    float c = toCircle.lengthSqr() - (radius*radius); // difference of squares

    float d = b*b - 4*a*c; // discriminant

    if (d >= 0) {
        float t = (-b-sqrt(d))/(2*a); // only need first intersection
        if (t >= 0) return t; // only return if going to collide
        return Float.NaN; 
    }
    return Float.NaN; // no colliding
}