=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::BlueprintMaker::Stash::ARRAY>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Fab::BlueprintMaker::Stash ();
use Test2::V0 -target => 'Fab::BlueprintMaker::Stash::ARRAY';
use Test2::Tools::Spec;

use constant STASH_CLASS => 'Fab::BlueprintMaker::Stash';

describe 'constructor `TIEARRAY`' => sub {
	
	tests 'it works' => sub {
		
		my $base   = STASH_CLASS()->new( '$STASH' );
		my $object = $CLASS->TIEARRAY( $base );
		
		is( ref($object), $CLASS, 'correct class' );
		is( $$$object, '$STASH', 'correct object guts' );
	};
};

describe 'method `FETCH`' => sub {
	
	tests 'it works' => sub {
		
		my $base   = STASH_CLASS()->new( '$STASH' );
		my $object = $CLASS->TIEARRAY( $base );
		my $got    = $object->FETCH( 42 );
		
		is( ref($got), STASH_CLASS(), 'correct class' );
		is( $$got, '$STASH->[42]', 'correct object guts' );
	};
};

done_testing;
