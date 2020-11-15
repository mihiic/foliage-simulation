package generation;

import h3d.scene.Scene;
import h3d.mat.Material;
import h3d.scene.Mesh;
import h3d.prim.Polygon;
import hxd.IndexBuffer;
import h3d.col.Point;

class BasicGrass {
    private var _vertices: Array<Point>;
    private var _indexBuffer: IndexBuffer;
    private var _polygon: Polygon;
    private var _mesh: Mesh;
    private var _material: Material;

    private var _debugEnabled: Bool;
    private var _scene: Scene;

    public function new(scene: Scene) {
        this._scene = scene;

        this.generateVertices();
        this.generateIndexBuffer();
        this.generateObject();
    }

    private function generateVertices() {
        this._vertices = [
            new Point(0, 0.25, 0),
            new Point(0, -0.25, 0),
            new Point(0, 0.15, 0.25),
            new Point(0, -0.15, 0.25),
            new Point(0, 0.10, 0.5),
            new Point(0, -0.10, 0.5),
            new Point(0, 0.01, 0.75),
            new Point(0, -0.01, 0.75)
        ];
    }

    private function generateIndexBuffer() {
        _indexBuffer = new IndexBuffer();

        var lastLeadingIndex: Int = _vertices.length - 2;
        trace(lastLeadingIndex);
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
        }
    }

    private function generateObject() {
        _polygon = new Polygon(_vertices, _indexBuffer);
        _polygon.addNormals();

        _mesh = new Mesh(_polygon, _scene);
        _mesh.material.color.set(0.3, 0.8, 0.1);
    }
}