package Mojo::JSON::XS;

use strict;
use warnings;

use base 'Mojo::Base';

use JSON::XS;
use Mojo::ByteStream 'b';

# Literal names
our $FALSE = Mojo::JSON::XS::_Bool->new(0);
our $TRUE  = Mojo::JSON::XS::_Bool->new(1);

# Byte order marks
my $BOM_RE = qr/
    (?:
    \357\273\277   # UTF-8
    |
    \377\376\0\0   # UTF-32LE
    |
    \0\0\376\377   # UTF-32BE
    |
    \376\377       # UTF-16BE
    |
    \377\376       # UTF-16LE
    )
/x;

# Unicode encoding detection
my $UTF_PATTERNS = {
    "\0\0\0[^\0]"    => 'UTF-32BE',
    "\0[^\0]\0[^\0]" => 'UTF-16BE',
    "[^\0]\0\0\0"    => 'UTF-32LE',
    "[^\0]\0[^\0]\0" => 'UTF-16LE'
};

__PACKAGE__->attr('_jsonxs' => sub { JSON::XS->new->convert_blessed(1) });
__PACKAGE__->attr('error');

sub decode {
    my ($self, $string) = @_;

    # Shortcut
    return unless $string;

    # Cleanup
    $self->error(undef);

    # Remove BOM
    $string =~ s/^$BOM_RE//go;

    # Detect and decode unicode
    my $encoding = 'UTF-8';
    for my $pattern (keys %$UTF_PATTERNS) {
        if ($string =~ /^$pattern/) {
            $encoding = $UTF_PATTERNS->{$pattern};
            last;
        }
    }
    $string = b($string)->decode($encoding)->to_string;

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

    my $string = $self->_jsonxs->encode($ref);

    # Unicode
    return b($string)->encode('UTF-8')->to_string;
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
