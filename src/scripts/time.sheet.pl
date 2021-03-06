#!/usr/local/bin/perl
#
# Title:        time.sheet.pl
# Project:	Time Sheet
# Desc:
# 
#   Generate a timesheet from log
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	6/23/94
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

$DEBUG = 0;

$LogFile = "$ENV{HOME}/pers/work/status/log";

@taskOrderArray = ("WILBAN",
		   "ANISERV",
		   "WILPAK",
		   "NAMESRV",
		   "CF",
		   "CORE",
		   "TOOLS",
		   "RATING",
		   "TRAF",
		   "BILLPRO",
		   "CISDESIGN",
		   "DISTRIB_DB",
		   "DIST",
		   "SICK",
		   "ST_DIS",
		   "VAC",
		   "HOLY",
		   "FLOAT",
		   "FAM_ILL",
		   "BEREAV",
		   "INJURY",
		   "MIL_LEV",
		   "JURY",
		   "NP_OVER",
		   "INT_MEET",
		   "TRAIN",
		   "COMP",
		   "OTHER" );

$doubeLine = 07;

%taskList = ("WILBAN",	"T00443-005\nWilband Prod Supp",
	     "ANISERV",	"T10245    \nANI Server",
	     "WILPAK",	"T03090-005\nWilPak SNMP Agent",
	     "NAMESRV", "T03180-005\nCF Name Server",
	     "CF",	"T92069-005\nCF Prod Support",
	     "CORE",	"T98033-011\nCentral Repos/TQM",
	     "TOOLS",	"T98033-013\nTools",
	     "RATING",	"T98033-015\nRating",
	     "TRAF",	"A00220-???\nTraffic Lookups",
	     "BILLPRO", "A00025-???\nBillPro Data WH",
	     "CISDESIGN",   "T04071-070\nPH I-Dev",
	     "DISTRIB_DB",  "T04071-050\nDBSS Interface",
	     "DIST",	    "T04071-060\nDist Development",
	     "SICK",	"Sick",
	     "ST_DIS",	"Short Trm Dis",
	     "VAC",	"Vacation",
	     "HOLY",	"Holiday",
	     "FLOAT", 	"Float Hol",
	     "FAM_ILL",	"Illness Fam",
	     "BEREAV",	"Bereavement",
	     "INJURY",	"Injury",
	     "MIL_LEV",	"Military Leave",
	     "JURY",	"Jury Duty",
	     "NP_OVER", "NonProd Overtime",
	     "INT_MEET","Int Meetings",
	     "TRAIN",	"Training",
	     "COMP",	"Comp Time",
	     "OTHER",	"Other"
	    );




@julianDate = (0,31,59,90,120,151,181,212,243,273,304,334);
@daysInMonth = (31,28,31,30,31,30,31,31,30,31,30,31);
@daysOfWeek = ("Mon","Tue","Wed","Thr","Fri","Sat","Sun" );

$prevYear      = 0;
$prevStartTime = 0;
$prevTaskMajor = "PERS";
$prevTaskMinor = "";

sub GenTimeSheet
{
  print "Weekly Timesheet - Paul Houghton - Week Ending $endOfWeek\n\n";

  print "Code: PAH  Dept: ????\n";
  
  print "                     Mon   Tue   Wed   Thu   Fri   Sat   Sun   Total";

    
  %orderTask = ();
  
  foreach $task ( keys(%taskHours) )
    {
      $orderTask{$taskOrder{$task}} = $task;
    }
  
#    @orderKeys = sort( keys( %orderTask ) );

  foreach $k (sort( keys( %orderTask ) ) )
    {
      if( $k >= $taskOrder{"SICK"} )
	{
	  printf("\n\n%-19s",$taskList{ $orderTask{$k} } );
	}
      else
	{
	  printf("\n\n%-30s",$taskList{ $orderTask{$k} } );
	}
      
      $tdays = 0;
      foreach $day (split(/,/,$taskHours{ $orderTask{$k} } ) )
	{
	  $tdays++;
	  if( $day == 0 )
	    {
	      print "   .  ";
	    }
	  else
	    {
	      printf("%6.2f",$day );
	    }
	}
      
      for(; $tdays < 7 ; $tdays++)
	{
	  print "   .  ";
	}
      
      printf("%8.2f",$taskWeekHours{$orderTask{$k}});
    }
  
  printf("\n\n%-19s","Totals");
  
  
  $totalWeekHours = 0;
  for( $wday = 0; $wday < 7; $wday++ )
    {
      if( $dayOfWeekHours[$wday] == 0 )
	{
	  print "   .  ";
	}
      else
	{
	    printf("%6.2f",$dayOfWeekHours[$wday] );
	  }
      $totalWeekHours += $dayOfWeekHours[$wday];
    }
  
  printf("%8.2f\n\n",$totalWeekHours);
  
  #  @taskKeys = sort( keys(%taskHours) );
  
  #  foreach $task (@taskKeys)
  #  {
  # $dayOfWeekHours
  # $taskWeekHours
  
  
  #      print "$task - $taskHours{$task} \n";
  #  }
  
  
}

#
# Init Task order
#

for( $t = 0; $t < $#taskOrderArray; ++ $t )
  {
    $taskOrder{ $taskOrderArray[$t] } = $t;
  }


open( LOG, "< $LogFile" ) || die "open $LogFile: $!";

while(<LOG>)
{
#
# looking for: ^00/00/00 09:30 xxx
#
  
  if(/^(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+)\s+(\S.+)/)
    {
      $taskMonth    = $1;
      $taskDate	    = $2;
      $taskYear	    = $3;
      
      $taskHour	    = $4;
      $taskMin	    = $5;
      $task	    = $6;
      
#
# looking for xxx:yyy
#
      
      if( $task =~ /(\S+):(\S*)/ )
	{
	  $taskMajor = $1;
	  $taskMinor = $2;
	}
      else
	{
	  $taskMajor = $task;
	  $taskMinor = "";
	}
      
      $taskJdate = $julianDate[$taskMonth - 1] + $taskDate;
      
      $startTime = ( ($taskJdate * 24 * 60) +
		    ($taskHour * 60) +
		    $taskMin );
      
      if( $taskYear % 4 == 0 && $taskMonth > 2 )	#is it leap year
	{
	  $taskJdate++;
	  $startTime += 24 * 60;
	}
      
      $prevTaskTime = $startTime - $prevStartTime;
      
      if( $prevYear != $taskYear )
	{
	  $prevTaskTime += 365 * 24 * 60;
	  
	  if( $prevYear % 4 == 0 )
	    {
	      $prevTaskTime += 24 * 60;
	    }
	}
      
      #
      # did the previous task span multable days?
      #
      
      
      for( $days = 0, $multiDayTaskTime = ($prevTaskTime % (24 * 60));
	  $prevTaskTime > (($taskHour * 60) + $taskMin) && $prevYear != 0;
	  $days++, $prevTaskDate++, $prevTaskTime -= $multiDayTaskTime,
	  $multiDayTaskTime = 24 * 60)
	{
	  if( $DEBUG )
	    {
	      print "$taskDate $taskHour $taskMin - $prevTaskTime - $days\n";
	    }
	  #
	  # need multi month handling!
	  #
	  
	  
	  if( $prevTaskDate >  $daysInMonth[$prevTaskMonth - 1] )
	    {
	      $prevTaskDate = 1;
	      $prevTaskMonth = (((11 + $prevTaskMonth) - 1) % 12) + 1;
	    }
	  
	  $taskday = sprintf("%02d/%02d/%02d %s",
			     $prevTaskMonth,
			     $prevTaskDate,
			     $prevYear,
			     $prevTaskMajor);
	      
	  $taskDateHours{ $taskday } += $multiDayTaskTime;
	      
	  if( $prevTaskMajor !~ "PERS" )
	    {
	      $day = sprintf("%02d/%02d/%02d",
			     $prevTaskMonth,
			     $prevTaskDate,
			     $prevYear);
	      
	      
	      $dateHours{ $day } = $multiDayTaskTime;
	    }
	  
	  if( $DEBUG ) 
	    {
	      printf("Multi Day: %02d/%02d/%02d %s - %d\n",
		     $prevTaskMonth,
		     $prevTaskDate,
		     $prevYear,
		     $prevTaskMajor,
		     $multiDayTaskTime);
	    }
	}
      
      if( $prevTaskMajor !~ "PERS" )
	{
	  
	  $taskday = sprintf("%02d/%02d/%02d %s",
			     $taskMonth,
			     $taskDate,
			     $taskYear,
			     $prevTaskMajor);
	  
	  
	  $taskDateHours{ $taskday } += $prevTaskTime;
	  
	  $day = sprintf("%02d/%02d/%02d",
			 $taskMonth,
			 $taskDate,
			 $taskYear);
	  
	  
	  $dateHours{ $day } += $prevTaskTime;
	  
	}
      
      # 1/1/70 was a thursday(4)
      
      $weekDay = (($taskYear - 70) + (($taskYear - 69) / 4)
		  + 3 + $taskJdate) % 7;
      
      
      
      
      if( $DEBUG )
	{ print "$taskday - $taskDateHours{$taskday}\n"; }
      
      $prevYear      = $taskYear;
      $prevTaskDate  = $taskDate;
      $prevTaskMonth = $taskMonth;
      $prevStartTime = $startTime;
      $prevTaskMajor = $taskMajor;
      $prevTaskMinor = $taskMinor;
      
    }
}

@dateKeys = sort( keys(%dateHours) );

foreach $dateKey (@dateKeys)
{
  printf("%6.2f\t%s\n", $dateHours{$dateKey} / 60,$dateKey);
}


@taskDateKeys = sort( keys(%taskDateHours) );

foreach $taskDateKey (@taskDateKeys)
{
  if($taskDateKey =~ /^(\d+)\/(\d+)\/(\d+)\s+(\S.+)/)
    {
      $taskMonth    = $1;
      $taskDate	    = $2;
      $taskYear	    = $3;
      $taskMajor    = $4
    }
  else
    {
      die "Task Date Key Error: $taskDateKey\n";
    }
  
  # 1/1/70 was a thursday(4)
  
  $taskJDate = $julianDate[$taskMonth - 1] + $taskDate;
  
  if( $taskYear % 4 == 0 && $taskMonth > 2 )	#is it leap year
    {
      $taskJDate++;
    }
      
  $weekDay = (($taskYear - 70) + (($taskYear - 69) / 4)
	      + 2 + $taskJDate) % 7;
  
  if( $dayHours == 0)
    {
      if( $weekDay != 6 && $weekDay != 0 && $taskJDate != $prevTaskJDate )
	{
	  $monthWorkDays++;
	}
      $prevTaskJDate = $taskJDate;
    }
  else
    {
      
      if( $taskJDate != $prevTaskJDate )
	{
	  printf(" - %6.2f \n",$dayHours / 60);
	  $dayHours = 0;
	  $prevTaskJDate = $taskJDate;
	  
	  if( $weekDay != 6 && $weekDay != 0 )
	    {
	      $monthWorkDays++;
	    }
	}
      else
	{
	  if( $taskDateKey !~ /PERS/  )
	    {
	      printf("\n");
	    }
	}
    }
  
  if(  $weekDay == 0 && $prevTaskWJDate != $taskJDate )
    {
      &GenTimeSheet( );
      %taskHours = ();
      %taskLastWeekDay = ();
      %taskWeekHours = ();
      @dayOfWeekHours = ();
      printf("\n-- WEEK HOURS: %.2f\n\n",$weekHours/ 60);
      $prevTaskWJDate = $taskJDate;
      $weekHours = 0;
    }
  
  if( $taskMonth != $prevTaskMonth )
    {
      printf("\n-- MONTH HOURS: (%d)  %.2f\n\n", 
	     $monthWorkDays * 8,
	     $monthHours / 60);
      $prevTaskMonth = $taskMonth;
      $monthHours = 0;
      $monthWorkDays = 0;
    }
  
  if( $taskDateKey !~ /PERS/ )
    {
      $weekHours += $taskDateHours{$taskDateKey};
      $monthHours += $taskDateHours{$taskDateKey};
      $dayHours += $taskDateHours{$taskDateKey};
      
      while( $taskLastWeekDay{$taskMajor} + 1 < $weekDay + 1 )
	{
	  $taskHours{$taskMajor} .= "0,";
	  $taskLastWeekDay{$taskMajor}++;
	}
      
      $taskHours{$taskMajor} .=
	sprintf("%.2f,",$taskDateHours{$taskDateKey} / 60 );
      
      $dayOfWeekHours[$weekDay] += $taskDateHours{$taskDateKey} / 60;
      $taskWeekHours{$taskMajor} += $taskDateHours{$taskDateKey} / 60;
      
      $taskLastWeekDay{$taskMajor}++;
      
      $endOfWeek = sprintf("%d/%d/%d",
			   $taskMonth,
			   $taskDate,
			   $taskYear );
      
      
      printf("%6.2f\t %s  %s",
	     $taskDateHours{$taskDateKey} / 60,
	     $daysOfWeek[$weekDay],
	     $taskDateKey);
    }
  
}

printf(" - %6.2f \n",$dayHours / 60);
$dayHours = 0;
$prevTaskJDate = $taskJDate;

if( $weekDay != 6 && $weekDay != 0 )
{
  $monthWorkDays++;
}
printf("\n-- WEEK HOURS: %.2f\n\n",$weekHours/ 60);
printf("\n-- MONTH HOURS: (%d)  %.2f\n\n", 
       $monthWorkDays * 8,
       $monthHours / 60);



#
# $Log$
# Revision 1.7  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
# Revision 1.6  1997/05/12 11:17:53  houghton
# Cleanup header and comments.
#
# Revision 1.5  1997/05/12 11:15:08  houghton
# Rework taskOrder so I don't have to specify an order number.
#
# Revision 1.4  1997/05/12 10:58:14  houghton
# Added Dist development.
#
# Revision 1.3  1997/02/24 15:27:01  houghton
# Added aniserver.
# Changed to open ~/pers/work/status/log.
#
# Revision 1.2  1996/10/02 12:07:32  houghton
# *** empty log message ***
#
# Revision 1.1  1995/11/16  18:05:08  houghton
# Initial Version.
#

# Local Variables:
# mode:perl
# End:
