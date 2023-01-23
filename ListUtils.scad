/*
    Some functions for processing lists
*/

function is_empty(list) = len(list) == 0;
/*
    Return an integer range for an integer or list
*/
function range(count) = is_num(count) ? [0:(count-1)] : [0:(len(count)-1)];

function drop(list, n) =
    (n < 0) ? undef
        : (len(list) <= n) ? [] : [ for (i = [n:(len(list)-1)]) list[i] ];

/*
    Apply a function to every item in a list
*/
function map(list, f) = [ for (v = list) f(v) ];

function fold(list, init, f) =
    is_empty(list) ? init : fold(drop(list, 1), f(init, list[0]), f);

function fold_index(list, init, f, index=0) =
    is_empty(list) ? init : fold_index(drop(list, 1), f(init, list[0], index), f, index+1);

function repeat(list, count) =
    (count == 0) ? [] : concat(list, repeat(list, count-1));

function generate(f, count) =
    (count <= 0) ? [] : [ for (i = range(count)) f(i) ];

function flat_map(list, f) = fold(list, [], function(a,b) concat(a, f(b)));

function map2(a, b, f) = [ for (i = range(a)) f(a[i],b[i]) ];

