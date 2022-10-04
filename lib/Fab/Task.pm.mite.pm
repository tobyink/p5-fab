{
package Fab::Task;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Task" );
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

    # Attribute definition_context (type: HashRef|Undef)
    # param declaration, file lib/Fab/Task.pm, line 12
    if ( exists $args->{"definition_context"} ) { do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"definition_context"}) eq 'HASH' } or do { package Fab::Mite; !defined($args->{"definition_context"}) }) } or croak "Type check failed in constructor: %s should be %s", "definition_context", "HashRef|Undef"; $self->{"definition_context"} = $args->{"definition_context"}; } ;

    # Attribute blueprint (type: InstanceOf["Fab::Blueprint"])
    # param declaration, file lib/Fab/Task.pm, line 18
    croak "Missing key in constructor: blueprint" unless exists $args->{"blueprint"}; 
    blessed( $args->{"blueprint"} ) && $args->{"blueprint"}->isa( "Fab::Blueprint" ) or croak "Type check failed in constructor: %s should be %s", "blueprint", "InstanceOf[\"Fab::Blueprint\"]"; $self->{"blueprint"} = $args->{"blueprint"}; 
    require Scalar::Util && Scalar::Util::weaken($self->{"blueprint"}) if ref $self->{"blueprint"};

    # Attribute name
    # param declaration, file lib/Fab/Task.pm, line 25
    croak "Missing key in constructor: name" unless exists $args->{"name"}; 
    $self->{"name"} = $args->{"name"}; 


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\A(?:blueprint|definition_context|name)\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for blueprint
# param declaration, file lib/Fab/Task.pm, line 18
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "blueprint" => "blueprint" },
    );
}
else {
    *blueprint = sub { @_ == 1 or croak( 'Reader "blueprint" usage: $self->blueprint()' ); $_[0]{"blueprint"} };
}

# Accessors for definition_context
# param declaration, file lib/Fab/Task.pm, line 12
sub definition_context { @_ > 1 ? do { do { package Fab::Mite; ((ref($_[1]) eq 'HASH') or (!defined($_[1]))) } or croak( "Type check failed in %s: value should be %s", "accessor", "HashRef|Undef" ); $_[0]{"definition_context"} = $_[1]; $_[0]; } : ( $_[0]{"definition_context"} ) }

# Accessors for id
# field declaration, file lib/Fab/Task.pm, line 33
sub id { @_ == 1 or croak( 'Reader "id" usage: $self->id()' ); ( exists($_[0]{"id"}) ? $_[0]{"id"} : ( $_[0]{"id"} = do { my $default_value = $_[0]->_build_id; (do { my $tmp = $default_value; defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/ }) or croak( "Type check failed in default: %s should be %s", "id", "Int" ); $default_value } ) ) }

# Accessors for name
# param declaration, file lib/Fab/Task.pm, line 25
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "name" => "name" },
    );
}
else {
    *name = sub { @_ == 1 or croak( 'Reader "name" usage: $self->name()' ); $_[0]{"name"} };
}

# Accessors for requirements
# field declaration, file lib/Fab/Task.pm, line 45
sub requirements { @_ == 1 or croak( 'Reader "requirements" usage: $self->requirements()' ); ( exists($_[0]{"requirements"}) ? $_[0]{"requirements"} : ( $_[0]{"requirements"} = do { my $default_value = []; (ref($default_value) eq 'ARRAY') or croak( "Type check failed in default: %s should be %s", "requirements", "ArrayRef" ); $default_value } ) ) }

# Delegated methods for requirements
# field declaration, file lib/Fab/Task.pm, line 45
*_push_requirement = sub {
my $shv_self=shift;
1;
my $shv_ref_invocant = do { $shv_self->requirements };
push(@{$shv_ref_invocant}, @_)
};
*all_requirements = sub {
@_==1 or croak("Wrong number of parameters in signature for all_requirements; usage: "."\$instance->all_requirements()");
my $shv_ref_invocant = do { $_[0]->requirements };
@{$shv_ref_invocant}
};
# Accessors for steps
# field declaration, file lib/Fab/Task.pm, line 35
sub steps { @_ == 1 or croak( 'Reader "steps" usage: $self->steps()' ); ( exists($_[0]{"steps"}) ? $_[0]{"steps"} : ( $_[0]{"steps"} = do { my $default_value = []; do { package Fab::Mite; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Fab::Step]) }) }; $ok } } or croak( "Type check failed in default: %s should be %s", "steps", "ArrayRef[InstanceOf[\"Fab::Step\"]]" ); $default_value } ) ) }

# Delegated methods for steps
# field declaration, file lib/Fab/Task.pm, line 35
*_push_step = sub {
my $shv_self=shift;
for my $shv_value (@_) { do { (do { use Scalar::Util (); Scalar::Util::blessed($shv_value) and $shv_value->isa(q[Fab::Step]) }) or croak("Type check failed in delegated method: expected %s, got value %s", "InstanceOf[\"Fab::Step\"]", $shv_value); $shv_value }; }
my $shv_ref_invocant = do { $shv_self->steps };
push(@{$shv_ref_invocant}, @_)
};
*all_steps = sub {
@_==1 or croak("Wrong number of parameters in signature for all_steps; usage: "."\$instance->all_steps()");
my $shv_ref_invocant = do { $_[0]->steps };
@{$shv_ref_invocant}
};

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