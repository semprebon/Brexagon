include <ListUtils.scad>;

function deviator(p, rand) =
    let(
        max_r = 0.1,
        ang = rand*360,
        echo(ang=ang),
        r = (2*max_r * floor(ang/360)) - max_r)
    p + r * [cos(ang), sin(ang)];

function semi_random_point_array(size, deviator) =
    let(
        r = rands(0, 1, value_count = size.x * size.y),
        delta = [1/size.x, 1/size.y],
        offset = 0.5 * size)
    flatten ([ for (j = range(size.y))
        [ for (i = range(size.x)) deviator([i*delta.x,j*delta.y], r[j*size.x+i]) ] ]);

module test() {
    points = semi_random_point_array([5,5]);
    for (p = points) {
        translate([10*p.x, 10*p.y]) sphere(r=0.5);
    }
}

test();