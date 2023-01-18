include <TestSupport.scad>
include <Association.scad>

module test_returns_value_for_key() {
    tag = "returns_value_for_key";
    a = associate(["name", "George", "age", 23, "gender", "male"]);
    assert_equals(23, a("age"), tag);
    assert_equals("George", a("name"), tag);
    assert_equals(72, a("height", 72));
}

module test_returns_undef_for_missing_key() {
    tag = "returns_undef_for_missing_key";
    a = associate(["name", "George", "age", 23, "gender", "male"]);
    assert_equals(undef, a("height"));
}

module test_returns_default_for_missing_key() {
    tag = "returns_default_for_missing_key";
    a = associate(["name", "George", "age", 23, "gender", "male"]);
    assert_equals(72, a("height", 72));
}

module test_merge_uses_second_value_if_duplicate() {
    tag = "merge_uses_second_value_if_duplicate";
    a = merge_associations(
        associate(["name", "George", "age", 23, "gender", "male"]),
        associate(["name", "George", "age", 30, "height", 72]));

    assert_equals("George", a("name"));
    assert_equals(30, a("age"));
    assert_equals(72, a("height"));
    assert_equals("male", a("gender"));
}

test_returns_value_for_key();
test_returns_undef_for_missing_key();
test_returns_default_for_missing_key();
test_merge_uses_second_value_if_duplicate();