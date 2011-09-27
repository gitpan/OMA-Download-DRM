use 5.8.7;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'OMA::Download::DRM',
    VERSION_FROM      => 'lib/OMA/Download/DRM.pm', # finds $VERSION
    PREREQ_PM         => {
        Crypt::Rijndael => 0.04
    },
    ($] >= 5.005 ?
    (ABSTRACT_FROM  => 'lib/OMA/Download/DRM.pm', # retrieve abstract from module
     AUTHOR         => 'Bernard Nauwelaerts <bpn@twi-31o2.org>') : ()),
);
