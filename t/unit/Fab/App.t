=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::App>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::App';
use Test2::Tools::Spec;
use Test2::Require::Module 'File::chdir';
use Path::Tiny;
use File::chdir;
use FindBin qw( $Bin );

describe 'method `run`' => sub {
	
	tests 'it works' => sub {
		
		no warnings 'once';
		
		my $tempfile = 'Path::Tiny'->tempfile;
		$tempfile->spew( '$::FLAG = 42;' . "\n" );
		
		my $app = $CLASS->new;
		my $guard = mock( $app, set => [
			_find_fab_pl => sub { $tempfile },
		] );
		
		my $return = $app->run;
		
		is( $return, 0, 'returned zero' );
		is( $Fab::CHDIR_TARGET, $tempfile->parent, '$Fab::CHDIR_TARGET' );
		is( $::FLAG, 42, 'file found was run' );
	};
};

describe 'method `_find_fab_pl`' => sub {
	
	tests 'it works' => sub {
		
		local $CWD = $Bin;
		
		my $app = $CLASS->new;
		my $found = $app->_find_fab_pl;
		
		isa_ok( $found, 'Path::Tiny' );
		like( $found, qr/Fab.pl$/, 'found the correct file, possibly' );
		like( $found->slurp, qr/9[a]02fd[0]965c9cb5c31afb2ef29797665bd08e9?84/, '... definitely!' );
	};
};

done_testing;
