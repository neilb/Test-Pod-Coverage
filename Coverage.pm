package Test::Pod::Coverage;

=head1 NAME

Test::Pod::Coverage - Check for pod coverage in your distribution.

=head1 VERSION

Version 0.04

    $Header: /home/cvs/test-pod-coverage/Coverage.pm,v 1.10 2004/01/19 03:52:21 andy Exp $

=cut

our $VERSION = "0.04";

=head1 SYNOPSIS

Checks for POD coverage in files for your distribution.

    use Test::Pod::Coverage tests=>1;
    pod_coverage_ok( "Foo::Bar", "Foo::Bar is covered" );

Can also be called with L<Pod::Coverage> parms.

    use Test::Pod::Coverage tests=>1;
    pod_coverage_ok(
	"Foo::Bar",
	{ also_private => [ qr/^[A-Z_]+$/ ], },
	"Foo::Bar, with all-caps functions as privates",
    );

If you want POD coverage for your module, but don't want to make
Test::Pod::Coverage a prerequisite for installing, create the following
as your F<t/pod-coverage.t> file:

    use Test::More;
    eval "use Test::Pod::Coverage";
    plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;

    plan tests => 1;
    pod_coverage_ok( "Pod::Master::Html");

=cut

use strict;
use warnings;

use Pod::Coverage;
use Test::Builder;

my $Test = Test::Builder->new;

sub import {
    my $self = shift;
    my $caller = caller;
    no strict 'refs';
    *{$caller.'::pod_coverage_ok'}       = \&pod_coverage_ok;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

=head1 FUNCTIONS

=head2 pod_coverage_ok( $module, [$parms, ] $msg )

Checks that the POD code in I<$module> has proper POD coverage.

If the I<$parms> hashref if passed in, they're passed into the
C<Pod::Coverage> object that the function uses.  Check the
L<Pod::Coverage> manual for what those can be.

=cut

sub pod_coverage_ok {
    my $module = shift;
    my $parms = (@_ && (ref $_[0] eq "HASH")) ? shift : {};
    my $msg = @_ ? shift : "Pod coverage on $module";

    my $pc = Pod::Coverage->new( package => $module, %$parms );
    my $rating = $pc->coverage;
    my $ok;
    if ( defined $rating ) {
	$ok = ($pc->coverage == 1);
	$Test->ok( $ok, $msg );
	if ( !$ok ) {
            my @nakies = sort $pc->naked;
	    $Test->diag( sprintf( "Coverage is %3.1f%% with %d naked subroutines", $rating*100, scalar @nakies ) );
            $Test->diag( "\t$_" ) for @nakies;
	}
    } else {
	$ok = 0;
	$Test->ok( $ok, $msg );
	$Test->diag( "$module: " . $pc->why_unrated );
    }

    return $ok;
}

=head1 AUTHOR

Written by Andy Lester, C<< <andy@petdance.com> >>.

=head1 COPYRIGHT

Copyright 2004, Andy Lester, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.

=cut

1;
