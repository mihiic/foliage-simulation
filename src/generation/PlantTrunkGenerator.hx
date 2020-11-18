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
        this.generateObject();
    }

    private function generateShape() {
        this._vertices = [
            new Point(-0.4, -0.7, 0),
            new Point(-0.5, 0.7, 0),
            new Point(0.9, 0, 0)
        ];

        this._basePolygonSides = 3;
    }

    private function extrapolateBaseShape() {
        var currentHeight: Float = 0;
        var currentScale = 1.0;
        var i = 1;
        while (i < 8) {
            currentHeight = i * 0.5;
            currentScale = 1 - i * 0.1;

            _vertices.push(new Point(-0.4 * currentScale, -0.7 * currentScale, currentHeight));
            _vertices.push(new Point(-0.5 * currentScale, 0.7 * currentScale, currentHeight));
            _vertices.push(new Point(0.9 * currentScale, 0, currentHeight));

            i++;
        }
    }

    private function generateIndexBuffer() {
        _indexBuffer = new IndexBuffer();

        var lastLeadingIndex: Int = _vertices.length - 2;
        
        // pseudo
        // for each two vertices in a base, get next layer and form quad from
        // 2 triangles polygons
        // last side loops back to first
        var currentVertexInLoop = 0;
        var currentLoop = 0;

        while (currentLoop < _vertices.length / _basePolygonSides) {
            while (currentVertexInLoop < _basePolygonSides) {
                var strip = [
                    currentLoop * _basePolygonSides + currentVertexInLoop, 
                    currentLoop * _basePolygonSides + (currentVertexInLoop + 1) % _basePolygonSides,
                    (currentLoop + 1) * _basePolygonSides + currentVertexInLoop,
                    (currentLoop + 1) * _basePolygonSides + (currentVertexInLoop + 1) % _basePolygonSides
                ];

                // 0 -> 3 -> 1
                // 0 -> 2 -> 3
                _indexBuffer.push(strip[0]);
                _indexBuffer.push(strip[3]);
                _indexBuffer.push(strip[1]);

                _indexBuffer.push(strip[0]);
                _indexBuffer.push(strip[2]);
                _indexBuffer.push(strip[3]);

                currentVertexInLoop++;
            }
            currentLoop++;
        }


        /*trace(lastLeadingIndex);
        var i = 0;
        while (i < lastLeadingIndex) {
            if (i % 2 == 0) {
                _indexBuffer.push(i);
                _indexBuffer.push(i + 1);
                _indexBuffer.push(i + 2);
            } else {
                _indexBuffer.push(i);
                _indexBuffer.push(i + 2);
                _indexBuffer.push(i + 1);
            }

            i++;
        }*/
    }

    private function generateObject() {
        _polygon = new Polygon(_vertices, _indexBuffer);
        _polygon.addNormals();

        _mesh = new Mesh(_polygon, _scene);
        _mesh.material.color.set(0.3, 0.8, 0.1);
    }
}