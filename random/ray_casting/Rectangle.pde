public class Rectangle {
    public Vec2 tLeft, tRight, bLeft, bRight, center;
    public float rwidth, rheight;

    public Rectangle(float tlx, float tly, float rwidth_, float rheight_) {
        this.rwidth = rwidth_; this.rheight = rheight_;
        this.tLeft = new Vec2(tlx, tly);
        this.tRight = new Vec2(tlx+rwidth, tly);
        this.bLeft = new Vec2(tlx, tly + rheight);
        this.bRight = new Vec2(tlx + rwidth, tly+rheight);
        this.center = new Vec2(tlx+(floor(rwidth/2)), tly+(floor(rheight/2)));
    }
}