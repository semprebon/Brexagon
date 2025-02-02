/*
    Basic tile construction used to create specific tiles

    TODO: Reorganize barrier code to put more in Barrier.scad
    TODO: Apply floor patterns to elevations
    TODO: Implement image-based and/or imported STL patterns
    TODO: Revise latch mechanism to be sturdier and more lenient of printing problems
    TODO: Eliminate "Can't open include file 'Tile.scad' warnings(?)
    TODO: fix pattern at corners
*/

include <HexUtils.scad>
include <OpenSCADLibraries/Association.scad>
include <OpenSCADLibraries/ListUtils.scad>
include <PatternCutters.scad>
include <Barrier.scad>
include <Elevation.scad>

VERSION = 1.1;
TOLERANCE = 0.2;    // tolerance for parts intended to slide against each other
LINE_WIDTH = 0.4;   // slicer line width
SEPARATION = 0.2;   // space separating tiles (in addition to tolerance)
TILE_HEIGHT = 5.6;  // nominal height of brick (excluding tenon if present)
TOP_THICKNESS = 2;  // Thickness of tile top
WALL_THICKNESS = 4*LINE_WIDTH; // thickness of tile hexagon walls
BASE_HEIGHT = 1.6;  // Height of base plane (i.e., without latching mechanics)
TENON_HEIGHT = 2;   // TODO: rename
TENON_FIT = -0.2;   // increase to loosen, decrease to tighten; was -0.04; TODO: rename
LAYER_HEIGHT = 0.2; // Slicer layer height
PIN_WALL_THICKNESS = 3*LINE_WIDTH;
PIN_HEIGHT = TILE_HEIGHT - TOP_THICKNESS;
LATCH_INSET = 1.5*LINE_WIDTH;   // inset from latch tip to pin shaft
CLIP_HEIGHT = 6*LAYER_HEIGHT;
CLIP_WIDTH = 8;
SOCKET_RADIUS = 2;

BARRIER_HEIGHT = DEFAULT_SIDE;

$FN = 60;

HEXAGON_BEVEL_DEPTH = WALL_THICKNESS/2;
MORTISE_SIZE = (DEFAULT_HEX_SIZE - SEPARATION) - 2*WALL_THICKNESS;
PIN_RADIUS = MORTISE_SIZE/2-WALL_THICKNESS;

USE_PIN = true;

function define_hex(position, barriers)
    = associate(["position", position, "barriers", barriers]);

/* Tile geometries */
TILE_SHAPE_HEXAGON = "hexagon";
TILE_SHAPE_TRAPEZOID = "trapezoid";
TILE_SHAPE_RECTANGLE = "rectangle";

/*
    Define a specified shape and size of tile from texture information
*/
function define_tile(shape, size, used=undef, barriers=[], elevations=[]) =
    let (
        positions = (shape == TILE_SHAPE_HEXAGON) ? hex_positions(size)
            : (shape == TILE_SHAPE_TRAPEZOID) ? trapezoid_positions(size)
            : (shape == TILE_SHAPE_RECTANGLE) ? rect_positions(size)
            : (shape == "triangle") ? trapezoid_positions(1, (size.x == undef) ? size: size.x, 1)
            : ["error"],
        _used = is_undef(used) ? [ for (i = range(positions)) i ] : used,
        hexes = [for (i = range(len(positions)))
        // TODO: in_list not working here, using index_of instead
                    if (!is_undef(index_of(_used, i))) define_hex(position=positions[i]) ],
//                    if (in_list(_used, i)) define_hex(position=positions[i]) ],
        xs = [ for (h=hexes) axial_to_xy(h("position")).x ],
        ys = [ for (h=hexes) axial_to_xy(h("position")).y ],
        ext = [DEFAULT_HEX_SIZE, size_to_height(DEFAULT_HEX_SIZE)] / 2,
        bounds = [[min(xs)-ext.x, min(ys)-ext.y], [max(xs)+ext.x, max(ys)+ext.y]],
        shape_size = [bounds[1].x-bounds[0].x, bounds[1].y-bounds[0].y])
        //echo("define_tile: ", xs=xs, ys=ys, bounds=bounds, size=shape_size) )
    associate(["shape", shape, "tile_size", size, "hexes", hexes, "barriers", barriers,
        "elevations", elevations,
        "bounds", bounds,
        "size", shape_size]);

function hex_center(hexes, i, size=DEFAULT_HEX_SIZE) =
    axial_to_xy(hexes[i]("position"), DEFAULT_HEX_SIZE);

function hex_vertices(hex) =
    let(
        center = axial_to_xy(hex("position")),
        _dx = dx(DEFAULT_HEX_SIZE),
        _dy = dy(DEFAULT_HEX_SIZE),
        vertex_offsets = [[0,2*_dy],[_dx,_dy],[_dx,-_dy],[0,-2*_dy],[-_dx,-_dy],[-_dx,_dy]])
    [for (p = vertex_offsets) center + p ];

/*
    Return true if two corner points are adjacent
*/
function are_adjacent(p1, p2) =
    (verify_point(p1) == verify_point(p2)) ? false
        : let(
            v = p2 - p1,
            range = DEFAULT_SIDE+TOLERANCE)
        v.x*v.x + v.y*v.y <= range*range;

function tile_vertices(tile) = unique(flat_map(tile("hexes"), function(hex) hex_vertices(hex)));
/*
    Returns a list of outer corner points of a tile (i.e, points only connected
    to a single hex),
*/
function corner_points(tile, offset=0) =
    let(
        vertices = tile_vertices(tile),
        corners = keep(vertices,
            function(p1)
                let(
                    adjacent_count = fold(vertices, 0, function(count, p2) are_adjacent(p1,p2) ? count+1 : count))
                    adjacent_count == 2))
    corners;

function hex_center_for_corner(tile, corner) =
    let(
        hex = find(tile("hexes"), function(h) are_adjacent(corner, axial_to_xy(h("position")))))
    axial_to_xy(hex("position"));

function barrier_point(x,y) = [x,y];
//    let(x1 = x/2,
//        y1 = floor(y/4) + [1/16,3/16,13/16,15/16][(y+4) % 4])
//    [x1,y1];
function y_barrier(x, y1, y2) = [barrier_point(x,y1), barrier_point(x,y2)];
function x_barrier(y, x1, x2) = [barrier_point(x1,y), barrier_point(x2,y)];

function is_elevated(tile, hex_index) = !is_empty(tile("elevations"));

module hexagon_prism(size, height) {
    linear_extrude(height=height) hex_shape(size);
}

module beveled_hexagon_prism(size, height, bevel=WALL_THICKNESS/3) {
    hull() {
        hexagon_prism(size=size, height=height-bevel);
        hexagon_prism(size=size-2*bevel, height=height);
    }
}

module mirrored_pair(planes) {
    children();
    mirror(planes) children();
}


module latch_outline(block, inset, back_bevel=0, locking=false) {
    //echo(block=block, inset=inset, back_bevel=back_bevel);
    p_start = block.y - inset.y;
    outline = [[0,0],[0,p_start+(locking ? inset.x : 0)],[-inset.x,p_start+inset.x],[-inset.x,block.y-inset.x],[0,block.y],
            [block.x-inset.x-back_bevel,block.y],[block.x-inset.x,block.y-back_bevel],[block.x-inset.x,0],[0,0]];
    polygon(outline);
}

module tile_clip_socket() {
    block_width = WALL_THICKNESS;
    block_size = [block_width,PIN_HEIGHT];
    //latch_height = block_height - 4*LAYER_HEIGHT;
    latch_size = [LATCH_INSET, LAYER_HEIGHT*6];
    length = MORTISE_SIZE;
    x_offset = PIN_RADIUS+LATCH_INSET+TOLERANCE;
    rotate([-90,0,0]) linear_extrude(height=size_to_side(MORTISE_SIZE), center=true) {
        //translate([-length/2,0]) square([length, CLIP_HEIGHT]);
        mirrored_pair([1,0,0]) translate([x_offset,0,0]) latch_outline(block_size, latch_size, 0);
        //mirror([-1,0,0]) translate([x_offset,0,0]) latch_outline(block_size, latch_size, 0);
    }
}

module edge_latch() {
    x_offset = PIN_RADIUS+LATCH_INSET+TOLERANCE;
    height = PIN_HEIGHT;
    for (i = range(3)) {
        rotate([0,0,i*120]) translate([0,0,PIN_HEIGHT]) tile_clip_socket();
    }
}

module center_column() {
    cylinder(r=SOCKET_RADIUS + WALL_THICKNESS, h=TILE_HEIGHT, $fn=12);
}

module simple_hex(size=DEFAULT_HEX_SIZE) {
    hex_size = size - SEPARATION;
    mortise_size = hex_size - 2 * WALL_THICKNESS;
    echo(size=size, hex_size=hex_size, mortise_size=mortise_size);
    difference() {
        beveled_hexagon_prism(size=size, height=TILE_HEIGHT);
        hexagon_prism(size=mortise_size, height=TILE_HEIGHT-TOP_THICKNESS);
    }
}

module simple_tenon(size=DEFAULT_HEX_SIZE, bevel=WALL_THICKNESS/4) {
    brick_size = size - SEPARATION;
    mortise_size = brick_size - 2 * WALL_THICKNESS;
    radius = mortise_size/2 - TENON_FIT;
//    difference() {
//        hull() {
//            cylinder(h=BASE_HEIGHT+TENON_HEIGHT, r=radius-bevel, $fn=$FN);
//            cylinder(h=BASE_HEIGHT+TENON_HEIGHT-bevel, r=radius, $fn=$FN);
//        }
//        translate([0,0,BASE_HEIGHT]) cylinder(h=TENON_HEIGHT, r=radius-WALL_THICKNESS, $fn=$FN);
//    }
}

/*
    Create a 2d "footprint" of a tile.

    Note: Overlap will ensure adjacent hexes are merged in union operation
*/
module tile_shape(tile, overlap=0.001) {
    hexes = tile("hexes");
    offset(delta=-overlap) {
        union() {
            for (i = range(hexes)) {
                translate(hex_center(hexes, i)) hex_shape(DEFAULT_HEX_SIZE+overlap);
            }
        }
    }
}

/*
    Bevel for bottom of mortise. This allows the tenon on the base to be guided easily
    into the mortise even with bottom-layer expansion (elephant-foot)
*/
module bottom_bevel_cutter(bevel) {
    translate([0,0,-1]) {
        minkowski() {
            linear_extrude(height=1) {
                difference() {
                    offset(delta=bevel) children();
                    children();
                }
            }
            cylinder(r1=bevel, r2=0, h=bevel, $fn=6);
        }
    }
}

/*
    Create a single hex
*/
module create_hex(size, barriers) {
    simple_hex(size=size-SEPARATION);
    hex_decoration(size, barriers);
}

module label_hex(i) {
    linear_extrude(height=2) text(text=str(i));
}

module tile_mortises(tile) {
    hexes = tile("hexes");
    //size = DEFAULT_HEX_SIZE;
    //hex_size = size - SEPARATION;
    bevel = LAYER_HEIGHT;
    for (i = range(hexes)) {
        translate(hex_center(hexes, i)) {
            _height = TILE_HEIGHT - (is_elevated(tile, i) ? 0 : TOP_THICKNESS);
            difference() {
                hexagon_prism(size=MORTISE_SIZE, height=_height);
                center_column();
            }

            //bottom_bevel_cutter(bevel) hex_shape(size=MORTISE_SIZE - 2*bevel);
        }
    }
}

module decorate_tile_floor(tile, pattern, scale=[1,1], offset=[0,0]) {
    bounds = tile("bounds");
    size = tile("size");
    if (! is_undef(pattern)) {
        translate([bounds[0].x,bounds[0].y,TILE_HEIGHT+HEXAGON_BEVEL_DEPTH]) rotate([-90,0,0]) {
            echo("decorate_tile_floor: ", size=size, scale=scale);
            scaled_pattern = scale_pattern(pattern, scale);
            expansion = [ ceil(size.x / scaled_pattern("size").x), ceil(size.y / scaled_pattern("size").y)];
            //expanded_pattern = expand_pattern(scaled_pattern, expansion);
            expanded_pattern = scaled_pattern;
//            echo("barrier_pattern_cutter: expansion", expansion=expansion, scaled_size=scaled_pattern("size"),
//                expanded_size=expanded_pattern("size"));
            cropped_pattern = crop_pattern(expanded_pattern, [size.x, size.y]);
            echo(pattern_size=pattern("size"), pattern_bounds=pattern("bounds"), tile_bounds=bounds);
            translated_pattern = offset_pattern(cropped_pattern, offset=[bounds[0].x, bounds[0].y]);
            pattern_cutter(cropped_pattern);
        }
    }
}

module adhesion_support(tile) {
    for (corner = corner_points(tile)) {
        let(
            center = hex_center_for_corner(tile, corner),
            v = corner - center,
            angle = atan2(v.y,v.x),
            size = DEFAULT_HEX_SIZE/8,
            dx = -WALL_THICKNESS/2-size_to_side(size))
//            dx = -TOLERANCE-size_to_side(size))
        translate(corner) rotate([0,0,angle])
            linear_extrude(height=LAYER_HEIGHT) translate([dx,0,0]) rotate([0,0,30]) hex_shape(size);
    }
}

/*
ElevationTest:
ECHO: vertices = [[-15.875, -9.16544], [-15.875, 9.16544], [0, -36.6617], [0, -18.3309], [0, 18.3309], [0, 36.6617], [15.875, -45.8272], [15.875, -9.16544], [15.875, 9.16544], [15.875, 45.8272], [31.75, -36.6617], [31.75, -18.3309], [31.75, 18.3309], [31.75, 36.6617]]
ECHO: elevation = ["polygon", [[19.5938, -42.5255], [30.75, -36.0844], [30.75, -18.9082], [15.875, -10.3201], [14.875, -8.58809], [14.875, 8.58809], [15.875, 10.3201], [30.75, 18.9082], [30.75, 31.7903], [15.875, 40.3784], [4.71875, 33.9374], [4.71875, 21.0552], [3.71875, 15.0291], [-11.1563, 6.44106], [-11.1563, -6.44106], [-11.1563, -6.44106], [3.71875, -15.0291], [4.71875, -21.0552], [4.71875, -33.9374]], "height", 18.3309]

TileTest:
ECHO: vertices = [[-15.875, -9.16544], [-15.875, 9.16544], [0, -36.6617], [0, -18.3309], [0, 18.3309], [0, 36.6617], [15.875, -45.8272], [15.875, -9.16544], [15.875, 9.16544], [15.875, 45.8272], [31.75, -36.6617], [31.75, -18.3309], [31.75, 18.3309], [31.75, 36.6617]]
ECHO: elevation = ["polygon", [[19.5938, -42.5255], [30.75, -36.0844], [30.75, -18.9082], [15.875, -10.3201], [14.875, -8.58809], [14.875, 8.58809], [15.875, 10.3201], [30.75, 18.9082], [30.75, 31.7903], [15.875, 40.3784], [4.71875, 33.9374], [4.71875, 21.0552], [3.71875, 15.0291], [-11.1563, 6.44106], [-11.1563, -6.44106], [-11.1563, -6.44106], [3.71875, -15.0291], [4.71875, -21.0552], [4.71875, -33.9374]], "height", 18.3309]

*/
/*
    Create a tile
*/

/*
    Determine if a given tile is elevated.

    TODO: resolve to hex level, not tile level
*/
module create_tile(tile, wall_pattern, floor_pattern) {
    hexes = tile("hexes");
    size = DEFAULT_HEX_SIZE;
    hex_size = size - SEPARATION;
    tile_bevel = 2*LAYER_HEIGHT;
    difference() {
        intersection() {
            union() {
                // Outer shape
                linear_extrude(height=TILE_HEIGHT) {
                    offset(delta=SEPARATION/2) {
                        for (i = range(hexes)) {
                            translate(hex_center(hexes, i)) hex_shape(DEFAULT_HEX_SIZE);
                        }
                    }
                }
                // raised area
                translate([0,0,TILE_HEIGHT]) for (i = range(hexes)) {
                    if (!is_elevated(tile, i)) {
                        translate(hex_center(hexes, i)) beveled_hexagon_prism(hex_size, height=HEXAGON_BEVEL_DEPTH);
                    }
                }
                // debug id
                translate([0,0,TILE_HEIGHT]) for (i = range(hexes)) {
                    translate(hex_center(hexes, i)) label_hex(i);
                }
                // barriers
                translate([0,0,TILE_HEIGHT]) for (b = tile("barriers")) {
                    barrier(size, b[0], b[1], wall_pattern);
                }

                // elevations
                translate([0,0,TILE_HEIGHT]) for (e = tile("elevations")) {
                    raise_elevation(tile_vertices(tile), e);
                }

                // zero
                //cylinder(r=1, h=20);
            }
            // trim walls
            linear_extrude(height=BASE_HEIGHT+BARRIER_HEIGHT) {
                offset(delta=-TOLERANCE) {
                    tile_shape(tile);
                }
            }
        }
        // mortises
        //translate([0,0,LAYER_HEIGHT])
        tile_mortises(tile);

        // socket
        for (i = range(hexes)) {
            translate(concat(hex_center(hexes, i), [WALL_THICKNESS])) {
                rotate([0,0,360/24]) cylinder(r=SOCKET_RADIUS, h=TILE_HEIGHT*10, $fn=12);
            }
        }

        // bottom outer bevel
        bottom_bevel_cutter(bevel=tile_bevel) offset(delta=-SEPARATION/2-TOLERANCE/2) tile_shape(tile);

        // floor pattern
        decorate_tile_floor(tile, floor_pattern);

    }
    // pins
    for (i = range(hexes)) {
        translate(hex_center(hexes, i)) edge_latch();
        //translate(hex_center(hexes, i)) center_column();
    }
}
