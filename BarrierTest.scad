include <Barrier.scad>

/*
    Create a brick wall with sides, top, ends textured, bottom plain
*/
module test_pattern_barrier() {
    pattern = tag_pattern(pattern=BRICK_PATTERN, tag="test");
    echo("iniital pattern:", pattern=pattern(list=true));
    patterned_barrier(size=[25,4,15], angle=HORIZONTAL_ANGLE, pattern=pattern);
    //translate([0,50,0]) patterned_barrier([25,4,15], angle=HORIZONTAL_ANGLE, offset=[2,-2], scale=[1,2]);
    //translate([-20,0,0]) patterned_barrier([25,4,15], angle=VERTICAL_ANGLE, pattern=WOOD_PATTERN);
}

test_pattern_barrier();