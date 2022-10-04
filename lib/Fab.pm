use 5.028;
use strict;
use warnings;

package Fab;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

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
of being limited to shell scripting.

=head2 Concepts

Your project should include a file F<Fab.pl> in its project root directory.
This starts with C<< use Fab; >>. Fab will import strict, warnings, etc for
you. The remainder of the file will be a list of products B<Fab> could make for
you, and tasks which B<Fab> could run for you. (A product is just a task which
leads to the creation of a file or directory in your project.)

Anywhere in your project directory, including project subdirectories, you
can run C<fab someproduct.xyz> at the command line, and B<Fab> will search
parent directories until it finds F<Fab.pl>. It will tempoarily C<chdir>
to wherever it found F<Fab.pl>, then create F<someproduct.xyz> for you.

Each product or task is defined as a set of prerequisites and an ordered
list of steps to assemble the product or complete the task. These are
given in an C<as> block. (See L</SYNOPSIS>.)

Prerequisites are defined with the C<need> keyword:

=over

=item C<< need 'filename' >>

This product or task needs a particular file. B<Fab> will create this file
first if it knows how to, or otherwise check that it exists.

=item C<< need '*.txt' >>

This product or task needs all files matching this pattern. B<Fab> will
first create all products it knows about which match the pattern, and
run all tasks which match the pattern.

=item C<< need qr/regexp/ >>

This product or task needs all files matching this pattern. B<Fab> will
first create all products it knows about which match the pattern, and
run all tasks which match the pattern.

=back

Steps can be:

=over

=item C<< run $command, @args >>

Run an external tool, like a compiler.

=item C<< run sub { ... }, @args >>

Run a Perl code block, passing it C<< @args >>.

=item C<< echo $string, @args >>

Outputs a line of information to STDERR. A newline will be appended.
If C<< @args >> is provided, B<Fab> will treat C<< $string >> as a formatting
string for C<sprintf>.

=item C<< set $option, $value >>

Tweaks internal B<Fab> options.

=back

Other keywords B<Fab> provides are:

=over

=item C<< path( $filename ) >>

Returns a L<Path::Tiny> object.

=item C<< this >>

Used within I<products> and not I<tasks>, returns a L<Path::Tiny> for the
filename which should be produced.

  run sub {
    my $text = '...';
    this->spew( $text );
  };

=item C<< which( $command ) >>

Like the shell C<which> command, but returns a L<Path::Tiny> object.

=item C<< stash >>

Within C<< run sub { ... } >> blocks, returns a hashref which can be used
as a stash.

Within the C<< @args >> of C<< run $command, @args >> or
C<< echo $string, @args >>, will return an object with magic overloading,
so that C<< stash->{'foo'}[0] >> will be a reference to the correct place
in the hashref.

=back

=head2 Phases

B<Fab> runs in two phases: the defining stage and the producing stage.

During the defining stage, all the C<product> and C<task> statements are
executed by Perl, to build a I<blueprint> for your project. The contents
of C<as> blocks are run, but the C<run>, C<echo>, and C<set> keywords
don't actually run, echo, or set anything — they just add those steps to
the blueprint.

During the producing stage, B<Fab> identifies which products need to
be produced and tasks need to be run, including their dependencies,
then runs each step for those products and tasks. Any C<run>, C<echo>,
and C<set> keywords which occur I<within> other C<< run sub { ... } >>
blocks will be run at this time too.

=head1 BUGS

Please report any bugs to
L<https://github.com/tobyink/p5-fab/issues>.

=head1 SEE ALSO

L<Beam::Make>.

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

