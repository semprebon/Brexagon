include <Tile.scad>

ACCESS_SIZE = (2/3)*MORTISE_SIZE;
RETAINER_SIZE = 2*(PIN_RADIUS + LATCH_INSET - WALL_THICKNESS - 2*TOLERANCE);

function clip_angle(tile, i) =
    let (hex = tile("hexes")[i])
    (i % 3) * 120;

/*
 Generates a base for bricks
 */
module tile_base(tile) {
    hexes = tile("hexes");
    //hole_radius = (1/3) * DEFAULT_HEX_SIZE;
    hole_size = 2 * PIN_RADIUS-LINE_WIDTH;
    bevel = 0.4;
    guide_size = RETAINER_SIZE;
    guide_offset = size_to_height(PIN_RADIUS) - size_to_side(guide_size);
    //-size_to_side(guide_size);

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
                translate(hex_center(hexes, i)) {
                        mirrored_pair([0,1,0]) translate([0,guide_offset]) hexagon_prism(guide_size, PIN_HEIGHT);
                }
            }
            // clip retainer
            translate([0,0,BASE_HEIGHT]) for (i = range(hexes)) {
                translate(hex_center(hexes, i)) difference() {
                        hexagon_prism(RETAINER_SIZE, PIN_HEIGHT-BASE_HEIGHT);
                        hexagon_prism(ACCESS_SIZE, PIN_HEIGHT-BASE_HEIGHT);
                }
            }
        }
        // center access hole
        for (i = range(hexes)) {
            translate(hex_center(hexes, i)) hexagon_prism(size=ACCESS_SIZE, height=TILE_HEIGHT);
        }
        // clip slot
        for (i = range(hexes)) {
            translate(hex_center(hexes, i)) rotate([0,0,clip_angle(tile, i)]) {
                translate([0,0,BASE_HEIGHT/2]) cube([DEFAULT_HEX_SIZE,CLIP_WIDTH+2*TOLERANCE,BASE_HEIGHT+4*TOLERANCE], center=true);
            }
        }
    }
}

module tile_clip() {
    block_width = WALL_THICKNESS;
    outer_latch_size = [block_width,PIN_HEIGHT];
    inner_latch_size = [block_width,PIN_HEIGHT+WALL_THICKNESS/2];
    //latch_height = block_height - 4*LAYER_HEIGHT;
    inset_size = [LATCH_INSET, LAYER_HEIGHT*5];
    length = DEFAULT_HEX_SIZE - 2*TOLERANCE;
    linear_extrude(height=CLIP_WIDTH) {
        translate([-length/2,0]) square([length, CLIP_HEIGHT]);
        mirrored_pair([1,0,0]) translate([-PIN_RADIUS,0,0]) latch_outline(outer_latch_size, inset_size);
        mirrored_pair([1,0,0]) translate([-ACCESS_SIZE/2+TOLERANCE,0,0]) latch_outline(inner_latch_size, inset_size, locking=true);
    }
}

module best_fit_tile_base(base_type, size) {
    tile = define_tile(base_type, size);

    intersection() {
        rotate([0,0,15]) translate([-DEFAULT_HEX_SIZE,0,0]) tile_base(tile);
        cube([220,220,250], center=true);
    }
}

