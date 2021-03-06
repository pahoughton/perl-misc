package App::Options;
require 5.006_001;
use strict;
use warnings;

our %Doc;
$Doc{ File }	=   "Options.pm";
$Doc{ Project } =   ["PerlUtils",""];
$Doc{ Item }   	=   "\$Id$)";
$Doc{ desc } = "Perl module to process command line arguments.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
$Doc{ Created } = "05/30/01 08:52";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";

$Doc{ VERSION } = "+VERSION+";

#
# Revision History: (See end of file for Revision Log)
#


require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use App::Options ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
#	
# ) ] );

# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '1.01';

our( $debug );

our @StdOpts =
  (
   [ "arg-file=s",	undef,
			"FILE",	    "opt",
			"command line arguments file.",
			"Name of the file to read command line"
			." arguments from."],
   [ "gen-arg-file",	undef,
			"",	    "opt",
			"generate the args file.",
			"Create the args file from the current option"
			." settings"],
   [ "help+",		undef,
			"",	    "opt",
			"Output usage information.",
			"The amount of information increases each"
			." time it appears on the command line."
			." The first instance just outputs the available"
			." command line arguments. Successive instances"
			." (i.e. -help -help -help) provide additional"
			." information up to 4 which output the entire"
			." program documentation." ],

   [ "man",		undef,
			"",	    "opt",
			"Output the entire program documentation.",
			"This is just a short cut for using -help 4 times" ],

   [ "nopager",		undef,
			"",	    "opt",
			"Don NOT use pager for help output",
			"When ever the help (or man) text has more lines"
			." that your terminal window, the default pager"
			." is used to keep the text from scrolling off"
			." the screen. To keep the pager from being used,"
			." put this option on the command line." ],

   [ "show-opts",	undef,
			"",	    "opt",
			"Show option and env values then exit.",
			"Output the command line options and their respective"
			." current values. Also output any relevant"
			." environment variables and their respective"
			." values." ],

   [ "debug+",		undef,
			"",	    "opt",
			"Output debug information.",
			"Increments the amount of debug information"
			." each time it is found in the arguments. So,"
			." no --debug sets debug level to 0 (none),"
			." one -debug sets it to 1 and -debug -debug"
			." sets the debug level to 2. The higher the"
			." level, the more debug information is"
			." output." ],
   [ "version",		undef,
			"",	    "opt",
			"Show version and exit.",
			"Output the program's version information"
			." then exit" ],
  );
# Preloaded methods go here.
sub new ($%);
sub opt ($$);
# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

App::Options - Perl extension for blah blah blah

=head1 SYNOPSIS

  use App::Options;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for App::Options, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut

use App::Debug;
use Getopt::Long;
use IO::File;
use Carp;

sub new ($%) {
  my ($this, %params) = @_;

  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;

  if( ! defined( $params{ OPTIONS } ) ) {
    croak( "required param `OPTIONS' not provided to App::Options." );
  }

  {
    my $unknown;
    my $p;
    foreach $p (keys(%params)) {
      print "Param: $p\n" if $debug;
      if( $p eq "DOCSELF" ) {
	$$self{ doc } = $params{ $p };
      } elsif( $p eq "OPTIONS" ) {
	$$self{ options } = $params{ $p };
      } elsif( $p eq "DEBUG" ) {
	$$self{ debug } = 1;
      } else {
	print "Unknown arg '$p' passed to App::Options\n";
	$unknown = 1;
      }
    }
    if( $unknown ) {
      croak( "Aborted for uknown App::Options parameter." );
    }
  }

  $$self{ opt }->{ maxwidth }->{ name } = 0;

  if( $debug ) {
    my $o;
    foreach $o (@{$$self{ options }}) {
      print "OPT(0): '$$o[0]'\n";
      print "OPT(1): '$$o[1]'\n";
      print "OPT(2): '$$o[2]'\n";
      print "OPT(3): '$$o[3]'\n";
      print "OPT(4): '$$o[4]'\n";
      print "OPT(5): '$$o[5]'\n";
      print "OPT(6): '$$o[6]'\n";
      if( ref( $$o[6] ) eq "ARRAY" ) {
	my $e;
	foreach $e (@{$$o[6]}) {
	  print "OPT(6-): '$e'\n";
	}
      }
      print "\n";

    }
  }
	

  my @bareOpts;
  my @reqOpts;
  my @getOpts;
  {
    my $o;
    foreach $o (@{$$self{ options }} ) {
      my $opt = $$o[0];
      my $optname;
      print "OPT: $opt\n" if $debug;
      if( $opt =~ /([-\w]+)(\|[-\|\w]+)*[@]*-$/ ) {
	# Do not use GetOptions this value will come from the
	# args after GetOptions has processed them.
	# print "BARE PARSE: '$1' '$2' '$3'\n";
	$optname = $1;
	push( @{$$self{ opt }->{ optnames }}, $optname );
	push( @bareOpts, $o );
	if( $$o[3] eq "req" ) {
	  push( @reqOpts, $optname );
	}
      } elsif ( $opt ) {
	if ( $opt !~
	     /^((\w+[-\w]*)(\|(\?|\w[-\w]*)?)*)?([!+]|[=:][infse][@%]?)?$/ ) {
	  confess "Invalid option format '$opt'";
	} else {
	  my $opttype = $5;
	  ($optname) = split(/\|/,$1);
	  push( @{$$self{ opt }->{ optnames }}, $optname );
	  if( length( $optname )
	      > $$self{ opt }->{ maxwidth }->{ name } ) {
	    $$self{ opt }->{ maxwidth }->{ name }
	      = ( length( $optname ) > 20 ? 20 : length( $optname ) );
	  }
	  if( $$o[3] eq "req" ) {
	    push( @reqOpts, $optname );
	  }
	  print "OPT: '$opt' '$optname' '$opttype'\n" if $debug;
	  if( $opttype ) {
	    if ( $opttype =~ /\@/ ) {
	      $$self{ option }->{ $optname } = ();
	      push( @getOpts, $opt, \@{$$self{ option }->{ $optname }} );
	    } elsif ( $opttype =~ /\%/ ) {
	      $$self{ option }->{ $optname } = {};
	      push( @getOpts, $opt, \%{$$self{ option }->{ $optname }} );
	    } else {
	      if( $opttype =~ /^=/ ) {
		$$self{ option }->{ $optname } = "";
		push( @getOpts, $opt, \$$self{ option }->{ $optname } );
	      } else {
		$$self{ option }->{ $optname } = 0;
		push( @getOpts, $opt, \$$self{ option }->{ $optname } );
	      }
	    }
	  } else {
	    $$self{ option }->{ $optname } = 0;
	    push( @getOpts, $opt, \$$self{ option }->{ $optname } );
	  }
	
	  if( $optname =~ /debug/i ) {
	    App::Debug::Configure( OUTLEVEL =>
				   \$$self{ option }->{ $optname } );
	  }
	  if( defined( $$o[1] ) ) { # default value
	    $$self{ option }->{ $optname } = $$o[1];
	  }
	}
      }
      if( ! defined( $optname ) ) {
	confess "No option name found for option.";
      }
      # Snatch env vars
      if( defined( $$o[6] ) ) {
	if( ref( $$o[6] ) eq "ARRAY" ) {
	  my $env;
	  foreach $env (@{$$o[6]}) {
	    if( $env =~ /\$ENV{(\w+)}(\w+)/ ) {
	      my $prefix = $1;
	      my $suffix = $2;
	      if( defined( $ENV{ $prefix } ) ) {
		my $var = "$ENV{ $prefix }" . "$suffix";
		Debug( 4, "Using env var '$var'" );
		
		if( defined( $ENV{ $var } ) ) {
		  $$self{ option }->{ $optname } = $ENV{ $var };
		  last;
		}
	      }
	    } else {
	      if( defined( $ENV{ $env } ) ) {
		$$self{ option }->{ $optname } = $ENV{ $var };
		last;
	      }
	    }
	  }
	} else {
	  if( defined( $ENV{ $$o[6] } ) ) {
	    $$self{ option }->{ $optname } = $ENV{ $$o[6] };
	  }
	}
      }
    }
  }

  {
    # if there is an arg file, use it
    for( my $i = 0; $i < scalar( @ARGV ); ++ $i ) {
      if( $ARGV[$i] =~ /-arg-file/ ) {
	if( $ARGV[$i] =~ /-arg-file=(.*)/ ) {
	  $$self{ option }->{ 'arg-file' } = $1;
	} else {
	  $$self{ option }->{ 'arg-file' } = $ARGV[ $i + 1 ];
	}
	$self->parse_arg_file();
	last;
      }
    }
  }

  if( $debug ) {
    Getopt::Long::Configure( "debug" );
  }

  if( ! GetOptions( @getOpts ) ) {
    if( $self{ doc } ) {
      $self{ doc }->usage( 1, 1 );
    }
    croak( "ERROR: GetOptions failed" );
    # FIXME - need better feedback
  }

  # print "OPTWIDTH: $$self{ opt }->{ maxwidth }->{ name }\n";
  # print "Proc Bare Opts\n";
  if( @bareOpts ) {
    my $o;
    foreach $o (@bareOpts) {
      # print "BARE: '$$o[0]'\n";
      my ($optname) = $$o[0] =~ /^(\w+)/;
      Debug( 2, "Bare opt name: '$optname'" );
      if( $$o[0] =~ /\@-$/ ) {
	while( @ARGV ) {
	  push( @{$$self{ option }->{ $optname }}, shift @ARGV);
	}
	last;
      }
      if( defined( $ARGV[0] ) ) {
	if( $$o[3] =~ /\|/ ) {
	  my $val;
	  foreach $val (split(/\|/,@{$$o[3]})) {
	    if( $ARGV[0] eq $val ) {
	      $$self{ option }->{ $optname } = shift @ARGV;
	      last;
	    }
	  }
	} else {
	  $$self{ option }->{ $optname } = shift @ARGV;
	}
      }
    }
  }

  if( $$self{ option }->{ 'gen-arg-file' } ) {
    $self->gen_arg_file();
    exit 0;
  }
  if( $$self{ option }->{ "show-opts" } ) {
    print "$$self{ prog } Option Values:\n\n";
    my $opt;
    foreach $opt (@{$$self{ opt }->{ optnames }}) {
      printf( "  %*s '%s'\n",
	      $$self{ opt }->{ maxwidth }->{ name },
	      $opt,
	      $$self{ option }->{ $opt } );
    }

    print "  Environment Variables\n\n";

    my $o;
    foreach $o (@{$$self{ options }}) {
      my $envVal;
      # print "ENV ARG: $$o[6]\n";
      if( defined( $$o[6] ) ) {
	if( ref( $$o[6] ) eq "ARRAY" ) {
	  # print "ENV is ARRAY\n";
	  my $env;
	  foreach $env (@{$$o[6]}) {
	    # print "ENV ARRAY: $env\n";
	    if( $env =~ /\$ENV{(\w+)}(\w+)/ ) {
	      my $prefix = $1;
	      my $suffix = $2;
	      if( defined( $ENV{ $prefix } ) ) {
		my $var = "$ENV{ $prefix }" . "$suffix";
		
		if( defined( $ENV{ $var } ) ) {
		  $envVal = $ENV{ $var };
		}
	      }
	    } else {
	      if( defined( $ENV{ $env } ) ) {
		$envVal = $ENV{ $env };
	      }
	    }
	    printf( "  %24s '%s'\n", $env, $envVal );
	  }
	} else {
	  printf( "  %24s '%s'\n", $$o[6], $ENV{ $$o[6] } );
	}
      }
    }
    if( $$self{ env } ) {
      my $env;
      foreach $env (@{$$self{ env }}) {
	printf( "  %24s '%s'\n", $$env[0], $ENV{ $$env[0] } );
      }
    }
  }


  {
    my $req;
    foreach $req (@reqOpts) {
      # print "Checking for req opt: $req\n";
      if( ! defined( $$self{ option }->{ $req } )
	  || length( $$self{ option }->{ $req } ) < 1 ) {
	push( @{$$self{ opt }->{ missing }}, $req );
	# print "IS MISSING\n";
      } else {
	# print "FOUND IT\n";
      }
    }
  }

  if( $$self{ doc } ) {

    if( $$self{ option }->{ help } ) {
      $$self{ doc }->usage( $$self{ option }->{ help },
			   ! $$self{ option }->{ nopager } );
      exit( 1 );
    }

    if( $$self{ option }->{ man } ) {
      $$self{ doc }->usage( 4, ! $$self{ option }->{ nopager } );
      exit( 1 );
    }

    if( defined( $$self{ opt }->{ missing } )
	&& scalar( @{$$self{ opt }->{ missing }}) ) {
      $$self{ doc }->usage( 1, 0 );
      my $a;
      foreach $a (@{$$self{ opt }->{ missing }}) {
	print "Required option '$a' missing.\n";
      }
      croak( "\n$main::0 aborted\n" );
    }
  }

  return $self;
}

sub opt ($$) {
  my ($self, $opt) = (@_);

  if( defined( $$self{ option }->{ $opt } ) ) {
    return( $$self{ option }->{ $opt } );
  } else {
    return( "" );
  }
}

sub gen_arg_file ($) {
  my ($self) = (@_);

  my $out;
  if( length( $$self{ option }->{ 'arg-file' } ) ) {
    $out = new IO::File( $$self{ option }->{ 'arg-file' },
			 "w" );
    defined( $out ) || croak( "open '".$$self{ option }->{ 'arg-file' }
			      ."'");
  } else {
    $out = new IO::Handle;
    $out->fdopen(fileno(STDOUT),"w")
      || croak "open STDOUT???";
  }

  $out->print( "# Generated arg file\n");
  foreach my $o (@{$$self{ opt }->{ optnames }}) {
    if( defined( $$self{ option }->{ $o } )
	&& $$self{ option }->{ $o }
      && $o ne "gen-arg-file" ) {
      $out->printf( "-%-30s  %s\n", $o, $self->opt( $o ) );
    } else {
      $out->print( "# -$o\n" );
    }
  }
}


sub parse_arg_file ($) {
  my ($self) = (@_);

  my $in;
  if( length( $$self{ option }->{ 'arg-file' } ) ) {
    $in = new IO::File( $$self{ option }->{ 'arg-file' },
			 "r" );
    defined( $in )
      || return( 0 );

    while( <$in> ) {
      if( /-(\S+)\s+(\S+)/ ) {
	$$self{ option }->{ $1 } = $2;
      }
    }
  }
}

# Set XEmacs mode
#
# Local Variables:
# mode:perl
# End:
