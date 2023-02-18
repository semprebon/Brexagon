include <Elevation.scad>
include <Tile.scad>

module test_e_pnt() {
    c = [0,0];
    polygon([ for (pos = ["N", "NE", "SE", "S", "SW", "NW"]) e_pnt([0,0], pos) ]);
    %translate([0,0,0.1]) polygon([ for (pos = ["Nc", "NEc", "SEc", "Sc", "SWc", "NWc"]) e_pnt([0,0], pos) ]);
    #polygon([ for (pos = ["Na", "NEa", "SEa", "Sa", "SWa", "NWa"]) e_pnt([0,0], pos) ]);
    #polygon([ for (pos = ["Nb", "NEb", "SEb", "Sb", "SWb", "NWb"]) e_pnt([0,0], pos) ]);
}

module test_tiny_hill() {
    elevation = define_elevation(
        polygon = [ for (pos = ["Nc", "NEc", "SEc", "Sc", "SWc", "NWc"]) e_pnt([0,0], pos) ],
        height = BARRIER_HEIGHT);
    tile = define_tile(TILE_SHAPE_HEXAGON, 1, [[]]);
    raise_elevation(tile_vertices(tile), elevation);
}

module test_cliff() {
    // hex centers (assumes hexes are aligned vertically with origin at center hex
    a = [1/2, -size_to_height(3/4)] * DEFAULT_HEX_SIZE;
    b = [0,0];
    c = [1/2, size_to_height(3/4)] * DEFAULT_HEX_SIZE;
    tile = define_tile(TILE_SHAPE_HEXAGON, 2, [[],undef,[],undef,undef,[],undef]);

    elevation = define_elevation(
        polygon=[
            e_pnt(a,"Sb"), e_pnt(a,"SE"), e_pnt(a,"NE"), e_pnt(a,"N"), e_pnt(b,"SE"),
            e_pnt(b,"NE"), e_pnt(c,"S"), e_pnt(c,"SE"), e_pnt(c,"NEa"), e_pnt(c,"Nc"),
            e_pnt(c,"NWc"), e_pnt(c,"SWc"), e_pnt(b,"Na"), e_pnt(b,"NWc"), e_pnt(b,"SWc"),
            e_pnt(b,"SWc"), e_pnt(b,"Sb"), e_pnt(a,"NWc"), e_pnt(a,"SWc")],
        height = BARRIER_HEIGHT);
    //#polygon(elevation("polygon"));
    #tile_shape(tile);
    raise_elevation(tile_vertices(tile), elevation);
    echo(a_NWc=e_pnt(a,"NWc"));
    %translate(concat(e_pnt(a,"SWc"), [BARRIER_HEIGHT])) sphere(r=1);
}

module test_all() {
    translate([50,0,0]) test_tiny_hill();
    translate([-50,0,0]) test_e_pnt();
    test_cliff();
}

test_all();