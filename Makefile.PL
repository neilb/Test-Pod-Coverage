use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Test::Pod::Coverage',
    VERSION_FROM        => 'Coverage.pm',
    ABSTRACT            => "Check for pod coverage in your distribution",
    PREREQ_PM => {
        'Pod::Coverage'         => 0,
        'Test::More'            => 0,
        'Test::Builder::Tester' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Test-Pod-Coverage-*' },
);
