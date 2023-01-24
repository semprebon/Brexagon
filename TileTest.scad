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

module layout_items(items_per_row=3, area=[220,220]) {
    items_per_column = ceil($children / items_per_row);
    delta = [area.x/items_per_row, area.y/items_per_column];
    offset = [delta.x/2, delta.y/2];
    echo(delta=delta);
    for (i = range($children)) {
        let(
            x = offset.x + (i % items_per_row)*delta.x,
            y = offset.y + (floor(i / items_per_row))*delta.y)
        {
            echo(position = [x,y]);
            translate([x,y,0]) children(i);
        }
    }
}
//test_tenon_fit();
//tile_mortises(define_tile(TILE_SHAPE_HEXAGON,1, [[]]));
// New barriers: 36.9s  Old Barriers: 36.3

layout_items(3) {
    create_tile(H1_FLOOR);
    create_tile(H2_FLOOR);
    create_tile(H3_FLOOR);
    create_tile(H4_FLOOR);
    create_tile(H1_Y_WALL);
    create_tile(H2_X_WALL);
    create_tile(H2_Y_WALL);
    create_tile(H3_X_HALL);
    create_tile(H3_Y_HALL);
    create_tile(H3_CORNER_A);
    create_tile(H1_T_WALL_A);
    create_tile(H3_CORNER_T_A);
    create_tile(H4_CORNER_ENTRY);
}

//create_tile(H4_CORNER_ENTRY);