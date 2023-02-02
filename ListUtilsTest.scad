include <ListUtils.scad>;
include <TestSupport.scad>;

module test_drop() {
    tag = "drop: ";
    assert_equals([], drop([],1), tag, "drop from empty list is empty list");
    assert_equals([], drop([1,2],4), tag, "drop too many from short list is empty list");
    assert_equals([3], drop([1,2,3],2), tag, "drop from list drops first values");
    assert_equals([2,3], drop([1,2,3]), tag, "drop 1 from list is no count specified");
    assert_equals(undef, drop([1,2,3],-1), tag, "can't drop negative items");
}

module test_drop_last() {
    tag = "drop_last: ";
    assert_equals([], drop_last([],1), tag, "drop from empty list is empty list");
    assert_equals([], drop_last([1,2],4), tag, "drop too many from short list is empty list");
    assert_equals([1], drop_last([1,2,3],2), tag, "drop from list drops last values");
    assert_equals([1,2], drop_last([1,2,3]), tag, "drop 1 from list is no count specified");
    assert_equals(undef, drop_last([1,2,3],-1), tag, "can't drop negative items");
}

module test_last() {
    tag = "last: ";
    assert_equals(undef, last([]), tag, "empty list has undef last item");
    assert_equals(2, last([1,2]), tag, "return last item");
}

module test_concat_to_last() {
    tag = "concat_to_last: ";
    assert_equals([], concat_to_last([], []), tag, "adding empty to empty returns empty");
    assert_equals([[1,2]], concat_to_last([[]], [1,2]), tag, "adding list to empty lists gives list of one");
    assert_equals([[1,2,3]], concat_to_last([[1,2,3]], []), tag, "adding empty list doesn't change last list");
    assert_equals([[1,2,3,4]], concat_to_last([[1,2,3]], [4]), tag, "adding list to single list adds to end of list");
    assert_equals([[1,2],[3,4]], concat_to_last([[1,2],[3]], [4]), tag, "adding list to many list adds to end of last list");
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

module test_remove() {
    tag = "remove: ";
    assert_equals([1,7], remove([0,1,2,4,6,7], function (a) a%2 == 0), tag, "remove even values");
    assert_equals([], remove([0,1,2,4,6,7], function (a) a%2 >= 0), tag, "remove all values");
    assert_equals([], remove([], function (a) a%2 >= 0), tag, "works on empty list");
}

module test_flat_map() {
    tag = "flat_map: ";
    double = function(a) [a,a];
    assert_equals([1,1,2,2,3,3], flat_map([1,2,3], double));
}

module test_reduce() {
    tag = "reduce: ";
    assert_equals(24, reduce([4,3,2,1], function (a,b) a*b), tag, "multiplies list items");
    assert_equals(4, reduce([4], function (a,b) a*b), tag, "return single item");
    assert_equals(undef, reduce([], function (a,b) a*b), tag, "return undef for empty list");
}

module test_quicksort() {
    tag = "quicksort: ";
    identity = function (a) a;
    assert_equals([1,1,2,3,6,8,9],
        quicksort([6,1,8,9,1,3,2], identity), tag, "sorts numbers");

    t_index = function (s) search("t", s)[0];
    unsorted = ["sect","stack", "trick","arrest", "stop"];
    assert_equals(["trick","stack","stop","sect","arrest"],
        quicksort(unsorted, t_index), "tag", "sorts numbers");
}

module test_fill() {
    tag = "fill: ";
    items = ["cat", "duck", "ox", "rabbit", "hen"];
    assert_equals([["cat", "duck", "ox"],["rabbit", "hen"]],
        fill(items, 11, get_size=function (s) len(s)), tag, "splits items in groups so group length <= 11");
    assert_equals([["cat", "duck"], ["ox"],["rabbit"], ["hen"]],
        fill(items, 7, get_size=function (s) len(s)), tag, "splits items in groups so group length <= 7");
    assert_equals([[]],
        fill([], 7, get_size=function (s) len(s)), tag, "returns list of empty list if no items");
}

module test_flatten() {
    tag = "flatten: ";
    items = [1,2,[3,4],[[5],[],6]];
    assert_equals([1,2,3,4,[5],[],6], flatten(items), tag, "flattens list");
    assert_equals([], flatten([]), tag, "flattens empty list");
}

test_drop();
test_last();
test_drop_last();
test_concat_to_last();
test_reduce();
test_fold();
test_fold_index();
test_repeat();
test_generate();
test_remove();
test_flat_map();
test_quicksort();
test_fill();
test_flatten();
