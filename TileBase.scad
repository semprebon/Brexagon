include <Tile.scad>

ACCESS_SIZE = (1/2)*MORTISE_SIZE; // hex size of bottom holes in base
RETAINER_SIZE = 2*(PIN_RADIUS + LATCH_INSET - WALL_THICKNESS - 4*TOLERANCE); // size of retainer
CLIP_BASE_SIZE = [2*PIN_RADIUS, CLIP_HEIGHT];
RETAINER_HEIGHT = PIN_HEIGHT-2*LAYER_HEIGHT;

/*
    Return angle of clip socket for given hex in base.
    Clip angles alternate along all the three hexagon axes to minimize weakness along any one.

    Each step along the +x axis rotates 120 degrees clockwise.
    Each step along the +x+y (NE) axes rotate 60 degrees clockwise.

    tile - tile object
    i - ordinal hex number
*/
function clip_angle(tile, i) =
    let (axial = tile("hexes")[i]("position"))
    (axial.x - axial.y % 3) * 120;

/*
    Generates a base for bricks based on a tile definition
*/
module tile_base(tile) {
    hexes = tile("hexes");
    echo(hex_positions=[ for (h = hexes) h("position") ]);
    //hole_radius = (1/3) * DEFAULT_HEX_SIZE;
    hole_size = 2 * PIN_RADIUS-LINE_WIDTH;
    bevel = 0.4;
    guide_size = RETAINER_SIZE;
    guide_offset = size_to_height(PIN_RADIUS) - size_to_side(guide_size);
    //-size_to_side(guide_size);
    //clip_slot_size = [2*PIN_RADIUS+2*TOLERANCE,CLIP_WIDTH+2*TOLERANCE,BASE_HEIGHT+4*TOLERANCE];
    clip_slot_size = [CLIP_BASE_SIZE.x+LATCH_INSET, CLIP_WIDTH, BASE_HEIGHT] + 4*TOLERANCE*[1,1,1];
    screw_hole_radius = 1.0;

    difference() {
        union() {
            // base bottom surface
            linear_extrude(height=BASE_HEIGHT) {
                offset(delta=-TOLERANCE) {
                    tile_shape(tile);
                }
            }
            // guide walls
            for (i = range(hexes)) {
                translate(hex_center(hexes, i)) rotate([0,0,clip_angle(tile, i)]) {
                        mirrored_pair([0,1,0]) translate([0,guide_offset]) hexagon_prism(guide_size, RETAINER_HEIGHT);
                }
            }
            // clip retainer
            for (i = range(hexes)) {
                translate(hex_center(hexes, i)) difference() {
                        hexagon_prism(RETAINER_SIZE, RETAINER_HEIGHT);
                        hexagon_prism(ACCESS_SIZE, RETAINER_HEIGHT);
                }
            }
        }
        // center access hole
        for (i = range(hexes)) {
            translate(hex_center(hexes, i)) {
                rotate([0,0,clip_angle(tile, i)]) mirrored_pair([0,1,0]) translate([0,4])
                hexagon_prism(size=ACCESS_SIZE, height=TILE_HEIGHT);
            }
        }
        // clip slot
        for (i = range(hexes)) {
            translate(hex_center(hexes, i)) rotate([0,0,clip_angle(tile, i)]) {
                translate([0,0,BASE_HEIGHT/2]) cube(clip_slot_size, center=true);
            }
        }
    }
}

module tile_clip() {
    block_width = WALL_THICKNESS;
    outer_latch_size = [block_width,PIN_HEIGHT];
    inner_latch_size = [block_width,PIN_HEIGHT+WALL_THICKNESS*5/8];
    //latch_height = block_height - 4*LAYER_HEIGHT;
    outer_inset_size = [LATCH_INSET, LAYER_HEIGHT*6];
    inner_inset_size = [LATCH_INSET+0.2, LAYER_HEIGHT*10];
    linear_extrude(height=CLIP_WIDTH) {
        translate([-CLIP_BASE_SIZE.x/2,0]) square(CLIP_BASE_SIZE);
        mirrored_pair([1,0,0]) translate([-PIN_RADIUS,0,0]) latch_outline(outer_latch_size, outer_inset_size);
        mirrored_pair([1,0,0]) translate([-ACCESS_SIZE/2+TOLERANCE,0,0]) latch_outline(inner_latch_size, inner_inset_size, locking=true);
    }
}

module clip_tool() {
    hexagon_prism(size=DEFAULT_HEX_SIZE, height=BASE_HEIGHT);
    translate([0,0,BASE_HEIGHT]) difference() {
        mirrored_pair([0,1,0]) translate([0,4]) hexagon_prism(size=ACCESS_SIZE-6*TOLERANCE, height=TILE_HEIGHT*1.5);
        translate([0,0,TILE_HEIGHT/2]) cube([CLIP_BASE_SIZE.x, CLIP_WIDTH+6*TOLERANCE, TILE_HEIGHT*10], center=true);
    }
}

module best_fit_tile_base(base_type, size) {
    tile = define_tile(base_type, size);
    offset = -tile("size") * 0.5 - tile("bounds")[0];

    intersection() {
        translate([offset.x, offset.y, 0]) tile_base(tile);
        cube([220,220,250], center=true);
    }
}

