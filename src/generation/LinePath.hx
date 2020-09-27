package generation;
import h3d.scene.Graphics;
import h3d.scene.Scene;
import h3d.col.Point;

class LinePath {
    private var _points: Array<Point>;
    private var _enabledDebug: Bool;
    private var _graphics: Graphics;

    public function new(?points: Array<Point>) {
        if (points != null) {
            this.setPoints(points);
        }
    }

    public function setPoints(points: Array<Point>) {
        _points = points;
    }

    public function enableDebug(s3d: Scene) {
        _enabledDebug = true;
        _graphics = new Graphics(s3d);
    }

    public function render() {
        if (!_enabledDebug) {
            return;
        }
        _graphics.clear();
        _graphics.lineStyle(2, 0xff0000);

        var i = 1;
        while (i < _points.length) {
            _graphics.drawLine(_points[i - 1], _points[i]);
            i++;
        }
    }
}
