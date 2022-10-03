=pod

=encoding utf-8

=head1 PURPOSE

Test that Fab DSL works.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0;
use Data::Dumper;

my ( $abc, $def, $xyz, @xyz );
$xyz = 0;

$Fab::NO_GO = 1;

my $blueprint = do {
	package Local::Test1;
	use Fab;
	
	task 'abc', as {
		need 'def', qr/xyz/;
		run sub { $abc = $_[0] }, 123;
	};
	
	task 'def', as {
		need 'xy*';
		run sub { $def = $_[0] }, 456;
	};
	
	task 'xyz', as {
		run sub { push @xyz, @_ }, 789, 0;
		run sub {
			run sub { ++$xyz };
		};
	};
	
	$Fab::MAKER->blueprint;
};

is(
	$blueprint,
	object {
		prop isa          => 'Fab::Blueprint';
		call finalized    => F();
		call tasks        => bag {
			item object {
				prop isa          => 'Fab::Task';
				prop isa          => 'Fab::Task::Simple';
				call definition_context => hash { etc; };
				call blueprint    => D();
				call name         => string 'abc';
				call requirements => bag { item string 'def'; item D(); end; };
				call steps        => array {
					item object {
						prop isa          => 'Fab::Step';
						prop isa          => 'Fab::Step::Run';
						call definition_context => hash { etc; };
						call task         => D();
						call command      => D();
						call args         => array { item number 123; end; };
					};
					end;
				};
			};
			item object {
				prop isa          => 'Fab::Task';
				prop isa          => 'Fab::Task::Simple';
				call definition_context => hash { etc; };
				call blueprint    => D();
				call name         => string 'def';
				call requirements => bag { item string 'xy*'; end; };
				call steps        => array {
					item object {
						prop isa          => 'Fab::Step';
						prop isa          => 'Fab::Step::Run';
						call definition_context => hash { etc; };
						call task         => D();
						call command      => D();
						call args         => array { item number 456; end; };
					};
					end;
				};
			};
			item object {
				prop isa          => 'Fab::Task';
				prop isa          => 'Fab::Task::Simple';
				call definition_context => hash { etc; };
				call blueprint    => D();
				call name         => string 'xyz';
				call requirements => bag { end; };
				call steps        => array {
					item object {
						prop isa          => 'Fab::Step';
						prop isa          => 'Fab::Step::Run';
						call definition_context => hash { etc; };
						call task         => D();
						call command      => D();
						call args         => array { item number 789; item number 0; end; };
					};
					item object {
						prop isa          => 'Fab::Step';
						prop isa          => 'Fab::Step::Run';
						call definition_context => hash { etc; };
						call task         => D();
						call command      => D();
						call args         => array { end; };
					};
					end;
				};
			};
			end;
		};
	},
	'got correct blueprint from DSL',
) or diag Dumper( $blueprint );

done_testing;

