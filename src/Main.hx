import generation.trunks.CubeTrunk;
import generation.FieldFiller;
import generation.trunks.LeafTrunk;
import generation.trunks.TyphaTrunk;
import generation.PlantTrunkGenerator;
import generation.LinePath;
import h3d.scene.CameraController;
import h3d.Vector;
import h3d.scene.Mesh;
import h3d.scene.fwd.DirLight;

class Main extends hxd.App {
	private var time:Float = 0;
	private var obj:Mesh;
	private var y = 0;

	private var path:LinePath;
	private var light:DirLight;

	override function init() {
		light = new DirLight(new Vector(0, 1, -1), s3d);
		s3d.lightSystem.ambientLight.set(0.2, 0.2, 0.2);
		s3d.camera.target = new Vector(0, 0, 0.5);
		s3d.camera.pos.set(-0.1, 0, 5);
		new CameraController(s3d).loadFromCamera();

		// var grass = new PlantTrunkGenerator(s3d, 8, 1.2, new TyphaTrunk());
		var grass = new PlantTrunkGenerator(s3d, 1, 1.2, new CubeTrunk());

		// floor plane
		var ff = new FieldFiller(s3d, 8, 0);
	}

	override function update(dt:Float) {
		time += dt;

		light.setDirection(new Vector(Math.cos(time), Math.sin(time), -1));
	}

	static function main() {
		new Main();
	}
}
