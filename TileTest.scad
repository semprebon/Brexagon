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

test_tenon_fit();
//tile_mortises(define_tile(TILE_SHAPE_HEXAGON,1, [[]]));

/*
layout_hexes(DEFAULT_HEX_SIZE, bricks=[
    ["N","NW","W3","SW"], // edge corner (a)
    ["W3","W2","W","E","E2","E3"], // center horizontal barrier (b)
    ["NW","W3","SW"], // outer vertical barrier (c)
    ["NW","W3","SW","NE","E3","SE"], // vertical hall (d)
    ["N"], // edge horizontal barrier (e)
    ["W3","SW"], // outer corner (f)
    ["NW","W3","W2","W","E","E2","E3"], // center corner (h)
    ["NW2","W2","SW2"], // inner vertical barrier (i)
    ["NW2","W3","SW2"], // inner vertical barrier (i)
    []]); // plain
*/

