include <HexUtils.scad>
include <Association.scad>

TOLERANCE = 0.2;
SEPARATION = 0.2;
BRICK_HEIGHT = 6; // nominal height of brick (excluding tenon if present)
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

function 2d_to_3d(p, z=0) = concat(p, [z]);

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


module hex_prism(size, height) {
    rotate([0,0,360/12]) linear_extrude(height=height) hex_shape(size);
}

module beveled_hex_prism(size, height, bevel=WALL_THICKNESS/3) {
    hull() {
        hex_prism(size=size-2*bevel, height=height);
        translate([0,0,bevel]) hex_prism(size=size, height=height-bevel);
    }
}

module unit_brick(size=DEFAULT_HEX_SIZE) {
    brick_size = size - SEPARATION;
    mortise_size = brick_size - 2 * WALL_THICKNESS;
    echo(size=size, brick_size=brick_size, mortise_size=mortise_size);
    difference() {
        beveled_hex_prism(size=size, height=BRICK_HEIGHT);
        hex_prism(size=mortise_size, height=BRICK_HEIGHT-TOP_THICKNESS);

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
module tile_base(size) {
    tile = create_tile(shape=TILE_SHAPE_HEXAGON, size=size, data=[]);
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
            translate(axial_to_xy(hexes[i][HEX_POSITION], DEFAULT_HEX_SIZE)7) simple_tenon(DEFAULT_HEX_SIZE);
        }
    //}
}

module best_fit_tile_base(size) {
    intersection() {
        rotate([0,0,15]) translate([-(size-1)*DEFAULT_HEX_SIZE,0,0]) tile_base(size);
        #cube([220,220,250], center=true);
    }
}

DX = 1/sqrt(12);
DY = 0.5;
HWT = DX/4;
WALL_TYPES = associate([
    "N", associate(["size", [1,HWT],        "location", [0,DY-HWT/2]]),
    "S", associate(["size", [1,HWT],        "location", [0,-DY+HWT/2]]),
    "E", associate(["size", [DX,2*HWT],     "location", [ 1/2*DX,0]]),
    "W", associate(["size", [DX,2*HWT],     "location", [-1/2*DX,0]]),
    "E2", associate(["size",[2*HWT,2*HWT],  "location", [ 5*DX/4,0]]),
    "W2", associate(["size",[2*HWT,2*HWT],  "location", [-5*DX/4,0]]),
    "E3", associate(["size",[2*HWT,2*HWT],  "location", [ 7*DX/4,0]]),
    "W3", associate(["size",[2*HWT,2*HWT],  "location", [-7*DX/4,0]]),
    "NE", associate(["size",[2*HWT,DY],     "location", [ 7/4*DX, DY/2]]),
    "SE", associate(["size",[2*HWT,DY],     "location", [ 7/4*DX,-DY/2]]),
    "SW", associate(["size",[2*HWT,DY],     "location", [-7/4*DX,-DY/2]]),
    "NW", associate(["size",[2*HWT,DY],     "location", [-7/4*DX, DY/2]]),
    "NE2", associate(["size",[2*HWT,DY],    "location", [ 5/4*DX, DY/2]]),
    "SE2", associate(["size",[2*HWT,DY],    "location", [ 5/4*DX,-DY/2]]),
    "SW2", associate(["size",[2*HWT,DY],    "location", [-5/4*DX,-DY/2]]),
    "NW2", associate(["size",[2*HWT,DY],    "location", [-5/4*DX, DY/2]]) ]);

function has_wall(list, wall) = [ for (w = list) if (w == wall) true][0];
function wall_size(size, wall) = concat(size*WALL_TYPES(wall)("size"), [WALL_HEIGHT]);
function wall_position(size, wall) = concat(size*WALL_TYPES(wall)("location"), [WALL_HEIGHT/2]);

// each unit can have 8 different walls togged on
module hex_brick(size, walls) {
    unit_brick(size=size-SEPARATION);
    translate([0,0,BRICK_HEIGHT]) {
        #intersection() {
            for (w = ["N","NE","NE2","E","E2","E3","SE","SE2","S","SW","SW2","W","W2","W3","NW","NW2"]) {
                if (has_wall(walls, w)) {
                    echo(w=w, data=WALL_TYPES(w)(list=true), wall_size=wall_size(size, w));
                    translate(wall_position(size, w)) cube(wall_size(size, w), center=true);
                }
            }
            hex_prism(size=size-SEPARATION, height=BRICK_HEIGHT+WALL_HEIGHT);
        }
    }
}

module layout_bricks(size, bricks, row_size = 5) {
    dx = size * 2/sqrt(3) + WALL_THICKNESS;
    dy = size + WALL_THICKNESS;
    for (i=(range(bricks))) {
        translate([dx*(i%row_size),dy*floor(i/row_size)]) hex_brick(size, bricks[i]);
    }
}

//unit_brick();
//translate([0,1.2*DEFAULT_HEX_SIZE,0]) unit_brick();
//translate([0,-1.2*DEFAULT_HEX_SIZE,0]) unit_brick();
best_fit_tile_base(size=4);
//tile_base(size=4);
//hex_brick(DEFAULT_HEX_SIZE, walls=["N","S","NE","SE"]);
//hex_brick(DEFAULT_HEX_SIZE, walls=["N","S","E","W","E2","W2","NE","SE","SW2","NW2"]);
//hex_brick(DEFAULT_HEX_SIZE, walls=["W","E2","W3"]);
/*
layout_bricks(DEFAULT_HEX_SIZE, bricks=[
    ["N","NW","W3","SW"], // edge corner (a)
    ["W3","W2","W","E","E2","E3"], // center horizontal wall (b)
    ["NW","W3","SW"], // outer vertical wall (c)
    ["NW","W3","SW","NE","E3","SE"], // vertical hall (d)
    ["N"], // edge horizontal wall (e)
    ["W3","SW"], // outer corner (f)
    ["NW","W3","W2","W","E","E2","E3"], // center corner (h)
    ["NW2","W2","SW2"], // inner vertical wall (i)
    ["NW2","W3","SW2"], // inner vertical wall (i)
    []]); // plain
*/
