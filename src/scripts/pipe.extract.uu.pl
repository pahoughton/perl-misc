#!/usr/local/bin/perl
#
# Title:        extract.uu.pl
# Project:	Mail
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	01/14/97 07:19
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

%Month2Num = ( "Jan", "01",
	       "Feb", "02",
	       "Mar", "03",
	       "Apr", "04",
	       "May", "05",
	       "Jun", "06",
	       "Jul", "07",
	       "Aug", "08",
	       "Sep", "09",
	       "Oct", "10",
	       "Nov", "11",
	       "Dec", "12"
	       );

$extractDir="$ENV{HOME}/Mail/extract";

$mesgFrom="";
$mesgText="";
$mesgDate="";


while(<>) {

  if( /^From: (\S+)/ && ! $mesgFrom ) {
    $mesgFrom=$1;
  }

  if( /^Date:.*(\d+) ([A-Z][a-z][a-z]) (\d+)/ ) {
    $mesgDate = sprintf( "%02d%02d%02d", $3 % 100, $Month2Num{$2}, $1 );
    # print "MesgDate: $1 $2 $3 - $mesgDate\n";
  }

  if( ! $mesgDir && $mesgFrom && $mesgDate ) {
    $mesgDir = "$extractDir/$mesgFrom-$mesgDate";

    # print "MesgDir: $mesgDir\n";
    # exit;
    
    if( ! -d $mesgDir ) {
      mkdir( $mesgDir, 0775 ) || die "mkdir $mesgDir: $!";
    } else {
      die "$mesgDir exist";
    }
  
  }
    
  
  if( /^begin \d\d\d (\S+)$/ ) {
    if( ! $mesgDir ) {
      die "mesgDir not set";
    }
    $begLine = $_;
    $outfn=$1;
    
    if( $outfn =~ /^\.tar\.\d\d\d\.(.*)/ ) {
      $uuoutfn="$mesgDir/$1.tar.Z";
    } elsif ( $outfn =~ /^\.(.*)/ ) {
	$uuoutfn="$mesgDir/$1";
      } else {
	$uuoutfn="$mesgDir/$outfn";
      }
    
    open( UU, "| uudecode -o $uuoutfn" ) ||
      die "open: '| uudecode $uuoutfn': $!\n";

    print UU $begLine;
    
    print "Found($.): $outfn - decoding ...\n";
    
    while(<>) {
      print UU ;
      
      if( /^end$/ ) {
	
	close(UU);
	print "End($.): $uuoutfn created\n";
	last;
      }
    }
  } else {
    $mesgText .= $_;
  }
      
#  print;
}

open( MSG, "> $mesgDir/mail.text.txt" ) ||
  die "open: '> $mesgDir/mail.text.txt': $!\n";

print MSG $mesgText;

close(MSG);


#
# $Log$
# Revision 1.1  1997/02/24 15:33:22  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:
