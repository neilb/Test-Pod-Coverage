use strict;
use warnings;
use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) {
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

WriteMakefile(
    NAME                => 'Test::Pod::Coverage',
    VERSION_FROM        => 'lib/Test/Pod/Coverage.pm',
    ABSTRACT            => "Check for pod coverage in your distribution",
    PREREQ_PM => {
        'Pod::Coverage'         => 0,
        'Test::More'            => 0,
        'Test::Builder::Tester' => 0,
    },

    ($mm_ver >= 6.48
        ? (MIN_PERL_VERSION => 5.006)
        : ()
    ),

    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Test-Pod-Coverage-*' },
);
