/*
    Test models for Tile.scad
*/
include <Tile.scad>

module test_tenon_fit() {
    tile = define_tile(TILE_SHAPE_HEXAGON, 1, [[]]);
    create_tile(tile);
    translate([DEFAULT_HEX_SIZE + 2, 0, 0]) tile_base(tile);
}

//simple_hex();
//translate([0,1.2*DEFAULT_HEX_SIZE,0]) simple_hex();
//translate([0,-1.2*DEFAULT_HEX_SIZE,0]) simple_hex();
//best_fit_tile_base(size=4);
//tile_base(shape=TILE_SHAPE_TRAPEZOID, size=[1,2]);
// enclosed rectangle
//create_hex(DEFAULT_HEX_SIZE, barriers=["NW","N2","NE", "E", "SE","S2","SW", "W"]);
// double cross
//create_hex(DEFAULT_HEX_SIZE, barriers=[]);

//create_hex(DEFAULT_HEX_SIZE, barriers=["N","S","E","W","E2","W2","NE","SE","SW2","NW2"]);
//create_hex(DEFAULT_HEX_SIZE, barriers=["W","E2","W3"]);

/*
tile = define_tile(TILE_SHAPE_HEXAGON, [2,2], [
    ["SW","S3","SE"],undef,
    ["NW2","N2","NE2", "SW2","S2","SE2"],undef,undef,
    ["NW","N3","NE"],undef]);
*/

//layout_tiles(spacing=3, tiles=[
//    H2_Y_WALL,
//    H2_X_WALL,
//    H3_CORNER_A,
//    H3_X_HALL,
//    H4_CORNER_ENTRY,
//    H1_T_WALL_A], pattern=BRICK_PATTERN);
    //
    //create_tile(H1_FLOOR);
    //create_tile(H2_FLOOR);
    //create_tile(H3_FLOOR);
    //create_tile(H4_FLOOR);
    //create_tile(H2_Y_WALL);
    //create_tile(H2_X_WALL);
    //create_tile(H3_CORNER_A);
    //create_tile(H3_X_HALL);
    //create_tile(H3_Y_HALL);
    //create_tile(H1_Y_WALL);
    //create_tile(H1_T_WALL_A);
    //create_tile(H3_CORNER_T_A);
/*
    H4_CORNER_ENTRY - Render: 2:15s, Vertices:2900
*/

//create_tile(H4_CORNER_ENTRY, wall_pattern=scale_pattern(BRICK_PATTERN, scale=[1,1]),
//    floor_pattern=WOOD_PATTERN);
tile = define_tile(TILE_SHAPE_HEXAGON, 1,[[]]);
//intersection() {
//    union() {
//        translate([0,0,BASE_HEIGHT+TOLERANCE]) create_tile(tile, wall_pattern=scale_pattern(BRICK_PATTERN, scale=[1,1]), floor_pattern=BLANK_PATTERN);
//        tile_base(define_tile(TILE_SHAPE_HEXAGON, 1, [[],[],[]]));
//    }
//    cube([50,50,BASE_HEIGHT+3], center=true);
//}

//translate([DEFAULT_HEX_SIZE+2,0,0]) create_tile(tile, wall_pattern=scale_pattern(BRICK_PATTERN, scale=[1,1]), floor_pattern=BLANK_PATTERN);
//tile_base(define_tile(TILE_SHAPE_HEXAGON, 1, [[],[],[]]));

tile_clip();
translate([0,PIN_HEIGHT+CLIP_HEIGHT+TOLERANCE+3,0]) mirror([0,1,0]) tile_clip_socket();
