package generation;

import generation.trunks.LeafTrunk;
import h3d.scene.Scene;
import h3d.mat.Material;
import h3d.scene.Mesh;
import h3d.prim.Polygon;
import hxd.IndexBuffer;
import h3d.col.Point;

class PlantTrunkGenerator {
    private var _vertices: Array<Point>;
    private var _indexBuffer: IndexBuffer;
    private var _polygon: Polygon;
    private var _mesh: Mesh;
    private var _material: Material;
    private var _scene: Scene;

    private var _basePolygonSides: Int;
    private var _baseVertices: Array<Point>;

    private var _levelOfDetail: Int;
    private var _heightPerSegment: Float;
    private var _trunkFunction: BaseTrunkFunction;

    public function new(
        scene: Scene,
        levelOfDetail = 8,
        ?height: Float,
        ?trunkFunction: BaseTrunkFunction
    ) {
        this._scene = scene;

        this._levelOfDetail = levelOfDetail;
        if (height != null) {
            _heightPerSegment = height / this._levelOfDetail;
        } else {
            var h = 0.5 + Math.random() * 1.5;
            _heightPerSegment = h / this._levelOfDetail;
        }

        if (trunkFunction == null) {
            _trunkFunction = new LeafTrunk();
        }

        this.generateShape();
        this.extrapolateBaseShape();
        this.generateIndexBuffer();
        this.generateCapIndices();
        this.generateObject();
    }

    private function generateShape() {
        this._vertices = [
            new Point(0, -0.1, 0),
            new Point(-0.3, 0, 0),
            new Point(0, -0.05, 0),
            new Point(0.3, 0, 0),
        ];

        this._basePolygonSides = this._vertices.length;

        this._baseVertices = [];
        var i = 0;
        while (i < this._basePolygonSides) {
            var v = this._vertices[i];
            _baseVertices.push(new Point(v.x, v.y, v.z));
            _vertices[i].scale(this.plantWidthCurve(0));
            i++;
        }
    }

    private function extrapolateBaseShape() {
        var currentHeight: Float = 0;
        var currentScale = this.plantWidthCurve(0);

        var i = 1;
        while (i <= this._levelOfDetail) {
            currentHeight = i * _heightPerSegment;
            currentScale = this.plantWidthCurve(i / this._levelOfDetail);

            var j = 0;
            while (j < _basePolygonSides) {
                var nextVertex = new Point(
                    _baseVertices[j].x * currentScale,
                    _baseVertices[j].y * currentScale,
                    currentHeight
                );
                _vertices.push(nextVertex);
                j++;
            }

            i++;
        }
    }

    private function generateIndexBuffer() {
        _indexBuffer = new IndexBuffer();

        var currentVertexInLoop = 0;
        var currentLoop = 0;

        while (currentLoop < _vertices.length / _basePolygonSides - 1) {
            while (currentVertexInLoop < _basePolygonSides) {
                var strip = [
                    currentLoop * _basePolygonSides + currentVertexInLoop, 
                    currentLoop * _basePolygonSides + (currentVertexInLoop + 1) % _basePolygonSides,
                    (currentLoop + 1) * _basePolygonSides + currentVertexInLoop,
                    (currentLoop + 1) * _basePolygonSides + (currentVertexInLoop + 1) % _basePolygonSides
                ];

                _indexBuffer.push(strip[0]);
                _indexBuffer.push(strip[3]);
                _indexBuffer.push(strip[1]);

                _indexBuffer.push(strip[0]);
                _indexBuffer.push(strip[2]);
                _indexBuffer.push(strip[3]);

                currentVertexInLoop++;
            }
            currentLoop++;
            currentVertexInLoop = 0;
        }
    }

    private function generateCapIndices() {
        var i: Int = 0;
        while (i < _basePolygonSides - 2) {
            _indexBuffer.push(0);
            _indexBuffer.push(i + 1);
            _indexBuffer.push(i + 2);
            i++;
        }

        i = 0;
        var lastRingStart = _vertices.length - _basePolygonSides;
        while (i < _basePolygonSides - 2) {
            _indexBuffer.push(lastRingStart);
            _indexBuffer.push(lastRingStart + i + 2);
            _indexBuffer.push(lastRingStart + i + 1);
            i++;
        }
    }

    private function generateObject() {
        _polygon = new Polygon(_vertices, _indexBuffer);
        _polygon.unindex();
        _polygon.addNormals();

        _mesh = new Mesh(_polygon, _scene);
        _mesh.material.color.set(0.3, 0.8, 0.1);
        _mesh.material.receiveShadows = false;
    }

    // calculates offset by using quadratic function with offset at base
    private function plantWidthCurve(offset: Float) {
        return _trunkFunction.calculateCurvePoint(offset);
    }
}