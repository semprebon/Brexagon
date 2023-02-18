/*
    Create barriers with decoration
*/
include <PatternCutters.scad>;

module barrier_pattern_cutter(size, angle=0, offset=[0,0], scale=[1,1], ends=false, pattern=BLANK_PATTERN) {
    // TODO: expand based on size of wall, pattern
    _ends = is_list(ends) ? ends : [ends, ends];
    //echo("barrier_pattern_cutter: scaling: ", wall_size=size, pattern_size=pattern("size"), scale=scale);
    scaled_pattern = scale_pattern(pattern, scale);
    expansion = [ ceil(size.x / scaled_pattern("size").x), ceil(size.z / scaled_pattern("size").y)];
    expanded_pattern = expand_pattern(scaled_pattern, expansion);
//    echo("barrier_pattern_cutter: expansion", expansion=expansion, scaled_size=scaled_pattern("size"),
//        expanded_size=expanded_pattern("size"));
    cropped_pattern = crop_pattern(expanded_pattern, [size.x, size.z]);
//    echo("barrier_pattern_cutter: crop", cropped_pattern("size"));
    rotate([0,0,angle]) {
        x_offset = [0,0,0];
        y_offset = [0,size.y/2,0];
        z_offset = [0,0,size.z];
        cut_pattern(cropped_pattern, offset=x_offset+y_offset+to_3d_point(offset));
        cut_pattern(cropped_pattern, offset=x_offset-y_offset+to_3d_point(offset));
        if (_ends[0]) cut_pattern(expanded_pattern, offset=[0,-size.y/2,0], rotation=[0,0,90]);
        if (_ends[1]) cut_pattern(expanded_pattern, offset=[size.x,-size.y/2,0], rotation=[0,0,90]);
        //cut_pattern(expanded_pattern, offset=[0,size.y/2,size.z], rotation=[90,0,0]);
    }
}

module create_barrier(size, angle=0) {
    rotate([0,0,angle]) {
        translate([0,-size.y/2,0]) cube(size);
    }
}

module patterned_barrier(size, angle=0, offset=[0,0], scale=[1,1], ends=false, pattern=BLANK_PATTERN) {
    //echo("patterned_barrier: ", pattern=pattern(list=true));
    difference() {
        create_barrier(size, angle);
        barrier_pattern_cutter(size, angle, offset, scale, ends, pattern);
    }
}

module barrier(size, p1, p2, pattern) {
    //scale=[size,(9/16)*sqrt(3)*size];
    //offset = scale_point([-1/2,11/16], scale);
    scale=[size,size*2/sqrt(3)];
    offset=[0,0];
    //offset = scale_point([-1/2,11/16], scale);
    start = scale_point(p1,scale) + offset;
    end = scale_point(p2,scale) + offset;
    width = (size/sqrt(3))/4;
    vector = end-start;
    length = sqrt(vector.x*vector.x + vector.y*vector.y);
    rotation = atan2(vector.y, vector.x);

    //echo("barrier: ", p1=p1, p2=p2, scale=scale, width=width, start=start, end=end,
    //    vector=vector, length=length, rotation=rotation);
    translate([start.x,start.y,0]) rotate([0,0,rotation])
        patterned_barrier([length,width,BARRIER_HEIGHT], pattern=pattern, offset=[0,HEXAGON_BEVEL_DEPTH]);
        //translate([0,-width/2,0]) cube([length,width,BARRIER_HEIGHT]);
}

