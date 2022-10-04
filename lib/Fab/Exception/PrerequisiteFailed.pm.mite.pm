{
package Fab::Exception::PrerequisiteFailed;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Exception::PrerequisiteFailed" );
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

    # Attribute task
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception/PrerequisiteFailed.pm, line 13
    croak "Missing key in constructor: task" unless exists $args->{"task"}; 
    $self->{"task"} = $args->{"task"}; 

    # Attribute prerequisite
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception/PrerequisiteFailed.pm, line 18
    croak "Missing key in constructor: prerequisite" unless exists $args->{"prerequisite"}; 
    $self->{"prerequisite"} = $args->{"prerequisite"}; 

    # Attribute message (type: Str)
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception.pm, line 9
    if ( exists $args->{"message"} ) { do { package Fab::Mite; defined($args->{"message"}) and do { ref(\$args->{"message"}) eq 'SCALAR' or ref(\(my $val = $args->{"message"})) eq 'SCALAR' } } or croak "Type check failed in constructor: %s should be %s", "message", "Str"; $self->{"message"} = $args->{"message"}; } ;

    # Attribute original_exception
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception.pm, line 15
    if ( exists $args->{"original_exception"} ) { $self->{"original_exception"} = $args->{"original_exception"}; } ;


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\A(?:message|original_exception|prerequisite|task)\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for message
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception.pm, line 9
sub message { @_ == 1 or croak( 'Reader "message" usage: $self->message()' ); ( exists($_[0]{"message"}) ? $_[0]{"message"} : ( $_[0]{"message"} = do { my $default_value = $_[0]->_build_message; do { package Fab::Mite; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or croak( "Type check failed in default: %s should be %s", "message", "Str" ); $default_value } ) ) }

# Accessors for original_exception
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception.pm, line 15
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "exists_predicates" => { "has_original_exception" => "original_exception" },
        "getters" => { "original_exception" => "original_exception" },
    );
}
else {
    *has_original_exception = sub { @_ == 1 or croak( 'Predicate "has_original_exception" usage: $self->has_original_exception()' ); exists $_[0]{"original_exception"} };
    *original_exception = sub { @_ == 1 or croak( 'Reader "original_exception" usage: $self->original_exception()' ); $_[0]{"original_exception"} };
}

# Accessors for prerequisite
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception/PrerequisiteFailed.pm, line 18
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "prerequisite" => "prerequisite" },
    );
}
else {
    *prerequisite = sub { @_ == 1 or croak( 'Reader "prerequisite" usage: $self->prerequisite()' ); $_[0]{"prerequisite"} };
}

# Accessors for task
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Exception/PrerequisiteFailed.pm, line 13
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "task" => "task" },
    );
}
else {
    *task = sub { @_ == 1 or croak( 'Reader "task" usage: $self->task()' ); $_[0]{"task"} };
}


BEGIN {
    require Fab::Exception;
    
    our %DOES = ( "Fab::Exception::PrerequisiteFailed" => 1, "Fab::Exception" => 1 );
}

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

# Methods from roles
sub context_to_string { goto \&Fab::Exception::context_to_string; }
sub rethrow { goto \&Fab::Exception::rethrow; }
sub throw { goto \&Fab::Exception::throw; }
sub to_string { goto \&Fab::Exception::to_string; }

1;
}