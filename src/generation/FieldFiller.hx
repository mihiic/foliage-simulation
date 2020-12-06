package generation;

import h3d.scene.Scene;
import h3d.scene.Mesh;

typedef FieldSettings = {
    width: Int,
    height: Int,
    density: Int,
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
            density: density
        }
        _scene = scene;

        generateFieldBase();
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
}