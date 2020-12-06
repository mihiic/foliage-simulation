package generation;
import h3d.col.Point;

class BaseTrunkFunction {
    public function calculateCurvePoint(offset: Float): Float {
        return 1;
    }

    public function generateBaseVertices(?levelOfDetail: Int): Array<Point> {
        return [];
    }

    public function generateHeight(): Float {
        return 0;
    }
}
