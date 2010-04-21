package Mojo::JSON::XS;

use strict;
use warnings;

use base 'Mojo::Base';

use JSON::XS;

# Literal names
our $FALSE = Mojo::JSON::XS::_Bool->new(0);
our $TRUE  = Mojo::JSON::XS::_Bool->new(1);

__PACKAGE__->attr('_jsonxs' => sub { JSON::XS->new->convert_blessed(1) });
__PACKAGE__->attr('error');

sub decode {
    my ($self, $string) = @_;

    # Shortcut
    return unless $string;

    # Cleanup
    $self->error(undef);

    my $result;

    eval {$result = $self->_jsonxs->decode($string);};

    if ($@) {
        $self->_exception($string, $@);
        return;
    }

    return $result;
}

sub encode {
    my ($self, $ref) = @_;

    return $self->_jsonxs->encode($ref);
}

sub false {$FALSE}

sub true {$TRUE}

sub _exception {
    my ($self, $string, $error) = @_;

    # Message
    $error ||= 'Syntax error';

    chop $error;
    $error =~ s/, at .*? line .*//;

    # Context
    my $context = substr $string, 0, 25;
    $context = "\"$context\"" if $context;
    $context ||= 'end of file';

    # Error
    $self->error(qq/$error near $context./) and return;
}

# Emulate boolean type
package Mojo::JSON::XS::_Bool;

use strict;
use warnings;

use base 'Mojo::Base';
use overload (
    '0+' => sub { $_[0]->{_value} },
    '""' => sub { $_[0]->{_value} }
);

sub new { shift->SUPER::new(_value => shift) }

sub TO_JSON { $_[0]->{_value} ? JSON::XS::true : JSON::XS::false }

1;
