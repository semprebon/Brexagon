/*
    Basic tile construction used to create specific tiles

    TODO: Brick pattern on tiles
    TODO: stone pattern on floor
*/

include <HexUtils.scad>
include <Association.scad>

// VERSION=0.11 - TENON_FIT=0.12
//VERSION = 0.12; // TENON_FIT=0.08
VERSION = 0.13; // TENON_FIT=0.04
TOLERANCE = 0.2;
LINE_WIDTH = 0.4;
SEPARATION = 0.2;
TILE_HEIGHT = 6; // nominal height of brick (excluding tenon if present)
TOP_THICKNESS = 2;
WALL_THICKNESS = 4*LINE_WIDTH;
BASE_HEIGHT = 1.6;
TENON_HEIGHT = 2;
TENON_FIT = 0.04; // increase to loosen, decrease to tighten

WALL_HEIGHT = 24;

$FN = 60;

function define_hex(position, barriers)
    = associate(["position", position, "barriers", barriers]);

/* Tile geometries */
TILE_SHAPE_HEXAGON = "hexagon";
TILE_SHAPE_TRAPEZOID = "trapezoid";
TILE_SHAPE_RECTANGLE = "rectangle";

/*
    Define a specified shape and size of tile from texture information
*/
function define_tile(shape, size, data) =
    let(
        positions = (shape == TILE_SHAPE_HEXAGON) ? hex_positions(size)
            : (shape == TILE_SHAPE_TRAPEZOID) ? trapezoid_positions(size)
            : (shape == TILE_SHAPE_RECTANGLE) ? rect_positions(size)
            : (shape == "triangle") ? trapezoid_positions(1, (size.x == undef) ? size: size.x, 1)
            : ["error"],
        hexes = [for (i = range(len(positions)))
                    let(datum = data[i % len(data)])
                    if (is_list(datum)) define_hex(position=positions[i], barriers=datum) ])
        associate(["shape", shape, "size", size, "hexes", hexes]);


module hexagon_prism(size, height) {
    linear_extrude(height=height) hex_shape(size);
}

module beveled_hexagon_prism(size, height, bevel=WALL_THICKNESS/3) {
    hull() {
        hexagon_prism(size=size, height=height-bevel);
        hexagon_prism(size=size-2*bevel, height=height);
    }
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
    difference() {
        hull() {
            cylinder(h=BASE_HEIGHT+TENON_HEIGHT, r=radius-bevel, $fn=$FN);
            cylinder(h=BASE_HEIGHT+TENON_HEIGHT-bevel, r=radius, $fn=$FN);
        }
        translate([0,0,BASE_HEIGHT]) cylinder(h=TENON_HEIGHT, r=radius-WALL_THICKNESS, $fn=$FN);
    }
}

function hex_center(hexes, i, size=DEFAULT_HEX_SIZE) =
    axial_to_xy(hexes[i]("position"), DEFAULT_HEX_SIZE);

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

module bottom_bevel_cutter(bevel) {
    translate([0,0,-1]) {
        minkowski() {
            linear_extrude(height=1) {
                difference() {
                    offset(delta=bevel) children();
                    children();
                }
            }
            cylinder(r1=bevel, r2=0, h=bevel, $r=24);
        }
    }
}

/*
 Generates a base for bricks
 */
module tile_base(tile) {
    hexes = tile("hexes");
    hole_radius = (1/3) * DEFAULT_HEX_SIZE;
    bevel = 0.4;

    difference() {
        union() {
            // base bottom surface
            linear_extrude(height=BASE_HEIGHT) {
                offset(delta=-TOLERANCE) {
                    tile_shape(tile);
                }
            }
            // tenons
            for (i = range(hexes)) {
                translate(hex_center(hexes, i)) simple_tenon(DEFAULT_HEX_SIZE);
            }
        }
        // center hole
        for (i = range(hexes)) {
            translate(hex_center(hexes, i)) cylinder(r=hole_radius, h=TILE_HEIGHT, $FN);
        }
        // bottom
        bottom_bevel_cutter(bevel) tile_shape(tile);
    }
}

module best_fit_tile_base(size) {
    intersection() {
        rotate([0,0,15]) translate([-(size-1)*DEFAULT_HEX_SIZE,0,0]) tile_base(size);
        #cube([220,220,250], center=true);
    }
}

HEIGHT = (2 / sqrt(3));
DX = 0.5;
DY = 1/sqrt(12);
BW = DY/2;
BARRIER_PLACEMENTS = associate([
    "E", associate(["size", [BW/2,1], "location", [DX-BW/4,0]]),
    "W", associate(["size", [BW/2,1], "location", [-DX+BW/4,0]]),
    "N", associate(["size", [BW,DY],  "location", [0, 1/2*DY]]),
    "S", associate(["size", [BW,DY],  "location", [0,-1/2*DY]]),
    "N2", associate(["size",[BW,BW],  "location", [0, 7*DY/4]]),
    "S2", associate(["size",[BW,BW],  "location", [0,-7*DY/4]]),
    "N3", associate(["size",[BW,BW],  "location", [0, 5*DY/4]]),
    "S3", associate(["size",[BW,BW],  "location", [0,-5*DY/4]]),
    "NE2", associate(["size",[DX,BW],  "location", [ DX/2, 7/4*DY]]),
    "SE2", associate(["size",[DX,BW],  "location", [DX/2, -7/4*DY]]),
    "SW2", associate(["size",[DX,BW],  "location", [-DX/2,-7/4*DY]]),
    "NW2", associate(["size",[DX,BW],  "location", [-DX/2, 7/4*DY]]),
    "NE", associate(["size",[DX,BW], "location", [ DX/2, 5/4*DY]]),
    "SE", associate(["size",[DX,BW], "location", [ DX/2, -5/4*DY]]),
    "SW", associate(["size",[DX,BW], "location", [-DX/2,-5/4*DY]]),
    "NW", associate(["size",[DX,BW], "location", [-DX/2, 5/4*DY]]) ]);

function has_barrier(list, barrier) = [ for (w = list) if (w == barrier) true][0];
function barrier_size(size, barrier) = concat(size*BARRIER_PLACEMENTS(barrier)("size"), [WALL_HEIGHT]);
function barrier_position(size, barrier) = concat(size*BARRIER_PLACEMENTS(barrier)("location"), [WALL_HEIGHT/2]);

/*
    Create a single hex
*/
module create_hex(size, barriers) {
    simple_hex(size=size-SEPARATION);
    hex_decoration(size, barriers);
}

module decorate_hex(size, hex) {
    barriers = hex("barriers");
    echo("decorate_hex:", hex=hex(list=true));
    translate([0,0,TILE_HEIGHT]) {
        intersection() {
            for (w = ["E","W","N","S","N2","S2","N3","S3","NE","SE","SW","NW","NE2","SE2","SW2","NW2"]) {
                if (has_barrier(barriers, w)) {
                    translate(barrier_position(size, w)) cube(barrier_size(size, w), center=true);
                }
            }
            hexagon_prism(size=size, height=TILE_HEIGHT+WALL_HEIGHT);
        }
    }
}

module label_hex(i) {
    linear_extrude(height=2) text(text=str(i));
}

module tile_mortises(tile, height=TILE_HEIGHT-TOP_THICKNESS) {
    hexes = tile("hexes");
    size = DEFAULT_HEX_SIZE;
    hex_size = size - SEPARATION;
    mortise_size = hex_size - 2 * WALL_THICKNESS;
    bevel = 0.4;
    for (i = range(hexes)) {
        translate(hex_center(hexes, i)) {
            hexagon_prism(size=mortise_size, height=TILE_HEIGHT-TOP_THICKNESS);
            #bottom_bevel_cutter(bevel) hex_shape(size=mortise_size - 2*bevel);
        }
    }
}

/*
    Create a tile
*/
module create_tile(tile) {
    hexes = tile("hexes");
    size = DEFAULT_HEX_SIZE;
    hex_size = size - SEPARATION;
    difference() {
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
                translate(hex_center(hexes, i)) beveled_hexagon_prism(hex_size, height=WALL_THICKNESS/2);
            }
            // hex decoration
            for (i = range(hexes)) {
                translate(hex_center(hexes, i)) decorate_hex(size, hexes[i]);
            }
            // debug id
//            translate([0,0,TILE_HEIGHT]) for (i = range(hexes)) {
//                translate(hex_center(hexes, i)) label_hex(i);
//            }
        }
        // mortises
        tile_mortises(tile);
        // bottom outer bevel
        bottom_bevel_cutter(bevel=0.4) offset(delta=SEPARATION/2) tile_shape(tile);
    }
}

module layout_tiles(size=DEFAULT_HEX_SIZE, tiles, d=[1.1, size_to_height(1.1)]) {
    _d = size * d;
    dy = size + WALL_THICKNESS;
    for (i=(range(bricks))) {
        translate([dx*(i%row_size),dy*floor(i/row_size)]) create_hex(size, bricks[i]);
    }
}
