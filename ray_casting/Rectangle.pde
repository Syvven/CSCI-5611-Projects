public class Rectangle {
    public Vec2 tLeft, tRight, bLeft, bRight, center;
    public float rwidth, rheight;

    public Rectangle(float tlx, float tly, float rwidth_, float rheight_) {
        tLeft = new Vec2(tlx, tly);
        tRight = new Vec2(tlx+rwidth, tly);
        bLeft = new Vec2(tlx, tly + rheight);
        bRight = new Vec2(tlx + rwidth, tly+rheight);
        center = new Vec2(tlx+(floor(rwidth/2)), tly+(floor(rheight/2)));
        rwidth = rwidth_; rheight = rheight_;
    }
}