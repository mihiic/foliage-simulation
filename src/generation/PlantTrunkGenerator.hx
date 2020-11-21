package generation;

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

    public function new(scene: Scene) {
        this._scene = scene;

        this.generateShape();
        this.extrapolateBaseShape();
        this.generateIndexBuffer();
        this.generateCapIndices();
        this.generateObject();
    }

    private function generateShape() {
        this._vertices = [
            new Point(-0.04, -0.07, 0),
            new Point(-0.05, 0.07, 0),
            new Point(0.09, 0, 0)
        ];

        this._basePolygonSides = 3;
    }

    private function extrapolateBaseShape() {
        var currentHeight: Float = 0;
        var currentScale = 1.0;
        var i = 1;
        while (i < 8) {
            currentHeight = i * 0.05;

            _vertices.push(new Point(-0.04, -0.07, currentHeight));
            _vertices.push(new Point(-0.05, 0.07, currentHeight));
            _vertices.push(new Point(0.09, 0, currentHeight));

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

                trace(strip);

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
        // triangle fan generation
        // bottom cap -> CCW (normals facing downwards)
        var i: Int = 0;
        while (i < _basePolygonSides - 2) {
            _indexBuffer.push(0);
            _indexBuffer.push(i + 1);
            _indexBuffer.push(i + 2);
            i++;
        }

        // upper cap -> CW (normals facing upwards)
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
    }
}