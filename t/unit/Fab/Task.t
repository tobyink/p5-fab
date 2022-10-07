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
use Data::Dumper;

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
	
	my ( $already, @actions, $expected );
	
	before_case 'init case' => sub { @actions = (); };
	
	case 'when task thinks it has already been fabricated' => sub {
		$already = 1;
		$expected = array {
			item array {
				item 'already_fabricated';
				item object {};
				end;
			};
			item array {
				item '$ctx';
				item 'set_already_fabricated';
				item D();
				item T();
				end;
			};
			end;
		};
	};
	
	case 'when task thinks it has not already been fabricated' => sub {
		$already = 0;
		$expected = array {
			item array {
				item 'already_fabricated';
				item object {};
				end;
			};
			item array {
				item '$ctx';
				item 'set_already_fabricated';
				item D();
				item T();
				end;
			};
			item array {
				item '$ctx';
				item 'log';
				item 'info';
				item string 'Task: "%s"';
				item string 'TestForFabricate';
				end;
			};
			item array {
				item 'satisfy_prerequisites';
				item object {};
				end;
			};
			item array {
				item 'run_steps';
				item object {};
				end;
			};
			item array {
				item 'check_postrequisites';
				item object {};
				end;
			};
			end;
		};
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForFabricate',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		my $guard = mock( $task, set => [
			already_fabricated => sub {
				shift;
				push @actions, [ already_fabricated => @_ ];
				return $already;
			},
			satisfy_prerequisites => sub {
				shift;
				push @actions, [ satisfy_prerequisites => @_ ];
			},
			run_steps => sub {
				shift;
				push @actions, [ run_steps => @_ ];
			},
			check_postrequisites => sub {
				shift;
				push @actions, [ check_postrequisites => @_ ];
			},
		] );
		
		my $ctx = mock( {}, set => [
			set_already_fabricated => sub {
				shift;
				push @actions, [ '$ctx', set_already_fabricated => @_ ];
			},
			log => sub {
				shift;
				push @actions, [ '$ctx', log => @_ ];
			},
		] );
		
		ok lives {
			$task->fabricate( $ctx );
		};
		is( \@actions, $expected, 'fabricate called things in the expected order' )
			or diag Dumper( \@actions );
	};
};

describe "method `already_fabricated`" => sub {
	
	my ( @GAF_args, $GAF_response, $expected_response );
	
	my $ctx = mock( {}, set => [
		get_already_fabricated => sub {
			shift; @GAF_args = @_;
			return $GAF_response;
		},
	] );
	
	before_case 'init case' => sub { @GAF_args = (); };
	
	case 'when context claims task was already fabricated' => sub {
		$GAF_response      = 1;
		$expected_response = T();
	};
	
	case 'when context claims task was not already fabricated' => sub {
		$GAF_response      = 0;
		$expected_response = F();
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForAF',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		my $response = $task->already_fabricated( $ctx );
		
		is(
			\@GAF_args,
			array {
				item number $task->id;
				end;
			},
			'$ctx->get_already_fabricated was passed the task ID and nothing else',
		);
		is( $response, $expected_response, 'got expected response' );
	};
};

describe "method `satisfy_prerequisites`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `_handle_prerequisite_failure`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `run_steps`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `_handle_step_failure`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `check_postrequisites`" => sub {
	
	tests "it doesn't die" => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForPostReq',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		ok lives {
			$task->check_postrequisites( mock( {} ) );
		};
	};
};

done_testing;
