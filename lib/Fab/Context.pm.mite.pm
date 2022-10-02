{
package Fab::Context;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Context" );
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

    # Attribute blueprint (type: Object)
    # param declaration, file lib/Fab/Context.pm, line 8
    croak "Missing key in constructor: blueprint" unless exists $args->{"blueprint"}; 
    blessed( $args->{"blueprint"} ) or croak "Type check failed in constructor: %s should be %s", "blueprint", "Object"; $self->{"blueprint"} = $args->{"blueprint"}; 


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\Ablueprint\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for _already_fabricated
# field declaration, file lib/Fab/Context.pm, line 18
sub _already_fabricated { @_ == 1 or croak( 'Reader "_already_fabricated" usage: $self->_already_fabricated()' ); ( exists($_[0]{"_already_fabricated"}) ? $_[0]{"_already_fabricated"} : ( $_[0]{"_already_fabricated"} = do { my $default_value = {}; (ref($default_value) eq 'HASH') or croak( "Type check failed in default: %s should be %s", "_already_fabricated", "HashRef" ); $default_value } ) ) }

# Delegated methods for _already_fabricated
# field declaration, file lib/Fab/Context.pm, line 18
*get_already_fabricated = sub {
@_ >= 2 or croak("Wrong number of parameters in signature for get_already_fabricated; usage: "."\$instance->get_already_fabricated(\$key)");
my $shv_self=shift;
my $shv_ref_invocant = do { $shv_self->_already_fabricated };
scalar(@_)>1 ? @{$shv_ref_invocant}{@_} : ($shv_ref_invocant)->{$_[0]}
};
*set_already_fabricated = sub {
@_ >= 3 or croak("Wrong number of parameters in signature for set_already_fabricated; usage: "."\$instance->set_already_fabricated(\$key, \$value, ...)");
my $shv_self=shift;
my $shv_ref_invocant = do { $shv_self->_already_fabricated };
my (@shv_params) = @_; scalar(@shv_params) % 2 and do { require Carp; Carp::croak("Wrong number of parameters; expected even-sized list of keys and values") };my (@shv_keys_idx) = grep(!($_ % 2), 0..$#shv_params); my (@shv_values_idx) = grep(($_ % 2), 0..$#shv_params); grep(!defined, @shv_params[@shv_keys_idx]) and do { require Carp; Carp::croak("Undef did not pass type constraint; keys must be defined") };for my $shv_tmp (@shv_keys_idx) { do { do { package Fab::Mite; defined($shv_params[$shv_tmp]) and do { ref(\$shv_params[$shv_tmp]) eq 'SCALAR' or ref(\(my $val = $shv_params[$shv_tmp])) eq 'SCALAR' } } or croak("Type check failed in delegated method: expected %s, got value %s", "Str", $shv_params[$shv_tmp]); $shv_params[$shv_tmp] }; };; @{$shv_ref_invocant}{@shv_params[@shv_keys_idx]} = @shv_params[@shv_values_idx];wantarray ? @{$shv_ref_invocant}{@shv_params[@shv_keys_idx]} : ($shv_ref_invocant)->{$shv_params[$shv_keys_idx[0]]}
};
# Accessors for blueprint
# param declaration, file lib/Fab/Context.pm, line 8
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "blueprint" => "blueprint" },
    );
}
else {
    *blueprint = sub { @_ == 1 or croak( 'Reader "blueprint" usage: $self->blueprint()' ); $_[0]{"blueprint"} };
}

# Accessors for stack
# field declaration, file lib/Fab/Context.pm, line 28
sub stack { @_ == 1 or croak( 'Reader "stack" usage: $self->stack()' ); ( exists($_[0]{"stack"}) ? $_[0]{"stack"} : ( $_[0]{"stack"} = do { my $default_value = []; (ref($default_value) eq 'ARRAY') or croak( "Type check failed in default: %s should be %s", "stack", "ArrayRef" ); $default_value } ) ) }

# Delegated methods for stack
# field declaration, file lib/Fab/Context.pm, line 28
*_pop_stack = sub {
@_==1 or croak("Wrong number of parameters in signature for _pop_stack; usage: "."\$instance->_pop_stack()");
1;
my $shv_ref_invocant = do { $_[0]->stack };
pop(@{$shv_ref_invocant})
};
*_push_stack = sub {
my $shv_self=shift;
1;
my $shv_ref_invocant = do { $shv_self->stack };
push(@{$shv_ref_invocant}, @_)
};
*empty_stack = sub {
@_==1 or croak("Wrong number of parameters in signature for empty_stack; usage: "."\$instance->empty_stack()");
my $shv_ref_invocant = do { $_[0]->stack };
!scalar(@{$shv_ref_invocant})
};
*get_stack = sub {
@_==1 or croak("Wrong number of parameters in signature for get_stack; usage: "."\$instance->get_stack()");
my $shv_ref_invocant = do { $_[0]->stack };
@{$shv_ref_invocant}
};
# Accessors for stash
# field declaration, file lib/Fab/Context.pm, line 13
sub stash { @_ == 1 or croak( 'Reader "stash" usage: $self->stash()' ); ( exists($_[0]{"stash"}) ? $_[0]{"stash"} : ( $_[0]{"stash"} = do { my $default_value = {}; (ref($default_value) eq 'HASH') or croak( "Type check failed in default: %s should be %s", "stash", "HashRef" ); $default_value } ) ) }


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