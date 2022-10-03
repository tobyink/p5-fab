use Fab;

my $compiler = which 'g++';
my @clean;

product 'hello', as {
	need 'hello.o';
	run $compiler, '-g', '-o', this(), 'hello.o';
	push @clean, this;
};

product 'hello.o', as {
	run $compiler, '-c', '-Wall', '-g', 'hello.cpp';
	push @clean, this;
};

product ':compile', as {
	need 'hello';
};

product ':test', as {
	need 'hello';
	run './hello';
};

product ':clean', as {
	echo 'Running cleaning process';
	run sub { unlink($_) for @clean };
};

product ':TOP', as {
	need ':compile';
};
