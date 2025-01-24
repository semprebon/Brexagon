/*
    Defines a set of terrain tiles
*/
include <Elevation.scad>
include <Tile.scad>

function h_pnt(hexes, index, pos) = e_pnt(hex_center(hexes, index), pos);

function define_elevation_tile(shape, size, heights, used, elevation_data) =
    let(
        hexes = define_tile(shape, size, used)("hexes"),
        elevations = [ for (i = range(elevation_data))
            define_elevation(
                polygon=[ for (pair = elevation_data[i]) h_pnt(hexes, pair.x, pair.y) ],
                height=heights[i]) ])
    define_tile(shape, size, used, elevations=elevations);

SD_3A_DOUBLE_SLOPE = define_elevation_tile(TILE_SHAPE_RECTANGLE, [1,3],
    heights = [BARRIER_HEIGHT],
    elevation_data = [[[0,"Sb"], [0,"SE"], [0,"NE"], [0,"N"], [1,"SE"],
        [1,"NE"], [2,"S"], [2,"SE"], [2,"NEa"], [2,"Nc"],
        [2,"NWc"], [2,"SWc"], [1,"Na"], [1,"NWc"], [1,"SWc"],
        [1,"SWc"], [1,"Sb"], [0,"NWc"], [0,"SWc"]]]);

SD_2A_DOUBLE_SLOPE = define_elevation_tile(TILE_SHAPE_RECTANGLE, [2,1],
    heights = [BARRIER_HEIGHT],
    elevation_data = [[[0,"SWa"],[0,"Sc"],[0,"SEb"],[1,"Sc"],[1,"SEb"],
        [1,"NE"], [1,"N"],[1,"NW"],[0,"N"],[0,"NW"]]]);

ST_2A_TERRACE = define_elevation_tile(TILE_SHAPE_RECTANGLE, [2,1],
    heights = [BARRIER_HEIGHT/2, BARRIER_HEIGHT],
    elevation_data = [
        [[0,"N"],[0,"SWc"],[0,"SEb"],[1,"Sc"],[1,"SEb"],[1,"NE"],[1,"N"],[1,"NW"]],
        [[0,"N"],[0,"NWa"],[0,"SWc"],[0,"Sc"],[0,"SEc"],[0,"NEb"]]]);

TERRAIN_TILES = associate([
    "SD2a_Double_Slope", SD_2A_DOUBLE_SLOPE,
    "ST2a_Terrace", ST_2A_TERRACE,
    "SD3a_Double_Slope", SD_3A_DOUBLE_SLOPE]);
