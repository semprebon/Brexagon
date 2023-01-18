/*
    Defines an association (i.e., dictionary) function, that given a keyword,
    returns the matching value.
*/

/*
    Get value from association
 */
function get(assoc, key, default=undef) =
    let (p = [ for (pair = assoc) if (pair[0] == key) pair[1] ])
    (p[0] == undef) ? default : p[0];

/*
    Create an associative array
 */
function associate(values) =
    let (
        count = len(values)/2,
        _data = [ for (i = [0:2:len(values)-1]) [values[i], values[i+1]] ]
    )
    function (key, default, list=false) !list ? get(_data, key, default) : values;

/*
    Merge two associations, giving the second preference
 */
function merge_associations(a, b) =
    associate(concat(b(list=true),a(list=true)));
