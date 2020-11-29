package generation.trunks;

class LeafTrunk extends BaseTrunkFunction {
    public function new() {
    }

    override public function calculateCurvePoint(offset: Float) {
        return  Math.sin(offset * Math.PI);
    }
}
