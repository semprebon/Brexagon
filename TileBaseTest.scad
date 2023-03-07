include <TileBase.scad>

//best_fit_tile_base(1);
dy = size_to_height(DEFAULT_HEX_SIZE) + 3;
dz = 0;
cutaway_view = "none"; // [ none, front, side, top ]
max_size = 5*size_to_height(DEFAULT_HEX_SIZE);

tile = define_tile(TILE_SHAPE_HEXAGON, [1,1]);

intersection() {
    union() {
        rotate([]) tile_base(tile);
        if (cutaway_view != "none") {
            translate([0,0,0]) rotate([90,0,0]) translate([0,0,-CLIP_WIDTH/2]) tile_clip();
            translate([0,0,BASE_HEIGHT+TOLERANCE]) create_tile(tile);
           translate([0,0,-BASE_HEIGHT-TOLERANCE]) clip_tool();
        } else {
            translate([0,dy/2,0]) tile_clip();
            translate([0,-dy,dz]) create_tile(tile, floor_pattern=WOOD_PATTERN);
           // translate([dy,dy,0]) clip_tool();
        }
    }

    if (cutaway_view != "none") {
        offset = (cutaway_view == "side") ? [0,max_size/2,0]
               : (cutaway_view == "front") ? [max_size/2,0,0] : [0,0,-max_size/2+BASE_HEIGHT];
        translate(offset) cube(max_size*[1,1,1], center=true);
    }
}
//pin_block();