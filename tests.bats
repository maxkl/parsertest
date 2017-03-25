#!/usr/bin/env bats

if [ -n "$RELEASE" ]; then dirname=release; else dirname=debug; fi
dir=out/$dirname
compile=$dir/test

@test "basic syntax" {
	skip "Parsing only is not supported atm"
	$compile test/syntax.tst
}

@test "prog1" {
	run $compile test/prog1.tst
	[ "$status" -eq 42 ]
}
