include <TestSupport.scad>
include <ClippingAlgorithm.scad>

module test_clip_segment_to_bounds() {
    tag="clip_segment_to_bounds: ";
    bounds = [0,0,10,10];
    in1 = [1,1]; in2=[2,8];
    left = [12,1]; right = [-2,8]; above = [2,12]; below = [2,-5];
    assert_equals([in1,in2], clip_segment_to_bounds(in1, in2, bounds), tag, "keeps segment inside unchanged");
    assert_equals([], clip_segment_to_bounds(left, left+[1,1], bounds), tag, "drops segment outside");
    assert_equals([in1, [10,1]], clip_segment_to_bounds(in1, left, bounds), tag, "drops segment to left of box");
    assert_equals([[2,10], [2,0]], clip_segment_to_bounds(above, below, bounds), tag, "drops segments above and below box");
    assert_equals([[10,2], [0,7]], clip_segment_to_bounds(left, right, bounds), tag, "drops segments left and right box");
}

test_clip_segment_to_bounds();
