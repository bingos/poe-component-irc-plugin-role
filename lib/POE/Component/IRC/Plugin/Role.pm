package POE::Component::IRC::Plugin::Role;

our $VERSION = '0.06';

use strict;
use Moose::Role;

has 'irc' => (
  is => 'ro',
  isa => 'POE::Component::IRC',
  writer => 'set_irc',
  clearer => 'clear_irc',
  init_arg   => undef,
);

has 'S_events' => (
  is => 'ro',
  isa => 'ArrayRef',
  auto_deref => 1,
  lazy_build => 1,
  builder => '_default_sevents',
);

has 'U_events' => (
  is => 'ro',
  isa => 'ArrayRef',
  auto_deref => 1,
  lazy_build => 1,
  builder => '_default_uevents',
);

sub _default_sevents {
  [ grep { s/S_(\w+)/$1/ } shift->meta->get_all_method_names ];
}
 
sub _default_uevents {
  [ grep { s/S_(\w+)/$1/ } shift->meta->get_all_method_names ];
}
 
sub PCI_register {
  my ($self, $irc) = splice @_, 0, 2;
  $self->set_irc( $irc );
  if ( $self->S_events and scalar @{ $self->S_events } > 0 ) {
    $irc->plugin_register( $self, 'SERVER', $self->S_events );
  }
  if ( $self->U_events and scalar @{ $self->U_events } > 0 ) {
    $irc->plugin_register( $self, 'USER', $self->U_events );
  }
  return 1;
}

sub PCI_unregister {
  my $self = shift;
  $self->clear_irc;
  return 1;
}

no Moose::Role;

'Moosified Plugins ahoy!'

__END__

=head1 NAME

POE::Component::IRC::Plugin::Role - A Moose role for POE::Component::IRC plugins

=head1 SYNOPSIS

  package My::Plugin;

  use Moose;
  use POE::Component::IRC::Plugin qw(:ALL);

  with 'POE::Component::IRC::Plugin::Role';

  # PCI_register and PCI_unregister are automatically dealt with

  sub S_001 {
    my $self = shift;
    $self->irc->yield( 'join', '#channel' );
    return PCI_EAT_NONE;
  }

  1;

=head1 DESCRIPTION

POE::Component::IRC::Plugin::Role is a L<Moose> role that encapsulates some of the boilerplate
required to write L<POE::Component::IRC> plugins with L<Moose>.

Simply consume the role in your L<Moose> based plugins.

=head1 ATTRIBUTES

=over

=item C<irc>

Should be a L<POE::Component::IRC> object. It can not be set in the constructor, but has C<set_irc> and C<clear_irc> 
writer and clearer methods, respectively. It is usually set for you by C<PCI_register> and cleared by C<PCI_unregister>
methods.

=item C<S_events>

An arrayref of C<SERVER> events to register for when C<PCI_Register> is called. The default is to register events for
the C<S_*> prefixed methods in your module. 

=item C<U_events>

An arrayref of C<USER> events to register for when C<PCI_register> is called. The default is to register events for
the C<U_*> prefixed methods in your module.

=back

=head1 METHODS

=over

=item C<PCI_register>

This is called everytime a plugin object is added to L<POE::Component::IRC>. It will set the C<irc> attribute 
and register for the requested C<S_events> and C<U_events>.

=item C<PCI_unregister>

This is called everytime a plugin object is removed from L<POE::Component::IRC>. It will clear the C<irc> attribute.

=back

=head1 AUTHOR

Chris C<BinGOs> Williams <chris@bingosnet.co.uk>

Chris Prather

Shawn M Moore

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<POE::Component::IRC>

L<POE::Component::IRC::Plugin>

L<Moose::Role>

=cut
