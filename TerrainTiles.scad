/*
    Defines a set of terrain tiles
*/
include <Elevation.scad>
include <Tile.scad>

BASE_TILE = define_tile(TILE_SHAPE_HEXAGON, 2, [[],[],[],[],[],[]]);

function h_pnt(hex_idx, pos) = e_pnt(BASE_TILE("hexes")[hex_idx]("position"), pos);

function define_elevation_tile(shape, size, height, idx_offsets) =
    base_tile = define_tile(TILE_SHAPE_HEXAGON, 2, [[],[],[],[],[],[]])("hexes")("positions");
    points = [ for (pair = idx_offset) h_pnt(pair.x, pair.y)];
    elevation = define_elevation(
        polygon=points,
        height = height)
    define_tile()

SD_3A_DOUBLE_SLOPE = define_elevation_tile(
    [[5,"Sb"], [5,"SE"], [5,"NE"], [5,"N"], [2,"SE"],
    [2,"NE"], [0,"S"], [0,"SE"], [0,"NEa"], [0,"Nc"],
    [0,"NWc"], [0,"SWc"], [2,"Na"], [2,"NWc"], [2,"SWc"],
    [2,"SWc"], [2,"Sb"], [5,"NWc"], [5,"SWc"]]);
