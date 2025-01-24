TERRAIN_TILE_KEYS = [ "SD2a_Double_Slope", "SD3a_Double_Slope", "ST2b_Terrace" ];
//TERRAIN_TILES(keys=true);
TILE_NAME = "SD2a_Double_Slope";

include <Tile.scad>
include <TileBase.scad>
include <TerrainTiles.scad>

function object_offset(index, d) = [0, d*index];

echo(tiles=TERRAIN_TILES(list=true),keys=TERRAIN_TILE_KEYS);

if (is_undef(TILE_NAME)) {
    for (i = (range(TERRAIN_TILE_KEYS))) {
        translate(object_offset(i, 100)) create_tile(TERRAIN_TILES(TERRAIN_TILE_KEYS[i]));
    }
} else {
    create_tile(TERRAIN_TILES(TILE_NAME));
}