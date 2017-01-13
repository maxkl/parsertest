#!/usr/bin/env bats

compile=out/test

@test "basic syntax" {
	$compile test/syntax.tst
}
