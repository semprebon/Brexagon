include <HexUtils.scad>
include <OpenSCADLibraries/Association.scad>
include <BOSL/math.scad>
include <Tile.scad>

// hexagon points

HEX_SUB_UNIT = [1/16, size_to_height(1/16)];

HEX_POINTS = associate([
    "N",    [0, 8], "NE", [ 8, 4], "SE", [8,-4],
    "S",    [0,-8], "SW", [-8,-4], "NW", [-8,4],
    "Nc",    [0,6], "NEc", [ 6, 3], "SEc", [6,-3],
    "Sc",    [0,-6], "SWc", [-6,-3], "NWc", [-6,3],
    "Na",    [2,7], "NEa", [ 8, 2], "SEa", [6,-5],
    "Sa",    [-2,-7], "SWa", [-8,-2], "NWa", [-6,5],
    "Nb",    [-2,7], "NEb", [ 6, 5], "SEb", [8,-2],
    "Sb",    [2,-7], "SWb", [-6,-5], "NWb", [-8,2]]);

function e_pnt(hex_center, pos) =
    [ for (i = [0,1]) hex_center[i] + HEX_SUB_UNIT[i] * (DEFAULT_HEX_SIZE-2) * HEX_POINTS(pos)[i] ];

function define_elevation(polygon, height=1) =
    associate([
        "polygon", polygon,
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
        faces = concat(side_faces, [reverse(top_face), bottom_face]), convexity = 10);
}

module raise_elevation(vertices, elevation) {
    elevation_to_polygon(vertices, elevation);
}