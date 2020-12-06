package generation;

import generation.trunks.TyphaTrunk;
import h3d.col.Point;
import generation.trunks.LeafTrunk;
import h3d.scene.Scene;
import h3d.scene.Mesh;

typedef FieldSettings = {
    width: Int,
    height: Int,
    density: Float,
}

class FieldFiller {
    private var _settings: FieldSettings;
    private var _scene: Scene;
    public function new(
        scene: Scene,
        levelOfDetail = 8,
        density = 1,
        width = 10,
        height = 10,
        ?trunkFunction: BaseTrunkFunction
    ) {
        _settings = {
            width: width,
            height: height,
            density: 1 / density
        }
        _scene = scene;

        generateFieldBase();
        populateField();
    }

    private function generateFieldBase() {
        var prim = new h3d.prim.Cube();
        prim.unindex();
        prim.addNormals();

        var o = new Mesh(prim, _scene);
        o.setPosition(-_settings.width / 2,-_settings.height / 2, 0);
        o.scaleX = _settings.width;
        o.scaleY = _settings.height;
        o.scaleZ = 0.001;

        o.material.color.set(0, 0.15, 0.25);
    }

    private function populateField() {
        // density is how many leafes on average per unit of area
        var units = _settings.width * _settings.height / _settings.density;

        var i = 0;
        while (i < units) {
            var x = Math.random() * _settings.width - _settings.width / 2;
            var y = Math.random() * _settings.height - _settings.height / 2;

            var trunk = Math.random() > 0.3 ? new LeafTrunk() : new TyphaTrunk();
            var grass = new PlantTrunkGenerator(_scene, 8, null, trunk);
            grass.setPosition(new Point(x, y, 0));
            i++;
        }
    }
}