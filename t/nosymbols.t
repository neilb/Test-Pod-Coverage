#!perl -T

use strict;
use lib "t";
use Test::More tests=>2;
use Test::Builder::Tester;

BEGIN {
    use_ok( 'Test::Pod::Coverage' );
}

test_out( "ok 1 - Checking Nosymbols" );
test_diag( "Nosymbols: no public symbols defined" );
pod_coverage_ok( "Nosymbols", "Checking Nosymbols" );
test_test( "Handles files with no symbols" );
