include <Elevation.scad>
include <Tile.scad>

module test_tiny_hill() {
    dy = size_to_height(3/8);
    d = [3/8, size_to_height(3/16)];
    elevation = define_elevation(
        polygon = [[0,dy], [d.x,d.y], [d.x,-d.y], [0,-dy], [-d.x,-d.y], [-d.x,d.y]],
        height = BARRIER_HEIGHT);
    tile = define_tile(TILE_SHAPE_HEXAGON, 1, [[]]);
    raise_elevation(tile_vertices(tile), elevation);
}

test_tiny_hill();
