# $Id: all_modules.t,v 1.1 2004/02/14 05:14:36 andy Exp $
use strict;

use Test::More tests => 2;

BEGIN {
    use_ok( "Test::Pod::Coverage" );
}

my @files = Test::Pod::Coverage::all_modules( "blib" );

# The expected files have slashes, not File::Spec separators, because
# that's how File::Find does it.
my @expected = qw( Test::Pod::Coverage );
@files = sort @files;
@expected = sort @expected;
is_deeply( \@files, \@expected, "Got all the distro files" );
