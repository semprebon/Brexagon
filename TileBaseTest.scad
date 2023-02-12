include <TileBase.scad>

//best_fit_tile_base(1);
dy = size_to_height(DEFAULT_HEX_SIZE) + 3;
dz = 0;
cutaway_view = false;
max_size = 5*size_to_height(DEFAULT_HEX_SIZE);

tile = define_tile(TILE_SHAPE_TRAPEZOID, [1,2]);
intersection() {
    union() {
        tile_base(tile);
        if (cutaway_view) {
            translate([0,0,0]) rotate([90,0,0]) translate([0,0,-CLIP_WIDTH/2]) tile_clip();
            translate([0,0,BASE_HEIGHT+2*TOLERANCE]) create_tile(tile);
        } else {
            translate([0,dy/2,0]) tile_clip();
            translate([0,-dy,dz]) create_tile(tile);
        }
    }
    if (cutaway_view) {
        translate([0,max_size/2,0]) cube(max_size*[1,1,1], center=true);
    }
}
//pin_block();