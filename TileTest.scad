/*
    Test models for Tile.scad
*/
include <Tile.scad>
include <TestSupport.scad>

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

H1_FLOOR = define_tile(TILE_SHAPE_HEXAGON, 1,[[]]);
H2_FLOOR = define_tile(TILE_SHAPE_RECTANGLE, [2,1], [[]]);
H3_FLOOR = define_tile(TILE_SHAPE_TRAPEZOID, [1,2], [[],[],[]]);
H4_FLOOR = define_tile(TILE_SHAPE_RECTANGLE, [2,2], [[],[],[],[]]);

H2_X_WALL = define_tile(TILE_SHAPE_TRAPEZOID, [1,2], [[],[],undef],
    barriers=[x_barrier(y=7/16, x1=-0.5, x2=1)]);
H1_Y_WALL = define_tile(TILE_SHAPE_HEXAGON, 1, [[]],
    barriers=[y_barrier(x=0, y1=-0.5, y2=0.5)]);
H2_Y_WALL = define_tile(TILE_SHAPE_RECTANGLE, [2,1], [[],[]],
    barriers=[y_barrier(x=0.5, y1=-5/16, y2=5/16)]);
H3_X_HALL = define_tile(TILE_SHAPE_HEXAGON, 2, [[],undef,[],undef,undef,[],undef],
    barriers=[x_barrier(y=7/16, x1=-0.5, x2=1),x_barrier(y=-7/16, x1=-0.5, x2=1)]);
H3_Y_HALL = define_tile(TILE_SHAPE_RECTANGLE, [3,1], [[],[],[]],
    barriers=[y_barrier(x=0.5, y1=-5/16, y2=5/16),y_barrier(x=1.5, y1=-5/16, y2=5/16)]);
H3_CORNER_A = define_tile(TILE_SHAPE_TRAPEZOID, [1,2], [[],[],[]],
    barriers=[x_barrier(y=7/16, x1=-0.5, x2=0.5),y_barrier(x=0.5, y1=-5/16, y2=0.5)]);
H1_T_WALL_A = define_tile(TILE_SHAPE_HEXAGON, 1, [[]],
    barriers=[y_barrier(x=0, y1=-0.5, y2=0.5),x_barrier(y=-5/16,x1=0,x2=0.5)]);
H3_CORNER_T_A = define_tile(TILE_SHAPE_TRAPEZOID, [1,2], [[],[],[]],
    barriers=[x_barrier(y=5/16,x1=-0.5,x2=0.5),y_barrier(x=0.5, y1=4/16, y2=1+4/16),
        x_barrier(y=1+1/16,x1=0.5,x2=1)]);
H4_CORNER_ENTRY = define_tile(TILE_SHAPE_TRAPEZOID, [2,2], [[],undef,[],[],[]],
    barriers=[x_barrier(y=5/16, x1=-0.5, x2=0.5), y_barrier(x=0.5, y1=6/16, y2=-5/16),
        y_barrier(x=1.5, y1=5/16, y2=-5/16)]);
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
create_tile(H4_CORNER_ENTRY, wall_pattern=scale_pattern(BRICK_PATTERN, scale=[1,1]),
    floor_pattern=WOOD_PATTERN);

//test_successive_sums();
