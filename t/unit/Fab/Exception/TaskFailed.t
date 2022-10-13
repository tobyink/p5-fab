=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Exception::TaskFailed>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Exception::TaskFailed';
use Test2::Tools::Spec;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( message original_exception task );
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
			task         => mock( {}, set => [
				name               => sub { "Task1" },
				definition_context => sub { +{ file => 'Fab.pl', line => 42 } },
			] ),
		);
		
		is( "$exception", $exception->to_string, 'correct stringification' );
	};
};

describe 'method `_build_message`' => sub {
	
	tests 'it works' => sub {
		
		my $exception = $CLASS->new(
			task         => mock( {}, set => [
				name               => sub { "Task1" },
				definition_context => sub { +{ file => 'Fab.pl', line => 42 } },
			] ),
		);
		
		is(
			$exception->_build_message,
			qq{Task "Task1"[Fab.pl:42] failed},
			'correct value',
		);
	};
};

done_testing;
