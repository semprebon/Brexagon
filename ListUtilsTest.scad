include <ListUtils.scad>;
include <TestSupport.scad>;

module test_drop() {
    tag = "drop: ";
    assert_equals([], drop([],1), tag, "drop from empty list is empty list");
    assert_equals([], drop([1,2],4), tag, "drop too many from short list is empty list");
    assert_equals([3], drop([1,2,3],2), tag, "drop from list drops first values");
    assert_equals(undef, drop([1,2,3],-1), tag, "can't drop negative items");
}

module test_fold() {
    tag = "fold ";
    sum = function (a,b) a + b;
    assert_equals(7, fold([1,2,3], 1, sum), tag, "accumulates 1 + (1+2+3) = 7");
    assert_equals(1, fold([], 1, sum), tag, "returns initial value if list empty");
}

module test_fold_index() {
    tag = "fold_index ";
    sum_mult = function (a,b,i) a + b*i;
    assert_equals(9, fold_index([3,4,2], 1, sum_mult), tag, "accumulates 1 + (0*3 + 1*4 + 2*2) = 9");
    assert_equals(1, fold_index([], 1, sum_mult), tag, "returns initial value if list empty");
}

module test_repeat() {
    tag = "repeat: ";
    assert_equals([], repeat([1,2], 0), tag, "repeat 0 times is empty list");
    assert_equals([1,2,1,2,1,2], repeat([1,2], 3), tag, "repeat 3 times is list repeated");
}

module test_generate() {
    tag = "generate: ";
    squares = function(i) i*i;
    assert_equals([], generate(squares, 0), tag, "generate 0 times is empty list");
    assert_equals([0,1,4,9], generate(squares, 4), tag, "generate 4 times");
}

module test_flat_map() {
    tag = "flat_map: ";
    double = function(a) [a,a];
    assert_equals([1,1,2,2,3,3], flat_map([1,2,3], double));
}

test_drop();
test_fold();
test_fold_index();
test_repeat();
test_generate();
test_flat_map();