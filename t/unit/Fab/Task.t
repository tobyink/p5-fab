=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Task>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Task';
use Test2::Tools::Spec;
use Path::Tiny;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( definition_context blueprint name id steps requirements );
	};
	
	tests 'it has the expected associated methods' => sub {
		
		can_ok $CLASS, $_ for
			qw( _push_step all_steps _push_requirement all_requirements );
	};
	
	tests 'it has an id' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForId',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		like( $task->id, qr/\A[1-9][0-9]*\z/, 'id field matches regexp for positive integers' );
	};

};

describe "method `add_step`" => sub {
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForId',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		my $step = mock( {}, set => [ isa => sub { 1 } ] );
		
		$task->add_step( $step );
		
		is(
			$task->steps,
			array {
				item exact_ref( $step );
				end;
			},
			'steps array is correct',
		);
	};
};

describe "method `add_requirement`" => sub {
	
	my ( $requirement, $expected );
	
	case 'with filename' => sub {
		$expected = $requirement = 'foo.txt';
	};
	
	case 'with glob' => sub {
		$expected = $requirement = 'foo.*';
	};
	
	case 'with regexp' => sub {
		$requirement = qr/foobar/;
		$expected = string "$requirement";
	};
	
	case 'with Path::Tiny' => sub {
		$requirement = 'Path::Tiny'->new( 'foobar.txt' );
		$expected = object {
			prop isa => 'Path::Tiny';
			call stringify => string "$requirement";
		};
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForId',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		$task->add_requirement( $requirement );
		
		is(
			$task->requirements,
			array {
				item $expected;
				end;
			},
			'requirements array contains the expected item',
		);
	};
};

describe "method `expand_requirements`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `this`" => sub {
	tests 'dies in this class' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForThis',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		my $e = dies {
			$task->this;
		};
		
		like( $e, qr/This task doesn't support this\(\)/, 'correct error message' );
	};
};

describe "method `fabricate`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `already_fabricated`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `satisfy_prerequisites`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `run_steps`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `check_postrequisites`" => sub {
	tests 'TODO' => sub { pass; };
};

done_testing;
