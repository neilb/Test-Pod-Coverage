package Test::Pod::Coverage;

=head1 NAME

Test::Pod::Coverage - Check for pod coverage in your distribution.

=head1 VERSION

Version 1.04

    $Header: /home/cvs/test-pod-coverage/Coverage.pm,v 1.24 2004/05/01 05:07:48 andy Exp $

=cut

our $VERSION = "1.04";

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

The L<Pod::Coverage> parms are also useful for subclasses that don't
re-document the parent class's methods.  Here's an example from
L<Mail::SRS>.

    pod_coverage_ok( "Mail::SRS" ); # No exceptions

    # Define the three overridden methods.
    my $trustme = { trustme => [qr/^(new|parse|compile)$/] };
    pod_coverage_ok( "Mail::SRS::DB", $trustme );
    pod_coverage_ok( "Mail::SRS::Guarded", $trustme );
    pod_coverage_ok( "Mail::SRS::Reversable", $trustme );
    pod_coverage_ok( "Mail::SRS::Shortcut", $trustme );

If you want POD coverage for your module, but don't want to make
Test::Pod::Coverage a prerequisite for installing, create the following
as your F<t/pod-coverage.t> file:

    use Test::More;
    eval "use Test::Pod::Coverage";
    plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;

    plan tests => 1;
    pod_coverage_ok( "Pod::Master::Html");

Finally, Module authors can include the following in a F<t/pod-coverage.t>
file and have C<Test::Pod::Coverage> automatically find and check all
modules in the module distribution:

    use Test::More;
    eval "use Test::Pod::Coverage 1.00";
    plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
    all_pod_coverage_ok();

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
    *{$caller.'::all_pod_coverage_ok'}   = \&all_pod_coverage_ok;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

=head1 FUNCTIONS

=head2 all_pod_coverage_ok( [$parms, ] $msg )

Checks that the POD code in all modules in the distro have proper POD
coverage.

If the I<$parms> hashref if passed in, they're passed into the
C<Pod::Coverage> object that the function uses.  Check the
L<Pod::Coverage> manual for what those can be.

=cut

sub all_pod_coverage_ok {
    my $parms = (@_ && (ref $_[0] eq "HASH")) ? shift : {};
    my $msg = shift;

    my $ok = 1;
    my @modules = all_modules();
    if ( @modules ) {
        $Test->plan( tests => scalar @modules );

        for my $module ( @modules ) {
            my $thismsg = defined $msg ? $msg : "Pod coverage on $module";

            my $thisok = pod_coverage_ok( $module, $parms, $thismsg );
            $ok = 0 unless $thisok;
        }
    } else {
        $Test->plan( tests => 1 );
        $Test->ok( 1, "No modules found." );
    }

    return $ok;
}


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
        $ok = ($rating == 1);
        $Test->ok( $ok, $msg );
        if ( !$ok ) {
            my @nakies = sort $pc->naked;
            my $s = @nakies == 1 ? "" : "s";
            $Test->diag(
                sprintf( "Coverage for %s is %3.1f%%, with %d naked subroutine$s:",
                    $module, $rating*100, scalar @nakies ) );
            $Test->diag( "\t$_" ) for @nakies;
        }
    } else { # No symbols
        my $why = $pc->why_unrated;
        $ok = ( $why =~ "no public symbols defined" );
        $Test->ok( $ok, $msg );
        $Test->diag( "$module: $why" );
    }

    return $ok;
}

=head2 all_modules( [@dirs] )

Returns a list of all modules in I<$dir> and in directories below. If
no directories are passed, it defaults to "blib".

Note that the modules are as "Foo::Bar", not "Foo/Bar.pm".

The order of the files returned is machine-dependent.  If you want them
sorted, you'll have to sort them yourself.

=cut

sub all_modules {
    my @starters = @_ ? @_ : ('blib');
    my %starters = map {$_,1} @starters;

    my @queue = @starters;

    my @modules;
    while ( @queue ) {
        my $file = shift @queue;
        if ( -d $file ) {
            local *DH;
            opendir DH, $file or next;
            my @newfiles = readdir DH;
            closedir DH;

            @newfiles = File::Spec->no_upwards( @newfiles );
            @newfiles = grep { $_ ne "CVS" && $_ ne ".svn" } @newfiles;

            push @queue, map "$file/$_", @newfiles;
        }
        if ( -f $file ) {
            next unless $file =~ /\.pm$/;

            my @parts = File::Spec->splitdir( $file );
            shift @parts if @parts && exists $starters{$parts[0]};
            shift @parts if @parts && $parts[0] eq "lib";
            $parts[-1] =~ s/\.pm$// if @parts;

            # Untaint the parts
            for ( @parts ) {
                /^([a-zA-Z0-9_]+)$/;
                die qq{Invalid and untaintable filename "$file"!} unless $_ eq $1;
                $_ = $1;
            }
            my $module = join( "::", @parts );
            push( @modules, $module );
        }
    } # while

    return @modules;
}

=head1 AUTHOR

Written by Andy Lester, C<< <andy@petdance.com> >>.

=head1 COPYRIGHT

Copyright 2004, Andy Lester, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.

=cut

1;
