#!/usr/bin/perl
#
# Title:        df.pl
# Project:	System
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	03/04/98 07:11
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

use lib "$ENV{HOME}/scripts/perllib";

require "PrettyNum.pl";

foreach $pdir (split(/:/,$ENV{PATH}))
  {
    if( -x "$pdir/df"
        && "$pdir/df" ne $0 )
      {
	$real_df = "$pdir/df";
	last;
      }
  }

if( ! $real_df )
  {
    die "did NOT find real 'df' in $ENV{PATH}\n";
  }


open( DFOUT, "$real_df -k |" );

print "          Size          Used         Avail  (all values in KB)\n";

while( <DFOUT> )
  {
    
    if( /^\S*\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+%\s+(\S+)/ )
      {
	$total = PrettyNum( $1 );
	$used = PrettyNum( $2 );
	$avail = PrettyNum( $3 );
	printf ("  %12s  %12s  %12s  $4\n", $total, $used, $avail);
      }
  }

#
# $Log$
# Revision 1.1  1999/05/03 14:28:38  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

