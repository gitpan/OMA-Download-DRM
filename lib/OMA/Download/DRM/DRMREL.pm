package OMA::Download::DRM::DRMREL;
 #############################################################################
# IT Development OMA WBXML DRMREL implementation                              #
# Copyright (c) BPN 2006 All Rights reseved                                   #
# Author  : Bernard Nauwelaerts <bpn\@it-development.be>                      #
# LICENCE : THIS IS UNPUBLISHED PROPRIETARY SOFTWARE                          #
#           This code is licenced to run ONLY on author's computers.          #
#           Utilisation, selling, distribution, modification or detention of  #
#           this code are strictly prohibited.                                #
#           This enfringe commercial secrets and intellectual property laws.  #
#                                                                             #
#           In all cases these copyright and header must remain intact        #
#                                                                             #
 ############################################################################
#                                                                             #
# Version : 1.00_03       Created : Jun 06 2006   Last Modified : Jun 06 2006 #
#                                                                             #
 ############################################################################
use strict;
our @ISA;

BEGIN {
    use 5.8.7;
    use OMA::Download::DRM::DRMREL::XML;
    use OMA::Download::DRM::DRMREL::WBXML;
}

### Class constructor ----------------------------------------------------------
sub new {
    my ($class, $encoding, %arg)=@_;
    
    my $self={
        'uid'            => $arg{'uid'},
        'permission'     => $arg{'permission'},
        'count'          => $arg{'count'},
        'key'            => $arg{key} || undef,
    };
    $self=bless $self, $class;

    push @ISA, 'OMA::Download::DRM::DRMREL::'.$encoding;
    
    $self->init;
    
    $self;
}


### Methods --------------------------------------------------------------------
sub packin {
    my $self=shift;
    
    # version
    my $context=$self->_in_element('context', $self->_in_element('version', $self->_in_string('1.0')));
    
    # agreement
    ## asset
    my $assetcontext=$self->_in_element('context', $self->_in_element('uid',      $self->_in_string($self->{uid})));
    my $assetkeyinfo=$self->_in_element('KeyInfo', $self->_in_element('KeyValue', $self->_in_opaque($self->{key}))) if $self->{key};
    my $asset=$self->_in_element('asset', $assetcontext.$assetkeyinfo); 
    
    ## permission
    my $count=$self->_in_element('count', $self->_in_string($self->{count}));
    my $constraint = $self->_in_element('constraint', $count) if $self->{count};
    my $permission=$self->_in_element('permission', $self->_in_element($self->{'permission'}, $constraint)); 

    
    my $agreement=$self->_in_element('agreement', $asset.$permission); 

    return $context.$agreement;
}

1;
__END__

=head1 NAME

OMA::Download::DRM::DRMREL - Perl extension for OMA rights expression

=head1 SYNOPSIS

    use OMA::Download::DRM::DRMREL;
    
    my $rel = OMA::Download::DRM::DRMREL->new('XML' || 'WBXML',
        
        ### Mandatory
        'key'                 => 'im9aazbjfgsorehf',
        'uid'                 => 'cid:image239872@foo.bar',
        'permission'          => 'display',
        
        ### Not Mandatory
        'count'               => 3,        
    );
    
    my $res = $rel->packit;

=head1 DESCRIPTION

OMA DRM Rights Expression Language implementation

This is partial implementation - Need to be completed

=head1 TODO

Use more than one permission, and other constraints than count

=head1 SEE ALSO

* OMA-Download-DRMREL-V1_0-20040615-A

* OMA::Download::DRM::DRMREL::XML

* OMA::Download::DRM::DRMREL::WBXML

=head1 AUTHOR

Bernard Nauwelaerts, E<lt>bpn@localhostE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Bernard Nauwelaerts

    THIS IS UNPUBLISHED PROPRIETARY SOFTWARE

This code is licenced to run ONLY on author's computers.
Utilisation, selling, distribution, modification or detention of this code are strictly prohibited.                                

This enfringe commercial secrets and intellectual property laws.  

In all cases this copyright notice must remain intact.

=cut
