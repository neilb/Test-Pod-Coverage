#$Id: Coverage.pm,v 1.4 2004/01/04 06:21:56 andy Exp $

package Test::Pod::Coverage;

=head1 NAME

Test::Pod::Coverage - Check for pod coverage in your distribution.

=head1 VERSION

Version 0.01

    $Header: /home/cvs/test-pod-coverage/Coverage.pm,v 1.4 2004/01/04 06:21:56 andy Exp $

=cut

our $VERSION = "0.01";

=head1 SYNOPSIS

Checks for POD coverage in files for your distribution.

    use Test::Pod::Coverage tests=>1;
    pod_coverage_ok( "Foo::Bar", "Foo::Bar is covered" );

Can also be called with a custom L<Pod::Coverage> object, if a
default one doesn't work for you.

    use Test::Pod::Coverage tests=>1;
    my $pc =
	Pod::Coverage->new(
	    package => "Foo::Bar",
	    also_private => [ qr/^FOO_/ ], # all FOO_* are private
	);
    pod_coverage_ok( $pc, "Foo::Bar is covered" );

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

=head2 pod_coverage_ok( $module, $msg )

Checks that the POD code in I<$module> has proper POD coverage.

=cut

sub pod_coverage_ok {
    my $pc = shift;
    $pc = Pod::Coverage->new( package => $pc ) unless ref $pc eq "Pod::Coverage";
    my $msg = shift;

    my $rating = $pc->coverage;
    my $ok;
    if ( defined $rating ) {
	$ok = ($pc->coverage == 1);
	$Test->ok( $ok, $msg );
	if ( !$ok ) {
	    $Test->diag( sprintf( "Coverage is %3.1f%%", $rating*100 ) );
	}
    } else {
	$ok = 0;
	$Test->ok( $ok, $msg );
	$Test->diag( $pc->why_unrated );
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
