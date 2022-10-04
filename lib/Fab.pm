use 5.028;
use strict;
use warnings;

package Fab;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use Fab::DSL ();
use Fab::Features;
use FindBin qw( $Bin );
use Import::Into;

our $NO_CHDIR;
our $CHDIR_TARGET;

@INC = map {
	if (ref $_) {
		$_;
	}
	else {
		my $dir = path($_)->absolute;
		$dir->canonpath, $_ eq '.' ? '.' : ();
	}
} @INC;

sub import ( $class, %opts ) {
	
	if ( !$opts{no_chdir} and !$NO_CHDIR ) {
		my $path = path( $CHDIR_TARGET // $Bin )->absolute->canonpath;
		chdir( "$path" );
		
		require Fab::Config;
		'Fab::Config'->import::into( 1 );
	}
	
	'Fab::DSL'->import::into( 1 );
	'Fab::Features'->import::into( 1 );
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Fab - fabrication

=head1 SYNOPSIS

  use Fab;
  
  my $compiler = which 'g++';
  my @clean;
  
  product 'hello', as {
    need 'hello.o';
    run $compiler, '-g', '-o', this, 'hello.o';
    push @clean, this;
  };
  
  product 'hello.o', as {
    run $compiler, '-c', '-Wall', '-g', 'hello.cpp';
    push @clean, this;
  };
  
  task ':compile', as {
    need 'hello';
  };
  
  task ':test', as {
    need ':compile';
    run './hello';
  };
  
  task ':clean', as {
    echo 'Running cleaning process';
    run sub { unlink($_) for @clean };
  };
  
  task ':TOP', as {
    need ':compile';
  };

=head1 DESCRIPTION

B<Fab> is an alternative to B<make>.

Unlike many clones of B<make>, B<Fab> doesn't attempt to use the same syntax.
It is more verbose, but that is considered a feature, not a bug. It allows
you to use the full features of Perl in your build/automation process instead
of 

=head1 BUGS

Please report any bugs to
L<https://github.com/tobyink/p5-fab/issues>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

