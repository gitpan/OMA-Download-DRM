package OMA::Download::DRM;
use strict;
use warnings;

BEGIN {
    $OMA::Download::DRM::VERSION = '1.00.06';  
}

sub new {
    my ($class, %arg)=@_;
	
	
    my $self={
        'content-type' => $arg{'content-type'},
        data           => $arg{data},
        key            => $arg{key},
        uid            => $arg{'uid'} || rand(999999999),
        domain         => $arg{domain} || 'example.com',
        #method         => $arg{method},
        boundary       => undef,
		mime		   => undef
    };
    $self=bless $self, $class;
    $self->{boundary} = 'mime-boundary/'.$self->{uid}.'/'.time;
	
    $self;
}
sub uid {
	return $_[0]->{uid};
}
sub fw_lock {
    my ($self)=@_;
    my $res='';
    $res.='--'.$self->{boundary}."\r\n";
    $res.= 'Content-Type: '.$self->{'content-type'}."\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";    
    $res.= ${$self->{data}};
    $res.= "\r\n";
    $res.='--'.$self->{boundary}."--";
	$self->{mime}='application/vnd.oma.drm.message; boundary='.$self->{boundary};
    return $res;
}
sub combined {
    my ($self, $permission, %constraint)=@_;
    my $res='';
    $res.='--'.$self->{boundary}."\r\n";
	use OMA::Download::DRM::REL;
    my $rel = OMA::Download::DRM::REL->new('XML', 
       'permission'           => $permission,
        'uid'                 => 'cid:'.$self->{uid}.'@'.$self->{domain},
        %constraint || ()
    );
    $res.= 'Content-Type: '.$rel->mime."\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";
    $res.= $rel->packit;
    $res.= "\r\n\r\n";
    $res.='--'.$self->{boundary}."\r\n";

    $res.= 'Content-Type: '.$self->{'content-type'}."\r\n";
    $res.= 'Content-ID: <'.$self->{uid}.'@'.$self->{domain}.">\r\n";
    $res.= 'Content-Transfer-Encoding: binary'."\r\n\r\n";    
    $res.= ${$self->{data}};
    $res.= "\r\n";
    $res.='--'.$self->{boundary}."--";
	$self->{mime}='application/vnd.oma.drm.message; boundary='.$self->{boundary};
    return $res;
}
sub separate_content {
    my ($self, $rights_issuer, $content_name)=@_;
	die "Need $rights_issuer" unless $rights_issuer;
	die "Need $content_name"  unless $content_name;
    use OMA::Download::DRM::CF;
    my $cf = OMA::Download::DRM::CF->new(
        ### Mandatory
        'key'                 => $self->{'key'},
        'data'                => $self->{data},
        'content-type'        => $self->{'content-type'},
        'content-uri'         => 'cid:'.$self->{uid}.'@'.$self->{domain},
        'Rights-Issuer'       => $rights_issuer,
        'Content-Name'        => $content_name,
    );
	$self->{mime}=$cf->mime;
    return $cf->packit;
}
sub separate_rights {
    my ($self, $permission, %constraint)=@_;
    use OMA::Download::DRM::REL;
	my $rel = OMA::Download::DRM::REL->new('WBXML', 
       'key'                 => $self->{'key'},
       'permission'           => $permission,
        'uid'                 => 'cid:'.$self->{uid}.'@'.$self->{domain},
        %constraint || ()
    );
	$self->{mime}=$rel->mime;
    return $rel->packit;
}

sub mime {
    my $self=shift;
    
}
1;
__END__

=head1 NAME

OMA::Download::DRM - Perl extension for packing DRM objects according to OMA DRM 1.0 specification

=head1 SYNOPSIS

  use OMA::Download::DRM;
  
  # Forward-Lock
  my $drm = OMA::Download::DRM->new(
				'content-type' => 'image/gif', 
				'data' => 'GIF image binary data REFERENCE here'
			);
  print "Content-type: ".$drm->mime."\n\n";                     # prints appropriate MIME type
  print $drm->fw_lock();                                        # Forward lock
  exit;
  
  # OR

  # Combined delivery
  my $drm = OMA::Download::DRM->new(
				'content-type' => 'image/gif', 
				'data' => 'GIF image binary data REFERENCE here', 
				'domain' => 'example.com'
			);
  print "Content-type: ".$drm->mime."\n\n";                     # prints appropriate MIME type
  print $drm->combined($permission, %constraint);   	        # Combined delivery. See OMA::Download::DRM::REL
  

  # OR
  
  # Separate Delivery
  my $drm = OMA::Download::DRM->new(
				'content-type' => 'image/gif', 
				'data' => 'GIF image binary data REFERENCE here', 
				'domain' => 'example.com', 
				'key' => '128-bit ascii key'
			);
  print "Content-type: ".$drm->mime."\n";                       # prints appropriate MIME type
  print "X-Oma-Drm-Separate-Delivery: 12\n";                    # the terminal expects WAP push 12 seconds later
  print $drm->separate_content($rights_issuer, $content_name);  # prints encrypted content
  my $rights = $drm->separate_rights($permission, %constraint)  # you have to send this rights object via WAP Push. See OMA::Download::DRM::REL
  

=head1 DESCRIPTION

This module encodes data objects according to the Open Mobile Alliance Digital Rights Management 1.0 specification in order to control how these objects are used.

=head1 SEE ALSO

OMA::Download::DRM::REL

OMA::Download::DRM::CF

OMA DRM 1.0 Specifications

=head1 REVISION INFORMATION

1.00.06		Documentation update

1.00.05		Documentation update

1.00.04		First public release

=head1 AUTHOR

Bernard Nauwelaerts, E<lt>bpgn@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Bernard Nauwelaerts, IT Development Belgium

Released under GPL licence.

=cut
