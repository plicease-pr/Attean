use v5.14;
use warnings;

=head1 NAME

Attean::API::Binding - Name to term bindings

=head1 VERSION

This document describes Attean::API::Binding version 0.001

=head1 DESCRIPTION

The Attean::API::Binding role defines a common API for all objects that map
names to L<Attean::API::Term> objects. This includes triples, quads, and
SPARQL results (variable bindings).

=head1 REQUIRED METHODS

The following methods are required by the L<Attean::API::Binding> role:

=over 4

=item C<< value( $name ) >>

=item C<< variables >>

=item C<< map( $mapper ) >>

=back

=head1 METHODS

The L<Attean::API::Binding> role role provides default implementations of the
following methods:

=over 4

=item C<< values >>

=item C<< tuples_string >>

=item C<< as_string >>

=cut

use Moose::Util::TypeConstraints;

package Attean::API::TripleOrQuad {
	use Moose::Role;
	sub apply_map {
		my $self	= shift;
		my $class	= ref($self);
		my $mapper	= shift;
		my %values	= map { $_ => $mapper->map($self->value($_)) } $self->variables;
		return $class->new( %values );
	}
}


package Attean::API::Binding 0.001 {
	use Moose::Role;
	
	requires 'value';
	requires 'variables';
	requires 'apply_map';
	sub values {
		my $self	= shift;
		return map { $self->value($_) } $self->variables;
	}
	
	sub tuples_string {
		my $self	= shift;
		my @strs	= map { $_->ntriples_string } $self->values;
		return join(' ', @strs);
	}
	sub as_string {
		shift->tuples_string();
	}
}


package Attean::API::Triple 0.001 {
	use Moose::Role;
	
	sub variables { return qw(subject predicate object) }
	sub value {
		my $self	= shift;
		my $key		= shift;
		if ($key =~ /^(subject|predicate|object)$/) {
			return $self->$key();
		} else {
			die "Unrecognized binding name '$key'";
		}
	}
	
	requires 'subject';		# TODO: type constrain to Attean::BlankOrIRI
	requires 'predicate';	# TODO: type constrain to Attean::IRI
	requires 'object';		# TODO: type constrain to Attean::API::Term
	
	sub as_quad {
		my $self	= shift;
		my $graph	= shift;
		return Attean::Quad->new($self->values, $graph);
	}

	with 'Attean::API::TripleOrQuad';
	with 'Attean::API::Binding';
}


package Attean::API::Quad 0.001 {
	use Moose::Role;
	
	sub variables { return qw(subject predicate object graph) }
	sub value {
		my $self	= shift;
		my $key		= shift;
		if ($key =~ /^(subject|predicate|object|graph)$/) {
			return $self->$key();
		} else {
			die "Unrecognized binding name '$key'";
		}
	}
	
	requires 'subject';		# TODO: type constrain to Attean::BlankOrIRI
	requires 'predicate';	# TODO: type constrain to Attean::IRI
	requires 'object';		# TODO: type constrain to Attean::API::Term
	requires 'graph';		# TODO: type constrain to Attean::BlankOrIRI

	with 'Attean::API::TripleOrQuad';
	with 'Attean::API::Triple';
}


package Attean::API::Result 0.001 {
	use Moose::Role;
	
	sub join {
		my $self	= shift;
		my $class	= ref($self);
		my $rowb	= shift;
	
		my %keysa;
		my @keysa	= $self->variables;
		@keysa{ @keysa }	= (1) x scalar(@keysa);
		my @shared	= grep { exists $keysa{ $_ } } ($rowb->variables);
		foreach my $key (@shared) {
			my $val_a	= $self->value($key);
			my $val_b	= $rowb->value($key);
			next unless (defined($val_a) and defined($val_b));
			my $equal	= (refaddr($val_a) == refaddr($val_b)) || $val_a->equal( $val_b );
			unless ($equal) {
				return;
			}
		}
	
		my $row	= { (map { $_ => $self->value($_) } grep { defined($self->value($_)) } $self->variables), (map { $_ => $rowb->value($_) } grep { defined($rowb->value($_)) } $rowb->variables) };
		my $joined	= Attean::Result->new( $row );
		return $joined;
	}

	sub apply_map {
		my $self	= shift;
		my $class	= ref($self);
		my $mapper	= shift;
		my %values	= map { $_ => $mapper->map($self->value($_)) } $self->variables;
		return $class->new( \%values );
	}

	with 'Attean::API::Binding';
}


union 'Attean::API::SPARQLResult', [qw( Bool Attean::API::Result )];

1;

__END__

=back

=head1 BUGS

Please report any bugs or feature requests to through the GitHub web interface
at L<https://github.com/kasei/attean/issues>.

=head1 SEE ALSO

L<http://www.perlrdf.org/>

=head1 AUTHOR

Gregory Todd Williams  C<< <gwilliams@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2014 Gregory Todd Williams.
This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
