# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl OMA-Download-DRM.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use lib 'lib/'; use lib '../lib/';
use Test::More tests => 1;
BEGIN { use_ok('OMA::Download::DRM') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

    my $data=_readfile('image.jpg');

    my $drm = OMA::Download::DRM->new(
        ### Mandatory
        'data'                => \$data,
        'content-type'        => 'image/jpeg',
        'cid'                 => 'image239872@foo.bar',
        'Rights-Issuer'       => 'http://foo.bar/pics/image239872',
        'Content-Name'        => '"Kilimanjaro Uhuru Peak"',
        
        ### Not Mandatory
        'Content-Description' => 'Nice image from Kilimanjaro',
        'Content-Vendor'      => 'IT Development Belgium',
        'Icon-URI'            => 'http://foo.bar/icon.gif',
    );
    
    print my $res = $drm->combined;
    

sub _readfile {
    my $file = shift;
    my $buffer='';
    my $o='';
    open T, $file or die $!;
        binmode T;
        while(read(T, $buffer, 65536)) {
            $o.= $buffer;
        }
    close T;
    $o;
}