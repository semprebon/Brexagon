/*
    Basic tile construction used to create specific tiles

    TODO: wood pattern/texture on floor
    TODO: fix pattern at corners
    TODO: separate pattern cut from wall construction (should fix corner too)
*/

include <HexUtils.scad>
include <Association.scad>
include <PatternCutters.scad>
include <Barrier.scad>

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

WALL_HEIGHT = DEFAULT_SIDE;

$FN = 60;

HEXAGON_BEVEL_DEPTH = WALL_THICKNESS/2;

function define_hex(position, barriers)
    = associate(["position", position, "barriers", barriers]);

/* Tile geometries */
TILE_SHAPE_HEXAGON = "hexagon";
TILE_SHAPE_TRAPEZOID = "trapezoid";
TILE_SHAPE_RECTANGLE = "rectangle";

/*
    Define a specified shape and size of tile from texture information
*/
function define_tile(shape, size, hex_data=[[]], barriers=[]) =
    let(
        positions = (shape == TILE_SHAPE_HEXAGON) ? hex_positions(size)
            : (shape == TILE_SHAPE_TRAPEZOID) ? trapezoid_positions(size)
            : (shape == TILE_SHAPE_RECTANGLE) ? rect_positions(size)
            : (shape == "triangle") ? trapezoid_positions(1, (size.x == undef) ? size: size.x, 1)
            : ["error"],
        hexes = [for (i = range(len(positions)))
                    let(datum = hex_data[i % len(hex_data)])
                    if (is_list(datum)) define_hex(position=positions[i], barriers=datum) ],
        xs = [ for (h=hexes) axial_to_xy(h("position")).x ],
        ys = [ for (h=hexes) axial_to_xy(h("position")).y ],
        ext = [DEFAULT_HEX_SIZE, size_to_height(DEFAULT_HEX_SIZE)] / 2,
        bounds = [[min(xs)-ext.x, min(ys)-ext.y], [max(xs)+ext.x, max(ys)+ext.y]],
        shape_size = [bounds[1].x-bounds[0].x, bounds[1].y-bounds[0].y])
        //echo("define_tile: ", xs=xs, ys=ys, bounds=bounds, size=shape_size) )
    associate(["shape", shape, "tile_size", size, "hexes", hexes, "barriers", barriers,
        "bounds", bounds,
        "size", shape_size]);

function barrier_point(x,y) = [x,y];
//    let(x1 = x/2,
//        y1 = floor(y/4) + [1/16,3/16,13/16,15/16][(y+4) % 4])
//    [x1,y1];
function y_barrier(x, y1, y2) = [barrier_point(x,y1), barrier_point(x,y2)];
function x_barrier(y, x1, x2) = [barrier_point(x1,y), barrier_point(x2,y)];

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
        cube([220,220,250], center=true);
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

module decorate_hex(size, hex, pattern) {
    barriers = hex("barriers");
//    echo("decorate_hex:", hex=hex(list=true));
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
            bottom_bevel_cutter(bevel) hex_shape(size=mortise_size - 2*bevel);
        }
    }
}

module barrier(size, p1, p2, pattern) {
    //scale=[size,(9/16)*sqrt(3)*size];
    //offset = scale_point([-1/2,11/16], scale);
    scale=[size,size*2/sqrt(3)];
    offset=[0,0];
    //offset = scale_point([-1/2,11/16], scale);
    start = scale_point(p1,scale) + offset;
    end = scale_point(p2,scale) + offset;
    width = (size/sqrt(3))/4;
    vector = end-start;
    length = sqrt(vector.x*vector.x + vector.y*vector.y);
    rotation = atan2(vector.y, vector.x);

    //echo("barrier: ", p1=p1, p2=p2, scale=scale, width=width, start=start, end=end,
    //    vector=vector, length=length, rotation=rotation);
    translate([start.x,start.y,0]) rotate([0,0,rotation])
        patterned_barrier([length,width,WALL_HEIGHT], pattern=pattern, offset=[0,HEXAGON_BEVEL_DEPTH]);
        //translate([0,-width/2,0]) cube([length,width,WALL_HEIGHT]);
}

module decorate_tile_floor(tile, pattern, scale=[1,1], offset=[0,0]) {
    bounds = tile("bounds");
    size = tile("size");
    if (! is_undef(pattern)) {
        translate([bounds[0].x,bounds[0].y,TILE_HEIGHT+HEXAGON_BEVEL_DEPTH]) rotate([-90,0,0]) {
            echo("decorate_tile_floor: ", size=size, tile=tile(list=true));
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

/*
    Create a tile
*/
module create_tile(tile, wall_pattern, floor_pattern) {
    hexes = tile("hexes");
    size = DEFAULT_HEX_SIZE;
    hex_size = size - SEPARATION;
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
                //difference() {
                    translate([0,0,TILE_HEIGHT]) for (i = range(hexes)) {
                        translate(hex_center(hexes, i)) beveled_hexagon_prism(hex_size, height=HEXAGON_BEVEL_DEPTH);
                    }
//                    if (! is_undef(floor_pattern)) {
//
//                        translate([0,0,TILE_HEIGHT+HEXAGON_BEVEL_DEPTH]) rotate([90,0,0]) {
//                            pattern_cutter(floor_pattern);
//                        }
//                    }
                //}
                // debug id
//                translate([0,0,TILE_HEIGHT]) for (i = range(hexes)) {
//                    translate(hex_center(hexes, i)) label_hex(i);
//                }
                // barriers
                translate([0,0,TILE_HEIGHT]) for (b = tile("barriers")) {
                    barrier(size, b[0], b[1], wall_pattern);
                }
                // zero
                //cylinder(r=1, h=20);
            }
            // trim walls
            linear_extrude(height=BASE_HEIGHT+WALL_HEIGHT) {
                offset(delta=-TOLERANCE) {
                    tile_shape(tile);
                }
            }
        }
        // mortises
        tile_mortises(tile);
        // bottom outer bevel
        bottom_bevel_cutter(bevel=0.4) offset(delta=SEPARATION/2) tile_shape(tile);
        #decorate_tile_floor(tile, floor_pattern);

    }
}

function successive_sums(list, acc=0) =
    (len(list) == 0) ? []
        : concat([acc+list[0]], successive_sums(drop(list, 1), acc+list[0]));

function bounds_center(b) = [(b[2]+b[0])/2, (b[1]+b[3])/2];

module center_in_space(space_bounds, obj_bounds) {
    translate(bounds_center(space_bounds) - bounds_center(obj_bounds)) children();
}

module layout_tiles(tiles, spacing=5, pattern=BLANK_PATTERN) {
    height = size_to_height(DEFAULT_HEX_SIZE);
    width = DEFAULT_HEX_SIZE;
    //echo("layout_tiles: ", tiles=map(tiles, function(t) t(list=true)), spacing=spacing);
    tiles_by_v_height = fill(quicksort(tiles, function (t) t("size").y), limit=200,
        get_size=function (t) t("size").x);
    echo("layout_tiles: ", count=len(tiles), row1=len(tiles_by_v_height[0]), row2=len(tiles_by_v_height[1]));
    let(
        row_heights = [ for (row = tiles_by_v_height) row[0]("size").y + spacing ],
        ys = successive_sums(row_heights)
    ) {
       // echo("layout_tiles: ", ys = ys, height=height);

        for (j = range(tiles_by_v_height)) {
            let(
                row = tiles_by_v_height[j],
                xs = successive_sums([ for (tile = row) tile("size").x + spacing ]))
            //echo("layout_tiles: ", xs=xs, width=width, sizes=[ for (tile = row) tile("size")])
            for (i = range(row)) {
                let(tile = row[i],
                        pos =[xs[i]-tile("bounds")[0], ys[j]-tile("bounds")[1]]) {
                    echo("layout_tiles: ", pos=pos, tile=row[i](list=true));
                    center_in_space([xs[i], ys[i], xs[i]+tile("size").x,ys[i]+row_heights[j]], tile("bounds")) {
                        create_tile(row[i], pattern);
                    }
                }
            }
        }
    }
}
