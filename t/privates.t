#!/usr/bin/perl -w

use strict;
use lib "t";
use Test::More tests=>4;
use Test::Builder::Tester;

BEGIN {
    use_ok( 'Test::Pod::Coverage' );
}

test_out( "not ok 1 - Privates fails" );
test_fail(+2);
test_diag( "Coverage is 60.0%" );
pod_coverage_ok( "Privates", "Privates fails" );
test_test( "Should fail at 60%" );

my $pc = Pod::Coverage->new(
    package => "Privates", 
    also_private => [ qr/^[A-Z_]+$/ ],
);
test_out( "ok 1 - Privates works w/a custom PC object" );
pod_coverage_ok( $pc, "Privates works w/a custom PC object" );
test_test( "Trying to pass PC object" );

pod_coverage_ok( $pc, "Privates works w/a custom PC object" );
__DATA__

not ok 2 - Privates fails
#     Failed test (t/privates.t at line 11)
#     # Coverage is 60.0%
#     # # Looks like you failed 1 tests of 2.
