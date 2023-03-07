include <HexUtils.scad>

module test_hexes_per_row() {
    assert([1] == hexes_per_row([1,1]));
    assert([2,3] == hexes_per_row([2,2]));
}

module test_hex_offset_to_axial() {
    tag = "hex_offset_to_axial";
    assert([0,0] == hex_offset_to_axial([1,1], 0), tag);

    assert([-2,2] == hex_offset_to_axial([3,3], 0), tag);
    assert([0,2] == hex_offset_to_axial(3, 2), tag);
    assert([-2,1] == hex_offset_to_axial(3,3), tag);
    assert([2,0] == hex_offset_to_axial(3,11), tag);
    assert([2,-1] == hex_offset_to_axial(3,15), tag);
    assert([2,-2] == hex_offset_to_axial(3,18), tag);

    assert([-2,1] == hex_offset_to_axial([3,2],0), tag);
    assert([1,1] == hex_offset_to_axial([3,2],3), tag);
    assert([-1,-1] == hex_offset_to_axial([3,2],9), tag);
    assert([2,-1] == hex_offset_to_axial([3,2],12), tag);

    assert([-2,1] == hex_offset_to_axial([3,2],0), tag);
    assert([1,1] == hex_offset_to_axial([3,2],3), tag);
    assert([-1,-1] == hex_offset_to_axial([3,2],9), tag);
    assert([2,-1] == hex_offset_to_axial([3,2],12), tag);
}


module test_rectangle_offset_to_axial() {
    tag = "rectangle_offset_to_axial";
    //assert([0,0], rectangle_offset_to_axial([1,1] 0), tag);

    assert([0,0] == rectangle_offset_to_axial([3,3], 0), tag);
    assert([2,0] == rectangle_offset_to_axial([3,3], 2), tag);
    assert([-1,1] == rectangle_offset_to_axial([3,3], 3), tag);
    assert([-1,2] == rectangle_offset_to_axial([3,3], 6), tag);
}

module test_is_in_rect_tile() {
    tag = "is_in_rect_tile";
    assert(is_in_rect_tile([1,2], [0,0]), tag);
    assert(is_in_rect_tile([1,2], [0,1]), tag);
    assert(!is_in_rect_tile([1,2], [-1,0]), tag);
    assert(!is_in_rect_tile([1,2], [1,0]), tag);
    assert(!is_in_rect_tile([1,2], [0,2]), tag);
    assert(!is_in_rect_tile([1,2], [0,-1]), tag);
}

module test_is_in_hex_tile() {
    tag = "is_in_hex_tile";
    assert(is_in_hex_tile(2, [0,0]), tag);
    assert(is_in_hex_tile(2, [0,1]), tag);
    assert(is_in_hex_tile(2, [-1,1]), tag);
    assert(is_in_hex_tile(2, [1,-1]), tag);
    assert(!is_in_hex_tile(2, [2,-2]), tag);
    assert(!is_in_hex_tile(2, [1,1]), tag);
    assert(!is_in_hex_tile(2, [-1,-1]), tag);
}

module test_is_in_semi_hex_tile() {
    tag = "is_in_semi_hex_tile";
    assert(is_in_semi_hex_tile(2, [0,0]), tag);
    assert(is_in_semi_hex_tile(2, [0,1]), tag);
    assert(is_in_semi_hex_tile(2, [-1,1]), tag);
    assert(!is_in_semi_hex_tile(2, [1,-1]), tag);
    assert(!is_in_semi_hex_tile(2, [2,-2]), tag);
    assert(!is_in_semi_hex_tile(2, [1,1]), tag);
    assert(!is_in_semi_hex_tile(2, [-1,-1]), tag);
}

//module test_x_range() {
//    tag = "hex_range: ";
//    assert([0], [for (i=[0:0]) i], tag, "check");
//    assert([0:0], x_range(1), tag, "count=1");
//    assert([-1:0], x_range(2), tag, "count=2");
//    assert([-1:1], x_range(3), tag, "count=3");
//}

module test_hex_positions() {
    tag = "hex_positions: ";
    assert([[0,0]] == hex_positions(1), "size=1");
    assert([[0,0]] == hex_positions([1,1]), "size=[1,1]");
    assert([[0,1],
                [0,0],[1,0],
                   [1,-1]] == hex_positions([1,2]));
    assert([[0,1],[1,1],
                [0,0],[1,0],[2,0],
                   [1,-1],[2,-1]] == hex_positions(2), "size=2");
}

module test_invert_rows() {
    tag = "invert_rows: ";
    assert([[0,0],[1,0],[2,0]] == invert_rows(trapezoid_positions([3,1])), "single_row");
    assert([[0,1],[1,1], [1,0]] == invert_rows(trapezoid_positions([1,2])), "triangle(2)");
    assert([[0,2],[1,2],[2,2], [1,1],[2,1], [2,0]] ==
            invert_rows(trapezoid_positions([1,3])), "triangle(3)");
}

module test_trapezoid_positions() {
    tag = "trapezoid_positions: ";
    assert([[0,0]] == trapezoid_positions(1), "size=1");
    assert([[0,1],[1,1],[2,1], [0,0],[1,0],[2,0],[3,0]] == trapezoid_positions([3,2]), "size=[3,2]");
    assert([[0,2], [0,1],[1,1], [0,0],[1,0],[2,0]] == trapezoid_positions([1,3]), "size=[1,3]");
}

module test_all() {
    test_hexes_per_row();
    test_rectangle_offset_to_axial();
    test_hex_positions();
    test_trapezoid_positions();
    test_invert_rows();
}

test_all();
