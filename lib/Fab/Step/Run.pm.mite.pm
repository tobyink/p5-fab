{

    package Fab::Step::Run;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Fab::Mite";
    our $MITE_VERSION = "0.010008";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Step::Run" );
        (
            *after, *around, *before,        *extends, *field,
            *has,   *param,  *signature_for, *with
          )
          = do {

            package Fab::Mite;
            no warnings 'redefine';
            (
                sub { $SHIM->HANDLE_after( $CALLER, "class", @_ ) },
                sub { $SHIM->HANDLE_around( $CALLER, "class", @_ ) },
                sub { $SHIM->HANDLE_before( $CALLER, "class", @_ ) },
                sub { },
                sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, has   => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) },
                sub { $SHIM->HANDLE_signature_for( $CALLER, "class", @_ ) },
                sub { $SHIM->HANDLE_with( $CALLER, @_ ) },
            );
          };
    }

    # Mite imports
    BEGIN {
        require Scalar::Util;
        *STRICT  = \&Fab::Mite::STRICT;
        *bare    = \&Fab::Mite::bare;
        *blessed = \&Scalar::Util::blessed;
        *carp    = \&Fab::Mite::carp;
        *confess = \&Fab::Mite::confess;
        *croak   = \&Fab::Mite::croak;
        *false   = \&Fab::Mite::false;
        *guard   = \&Fab::Mite::guard;
        *lazy    = \&Fab::Mite::lazy;
        *ro      = \&Fab::Mite::ro;
        *rw      = \&Fab::Mite::rw;
        *rwp     = \&Fab::Mite::rwp;
        *true    = \&Fab::Mite::true;
    }

    BEGIN {
        require Fab::Step;

        use mro 'c3';
        our @ISA;
        push @ISA, "Fab::Step";
    }

    # Standard Moose/Moo-style constructor
    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Attribute definition_context (type: HashRef|Undef)
        # param declaration, file lib/Fab/Step.pm, line 9
        if ( exists $args->{"definition_context"} ) {
            do {

                package Fab::Mite;
                (
                    do {

                        package Fab::Mite;
                        ref( $args->{"definition_context"} ) eq 'HASH';
                      }
                      or do {

                        package Fab::Mite;
                        !defined( $args->{"definition_context"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "definition_context", "HashRef|Undef";
            $self->{"definition_context"} = $args->{"definition_context"};
        }

        # Attribute task (type: Undef|InstanceOf["Fab::Task"])
        # param declaration, file lib/Fab/Step.pm, line 15
        croak "Missing key in constructor: task" unless exists $args->{"task"};
        do {

            package Fab::Mite;
            (
                do { package Fab::Mite; !defined( $args->{"task"} ) }
                  or (
                    do {
                        use Scalar::Util ();
                        Scalar::Util::blessed( $args->{"task"} )
                          and $args->{"task"}->isa(q[Fab::Task]);
                    }
                  )
            );
          }
          or croak "Type check failed in constructor: %s should be %s", "task",
          "Undef|InstanceOf[\"Fab::Task\"]";
        $self->{"task"} = $args->{"task"};
        require Scalar::Util && Scalar::Util::weaken( $self->{"task"} )
          if ref $self->{"task"};

        # Attribute command (type: Str|InstanceOf["Path::Tiny"]|CodeRef)
        # param declaration, file lib/Fab/Step/Run.pm, line 11
        croak "Missing key in constructor: command"
          unless exists $args->{"command"};
        do {

            package Fab::Mite;
            (
                do {

                    package Fab::Mite;
                    defined( $args->{"command"} ) and do {
                        ref( \$args->{"command"} ) eq 'SCALAR'
                          or ref( \( my $val = $args->{"command"} ) ) eq
                          'SCALAR';
                    }
                  }
                  or (
                    do {
                        use Scalar::Util ();
                        Scalar::Util::blessed( $args->{"command"} )
                          and $args->{"command"}->isa(q[Path::Tiny]);
                    }
                  )
                  or
                  do { package Fab::Mite; ref( $args->{"command"} ) eq 'CODE' }
            );
          }
          or croak "Type check failed in constructor: %s should be %s",
          "command", "Str|InstanceOf[\"Path::Tiny\"]|CodeRef";
        $self->{"command"} = $args->{"command"};

        # Attribute args (type: ArrayRef)
        # param declaration, file lib/Fab/Step/Run.pm, line 16
        do {
            my $value = exists( $args->{"args"} ) ? $args->{"args"} : [];
            ( ref($value) eq 'ARRAY' )
              or croak "Type check failed in constructor: %s should be %s",
              "args", "ArrayRef";
            $self->{"args"} = $value;
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(/\A(?:args|command|definition_context|task)\z/),
          keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        return $self;
    }

    my $__XS = !$ENV{PERL_ONLY}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for args
    # param declaration, file lib/Fab/Step/Run.pm, line 16
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "args" => "args" },
        );
    }
    else {
        *args = sub {
            @_ == 1 or croak('Reader "args" usage: $self->args()');
            $_[0]{"args"};
        };
    }

    # Accessors for command
    # param declaration, file lib/Fab/Step/Run.pm, line 11
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "command" => "command" },
        );
    }
    else {
        *command = sub {
            @_ == 1 or croak('Reader "command" usage: $self->command()');
            $_[0]{"command"};
        };
    }

    # See UNIVERSAL
    sub DOES {
        my ( $self, $role ) = @_;
        our %DOES;
        return $DOES{$role} if exists $DOES{$role};
        return 1            if $role eq __PACKAGE__;
        if ( $INC{'Moose/Util.pm'}
            and my $meta = Moose::Util::find_meta( ref $self or $self ) )
        {
            $meta->can('does_role') and $meta->does_role($role) and return 1;
        }
        return $self->SUPER::DOES($role);
    }

    # Alias for Moose/Moo-compatibility
    sub does {
        shift->DOES(@_);
    }

    1;
}
