=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Exception::StepFailed>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Exception::StepFailed';
use Test2::Tools::Spec;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( message original_exception step error );
	};
	
	tests 'it has the expected associated methods' => sub {
		
		can_ok $CLASS, $_ for
			qw( has_original_exception );
	};
	
	tests 'it has the correct role' => sub {
		
		DOES_ok( $CLASS, 'Fab::Exception' );
	};
};

describe 'overload `""`' => sub {
	
	tests 'it works' => sub {
		
		my $exception = $CLASS->new(
			step         => mock( {}, set => [
				definition_context => sub { +{ file => 'Fab.pl', line => 42 } },
			] ),
			error        => 'XYZ',
		);
		
		is( "$exception", $exception->to_string, 'correct stringification' );
	};
};

describe 'method `_build_message`' => sub {
	
	tests 'it works' => sub {
		
		my $exception = $CLASS->new(
			step         => mock( {}, set => [
				definition_context => sub { +{ file => 'Fab.pl', line => 42 } },
			] ),
			error        => 'XYZ',
		);
		
		is(
			$exception->_build_message,
			qq{Step[Fab.pl:42] failed: XYZ},
			'correct value',
		);
	};
};

done_testing;
