#!/usr/bin/env bats

if [ -n "$RELEASE" ]; then dirname=release; else dirname=debug; fi
dir=out/$dirname
compile=$dir/test

@test "basic syntax" {
	$compile test/syntax.tst
}
