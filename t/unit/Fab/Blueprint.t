=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Blueprint>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Blueprint';
use Test2::Tools::Spec;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( definition_context finalized tasks task_lookup context );
	};
	
	tests 'it has the expected associated methods' => sub {
		
		can_ok $CLASS, $_ for
			qw( finalize _push_task all_tasks _build_task_lookup _set_context stash );
	};
};

describe "method `add_task`" => sub {
	
	use Fab::Features;
	
	my sub mk_task ( $name ) {
		return mock( {}, set => [
			isa  => sub { $_[1] eq 'Fab::Task' },
			name => sub { $name },
		] );
	}
	
	tests 'it works' => sub {
		
		my $blueprint;
		
		ok lives {
			$blueprint = $CLASS->new;
		}, 'created new blueprint';
		
		is(
			$blueprint->tasks,
			array { end; },
			'empty tasks list',
		);
		
		is(
			$blueprint->task_lookup,
			hash { end; },
			'empty task_lookup hashref',
		);
		
		ok lives {
			$blueprint->add_task( mk_task( 'Foo' ) );
		}, 'added a task';
		
		is(
			$blueprint->tasks,
			array {
				item D();
				end;
			},
			'one item in tasks list',
		);
		
		is(
			$blueprint->task_lookup,
			hash {
				field Foo => D();
				end;
			},
			'one item in task_lookup hashref',
		);
		
		ok lives {
			$blueprint->add_task( mk_task( 'Bar' ) );
		}, 'added a task';
		
		is(
			$blueprint->tasks,
			array {
				item D();
				item D();
				end;
			},
			'two items in tasks list',
		);
		
		is(
			$blueprint->task_lookup,
			hash {
				field Foo => D();
				field Bar => D();
				end;
			},
			'two items in task_lookup hashref',
		);
		
		ok lives {
			$blueprint->finalize;
		}, 'finalized blueprint';
		
		my $e = dies {
			$blueprint->add_task( mk_task( 'Baz' ) );
		};
		
		isnt( $e, undef, 'cannot add new tasks to finalized blueprints' );
	};
};

describe "method `find_tasks`" => sub {
	
	use Fab::Features;
	
	tests 'it works' => sub {
		
		my $blueprint = $CLASS->new;
		
		my sub mk_task ( $name ) {
			$blueprint->add_task(
				mock( {}, set => [
					isa  => sub { $_[1] eq 'Fab::Task' },
					name => sub { $name },
				] ),
			);
		}
		
		my sub find ( $term ) {
			return [ sort map $_->name, $blueprint->find_tasks( $term ) ];
		}
		
		mk_task 'Foo';
		mk_task 'Bar';
		mk_task 'Baz';
		
		is(
			find( 'Foo' ),
			[ 'Foo' ],
			'find by name, thing that exists',
		);
		
		is(
			find( 'Fool' ),
			[],
			'find by name, thing that does not exist',
		);
		
		is(
			find( 'B*' ),
			[ 'Bar', 'Baz' ],
			'find by glob, thing that exists',
		);
		
		is(
			find( 'B*l' ),
			[],
			'find by glob, thing that does not exist',
		);
		
		is(
			find( qr/^B.*/ ),
			[ 'Bar', 'Baz' ],
			'find by regexp, thing that exists',
		);
		
		is(
			find( qr/^B.*l/ ),
			[],
			'find by regexp, thing that does not exist',
		);
		
		mk_task 'Fool';
		is(
			find( 'Fool' ),
			[ 'Fool' ],
			'find by name, thing that was added later',
		);
	};
};

done_testing;
