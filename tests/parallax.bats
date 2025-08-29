load ./common

@test "parallax version" {
    run parallax --version
    assert_output --partial 'arallax version'
}
