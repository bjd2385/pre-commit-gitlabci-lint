#! /bin/bash
# Test all test cases in this directory. Files should end in PASS or FAIL to indicate the expected outcome.


set -e


##
# Generate all test bats files/cases to execute upon.
generate_tests()
{
    local tests
    mapfile -t tests < <(find ./tests/ -type f -name "*.yml")

    for f in "${tests[@]}"; do
        printf "%s\\n" "$f"
        f_base="$(basename "$f")"
        f_base_ext="${f_base%.*}"
        f_path="$(dirname "$f")"
        f_bats="${f_path}/${f_base_ext}.bats"

        if [ "$(echo "$f_base_ext" | awk '/(PASS)$/')" ]; then
            # PASS
            cat > "$f_bats" << EOFI
#! /usr/bin/env bats

@test "$f_base" {
    poetry run gitlabci-lint -c "$f" -p 53075218
}
EOFI
        else
            # FAIL
            cat > "$f_bats" << EOFI
#! /usr/bin/env bats

@test "$f_base" {
    ! poetry run gitlabci-lint -c "$f" -p 53075218
}
EOFI
        fi
    done
}


##
# Clean up generated bats test files from YAML examples.
cleanup_tests()
{
    rm ./tests/.*.bats
}


main()
{
    generate_tests

    bats ./tests/.*.bats

    cleanup_tests
}


main
unset -f main generate_tests cleanup_tests