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
	
	my ( $blueprint, $task, $expected, $expected_log, $finder_count, $expected_finder_count );
	before_case 'init case' => sub {
		( $blueprint, $task, $expected, $expected_log ) = ( undef ) x 4;
		$expected_finder_count = $finder_count = 0;
	};
	
	case 'for task with no requirements' => sub {
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub { fail 'should not be called!'; },
		] );
		$task = $CLASS->new(
			name      => 'TestForER01',
			blueprint => $blueprint,
		);
		$expected      = array { end; };
		$expected_log  = array { end; };
	};
	
	case 'for task with required file which exists but with no recipe in blueprint' => sub {
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				fail 'wrong args to finder!' unless $_[1] eq 't/Fab.pl';
				return;
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER02',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/Fab.pl' );
		$expected      = array {
			item object {
				prop isa   => 'Fab::Task::Product';
				call name  => 't/Fab.pl';
				call steps => array { end; };
			};
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = 1;
	};
	
	case 'for task with required file which exists and has a recipe in blueprint' => sub {
		my $prereq;
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				fail 'wrong args to finder!' unless $_[1] eq 't/Fab.pl';
				return $prereq;
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER03',
			blueprint => $blueprint,
		);
		$prereq = $CLASS->new(
			name      => 't/Fab.pl',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/Fab.pl' );
		$expected      = array {
			item exact_ref( $prereq );
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = 1;
	};
	
	case 'for task with required file which exists and has a recipe in blueprint, found via wildcard' => sub {
		my $prereq;
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				fail 'wrong args to finder!' unless $_[1] eq 't/*.*';
				return $prereq;
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER04',
			blueprint => $blueprint,
		);
		$prereq = $CLASS->new(
			name      => 't/Fab.pl',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/*.*' );
		$expected      = array {
			item exact_ref( $prereq );
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = 1;
	};
	
	case 'for task with required file which does not exist and no recipe in blueprint' => sub {
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				fail 'wrong args to finder!' unless $_[1] eq 't/not-existing.txt';
				return;
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER05',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/not-existing.txt' );
		$expected = array { end; };
		$expected_log  = array {
			item array {
				item 'error';
				item match( qr/does not exist/ );
				etc;
			};
			end;
		};
		$expected_finder_count = 1;
	};
	
	case 'for task with required file which does not exist and multiple recipes in blueprint' => sub {
		my ( $prereq1, $prereq2 );
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				fail 'wrong args to finder!' unless $_[1] eq 't/*.not-exist';
				return ( $prereq1, $prereq2 );
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER06',
			blueprint => $blueprint,
		);
		$prereq1 = $CLASS->new(
			name      => 't/123.not-exist',
			blueprint => $blueprint,
		);
		$prereq2 = $CLASS->new(
			name      => 't/456.not-exist',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/*.not-exist' );
		$expected      = bag {
			item exact_ref( $prereq1 );
			item exact_ref( $prereq2 );
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = 1;
	};
	
	case 'for task with recursive requirements' => sub {
		my ( $prereq1, $prereq2 );
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				if ( $_[1] eq 't/123.not-exist' ) {
					return $prereq1;
				}
				if ( $_[1] eq 't/456.not-exist' ) {
					return $prereq2;
				}
				fail 'wrong args to finder!';
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER07',
			blueprint => $blueprint,
		);
		$prereq1 = $CLASS->new(
			name      => 't/123.not-exist',
			blueprint => $blueprint,
		);
		$prereq2 = $CLASS->new(
			name      => 't/456.not-exist',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/123.not-exist' );
		$prereq1->add_requirement( 't/456.not-exist' );
		$expected      = bag {
			item exact_ref( $prereq1 );
			item exact_ref( $prereq2 );
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = 2;
	};
	
	case 'for task with looping requirements' => sub {
		my ( $prereq1, $prereq2 );
		$blueprint = mock( {}, set => [
			isa        => sub { 1 },
			find_tasks => sub {
				$finder_count++;
				if ( $_[1] eq 't/123.not-exist' ) {
					return $prereq1;
				}
				if ( $_[1] eq 't/456.not-exist' ) {
					return $prereq2;
				}
				if ( $_[1] eq 'TestForER08' ) {
					return $task;
				}
				fail 'wrong args to finder!';
			},
		] );
		$task = $CLASS->new(
			name      => 'TestForER08',
			blueprint => $blueprint,
		);
		$prereq1 = $CLASS->new(
			name      => 't/123.not-exist',
			blueprint => $blueprint,
		);
		$prereq2 = $CLASS->new(
			name      => 't/456.not-exist',
			blueprint => $blueprint,
		);
		$task->add_requirement( 't/123.not-exist' );
		$prereq1->add_requirement( 't/456.not-exist' );
		$prereq2->add_requirement( 'TestForER08' );
		$expected      = bag {
			item exact_ref( $prereq1 );
			item exact_ref( $prereq2 );
			end;
		};
		$expected_log  = array { end; };
		$expected_finder_count = D();
	};
	
	tests 'it works' => sub {
		
		my @log;
		my $ctx = mock( {}, set => [
			log => sub { shift; push @log, [ @_ ]; },
		] );
		
		my @expanded = $task->expand_requirements( $ctx );
		
		is( \@expanded, $expected, 'expected results' )
			or diag Dumper( \@expanded );
		is( \@log, $expected_log, 'expected log' )
			or diag Dumper( \@log );
		is( $finder_count, $expected_finder_count, 'find_tasks called expected number of times' )
			or diag "FINDER COUNT: $finder_count";
	};
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
	
	my ( @to_fabricate, @fabricated, $die_on );
	my $expected_fabricated;
	my $expected_exception;
	
	my $blueprint = mock( {}, set => [ isa => sub { 1 } ] );
	my $throw_exception;
	
	before_case 'init case' => sub {
		$die_on = qr/NOTHINGCALLEDTHIS/;
		( @to_fabricate, @fabricated ) = ();
		$expected_exception = undef;
	};
	
	case 'no requirements' => sub {
		$expected_fabricated = array { end; };
	};
	
	case 'one requirement' => sub {
		@to_fabricate = (
			$CLASS->new( name => 'abc', blueprint => $blueprint ),
		);
		$expected_fabricated = array { item 'abc'; end; };
	};
	
	case 'two requirements' => sub {
		@to_fabricate = (
			$CLASS->new( name => 'abc', blueprint => $blueprint ),
			$CLASS->new( name => 'def', blueprint => $blueprint ),
		);
		$expected_fabricated = array { item 'abc'; item 'def'; end; };
	};
	
	case 'two requirements; first fails' => sub {
		@to_fabricate = (
			$CLASS->new( name => 'abc', blueprint => $blueprint ),
			$CLASS->new( name => 'def', blueprint => $blueprint ),
		);
		$die_on = qr/abc/;
		$throw_exception = mock( {}, set => [
			isa => sub { 1 },
			task => sub { $to_fabricate[0] },
			to_string => sub { 'AAAA' },
		] );
		
		$expected_fabricated = array { end; };
		$expected_exception  = object {
			prop isa                 => 'Fab::Exception::PrerequisiteFailed';
			call message             => 'Task "TestForSP" did not have prerequisite "abc"';
			call original_exception  => exact_ref( $throw_exception );
			call task                => object {};
		};
	};
	
	case 'two requirements; second fails' => sub {
		@to_fabricate = (
			$CLASS->new( name => 'abc', blueprint => $blueprint ),
			$CLASS->new( name => 'def', blueprint => $blueprint ),
		);
		$die_on = qr/def/;
		$throw_exception = mock( {}, set => [
			isa => sub { 1 },
			task => sub { $to_fabricate[1] },
			to_string => sub { 'AAAA' },
		] );
		
		$expected_fabricated = array { item 'abc'; end; };
		$expected_exception  = object {
			prop isa                 => 'Fab::Exception::PrerequisiteFailed';
			call message             => 'Task "TestForSP" did not have prerequisite "def"';
			call original_exception  => exact_ref( $throw_exception );
			call task                => object {};
		};
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForSP',
			blueprint => $blueprint,
		);
		my $guard = mock( $task, set => [
			all_requirements => sub { @to_fabricate },
		] );
		my $ctx = mock( {}, set => [
			fabricate => sub {
				my $req = pop;
				if ( $req->name =~ $die_on ) {
					die( $throw_exception );
				}
				push @fabricated, $req->name;
			},
		] );
		
		my $e = dies {
			$task->satisfy_prerequisites( $ctx );
		};
		is( \@fabricated, $expected_fabricated, 'expected prereqs fabricated' )
			or diag Dumper( \@fabricated );
		is( $e, $expected_exception, 'expected exception' )
			or diag Dumper( $e );
	};
};

describe "method `_handle_prerequisite_failure`" => sub {
	
	tests 'it works' => sub {
		
		my $blueprint = mock( {}, set => [ isa => sub { 1 } ] );
		my $context   = mock( {}, set => [ isa => sub { 1 } ] );
		my $task = $CLASS->new(
			name      => 'TestForHPF',
			blueprint => $blueprint,
		);
		my $other = $CLASS->new(
			name      => 'Other',
			blueprint => $blueprint,
		);
		my $orig_e = mock( {}, set => [
			task => sub { $other },
		] );
		
		my $e = dies {
			$task->_handle_prerequisite_failure( $context, $orig_e );
		};
		
		is(
			$e,
			object {
				prop isa                 => 'Fab::Exception::PrerequisiteFailed';
				call task                => exact_ref( $task );
				call prerequisite        => exact_ref( $other );
				call original_exception  => exact_ref( $orig_e );
			},
		);
	};
};

describe "method `run_steps`" => sub {
	tests 'TODO' => sub { pass; };
};

describe "method `_handle_step_failure`" => sub {
	
	tests 'it works' => sub {
		
		my $blueprint = mock( {}, set => [ isa => sub { 1 } ] );
		my $context   = mock( {}, set => [ isa => sub { 1 } ] );
		my $task = $CLASS->new(
			name      => 'TestForHSF',
			blueprint => $blueprint,
		);
		my $orig_e = mock( {}, set => [] );
		
		my $e = dies {
			$task->_handle_step_failure( $context, $orig_e );
		};
		
		is(
			$e,
			object {
				prop isa                 => 'Fab::Exception::TaskFailed';
				call task                => exact_ref( $task );
				call original_exception  => exact_ref( $orig_e );
			},
		);
	};
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
