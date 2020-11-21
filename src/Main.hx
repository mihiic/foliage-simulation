import generation.PlantTrunkGenerator;
import generation.BasicGrass;
import format.swf.Data.MorphShapeData1;
import generation.LinePath;
import h3d.scene.CameraController;
import h3d.prim.Cube;
import hxd.IndexBuffer;
import h3d.col.Point;
import h3d.Vector;
import h3d.scene.Mesh;
import h3d.scene.fwd.DirLight;

class Main extends hxd.App {
	private var time:Float = 0;
	private var obj:Mesh;
	private var y = 0;

	private var path: LinePath;

	override function init() {
		var light = new DirLight(new Vector(1, 1, -1), s3d);
		s3d.lightSystem.ambientLight.set(0.2, 0.2, 0.2);

		s3d.camera.target = new Vector(0, 0, 0);
		s3d.camera.pos.set(-0.1, 0, 5);
		new CameraController(s3d).loadFromCamera();

		this.path = new LinePath([
			new Point(0, 0, 0),
			new Point(0, 0.5, 0.5),
			new Point(0, 0, 1)
		]);
		this.path.enableDebug(s3d);
		this.path.render();

		var grass = new PlantTrunkGenerator(s3d);
	}

	override function update(dt:Float) {
		time += 0.1 * dt;
	}

	static function main() {
		new Main();
	}
}
