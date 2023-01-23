/*
    Test patterns
*/
include <PatternCutters.scad>

/*
    Create a brick wall with sides, top, ends textured, bottom plain
*/
module test_brick_cutter() {
    brick_wall([25,4,15], angle=HORIZONTAL_ANGLE);
    translate([0,50,0]) brick_wall([25,4,15], angle=HORIZONTAL_ANGLE, offset=[2,-2], scale=[1,2]);
    translate([-20,0,0]) brick_wall([4,25,15], angle=VERTICAL_ANGLE, depth=0.2);
}

module test_line_segment() {
    ps = [[1,1], [1,8], [4,1]];
    line(ps);
}

module test_pattern_cutter() {
    pattern_cutter(BRICK_PATTERN);
}

module test_repeat_pattern() {
    pattern_cutter(expand_pattern(BRICK_PATTERN, [3,2]));
}

//test_line_segment();
//test_pattern_cutter();
//test_repeat_pattern();
test_brick_cutter();