/*
    Test patterns
*/
include <PatternCutters.scad>

module test_line_segment() {
    ps = [[1,1], [1,8], [4,1]];
    line(ps);
}

module test_crop_path() {
    in1 = [1,1]; in2=[2,8]; in3=[9,9];
    out1 = [12,1]; out2 = [12,2];
    assert([[in1,in2,in3]] == crop_path([in1,in2,in3], [10,10]), "keeps paths inside unchanged");
    assert([] == crop_path([out1,out2], [10,10]), "drops paths outside");

    left = [12,1]; right = [-2,8]; above = [2,12]; below = [2,-5];
    assert([[in1, [10,1]],[[10,3],[8,5]]] ==
        crop_path([in1, left, [8,5]], [10,10]), "truncates path that goes out and back in");
    assert([[in1, [10,1]],[[10,5],[8,5]]] ==
        crop_path([[1,1],[12,1],[12,5], [8,5]], [10,10]), "truncates path that goes out and back in");
    assert([[[1,1],[10,1]],[[10,3],[3,10]],[[1,10],[1,1]]] ==
        crop_path([[1,1],[12,1],[1,12],[1,1]], [10,10]), "truncates path that goes out and back in");
}

module test_pattern_cutter() {
    pattern_cutter(WOOD_PATTERN);
    %cube(to_3d_point(WOOD_PATTERN("size"))+[0,0.1,0]);
}

module test_repeat_pattern() {
    pattern_cutter(expand_pattern(BRICK_PATTERN, [3,2]));
    size = BRICK_PATTERN("size");
    %cube([size.x*3,0.1,size.y*2]);
}

module test_crop_pattern() {
    expanded = expand_pattern(BRICK_PATTERN, [1,1]);
    cropped = crop_pattern(expanded, DEFAULT_PATTERN_SIZE);
    pattern_cutter(cropped);
    %cube([DEFAULT_PATTERN_SIZE.x, DEFAULT_SIDE/4, DEFAULT_PATTERN_SIZE.y]);
}

module test_all() {
    test_crop_path();
    test_pattern_cutter();
    translate([0,50,0]) test_repeat_pattern();
    translate([0,100,0]) test_crop_pattern();
}

//test_pattern_cutter();
//test_crop_path();
//test_crop_pattern();
test_all();