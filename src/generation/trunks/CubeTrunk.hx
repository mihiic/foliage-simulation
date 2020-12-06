package generation.trunks;

import h3d.col.Point;

class CubeTrunk extends BaseTrunkFunction {
	public function new() {}

	override public function calculateCurvePoint(offset:Float) {
		return 1;
	}

	override public function generateBaseVertices(?levelOfDetail: Int) {
		return [
			new Point(-0.5, -0.5, 0),
			new Point(-0.5, 0.5, 0),
			new Point(0.5, 0.5, 0),
			new Point(0.5, -0.5, 0)
		];
	}

	override public function generateHeight() {
		return 0.5 + Math.random() * 1;
	}
}
