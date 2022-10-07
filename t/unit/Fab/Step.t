=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Step>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Step';
use Test2::Tools::Spec;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( definition_context task );
	};
};

done_testing;
