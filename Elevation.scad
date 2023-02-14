include <HexUtils.scad>
include <OpenSCADLibraries/Association.scad>
include <BOSL/math.scad>
include <Tile.scad>

function define_elevation(polygon, height=1) =
    associate([
        "polygon", DEFAULT_HEX_SIZE * polygon,
        "height", height]);

function nearest_vertex(poly, point) = fold(poly, [1/0, undef],
    function (mem, p) let(d = distance(point, p)) (d < mem[0]) ? [d,p] : mem)[1];

module elevation_to_polygon(vertices, elevation) {
    top_polygon = [ for (p = elevation("polygon")) concat(p, [elevation("height")]) ];
    echo(top_polygon=top_polygon, polygon=elevation("polygon"));
    top_face = [ for (i = range(top_polygon)) i ];
    bottom_polygon = [ for (p = elevation("polygon")) concat(nearest_vertex(vertices, p), [0]) ];
    max = len(top_polygon);
    side_faces = [ for (i = top_face) [i, (i+1) % max, (i+1) % max + max, i+max] ];
    bottom_face = [ for (i = top_face) i + max ];
    echo(points=concat(top_polygon, bottom_polygon), triangles=concat(side_faces, [top_face, bottom_face]));
    polyhedron(points = concat(top_polygon, bottom_polygon),
        faces = concat(side_faces, [top_face, bottom_face]), convexity = 10);
}

module raise_elevation(vertices, elevation) {
    elevation_to_polygon(vertices, elevation);
}