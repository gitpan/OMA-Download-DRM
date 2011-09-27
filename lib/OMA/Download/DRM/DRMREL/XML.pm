package OMA::Download::DRM::DRMREL::XML;
 #############################################################################
# IT Development OMA XML DRMREL implementation                              #
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
# Version : 1.00_02       Created : Jun 06 2006   Last Modified : Jun 06 2006 #
#                                                                             #
 ############################################################################
use strict;

BEGIN {
    use 5.8.7;
    use MIME::Base64;
}


### Class init -----------------------------------------------------------------
sub init {
    my $self=shift;
    $self->{'element_tokens'} = {
        'rights'      => 'o-ex:rights',
        'context'     => 'o-ex:context',
        'version'     => 'o-dd:version',
        'uid'         => 'o-dd:uid',
        'agreement'   => 'o-ex:agreement',
        'asset'       => 'o-ex:asset',
        'KeyInfo'     => 'ds:KeyInfo',
        'KeyValue'    => 'ds:KeyValue',
        'permission'  => 'o-ex:permission',
        'play'        => 'o-dd:play',
        'display'     => 'o-dd:display',
        'execute'     => 'o-dd:execute',
        'print'       => 'o-dd:print',
        'constraint'  => 'o-ex:constraint',
        'count'       => 'o-dd:count',
        'datetime'    => 'o-dd:datetime',
        'start'       => 'o-dd:start',
        'end'         => 'o-dd:end',
        'interval'    => 'o-dd:interval',
    };
    $self->{key}=encode_base64($self->{key}); $self->{key}=~s/[\r\n]//g;
    1
}



### Properties -----------------------------------------------------------------
sub mime      { 'application/vnd.oma.drm.rights+xml' }
sub extension { '.dr' }

### Methods --------------------------------------------------------------------
sub packit {
    my $self=shift;
    my $res='';
    $res.='<?xml version="1.0" encoding="utf-8"?>'."\n";   # WBXML Version Number (1.3)
    $res.='<!DOCTYPE o-ex:rights PUBLIC "-//OMA//DTD DRMREL 1.0//EN" "http://www.oma.org/dtd/dr">'."\n";  # Public Identifier (~//OMA//DTD DRMREL 1.0//EN)
    
    my $content=$self->packin;

    # rights element attributes
    return $res.'<o-ex:rights xmlns:o-ex="http://odrl.net/1.1/ODRL-EX" xmlns:o-dd="http://odrl.net/1.1/ODRL-DD" xmlns:ds="http://www.w3.org/2000/09/xmldsig#/">'."\n".$content."\n".'</o-ex:rights>';
}

#--- Support routines ----------------------------------------------------------
sub _in_element {
    my $self   =shift;
    my $element=shift;
    my $content=shift || '';
    die "Unknown element token $element" unless $self->{element_tokens}{$element};
    my $res='<'.$self->{element_tokens}{$element};
    if ($content) {
        $res.='>'.$content.'</'.$self->{element_tokens}{$element}.'>'
    } else {
        $res.='/>'
    }
    $res;
}
sub _in_string {
    my $self   =shift;
    my $string=shift;
    $string;
}
sub _in_opaque {
    my $self   =shift;
    my $data=shift;
    $data;
}
1;




__END__

=head1 NAME

OMA::Download::DRM::DRMCF::XML - XML representation of OMA DRM REL

=head1 TODO


=head1 SEE ALSO

OMA::Download::DRM::DRMCF

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
