include <HexUtils.scad>
include <Association.scad>

TOLERANCE = 0.2;
SEPARATION = 0.2;
TILE_HEIGHT = 6; // nominal height of brick (excluding tenon if present)
TOP_THICKNESS = 2;
WALL_THICKNESS = 1.68;
BASE_HEIGHT = 1.6;
TENON_HEIGHT = 2;
TENON_FIT = 0.05;

WALL_HEIGHT = 24;

/* Hex Data Offsets */
HEX_POSITION = 0;   // Axial coordinates of hex
HEX_LEVEL = 1;      // height of hex, in abstract coordinates
HEX_TERRAIN = 2;    // Terrain object

function hex_data(position, descriptor) = [position, descriptor[0], descriptor[1]];

function hex_height(hex_data) = level_thickness * hex_data[HEX_LEVEL];

//function 2d_to_3d(p, z=0) = concat(p, [z]);

/* Offsets ino tile object */
TILE_SHAPE = 0; // "hex", "semi_hex", or "rect
TILE_SIZE = 1; // [x,y] size of tile
TILE_HEXES = 2; //

/* Tile geometries */
TILE_SHAPE_HEXAGON = "hexagon";
TILE_SHAPE_TRAPEZOID = "trapezoid";
TILE_SHAPE_RECTANGLE = "rectangle";
// TODO: implement parallelogram tiles

/*
 Create a specified shape and size of tile from texture information
*/
function create_tile(shape, size, data) =
    let(
        positions = (shape == TILE_SHAPE_HEXAGON) ? hex_positions(size)
            : (shape == TILE_SHAPE_TRAPEZOID) ? trapezoid_positions(size)
            : (shape == TILE_SHAPE_RECTANGLE) ? rect_positions(size)
            : (shape == "triangle") ? trapezoid_positions(1, (size.x == undef) ? size: size.x, 1)
            : ["error"],
        hexes = [for (i = range(len(positions)))
                    hex_data(position=positions[i], descriptor = data[i % len(data)])])
    [shape, size,  hexes];


module hexagon_prism(size, height) {
    linear_extrude(height=height) hex_shape(size);
}

module beveled_hexagon_prism(size, height, bevel=WALL_THICKNESS/3) {
    hull() {
        hexagon_prism(size=size-2*bevel, height=height);
        translate([0,0,bevel]) hexagon_prism(size=size, height=height-bevel);
    }
}

module simple_hex(size=DEFAULT_HEX_SIZE) {
    brick_size = size - SEPARATION;
    mortise_size = brick_size - 2 * WALL_THICKNESS;
    echo(size=size, brick_size=brick_size, mortise_size=mortise_size);
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
            cylinder(h=BASE_HEIGHT+TENON_HEIGHT, r=radius-bevel, $fn=60);
            cylinder(h=BASE_HEIGHT+TENON_HEIGHT-bevel, r=radius, $fn=60);
        }
        translate([0,0,BASE_HEIGHT]) cylinder(h=TENON_HEIGHT, r=radius-WALL_THICKNESS, $fn=60);
    }
}

/*
 Generates a base for bricks
 */
module tile_base(shape=TILE_SHAPE_HEXAGON, size=1) {
    tile = create_tile(shape=shape, size=size, data=[]);
    hexes = tile[TILE_HEXES];

    linear_extrude(height=BASE_HEIGHT) {
        offset(delta=TOLERANCE/2) {
            for (i = range(hexes)) {
                translate(axial_to_xy(hexes[i][HEX_POSITION], DEFAULT_HEX_SIZE)) hex_shape(DEFAULT_HEX_SIZE);
            }
        }
    }
    //translate([0,0,BASE_HEIGHT]) {
        for (i = range(hexes)) {
            translate(axial_to_xy(hexes[i][HEX_POSITION], DEFAULT_HEX_SIZE)) simple_tenon(DEFAULT_HEX_SIZE);
        }
    //}
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
    "NE", associate(["size",[DX,BW],  "location", [ DX/2, 7/4*DY]]),
    "SE", associate(["size",[DX,BW],  "location", [-DX/2, 7/4*DY]]),
    "SW", associate(["size",[DX,BW],  "location", [-DX/2,-7/4*DY]]),
    "NW", associate(["size",[DX,BW],  "location", [ DX/2,-7/4*DY]]),
    "NE2", associate(["size",[DX,BW], "location", [ DX/2, 5/4*DY]]),
    "SE2", associate(["size",[DX,BW], "location", [-DX/2, 5/4*DY]]),
    "SW2", associate(["size",[DX,BW], "location", [-DX/2,-5/4*DY]]),
    "NW2", associate(["size",[DX,BW], "location", [ DX/2,-5/4*DY]]) ]);

function has_barrier(list, barrier) = [ for (w = list) if (w == barrier) true][0];
function barrier_size(size, barrier) = concat(size*BARRIER_PLACEMENTS(barrier)("size"), [WALL_HEIGHT]);
function barrier_position(size, barrier) = concat(size*BARRIER_PLACEMENTS(barrier)("location"), [WALL_HEIGHT/2]);

/*
    Create a single hex
*/
module create_hex(size, barriers) {
    simple_hex(size=size-SEPARATION);
    translate([0,0,TILE_HEIGHT]) {
        intersection() {
            #for (w = ["E","W","N","S","N2","S2","N3","S3","NE","SE","SW","NW","NE2","SE2","SW2","NW2"]) {
                if (has_barrier(barriers, w)) {
                    echo(w=w, data=BARRIER_PLACEMENTS(w)(list=true), barrier_size=barrier_size(size, w));
                    translate(barrier_position(size, w)) cube(barrier_size(size, w), center=true);
                }
            }
            hexagon_prism(size=size-SEPARATION, height=TILE_HEIGHT+WALL_HEIGHT);
        }
    }
}

module layout_hexes(size, bricks, row_size = 5) {
    dx = size * 2/sqrt(3) + WALL_THICKNESS;
    dy = size + WALL_THICKNESS;
    for (i=(range(bricks))) {
        translate([dx*(i%row_size),dy*floor(i/row_size)]) create_hex(size, bricks[i]);
    }
}

//simple_hex();
//translate([0,1.2*DEFAULT_HEX_SIZE,0]) simple_hex();
//translate([0,-1.2*DEFAULT_HEX_SIZE,0]) simple_hex();
//best_fit_tile_base(size=4);
//tile_base(shape=TILE_SHAPE_TRAPEZOID, size=[1,2]);
// enclosed rectangle
//create_hex(DEFAULT_HEX_SIZE, barriers=["NW","N2","NE", "E", "SE","S2","SW", "W"]);
// double cross
create_hex(DEFAULT_HEX_SIZE, barriers=["N3","N2","N","S","S2","S3", "NE2","SE2","SW2","NW2"]);

//create_hex(DEFAULT_HEX_SIZE, barriers=["N","S","E","W","E2","W2","NE","SE","SW2","NW2"]);
//create_hex(DEFAULT_HEX_SIZE, barriers=["W","E2","W3"]);

/*
layout_hexes(DEFAULT_HEX_SIZE, bricks=[
    ["N","NW","W3","SW"], // edge corner (a)
    ["W3","W2","W","E","E2","E3"], // center horizontal barrier (b)
    ["NW","W3","SW"], // outer vertical barrier (c)
    ["NW","W3","SW","NE","E3","SE"], // vertical hall (d)
    ["N"], // edge horizontal barrier (e)
    ["W3","SW"], // outer corner (f)
    ["NW","W3","W2","W","E","E2","E3"], // center corner (h)
    ["NW2","W2","SW2"], // inner vertical barrier (i)
    ["NW2","W3","SW2"], // inner vertical barrier (i)
    []]); // plain
*/
