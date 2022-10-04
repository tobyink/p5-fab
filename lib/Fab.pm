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

sub _make_inc_absolute ( $class ) {
	state $done = 0;
	return if $done;
	
	@INC = map {
		if (ref $_) {
			$_;
		}
		else {
			my $dir = path($_)->absolute;
			$dir->canonpath, $_ eq '.' ? '.' : ();
		}
	} @INC;
	
	++$done;
}

sub import ( $class, %opts ) {
	
	if ( !$opts{no_chdir} and !$NO_CHDIR ) {
		
		$class->_make_inc_absolute;
		
		my $path = path( $CHDIR_TARGET // $Bin )->absolute->canonpath;
		chdir( "$path" );
		
		require Fab::Config;
		'Fab::Config'->import::into( 1 );
	}
	
	'Fab::DSL'->import::into( 1, @{ $opts{dsl} // [] } );
	'Fab::Features'->import::into( 1, @{ $opts{features} // [] } );
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

Tweaks options for this task/product. Options are case-sensitive
and normally all lowercase.

C<< set stdin => $in >> sets STDIN for any further C<< run $command >>
steps. C<< $in >> may be a reference to a scalar string,
a coderef, a filename, or a filehandle open for reading.

C<< set stdout => $out >> sets STDOUT for any further C<< run $command >>
steps. C<< $out >> may be a reference to a scalar string,
a coderef, a filename, or a filehandle open for writing.

C<< set stderr => $err >> sets STDERR for any further C<< run $command >>
steps. C<< $err >> may be a reference to a scalar string,
a coderef, a filename, or a filehandle open for writing.

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

B<Fab> runs in two phases: the defining phase and the producing phase.

During the defining phase, all the C<product> and C<task> statements are
executed by Perl, to build a I<blueprint> for your project. The contents
of C<as> blocks are run, but the C<run>, C<echo>, and C<set> keywords
don't actually run, echo, or set anything; they just add those steps to
the blueprint.

During the producing phase, B<Fab> identifies which products need to
be produced and tasks need to be run, including their dependencies,
then runs each step for those products and tasks. Any C<run>, C<echo>,
and C<set> keywords which occur I<within> other C<< run sub { ... } >>
blocks will be run at this time too.

Note that any Perl statements in C<as> blocks, including conditionals, etc
are evaluated during the defining phase. If you wish Perl code to run during
the producing phase, you will need to wrap it in C<< run sub { ... } >> so
that it becomes a step in a task or product.

=head2 Configuration

If a file called F<Fab.yml> is found in the same directory as F<Fab.pl>,
then this will be parsed as a YAML file and the resulting data will be
available in the C<< %CONFIG >> hash.

For example, in F<Fab.yml>:

  ---
  compiler: g++

And in F<Fab.pl>:

  product 'hello.o', as {
    my $compiler = which( $CONFIG{compiler} );
    run $compiler, '-c', '-Wall', '-g', 'hello.cpp';
    push @clean, this;
  };

This allows you to make parts of your build process configurable without
relying on environment variables, command-line arguments, or editing
settings directly in F<Fab.pl>.

=head1 INSTALLATION

B<Fab> requires Perl 5.28 or above, and recommends at least Perl 5.34.1.
(Older versions of Perl do not have support for subroutine signatures which
B<Fab> uses internally and encourages the use of in F<Fab.pl> scripts.)

Additionally the L<Exporter::Tiny>, L<File::Which>, L<Hook::AfterRuntime>,
L<Import::Into>, L<IPC::Run>, L<Path::Tiny>, L<Text::Glob>, and L<YAML::PP>
modules are required, which can be downloaded from the CPAN.

To install B<Fab>, I recommend you use L<App::cpanminus>. If you do not
already have it, it can be installed using:

  curl -L https://cpanmin.us | perl - App::cpanminus

You may need to run this as root if you don't have permission to write to
Perl's library paths.

Once L<App::cpanminus> is installed, run:

  cpanm Fab

This will install B<Fab> as well as all its dependencies from the CPAN.

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

