{
package Fab::Tools::Make2Fab;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Tools::Make2Fab" );
    ( *after, *around, *before, *extends, *field, *has, *param, *signature_for, *with ) = do {
        package Fab::Mite;
        no warnings 'redefine';
        (
            sub { $SHIM->HANDLE_after( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_around( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_before( $CALLER, "class", @_ ) },
            sub {},
            sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) },
            sub { $SHIM->HANDLE_has( $CALLER, has => @_ ) },
            sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) },
            sub { $SHIM->HANDLE_signature_for( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_with( $CALLER, @_ ) },
        );
    };
};

# Mite imports
BEGIN {
    require Scalar::Util;
    *STRICT = \&Fab::Mite::STRICT;
    *bare = \&Fab::Mite::bare;
    *blessed = \&Scalar::Util::blessed;
    *carp = \&Fab::Mite::carp;
    *confess = \&Fab::Mite::confess;
    *croak = \&Fab::Mite::croak;
    *false = \&Fab::Mite::false;
    *guard = \&Fab::Mite::guard;
    *lazy = \&Fab::Mite::lazy;
    *ro = \&Fab::Mite::ro;
    *rw = \&Fab::Mite::rw;
    *rwp = \&Fab::Mite::rwp;
    *true = \&Fab::Mite::true;
};

# Gather metadata for constructor and destructor
sub __META__ {
    no strict 'refs';
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
        HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
    };
}


# Standard Moose/Moo-style constructor
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Attribute input (type: ScalarRef|InstanceOf["Path::Tiny"]|FileHandle|Str)
    # param declaration, file lib/Fab/Tools/Make2Fab.pm, line 11
    croak "Missing key in constructor: input" unless exists $args->{"input"}; 
    do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"input"}) eq 'SCALAR' or ref($args->{"input"}) eq 'REF' } or (do { use Scalar::Util (); Scalar::Util::blessed($args->{"input"}) and $args->{"input"}->isa(q[Path::Tiny]) }) or (do { package Fab::Mite; use Scalar::Util (); (ref($args->{"input"}) && Scalar::Util::openhandle($args->{"input"})) or (Scalar::Util::blessed($args->{"input"}) && $args->{"input"}->isa("IO::Handle")) }) or do { package Fab::Mite; defined($args->{"input"}) and do { ref(\$args->{"input"}) eq 'SCALAR' or ref(\(my $val = $args->{"input"})) eq 'SCALAR' } }) } or croak "Type check failed in constructor: %s should be %s", "input", "ScalarRef|InstanceOf[\"Path::Tiny\"]|FileHandle|Str"; $self->{"input"} = $args->{"input"}; 


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\Ainput\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

    return $self;
}

# Used by constructor to call BUILD methods
sub BUILDALL {
    my $class = ref( $_[0] );
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    $_->( @_ ) for @{ $meta->{BUILD} || [] };
}

# Destructor should call DEMOLISH methods
sub DESTROY {
    my $self  = shift;
    my $class = ref( $self ) || $self;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $in_global_destruction = defined ${^GLOBAL_PHASE}
        ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
        : Devel::GlobalDestruction::in_global_destruction();
    for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
        my $e = do {
            local ( $?, $@ );
            eval { $demolisher->( $self, $in_global_destruction ) };
            $@;
        };
        no warnings 'misc'; # avoid (in cleanup) warnings
        die $e if $e;       # rethrow
    }
    return;
}

my $__XS = !$ENV{PERL_ONLY} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for input
# param declaration, file lib/Fab/Tools/Make2Fab.pm, line 11
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "input" => "input" },
    );
}
else {
    *input = sub { @_ == 1 or croak( 'Reader "input" usage: $self->input()' ); $_[0]{"input"} };
}

# Accessors for output
# field declaration, file lib/Fab/Tools/Make2Fab.pm, line 22
sub output { @_ == 1 or croak( 'Reader "output" usage: $self->output()' ); ( exists($_[0]{"output"}) ? $_[0]{"output"} : ( $_[0]{"output"} = do { my $default_value = $_[0]->_build_output; do { package Fab::Mite; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or croak( "Type check failed in default: %s should be %s", "output", "Str" ); $default_value } ) ) }

# Accessors for parsed
# field declaration, file lib/Fab/Tools/Make2Fab.pm, line 17
sub parsed { @_ == 1 or croak( 'Reader "parsed" usage: $self->parsed()' ); ( exists($_[0]{"parsed"}) ? $_[0]{"parsed"} : ( $_[0]{"parsed"} = do { my $default_value = $_[0]->_build_parsed; blessed( $default_value ) or croak( "Type check failed in default: %s should be %s", "parsed", "Object" ); $default_value } ) ) }


# See UNIVERSAL
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    if ( $INC{'Moose/Util.pm'} and my $meta = Moose::Util::find_meta( ref $self or $self ) ) {
        $meta->can( 'does_role' ) and $meta->does_role( $role ) and return 1;
    }
    return $self->SUPER::DOES( $role );
}

# Alias for Moose/Moo-compatibility
sub does {
    shift->DOES( @_ );
}

1;
}