/*
    Cutters for inscribing a pattern into a surface.

    A pattern consists of a number of grooves. Each groove has a specified depth,
    and a number of points defining the path the groove takes in 2d space

    TODO: provide separate end and top patterns
    TODO: make associations easier to update without having to code all properties each time
*/
include <ListUtils.scad>
include <HexUtils.scad>
include <Association.scad>
include <ClippingAlgorithm.scad>

/*
    Create a brick wall
*/

HORIZONTAL_ANGLE = 0;
VERTICAL_ANGLE = 90;
DEFAULT_PATTERN_SIZE = [2*DEFAULT_SIDE,DEFAULT_SIDE];
DEFAULT_BRICK_SIZE = [12,4,4];
NO_PATTERN = false;
PATTERN_DEPTH = 0.4;

/*
    Point functions
*/
function scale_point(p, s) = map2(p, s, function(a,b) a*b);

function is_inside(size, point) = !is_undef(point) && (point.x < size.x) && (point.y < size.y);
/*
    Path functions
*/
function map_path(path, f) = [ for (point = path) f(point) ];

function verify_point(p) =
    assert(is_list(p) && len(p)==2 && is_num(p.x) && is_num(p.y), str("Bad Point:", p))
    p;

function verify_path(path) = map(path, function (p) verify_point(p));

/*
    returns a list of new paths
*/
function crop_path(path, size, previous, new_paths=[]) =
    let(
        //xxx = echo("crop_path: ", path=path, size=size, previous=previous, new_paths=new_paths),
        //yyy = verify_path(path),
        result =
            is_empty(path)
                ? new_paths
                : let(point = path[0], rest = drop(path))
                  //echo(point=point, rest=rest)
                  is_undef(previous)
                        ? crop_path(rest, size, point, is_inside(size,point) ? concat(new_paths, [[point]]) : new_paths)
                        : let(segment = verify_path(clip_segment_to_bounds(previous, point, [0,0,size.x, size.y])))
                          //echo("crop_path(breaking): ", previous=previous, segment=segment)
                          is_empty(segment)
                            ? crop_path(rest, size, point, new_paths)
                            : (previous == segment[0])
                                ? crop_path(rest, size, point, concat_to_last(new_paths, verify_path([segment[1]])))
                                : crop_path(rest, size, point, concat(new_paths, [verify_path(segment)])) )
    //echo("crop_path: ", result=result)
    result;

/*
    Groove object

    ECHO: grooves = [
        ["depth", 0.25, "path", [[0, 0], [8, 0]]],
        ["depth", 0.25, "path", [[0, 3], [8, 3]]], ["depth", 0.25, "path", [[0, 0], [0, 3]]],
        ["depth", 0.25, "path", [[4, 3], [4, 6]]]]
    WARNING: Assignment without variable name undef in file PatternCutters.scad, line 85
    ECHO: grooves = [["depth", 0.25, "path", [[0, 0], [8, 0]]], ["depth", 0.25, "path", [[8, 0], [16, 0]]], ["depth", 0.25, "path", [[0, 6], [8, 6]]], ["depth", 0.25, "path", [[8, 6], [16, 6]]], ["depth", 0.25, "path", [[0, 12], [8, 12]]], ["depth", 0.25, "path", [[8, 12], [16, 12]]], ["depth", 0.25, "path", [[0, 3], [8, 3]]], ["depth", 0.25, "path", [[8, 3], [16, 3]]], ["depth", 0.25, "path", [[0, 9], [8, 9]]], ["depth", 0.25, "path", [[8, 9], [16, 9]]], ["depth", 0.25, "path", [[0, 15], [8, 15]]], ["depth", 0.25, "path", [[8, 15], [16, 15]]], ["depth", 0.25, "path", [[0, 0], [0, 3]]], ["depth", 0.25, "path", [[8, 0], [8, 3]]], ["depth", 0.25, "path", [[0, 6], [0, 9]]], ["depth", 0.25, "path", [[8, 6], [8, 9]]], ["depth", 0.25, "path", [[0, 12], [0, 15]]], ["depth", 0.25, "path", [[8, 12], [8, 15]]], ["depth", 0.25, "path", [[4, 3], [4, 6]]], ["depth", 0.25, "path", [[12, 3], [12, 6]]], ["depth", 0.25, "path", [[4, 9], [4, 12]]], ["depth", 0.25, "path", [[12, 9], [12, 12]]], ["depth", 0.25, "path", [[4, 15], [4, 18]]], ["depth", 0.25, "path", [[12, 15], [12, 18]]]]
    WARNING: Assignment without variable name undef in file PatternCutters.scad, line 85
    ECHO: grooves = [["depth", 0.25, "path", [[[0, 0], [8, 0]]]], ["depth", 0.25, "path", [[[8, 0], [10, 0]]]], ["depth", 0.25, "path", [[[0, 6], [8, 6]]]], ["depth", 0.25, "path", [[[8, 6], [10, 6]]]], ["depth", 0.25, "path", [[[0, 3], [8, 3]]]], ["depth", 0.25, "path", [[[8, 3], [10, 3]]]], ["depth", 0.25, "path", [[[0, 9], [8, 9]]]], ["depth", 0.25, "path", [[[8, 9], [10, 9]]]], ["depth", 0.25, "path", [[[0, 0], [0, 3]]]], ["depth", 0.25, "path", [[[8, 0], [8, 3]]]], ["depth", 0.25, "path", [[[0, 6], [0, 9]]]], ["depth", 0.25, "path", [[[8, 6], [8, 9]]]], ["depth", 0.25, "path", [[[4, 3], [4, 6]]]], ["depth", 0.25, "path", [[[4, 9], [4, 10]]]]]

*/
function define_groove(depth=PATTERN_DEPTH, path=[]) =
    assert(!is_empty(path), str("EMPTY GROOVE!", path))
    associate(["depth", depth, "path", path]);

function map_groove_points(groove, f) =
    define_groove(
        depth = groove("depth"),
        path = [ for (p = groove("path")) f(p) ]);

function groove_bounding_box(groove) =
    is_empty(groove("path")) ? [[0,0],[0,0]]
        : let(
            xxx = verify_path(groove("path")),
            xs = [ for (p = groove("path")) p.x ],
            ys = [ for (p = groove("path")) p.y ])
        [ [min(xs), min(ys)], [max(xs), max(ys)] ];

function groove_size(groove) =
    let(b = groove_bounding_box(groove))
    b[1] - b[0];

function list_grooves(pattern) =
    let(list = is_function(pattern) ? pattern("grooves") : pattern)
    [ for (g = list) g(list=true) ];

/*
    Pattern object
*/
function define_pattern(size, grooves, depth = PATTERN_DEPTH, tag="") =
    let(
        bounding_boxes = [ for (g = grooves) groove_bounding_box(g) ],
        bounding_box = is_empty(bounding_boxes)
            ? [[0,0],[0,0]]
            : reduce(bounding_boxes, function (a, b)
                [[min(a[0].x,b[0].x), min(a[0].y,b[0].y)],
                 [max(a[1].x,b[1].x), max(a[1].y,b[1].y)]]),
       _size = (size != undef) ? size : bounding_box[1] - bounding_box[0] )
    associate(["size", _size, "grooves", grooves, "depth", depth, "bounds", bounding_box]);

function define_pattern_from_paths(size=undef, depth=PATTERN_DEPTH, paths=[], tag="") =
    echo("define_pattern_from_paths ", tag=tag)
    define_pattern(
        size = size,
        grooves = [ for (path = paths) define_groove(depth, path) ],
        tag = tag);

function offset_pattern(pattern, offset) =
    let(xxx = verify_point(offset))
    define_pattern(
        size = pattern("size"),
        grooves = [ for (groove = pattern("grooves")) map_groove_points(groove, function(p) p + offset) ],
        tag = str("offset ", pattern("tag")) );

function merge_patterns(a, b) =
    define_pattern(
        size = [max(a("size").x, b("size").x), max(a("size").y, b("size").y)],
        grooves = concat(a("grooves"), b("grooves")),
        tag = str(a("tag"), "-", b("tag")) );

function repeat_grooves(count, offset, grooves) =
    let(offsets = generate(function(i) i*offset, count))
    fold(offsets, [], function(accum, x) concat(accum, offset_grooves(grooves, x)));

function set_pattern_depth(pattern, depth) =
    define_pattern(size=pattern("size"), grooves=pattern("grooves"), depth=depth, tag = pattern("tag"));

function scale_pattern(pattern, scale) =
    echo("scale_pattern: ", pattern=pattern(list=true))
    let(
        new_size = map2(pattern("size"), scale, function(a,b) a*b) )
    define_pattern(
        size = new_size,
        depth = pattern("depth"),
        // TODO: should set to array of Groove objects
        grooves = [ for (g = pattern("grooves"))
            map_groove_points(g, function(p) scale_point(p, scale)) ],
        tag = str("scaled ", pattern("tag")));

function expand_pattern(pattern, repeat, offset) =
    echo("expand_pattern: ", pattern=pattern(list=true), repeat=repeat, offset=offset)
    let(
        x=1,
        size = pattern("size"),
        new_size = map2(size, repeat, function (a,b) a*b),
        _offset = is_undef(offset) ? size : offset,
        centering_offset = [0,0], //[-new_size.x/2, 0],
        x_offset = [size.x, 0],
        y_offset = [0, size.y],
        //echo("expand_pattern: ", _offset=_offset, centering_offset=centering_offset, x_offset=x_offset, y_offset=y_offset),
        grooves = [
            for (groove = pattern("grooves"))
                each [ for (j = range(repeat.y))
                    each [ for (i = range(repeat.x))
                        map_groove_points(groove, function (p) p + y_offset*j + x_offset*i + centering_offset) ]]],
        xxx = echo("expand_pattern: ", tag=pattern("tag"), grooves=list_grooves(grooves)) )
    define_pattern(
        size = new_size,
        depth = pattern("depth"),
        grooves = grooves,
        tag = str("expanded ", pattern("tag")));

function paths_to_grooves(paths, depth) =
    let(good_paths = remove(paths, function (p) is_empty(p)))
    [ for (path = good_paths) define_groove(depth=depth, path=verify_path(path)) ];

function crop_pattern(pattern, size) =
    let(
        all_grooves = fold(pattern("grooves"), [],
            function(list, g) concat(list, paths_to_grooves(crop_path(g("path"), size), g("depth")))),
        new_grooves = remove(all_grooves,
            function (g) is_empty(g("path"))))
    //echo("crop_pattern: ", pattern_grooves=list_grooves(pattern), all_grooves=all_grooves, new_grooves=new_grooves)
    define_pattern(
        size = size,
        depth = pattern("depth"),
        grooves = new_grooves,
        tag = str("crop ", pattern("tag")));

function tag_pattern(pattern, tag) =
    define_pattern(
        size = pattern("size"),
        depth = pattern("depth"),
        grooves = pattern("grooves"),
        tag = tag);

function repeated_x_grooves(n, dy, p0=[0,0], depth=0.3, size=DEFAULT_PATTERN_SIZE) =
    [ for (i = range(n)) define_groove(path=[[0, i*dy]+p0, [size.x, i*dy]+p0], depth=depth) ];

function repeated_y_grooves(n, dx, p0=[0,0], depth=0.3, size=DEFAULT_PATTERN_SIZE) =
    [ for (i = range(n)) define_groove(path=[[i*dx, 0]+p0, [i*dx, size.y]+p0], depth=depth) ];

function brick_pattern(brick_counts, size=DEFAULT_PATTERN_SIZE, depth=0.3, x_offset) =
    let(
        d = [ for (i = range(brick_counts)) size[i] / brick_counts[i] ],
        _x_offset = is_undef(x_offset) ? d.x/2 : x_offset,
        horizontals = repeated_x_grooves(brick_counts.y+1, d.y, size=size),
        verticals = flatten([ for (j=range(brick_counts.y))
                repeated_y_grooves(brick_counts.x, d.x, p0=[(j % 2) * _x_offset, j*d.y], size=[size.x, d.y]) ]) )
    define_pattern(
        size = size,
        depth = depth,
        grooves = concat(horizontals, verticals));


function to_3d_point(p, y=0) = [p.x, y, p.y];

module line_segment(p1, p2, depth) {
    side = depth * (2 / sqrt(2));
    vector = p2-p1;
    length = sqrt(vector.x*vector.x + vector.y*vector.y);
    rotation = -atan2(vector.y, vector.x);
    //echo(p1=p1, p2=p2, vector=vector, length=length, center=center, rotation=rotation);
    translate(to_3d_point(p1)) rotate([0,rotation,0])
        rotate([45,0,0]) translate([length/2,0,0]) cube([length,side,side], center=true);
}

module end_point(p, depth) {
    translate(to_3d_point(p)) rotate([90,0,0]) {
        cylinder(r1=depth, r2=0, h=depth, $fn=12);
        translate([0,0,-depth]) cylinder(r2=depth, r1=0, h=depth, $fn=12);
    }
}

module line(points, depth) {
    for (i = range(points)) {
        let(p2 = points[(i+1) % len(points)])
        line_segment(points[i], p2, depth);
        end_point(points[i], depth);
    }
}

/*
*/
module pattern_cutter(pattern) {
    if (NO_PATTERN == false) {
        for (groove = pattern("grooves")) {
            line(groove("path"), depth=groove("depth"));
        }
    }
}

module cut_pattern(pattern, offset=[0,0,0], rotation=[0,0,0]) {
        translate(offset) rotate(rotation) pattern_cutter(pattern);
}

BRICK_PATTERN = brick_pattern(brick_counts = [5,4], depth=0.3);

WOOD_PATTERN = brick_pattern(brick_counts = [3,20], depth=0.15, size=[5*DEFAULT_SIDE, 3*DEFAULT_HEX_SIZE]);
/*
    size=[20,6],
    tag = "WOOD",
    grooves = [
        define_groove(depth=0.3, path=[[0,0],[20,40]]),
        define_groove(depth=0.3, path=[[4,0],[4,2]]),
        define_groove(depth=0.3, path=[[0,2],[20,2]]),
        define_groove(depth=0.3, path=[[11,2],[11,4]]),
        define_groove(depth=0.3, path=[[0,4],[20,4]]),
        define_groove(depth=0.3, path=[[15,4],[15,6]]),
        define_groove(depth=0.3, path=[[0,6],[20,6]]) ]);
*/
BLANK_PATTERN = define_pattern(
    size=DEFAULT_PATTERN_SIZE,
    grooves = []);
