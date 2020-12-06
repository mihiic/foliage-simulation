import h3d.Buffer;
import hxd.IndexBuffer;
import h3d.prim.Polygon;

class SkinWeightsPolygon extends Polygon {
    var weights: Array<Float>;

    public function setWeights(w: Array<Float>) {
        weights = w;
    }

    override function alloc( engine : h3d.Engine ) {
        dispose();
        
        trace('number of vertices', points.length);

		var size = 3;
		var names = ["position"];
		var positions = [0];
		if( normals != null ) {
			names.push("normal");
			positions.push(size);
			size += 3;
		}
		if( tangents != null ) {
			names.push("tangent");
			positions.push(size);
			size += 3;
		}
		if( uvs != null ) {
			names.push("uv");
			positions.push(size);
			size += 2;
		}
		if( colors != null ) {
			names.push("color");
			positions.push(size);
			size += 3;
        }
        if (weights != null) {
            names.push("weights");
            names.push("indexes");
        }

        var skinBuffser = new hxd.FloatBuffer();
        var indexIndex = new hxd.FloatBuffer();
        var buf = new hxd.FloatBuffer();
		for( k in 0...points.length ) {
			var p = points[k];
			buf.push(p.x);
			buf.push(p.y);
			buf.push(p.z);
			if( normals != null ) {
				var n = normals[k];
				buf.push(n.x);
				buf.push(n.y);
				buf.push(n.z);
			}
			if( tangents != null ) {
				var t = tangents[k];
				buf.push(t.x);
				buf.push(t.y);
				buf.push(t.z);
			}
			if( uvs != null ) {
				var t = uvs[k];
				buf.push(t.u);
				buf.push(t.v);
			}
			if( colors != null ) {
				var c = colors[k];
				buf.push(c.x);
				buf.push(c.y);
				buf.push(c.z);
            }
            if (weights != null) {
                var w = weights[k];
                skinBuffser.push(w * 0.33);
                indexIndex.push(0);
                
                // WTF!?!?!?
                if (k == 35) {
                    skinBuffser.push(w * 0.33);
                    indexIndex.push(0);

                    skinBuffser.push(w * 0.33);
                    indexIndex.push(0);
                }
            }
		}
		var flags : Array<h3d.Buffer.BufferFlag> = [];
		if( idx == null ) flags.push(Triangles);
		if( normals == null || tangents != null ) flags.push(RawFormat);
		buffer = h3d.Buffer.ofFloats(buf, size, flags);
        var sbuf = h3d.Buffer.ofFloats(skinBuffser, 1, flags);

        for( i in 0...names.length ) {
            if (names[i] == 'weights') {
                addBuffer(names[i], sbuf, 0);
            } else if (names[i] == "indexes") {
                addBuffer(names[i], Buffer.ofFloats(indexIndex, 1, flags), 0);
            }
            else {
                addBuffer(names[i], buffer, positions[i]);
            }
        }

		if( idx != null )
			indexes = h3d.Indexes.alloc(idx);
	}
}