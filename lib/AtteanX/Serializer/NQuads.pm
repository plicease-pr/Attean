=head1 NAME

AtteanX::Serializer::NQuads - N-Triples Serializer

=head1 VERSION

This document describes AtteanX::Serializer::NQuads version 0.028

=head1 SYNOPSIS

 use Attean;
 my $serializer = Attean->get_serializer('NQuads')->new();
 $serializer->serialize_iter_to_io( $iter, $fh );

=head1 DESCRIPTION

Serializes triples and quads into the RDF 1.1 N-Quads format.

=head1 ATTRIBUTES

=over 4

=item C<< canonical_media_type >>

=back

=head1 METHODS

=over 4

=item C<< serialize_iter_to_io( $fh, $iterator ) >>

=item C<< serialize_iter_to_bytes( $fh ) >>

=cut

use v5.14;
use warnings;

package AtteanX::Serializer::NQuads 0.028 {
	use Moo;
	use Types::Standard qw(Str ArrayRef);
	use Encode qw(encode);
	use Attean::ListIterator;
	use List::MoreUtils qw(any);
	use namespace::clean;

	extends 'AtteanX::Serializer::NTuples';
	has 'canonical_media_type' => (is => 'ro', isa => Str, init_arg => undef, default => 'application/n-quads');

=item C<< media_types >>

Returns a list of media types that identify the format produced by this serializer.

=cut

	sub media_types {
		return [qw(application/n-quads)];
	}

	with 'Attean::API::MixedStatementSerializer';
	with 'Attean::API::AppendableSerializer';
}

1;

__END__

=back

=head1 BUGS

Please report any bugs or feature requests to through the GitHub web interface
at L<https://github.com/kasei/perlrdf/issues>.

=head1 SEE ALSO

L<https://www.w3.org/TR/n-quads/>

=head1 AUTHOR

Gregory Todd Williams  C<< <gwilliams@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2014--2020 Gregory Todd Williams. This
program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
