package OMA::Download::DRM::CF;
 #############################################################################
# IT Development OMA CF implementation                                     #
# Copyright (c) BPN 2006 All Rights reseved                                   #
# Author  : Bernard Nauwelaerts <bpn#it-development%be>                       #
# LICENCE : GPL                                                               #
#                                                                             #
 ############################################################################
#                                                                             #
# Version : 1.00_03       Created : Jun 06 2006   Last Modified : Jun 06 2006 #
#                                                                             #
 ############################################################################
use strict;

BEGIN {
    use Crypt::Rijndael;
}


### Class constructor ----------------------------------------------------------
sub new {
    my ($class, %arg)=@_;
    
    for ('key', 'data', 'content-type', 'content-uri', 'Rights-Issuer', 'Content-Name') {
        die 'Need '.$_ unless $arg{$_};
    }
    die "Key must be 128 bits long" if length($arg{key}) != 16;
    
    my $self={
        'key'          => $arg{key},
        'data'         => $arg{data},
        'content-type' => $arg{'content-type'},
        'content-uri'  => $arg{'content-uri'},
        headers => {
            #'Encryption-Method'   => $arg{'Encryption-Method'}   || 'AES128CBC;padding=RFC2630;plaintextlen='.length(${$arg{data}}),
            'Encryption-Method'   => $arg{'Encryption-Method'}   || 'AES128CBC',
            'Rights-Issuer'       => $arg{'Rights-Issuer'},
            'Content-Name'        => $arg{'Content-Name'},
            'Content-Description' => $arg{'Content-Description'} || '',
            'Content-Vendor'      => $arg{'Content-Vendor'}      || '',
            'Icon-URI'            => $arg{'Icon-URI'}            || ''
        },
        'block-size' => 16,
    };
    $self=bless $self, $class;
    $self;
}



### Properties -----------------------------------------------------------------
sub header {
    my $self=shift;
    my $key=shift;
    $self->{headers}{$key} || undef;
}
sub mime      { 'application/vnd.oma.drm.content' }
sub extension { '.dcf' }
### Methods --------------------------------------------------------------------
sub packit {
    my $self=shift;
    my $res='';
    
    my $cdat='';                                      # Encrypted data variable
    $self->_crypt($self->{data}, \$cdat);             # Crypt data
    
    #$self->{headers}{'Encryption-Method'}.=length($cdat);      #
    
    #my $head=$self->_headers."\r\n";                  # Get headers
    my $head=$self->_headers;                          # Get headers
    
    $res.=pack("C", 1);                               # CF Version Number (1)
    $res.=pack("C", length($self->{'content-type'})); # Length of ContentType field
    $res.=pack("C", length($self->{'content-uri'}));  # Length of ContentURI field
    $res.=$self->{'content-type'};                    # ContentType field
    $res.=$self->{'content-uri'};                     # ContentURI field
    $res.=_uint2uintvar(length($head));               # Length of the Headers field
    $res.=_uint2uintvar(length($cdat));               # Length of Data field
    $res.=$head;                                      # Headers
    $res.=$cdat;                                      # Encrypted data
    return $res;
} 




#--- Support routines ----------------------------------------------------------
sub _crypt {
    my $self=shift;
    my $data=shift;
    my $cdat=shift;    
    my $cipher = Crypt::Rijndael->new($self->{'key'}, Crypt::Rijndael::MODE_CBC);
    $$cdat = $cipher->encrypt($$data._padding($data, $self->{'block-size'}));
    1
}
sub _padding {                                        # Fill in missed bytes
    my $data=shift;
    my $blocksize=shift;
    ### rfc2630 6.3
    my $numpad = $blocksize - (length($$data) % $blocksize);
    pack("C", $numpad) x $numpad;
}
sub _headers {
    my $self=shift;
    my $res='';
    for (keys %{$self->{headers}}) {
        if ($self->{headers}{$_}) {
            $res.=$_.': '.$self->{headers}{$_}."\r\n";
        }
    }
    $res;
}
sub _uint2uintvar {
    ### Lightweight algorithm implementation
    my $int=shift || return pack("C", 0);
    my $lst=0;                                    # We begin with the last octet
    my $res='';                                   
    while ($int > 0) {
        $res=pack("C", ($int & 127) | $lst).$res; # Take 7 LSBits, MSBit is clear if last octet
        $int>>=7;                                 # Shift 7 bits right
        $lst=128;                                 # Next octets wont be lastes
    }
    $res;
}


1;




__END__

=head1 NAME

OMA::Download::DRM::CF - Perl extension for OMA DRM Content Format implementation

=head1 SYNOPSIS

    use OMA::Download::DRM::CF;
    my $cf = OMA::Download::DRM::CF->new(
        ### Mandatory
        'key'                 => 'im9aazbjfgsorehf',
        'data'                => \$data,
        'content-type'        => 'image/jpeg',
        'content-uri'         => 'cid:image239872@foo.bar',
        'Rights-Issuer'       => 'http://example.com/pics/image239872',
        'Content-Name'        => '"Kilimanjaro Uhuru Peak"',
        
        ### Optional
        'Content-Description' => 'Nice image from Kilimanjaro',
        'Content-Vendor'      => 'IT Development Belgium',
        'Icon-URI'            => 'http://example.com/icon.gif',
    );
    
    my $res = $cf->packit;

=head1 DESCRIPTION

Pack & encrypt OMA DRM content objects

=head1 SEE ALSO

* OMA-Download-CF-V1_0-20040615-A

* WAP-230-WSP-20010705-a

* RFC2760

* Crypt::Rijndael

=head1 AUTHOR

Bernard Nauwelaerts, E<lt>bpgn@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Bernard Nauwelaerts, IT Development Belgium

Released under GPL licence

=cut
