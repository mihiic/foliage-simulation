package generation;

import h3d.prim.FBXModel;
import h3d.prim.MeshPrimitive;
import h3d.scene.MultiMaterial;
import h3d.scene.CameraController;
import haxe.ds.Vector;
import h3d.Matrix;
import h3d.anim.Skin;
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
    private var _polygon: SkinWeightsPolygon;
    private var _mesh: Mesh;
    private var _material: Material;
    private var _scene: Scene;

    private var _basePolygonSides: Int;
    private var _baseVertices: Array<Point>;

    private var _levelOfDetail: Int;
    private var _heightPerSegment: Float;
    private var _trunkFunction: BaseTrunkFunction;
    private var _skeleton: Skin;

    public function new(
        scene: Scene,
        levelOfDetail = 8,
        ?height: Float,
        ?trunkFunction: BaseTrunkFunction
    ) {
        this._scene = scene;

        this._levelOfDetail = levelOfDetail;

        if (trunkFunction == null) {
            _trunkFunction = new LeafTrunk();
        } else {
            _trunkFunction = trunkFunction;
        }

        if (height != null) {
            _heightPerSegment = height / this._levelOfDetail;
        } else {
            var h = trunkFunction.generateHeight();
            _heightPerSegment = h / this._levelOfDetail;
        }

        this.generateShape();
        this.extrapolateBaseShape();
        this.generateIndexBuffer();
        this.generateCapIndices();
        this.generateObject();

        this.generateSkeleton();
    }

    public function setPosition(position: Point) {
        _mesh.setPosition(position.x, position.y, position.z);
    }

    private function generateShape() {
        this._vertices = this._trunkFunction.generateBaseVertices(_levelOfDetail);
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
        _polygon = new SkinWeightsPolygon(_vertices, _indexBuffer);
        _polygon.unindex();
        _polygon.addNormals();

        //_mesh = new Mesh(_polygon, _scene);
        //_mesh.material.color.set(0.3, 0.8, 0.1);
        // _mesh.material.receiveShadows = false;
    }

    // calculates offset by using quadratic function with offset at base
    private function plantWidthCurve(offset: Float) {
        return _trunkFunction.calculateCurvePoint(offset);
    }

    private function generateSkeleton() {
        _skeleton = new Skin('plant', _vertices.length, 2);
        _skeleton.primitive = _polygon;

        var joints: Array<Joint> = [];

        var i = 0;
        while (i <= _levelOfDetail) {
            var joint = new Joint();
            joint.index = i;
            // joint.bindIndex = i;

            joint.defMat = getPoseMatrix(i);
            var m = new Matrix();
            m.identity();
            joint.transPos = m;

            /*if (i > 0) {
                joint.parent = joints[joints.length - 1];
            }*/
            joints.push(joint);
            i++;
        }
        _skeleton.setJoints(joints, [joints[0]]);
        
        var ring = 0;
        for (joint in joints) {
            i = 0;
            while (i < _baseVertices.length) {
                _skeleton.addInfluence(ring * _baseVertices.length + i, joint, 1);
                i++;
            }
            ring++;
        }

        _skeleton.initWeights();
        // _skeleton.split(1, [], null);
        //_skeleton.initWeights();

        renderSkeleton();
        assignVerticesToJoints();
    }

    private function getCenterOfMassForPosition(ring: Int) {
        var points = [];
        var i = ring * _baseVertices.length;
        while (i < (ring + 1) * _baseVertices.length) {
            points.push(_vertices[i]);
            i++;
        }

        var x: Float = 0;
        var y: Float = 0;
        var z: Float = 0;

        for (point in points) {
            x += point.x;
            y += point.y;
            z += point.z;
        }

        var normalFactor = 1 / points.length;
        return new Point(x * normalFactor, y * normalFactor, z * normalFactor);
    }

    private function getPoseMatrix(ring: Int): Matrix {
        var matrix = new Matrix();
        var point = this.getCenterOfMassForPosition(ring);
        matrix.initTranslation(
            point.x, point.y, point.z
        );

        return matrix;
    }

    private function renderSkeleton() {
        var points = [];

        for (joint in _skeleton.allJoints) {
            // trace(joint.defMat);
            points.push(new Point(
                joint.defMat.tx, joint.defMat.ty, joint.defMat.tz
            ));
        }

        var line = new LinePath(points);
        line.enableDebug(_scene);
        line.render();
    }

    private function assignVerticesToJoints() {
        var i = 0;
        var vertexJoints = new Vector<Int>(_vertices.length);
        var vertexWeights = new Vector<Float>(_vertices.length);
        while (i < _vertices.length) {
            vertexJoints[i] = 1;
            vertexWeights[i] = 1;
            i++;
        }

        //_skeleton.vertexJoints = vertexJoints;
        //_skeleton.vertexWeights = vertexWeights;

        // _skeleton.allJoints[1].defMat.ty = 2;

        var material = Material.create();
        material.color.set(0.3, 0.8, 0.1);
        //var skin = new h3d.scene.Skin(_skeleton, [material], _scene);
        //var mesh = new Mesh(_polygon, material, _scene);
        // var multiMaterialMesh = new MultiMaterial(_polygon, [material], _scene);
        this.testBasicSkin();
        //trace(skin.materials);
        //skin.material.color.set(0.3, 0.8, 0.1);
        _mesh = new Mesh(_polygon, _scene);
        _mesh.material.color.set(0.3, 0.8, 0.1);
         _mesh.material.receiveShadows = false;
        // skin.showJoints = true;
    }

    private function testBasicSkin() {
        var skeleton = new Skin('skin', _vertices.length, 1);
        skeleton.primitive = _polygon;
        skeleton.initWeights();

        var material = Material.create();
        material.color.set(0.3, 0.8, 0.1);
        material.receiveShadows = false;

        var index = [];
        var buffer = [];
        var i = 0.0;
        for (v in _vertices) {
            index.push(0);
            buffer.push(i);
            i++;
        }

        _skeleton.split(1, index, null);
        _polygon.setWeights(buffer);
        // trace(_skeleton.primitive.)
        // new MeshPrimitive();
        var skin = new h3d.scene.Skin(_skeleton, [material], _scene);
        skin.showJoints = true;
        // new MeshPrimitive
        //new Scene
    }
}