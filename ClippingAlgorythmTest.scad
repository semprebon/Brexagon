include <ClippingAlgorithm.scad>

module test_clip_segment_to_bounds() {
    bounds = [0,0,10,10];
    in1 = [1,1]; in2=[2,8];
    left = [12,1]; right = [-2,8]; above = [2,12]; below = [2,-5];
    assert([in1,in2] == clip_segment_to_bounds(in1, in2, bounds), "keeps segment inside unchanged");
    assert([] == clip_segment_to_bounds(left, left+[1,1], bounds), "drops segment outside");
    assert([in1, [10,1]] == clip_segment_to_bounds(in1, left, bounds), "drops segment to left of box");
    assert([[2,10], [2,0]] == clip_segment_to_bounds(above, below,4 bounds), "drops segments above and below box");
    assert([[10,2], [0,7]] == clip_segment_to_bounds(left, right, bounds), "drops segments left and right box");
}

test_clip_segment_to_bounds();
