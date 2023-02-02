/*
    Use Cohen-Sutherland clipping algorithm to clip a line segment to a bounding box
*/

INSIDE = [false,false,false,false];
LEFT   = [false,false,false,true];
RIGHT  = [false,false,true,false];
BOTTOM = [false,true,false,false];
TOP    = [true,false,false,false];

function _combine_codes(a, b, f) = [ for (i = [0:3]) f(a[i], b[i]) ];
function _or(a, b) = [ for (i = [0:3]) a[i] || b[i] ];
function _and(a, b) = [ for (i = [0:3]) a[i] && b[i] ];

function _compute_out_code(p, bounds) =
    let(x_code = (p.x < bounds[0]) ? LEFT : (p.x > bounds[2]) ? RIGHT : INSIDE)
        _or(x_code, (p.y < bounds[1]) ? BOTTOM : (p.y > bounds[3]) ? TOP : INSIDE);

function _clip_segment_to_bounds(p0, p1, bounds, code0, code1) =
    (_or(code0, code1) == INSIDE) ? [p0, p1]
        : (_and(code0, code1) != INSIDE) ? []
        : let(
            out_code = (code0 == INSIDE) ? code1 : code0,
            dx = p1.x - p0.x,
            dy = p1.y - p0.y,
            p = out_code[0] ? [p0.x + dx * (bounds[3] - p0.y) / dy, bounds[3] ]
                : out_code[1] ? [p0.x + dx * (bounds[1] - p0.y) / dy, bounds[1] ]
                : out_code[2] ? [bounds[2], p0.y + dy * (bounds[2] - p0.x) / dx ]
                : out_code[3] ? [bounds[0], p0.y + dy * (bounds[0] - p0.x) / dx ]
                : [])
              (out_code == code0)
                ? _clip_segment_to_bounds(p, p1, bounds, _compute_out_code(p, bounds), code1)
                : _clip_segment_to_bounds(p0, p, bounds, code0, _compute_out_code(p, bounds));

/*
    Clip a line segment (p0, p1) to a bounding box (bounds)
    returns: either [] (if segment is outside the bounds), or a new segment that is inside the bounds`
*/
function clip_segment_to_bounds(p0, p1, bounds) =
    //echo("clip_segment_to_bounds: ", p0=p0, p1=p1, bounds=bounds)
    let (
        code0 = _compute_out_code(p0, bounds),
        code1 = _compute_out_code(p1, bounds))
    _clip_segment_to_bounds(p0, p1, bounds, code0, code1);