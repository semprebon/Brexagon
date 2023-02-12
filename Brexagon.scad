
SHAPE = "H4_CORNER_ENTRY"; // [ H1_FLOOR, H2_FLOOR, H3_FLOOR, H4_FLOOR, H2_Y_WALL, H2_X_WALL, H1_Y_WALL, H3_X_HALL, H3_Y_HALL, H3_CORNER_A, H1_T_WALL_A, H3_CORNER_T_A, H4_CORNER_ENTRY, H2_X_ENTRY, BASE, CLIP]

WALL_PATTERN = "BLANK"; // [BLANK, BRICK, WOOD]
FLOOR_PATTERN = "BLANK"; // [BLANK, BRICK, WOOD]

BASE_SIZE = [2,2]; // [1:5]
BASE_TYPE = "hexagon"; // [ hexagon,trapezoid,rectangle ]

include <Tile.scad>
include <TileBase.scad>

// tile shapes
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
H2_X_ENTRY = define_tile(TILE_SHAPE_RECTANGLE, [2,1], [[],[]],
     barriers=[x_barrier(y=7/16, x1=0.5, x2=1.5),x_barrier(y=-7/16, x1=0.5, x2=1.5)]);

SHAPES = associate([
    // Floors
    "H1_FLOOR", H1_FLOOR, "H2_FLOOR", H2_FLOOR, "H3_FLOOR", H3_FLOOR, "H4_FLOOR", H4_FLOOR,
    // Simple walls
    "H2_Y_WALL", H2_Y_WALL, "H2_X_WALL", H2_X_WALL, "H1_Y_WALL", H1_Y_WALL,
    // Halls
    "H3_X_HALL", H3_X_HALL, "H3_Y_HALL", H3_Y_HALL,
    // Simple Corners
    "H3_CORNER_A", H3_CORNER_A,
    // Complex Corners
    "H1_T_WALL_A", H1_T_WALL_A, "H3_CORNER_T_A", H3_CORNER_T_A,
    // Entrances
    "H4_CORNER_ENTRY", H4_CORNER_ENTRY, "H2_X_ENTRY", H2_X_ENTRY]);

PATTERNS = associate([
    "BLANK", BLANK_PATTERN, "BRICK", BRICK_PATTERN, "WOOD", WOOD_PATTERN]);

if (SHAPE == "BASE") {
    best_fit_tile_base(BASE_TYPE, BASE_SIZE);
} else if (SHAPE == "CLIP") {
    tile_clip();
} else {
    create_tile(SHAPES(SHAPE), wall_pattern=PATTERNS(WALL_PATTERN), floor_pattern=PATTERNS(FLOOR_PATTERN));
}


