package OMA::Download::DRM;
use strict;
use warnings;

BEGIN {
    use 5.8.7;

    our $VERSION = '1.00.04';
    $VERSION = eval $VERSION;  # see L<perlmodstyle>
}

sub new {
    my ($class, %arg)=@_;
    my $self = {
        data           => $arg{'data'},
        cid            => $arg{'uid'} || die "uid argument needed",
        domain         => $arg{domain} || die "domain argument needed",
        boundary       => 'mime-boundary/'.$arg{'uid'}.'/'.time,
        'content-type' => $arg{'content-type'},
    };
    $self=bless $self, $class;
    print "\n domain".$self->{domain}."\n";
    $self;
}

sub combined {
    my ($self, $permission, %constraint)=@_;
    my $res='';
    $res.='--'.$self->{'boundary'}."\r\n";
    use OMA::Download::DRM::DRMREL;
    my $rel = OMA::Download::DRM::DRMREL->new('XML', 
        ### Mandatory
        'key'                 => undef,
        'permission'          => $permission,
        'uid'                 => 'cid:'.$self->{cid}.'@'.$self->{domain},
        %constraint || ()
    );
    $res.= 'Content-type: '.$rel->mime."\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";
    $res.= $rel->packit;
    $res.= "\r\n\r\n";
    $res.='--'.$self->{boundary}."\r\n";

    $res.= 'Content-type: '.$self->{'content-type'}."\r\n";
    $res.= 'Content-ID: <'.$self->{cid}.'@'.$self->{domain}.">\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";    
    $res.= ${$self->{data}};
    $res.= "\r\n";
    $res.='--'.$self->{boundary}."--";
    return $res;
}
sub fw_lock {
    my $self=shift;
    my $res='';
    $res.='--'.$self->{boundary}."\r\n";
    $res.= 'Content-type: '.$self->{'content-type'}."\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";    
    $res.= ${$self->{data}};
    $res.= "\r\n";
    $res.='--'.$self->{boundary}."--";
    return $res;
}

sub mime {
    my $self=shift;
    'application/vnd.oma.drm.message; boundary='.$self->{boundary}
}
1;
__END__

=head1 NAME

OMA::Download::DRM - Perl extension for packaging DRM objects according to OMA DRM 1.0 specification

=head1 SYNOPSIS

  use OMA::Download::DRM;
  
  

=head1 DESCRIPTION

Incomplete implementation

=head1 SEE ALSO

OMA DRM Specifications

=head1 AUTHOR

Bernard Nauwelaerts, E<lt>bpn@localhostE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Bernard Nauwelaerts, IT Development Belgium

=cut
