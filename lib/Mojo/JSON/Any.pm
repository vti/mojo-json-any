package Mojo::JSON::Any;

use strict;
use warnings;

use Mojo::JSON;

use constant JSONXS => ($ENV{MOJO_JSON})
  ? 0
  : eval { require JSON::XS; require Mojo::JSON::XS; 1 };

sub new { shift; JSONXS ? Mojo::JSON::XS->new(@_) : Mojo::JSON->new(@_) }

1;
