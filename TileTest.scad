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

module test_corner_points_with_0_offset() {
    tile = define_tile(TILE_SHAPE_TRAPEZOID, [1,2], [[],[],[]]);
    corners = corner_points(tile);
    for (p = corners) {
        translate(p) sphere(r=3);
    }
}

module test_elevations() {
    // hex centers (assumes hexes are aligned vertically with origin at center hex
    a = [1/2, -size_to_height(3/4)] * DEFAULT_HEX_SIZE;
    b = [0,0];
    c = [1/2, size_to_height(3/4)] * DEFAULT_HEX_SIZE;

    elevation = define_elevation(
        polygon=[
            e_pnt(a,"Sb"), e_pnt(a,"SE"), e_pnt(a,"NE"), e_pnt(a,"N"), e_pnt(b,"SE"),
            e_pnt(b,"NE"), e_pnt(c,"S"), e_pnt(c,"SE"), e_pnt(c,"NEa"), e_pnt(c,"Nc"),
            e_pnt(c,"NWc"), e_pnt(c,"SWc"), e_pnt(b,"Na"), e_pnt(b,"NWc"), e_pnt(b,"SWc"),
            e_pnt(b,"SWc"), e_pnt(b,"Sb"), e_pnt(a,"NWc"), e_pnt(a,"SWc")],
        height = BARRIER_HEIGHT);

    tile = define_tile(TILE_SHAPE_HEXAGON, 2, [[],undef,[],undef,undef,[],undef],
        elevations = [elevation]);
    create_tile(tile=tile);
}

module test_all() {
    translate([75,0,0]) test_elevations();
    test_corner_points_with_0_offset();
}

test_all();