package generation.trunks;
import h3d.col.Point;

class LeafTrunk extends BaseTrunkFunction {
	public function new() {}

	override public function calculateCurvePoint(offset:Float) {
		return Math.sin(offset * Math.PI);
	}

	override public function generateBaseVertices(?levelOfDetail: Int) {
		return [
			new Point(0, -0.1, 0),
			new Point(-0.3, 0, 0),
			new Point(0, -0.05, 0),
			new Point(0.3, 0, 0)
		];
	}

	override public function generateHeight() {
		return 0.5 + Math.random() * 1;
	}
}
