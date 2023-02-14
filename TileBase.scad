include <Tile.scad>

ACCESS_SIZE = (2/3)*MORTISE_SIZE;
RETAINER_SIZE = 2*(PIN_RADIUS + LATCH_INSET - WALL_THICKNESS - 2*TOLERANCE);
CLIP_BASE_SIZE = [2*PIN_RADIUS, CLIP_HEIGHT];

function clip_angle(tile, i) =
    let (axial = tile("hexes")[i]("position"))
    (axial.x - axial.y % 3) * 120;

/*
 Generates a base for bricks
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
    clip_slot_size = [CLIP_BASE_SIZE.x+LATCH_INSET, CLIP_WIDTH, BASE_HEIGHT] + 2*TOLERANCE*[2,1,2];

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
                translate([0,0,BASE_HEIGHT/2]) cube(clip_slot_size, center=true);
            }
        }
    }
}

module tile_clip() {
    block_width = WALL_THICKNESS;
    outer_latch_size = [block_width,PIN_HEIGHT];
    inner_latch_size = [block_width,PIN_HEIGHT+WALL_THICKNESS*7/8];
    //latch_height = block_height - 4*LAYER_HEIGHT;
    outer_inset_size = [LATCH_INSET, LAYER_HEIGHT*6];
    inner_inset_size = [LATCH_INSET+0.2, LAYER_HEIGHT*10];
    linear_extrude(height=CLIP_WIDTH) {
        translate([-CLIP_BASE_SIZE.x/2,0]) square(CLIP_BASE_SIZE);
        mirrored_pair([1,0,0]) translate([-PIN_RADIUS,0,0]) latch_outline(outer_latch_size, outer_inset_size);
        mirrored_pair([1,0,0]) translate([-ACCESS_SIZE/2+TOLERANCE,0,0]) latch_outline(inner_latch_size, inner_inset_size, locking=true);
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

