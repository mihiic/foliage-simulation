package generation.trunks;

import h3d.col.Point;

class TyphaTrunk extends BaseTrunkFunction {
	public function new() {}

	override public function calculateCurvePoint(offset:Float) {
        if (offset < 0.6) {
            return 0.1;
        }
        if (offset > 0.98) {
            return 0;
        }

        return 0.5;
	}

	override public function generateBaseVertices(?levelOfDetail: Int) {
        if (levelOfDetail == null) {
            return [
                new Point(-0.1, -0.1, 0),
                new Point(-0.1, 0.1, 0),
                new Point(0.1, 0.1, 0),
                new Point(0.1, -0.1, 0)
            ];
        }
        var vertices = [];
        var i = 0;
        while (i < levelOfDetail) {
            var offset = i / levelOfDetail;
            vertices.push(new Point(
                Math.cos(offset * Math.PI * 2) * 0.1,
                -Math.sin(offset * Math.PI * 2) * 0.1,
                0
            ));
            i++;
        }
        return vertices;
	}
}


