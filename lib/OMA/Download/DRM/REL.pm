package OMA::Download::DRM::REL;
 #############################################################################
# IT Development OMA WBXML DRM REL implementation                             #
# Copyright (c) BPN 2006 All Rights reseved                                   #
# Author  : Bernard Nauwelaerts <bpn\@it-development.be>                      #
# LICENCE : GPL                                                               #
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
}

### Class constructor ----------------------------------------------------------
sub new {
    my ($class, $encoding, %arg)=@_;
    die "Need Permission argument" unless $arg{'permission'};
    my $self={
        'uid'            => $arg{'uid'},
        'permission'     => $arg{'permission'},
        'count'          => $arg{'count'},
        'key'            => $arg{key} || undef,
    };
    $self=bless $self, $class;

	eval ('use OMA::Download::DRM::REL::'.$encoding);
    push @ISA, 'OMA::Download::DRM::REL::'.$encoding;
    
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
    my $assetcontext=$self->_in_element('context', $self->_in_element('uid', $self->_in_string($self->{uid})));
    my $assetkeyinfo = $self->{key} ? $self->_in_element('KeyInfo', $self->_in_element('KeyValue', $self->_in_opaque($self->{key}))) : '';
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

OMA::Download::DRM::REL - Perl extension for OMA Rights Expression Language 1.0

=head1 SYNOPSIS

    use OMA::Download::DRM::REL;
    
    my $rel = OMA::Download::DRM::REL->new('XML' || 'WBXML',
        
        ### Mandatory
        'key'                 => 'im9aazbjfgsorehf',
        'uid'                 => 'cid:image239872@example.com',
        'permission'          => 'display',   					# Can be 'display', 'play', 'execute' or 'print'
        
        ### Optional
        'count'               => 3,        
    );
    
    my $res = $rel->packit;

=head1 DESCRIPTION

OMA DRM Rights Expression Language implementation

This is a partial implementation - Needs to be completed

=head1 TODO

Use more than one permission, and other constraints than count

=head1 SEE ALSO

* OMA-Download-REL-V1_0-20040615-A

* OMA::Download::DRM::REL::XML

* OMA::Download::DRM::REL::WBXML

=head1 AUTHOR

Bernard Nauwelaerts, E<lt>bpn@localhostE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Bernard Nauwelaerts, IT Development Belgium

Released under GPL licence.

=cut
