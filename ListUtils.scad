/*
    Some functions for processing lists
*/

function is_empty(list) = len(list) == 0;
/*
    Return an integer range for an integer or list
*/
function range(count) = is_num(count) ? [0:(count-1)] : [0:(len(count)-1)];

function drop(list, n=1) =
    (n < 0) ? undef
        : (len(list) <= n) ? [] : [ for (i = [n:(len(list)-1)]) list[i] ];

function last(list) = list[len(list)-1];

function drop_last(list, n=1) =
    (n < 0) ? undef
        : (len(list) <= n) ? [] : [ for (i = [0:1:(len(list)-n-1)]) list[i] ];

function append(list, a) = concat(list, [a]);

function concat_to_last(lists, list) =
    is_empty(list) ? lists
        : is_empty(lists) ? [list]
        : concat(drop_last(lists), [concat(last(lists), list)]);

function append_to_last(lists, a) = concat_to_last(lists, [a]);

/*
    Apply a function to every item in a list
*/
function map(list, f) = [ for (v = list) f(v) ];

function fold(list, init, f) =
    is_empty(list) ? init : fold(drop(list, 1), f(init, list[0]), f);

function fold_index(list, init, f, index=0) =
    is_empty(list) ? init : fold_index(drop(list, 1), f(init, list[0], index), f, index+1);

function reduce(list, f) =
    is_empty(list) ? undef
        : (len(list) == 1) ? list[0]
        : f(list[0], reduce(drop(list, 1), f));

function repeat(list, count) =
    (count == 0) ? [] : concat(list, repeat(list, count-1));

function generate(f, count) =
    (count <= 0) ? [] : [ for (i = range(count)) f(i) ];

function remove(list, f) = fold(list, [], function (list,item) f(item) ? list : concat(list, [item]));

function flat_map(list, f) = fold(list, [], function(a,b) concat(a, f(b)));

function map2(a, b, f) = [ for (i = range(a)) f(a[i],b[i]) ];

function is_any(list, pred) = fold(list, false, function (bool,a) bool || pred(a));

function is_all(list, pred) = fold(list, true, function (bool,a) bool && pred(a));

function quicksort(arr, f) =
    !(len(arr)>0) ? []
        : let(pivot   = f(arr[floor(len(arr)/2)]),
              lesser  = [ for (y = arr) if (f(y)  < pivot) y ],
              equal   = [ for (y = arr) if (f(y) == pivot) y ],
              greater = [ for (y = arr) if (f(y)  > pivot) y ]
              )
            concat(quicksort(lesser, f), equal, quicksort(greater, f));

function pop_to_size(new_items, limit, popped_items=[], get_size) =
    (len(new_items) == 0) ? [current_items, new_items]
        : let(
            item = new_items[0],
            size = get_size(item))
        (size > limit) ? [popped_items, new_items]
            : pop_to_size(drop(new_items, 1), limit-size, concat(popped_items, [item]), get_size);

function replace_last(list,item) =
     concat([ for (i = [0:1:(len(list)-2)]) list[i] ], [item]);

function fill(items, limit, get_size, groups=[[]]) =
    (len(items) == 0) ? groups
        : let(
            item = items[0],
            new_items = drop(items, 1),
            last_group = groups[len(groups)-1],
            new_size = get_size(item) + fold(last_group, 0, function(a,b) a+get_size(b)))
          (new_size <= limit)
            ? fill(drop(items,1), limit, get_size, replace_last(groups, concat(last_group, item)))
            : fill(drop(items,1), limit, get_size, concat(groups, [[item]]));

function flatten(arr) = fold(arr, [], function(a,b) concat(a, b));

