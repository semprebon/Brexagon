/*
    Cutters for inscribing a pattern into a surface

    TODO: provide separate end and top patterns
*/
include <ListUtils.scad>
include <HexUtils.scad>
include <Association.scad>

/*
    Create a brick wall
*/

HORIZONTAL_ANGLE = 0;
VERTICAL_ANGLE = 90;
DEFAULT_BRICK_SIZE = [12,4,4];
NO_PATTERN = false;
PATTERN_DEPTH = 0.4;

function scale_point(p, s) = map2(p, s, function(a,b) a*b);

function define_pattern(size = [1,1], strokes = [], depth = PATTERN_DEPTH) =
    associate(["size", size, "strokes", strokes, "depth", depth]);

function map_points(strokes, f) =
    [ for (stroke = strokes) [ for (point = stroke) f(point) ] ];

function offset_strokes(strokes, offset) = map_points(strokes, function(p) p + offset);

function repeat_strokes(count, offset, strokes) =
    let(offsets = generate(function(i) i*offset, count))
    fold(offsets, [], function(accum, x) concat(accum, offset_strokes(strokes, x)));

function set_pattern_depth(pattern, depth) =
    define_pattern(size=pattern("size"), strokes=pattern("strokes"), depth=depth);

function scale_pattern(pattern, scale) =
    let(
        new_size = map2(pattern("size"), scale, function(a,b) a*b) )
    define_pattern(
        size = new_size,
        depth = pattern("depth"),
        strokes = map_points(pattern("strokes"), function(p) scale_point(p, scale)) );

function expand_pattern(pattern, repeat, offset=undef) =
    //echo("expand_pattern: ", pattern=pattern(list=true), repeat=repeat, offset=offset)
    let(
        size = pattern("size"),
        new_size = map2(size, repeat, function (a,b) a*b),
        x_offset = [size.x, 0],
        y_offset = [0, size.y],
        centering_offset = is_undef(offset) ? [-new_size.x/2, 0] : offset
    )
    //echo("expand_pattern: ", size=size, x_offset=x_offset, y_offset=y_offset, centering_offset=centering_offset)
    define_pattern(
        size = new_size,
        depth = pattern("depth"),
        strokes = offset_strokes(repeat_strokes(repeat.y, y_offset,
            repeat_strokes(repeat.x, x_offset, pattern("strokes"))), centering_offset));
//        strokes = repeat_strokes(repeat.y, y_offset,
//            repeat_strokes(repeat.x, x_offset, pattern("strokes"))));

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
        for (stroke = pattern("strokes")) {
            line(stroke, depth=pattern("depth"));
        }
    }
}

module cut_pattern(pattern, offset=[0,0,0], rotation=[0,0,0]) {
        translate(offset) rotate(rotation) pattern_cutter(pattern);
}

BRICK_PATTERN = define_pattern(
    size=[8,6],
    strokes = [[[0,0],[8,0]], [[0,3],[8,3]], [[0,0],[0,3]], [[4,3],[4,6]]]);

module brick_wall(size, angle, offset=[0,0], scale=[1,1], depth=PATTERN_DEPTH) {
    expand = [10,4];
    bricks = expand_pattern(set_pattern_depth(scale_pattern(BRICK_PATTERN, scale), depth), expand);
    difference() {
        x_offset = [0,0,0];
        y_offset = [0,size.y/2,0];
        z_offset = [0,0,size.z];
        translate([0,-size.y/2,0]) cube(size);
        cut_pattern(bricks, offset=x_offset+y_offset+to_3d_point(offset));
        cut_pattern(bricks, offset=x_offset-y_offset);
        cut_pattern(bricks, offset=[0,-size.y/2,0], rotation=[0,0,90]);
        cut_pattern(bricks, offset=[size.x,-size.y/2,0], rotation=[0,0,90]);
        cut_pattern(bricks, offset=[0,size.y/2,size.z], rotation=[90,0,0]);
    }
}
