#!/usr/bin/perl
# IBM_PROLOG_BEGIN_TAG 
# This is an automatically generated prolog. 
#  
# bos720 src/bos/usr/samples/ahafs/bin/aha.pl 1.4.1.1 
#  
# Licensed Materials - Property of IBM 
#  
# Restricted Materials of IBM 
#  
# COPYRIGHT International Business Machines Corp. 2009,2013 
# All Rights Reserved 
#  
# US Government Users Restricted Rights - Use, duplication or 
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp. 
#  
# IBM_PROLOG_END_TAG 
# Subroutines in this FILE  aha.pl:
#      read_arguments
#      syntax
#      monitor_a_event
#      parse_key_values
#      aha_mon_file
#      create_parentdir
#      read_data
#      print_data
#      send_email
#      monitor_a_set_of_events
#      read_input_file
#
# PURPOSE: To monitor a set of events listed in a file (-i flag)
#          or to monitor only one event (-m flag).
# SYNTAX:
#     aha.pl -i <aha-input-file> [-e <emailIds-separated-by-semiColon>]
#     aha.pl -m <aha-monitor-file> <key1>=<value1>[;<key2>=<value2>;...] [-e <emailIds>]
#   e.g.
#     aha.pl -i aha.inp -e user1@abc.com;user2@efg.com
#     aha.pl -m /aha/fs/utilFs.monFactory/tmp.mon "THRESH_HI=90;NOTIFY_CNT=1" user@abc.com
#
# NOTE: Now (2012/12 onward), this script does not support WAIT_IN_READ as a WAIT_TYPE
#       which was provided as an input option with its previous version shipped with
#       AIX 6100-06-00-0000 & AIX 7100-00-00-0000.
#
# CHANGELOG:
#     2008/04/01 Created by N.Dubey
#     2008/04/09 Updated by J.Jann
#     2008/10/30 Updated by R.Burugula, N.Dubey
#     2008/11/15 Updated by J.Jann
#     2009/01/21 Updated by N.Dubey
#     2009/07/30 Updated by N.Dubey
#     2010/03/01 Updated by N.Dubey
#     2010/09/14 Updated by N.Dubey
#     2011/04/15 Updated by N.Dubey
#     2011/06/22 Updated by N.Dubey
#     2012/03/28 Updated by J.Jann
#     2012/11/14 Updated by N.Dubey
#     2012/12/12 Updated by J.Jann
#     2013/01/21 Updated by N.Dubey

use FileHandle;

undef $monFile;
undef $monFileWrStr;
undef $emailList;

undef $cfgFile;
@monFiles= ();
@wrStrs= ();
@notifyCnts= ();
@rearmSecs= ();
@notifiedTime= ();
$minTimeout = 0;

$user=$ENV{"USER"};
$outFile="/tmp/.ahafs.out.$user.$$";
$mailSubject="";

$data_available = 0;

#=============================================================================
# A) Read the arguments
&read_arguments(@ARGV);

# B) Monitor event/events
if ( (!defined $cfgFile) && (!defined $monFileWrStr) )
{
    &syntax;
}
if (defined $monFileWrStr)
{
   &monitor_a_event;
}
elsif (defined $cfgFile)
{
   &monitor_a_set_of_events;
}
exit(0);

# 1 --------------------------------------------------------------------------
sub read_arguments
# Parse the input arguments
{
   my ($option);

   if ($#ARGV < 0)
   {
      &syntax;
   }
   while (@_)
   {
      my $option = shift;
      if ($option eq "-h")
      {
         &syntax;
      }
      elsif ($option eq "-i")
      {
         $cfgFile = shift;
      }
      elsif ($option eq "-e")
      {
         $emailList = shift;
      }
      elsif ($option eq "-m")
      {
         $monFile = shift;
         $monFileWrStr = shift;
      }
      else
      {
         &syntax;
      }
   }

}

# 2 --------------------------------------------------------------------------
sub syntax
{
    printf ("\nSYNTAX1: %s -i <aha-input-file> [-e <emailIds>] \n", $0);
    printf ("SYNTAX2: %s -m <aha-monitor-file> \"<key1>=<value1>[;<key2>=<value2>;...]>\" [-e <emailIds>] \n",
            $0);
    printf("  where: \n");
    printf("   <aha-input-file>  : A file with a list of AHA events & their thresholds\n");
    printf("                       in the format of the file \"aha.inp\".\n");
    printf("   <emailIds>        : Email-Ids separated by ';' to send the report to.\n");
    printf("   <aha-monitor-file>: Pathname of an AHA file with suffix \".mon\".\n");
    printf("  The supported key names and their values are:\n");
    printf("   --------------------------------------------------------------- \n");
    printf("    Key-Name  | Key-Values Supported     | Comments                \n");
    printf("   =============================================================== \n");
    printf("    CHANGED   | YES                      | monitors state-change.  \n");
    printf("              |                          | It cannot be used with  \n");
    printf("              |                          |  THRESH_HI or THRESH_LO.\n");
    printf("   -----------|--------------------------|------------------------ \n");
    printf("    THRESH_HI | positive integer         | monitors high threshold.\n");
    printf("    THRESH_LO | positive integer         | monitors low  threshold.\n");
    printf("   -----------|--------------------------|------------------------ \n");
    printf("    INFO_LVL  | 1 (default)              | Generic info.           \n");
    printf("              | 2                        | Above + info from evProd.\n");
    printf("              | 3                        | Above + stack trace.    \n");
    printf("   -----------|--------------------------|------------------------ \n");
    printf("    NOTIFY_CNT| -1 (default)             | notifies at each occurrence\n");
    printf("              |                          |  (i.e. continuous monitoring).\n");
    printf("              | >0 and <=32767           | notifies after specified  \n");
    printf("              |                          |  number of occurrences.  \n");
    printf("   -----------|--------------------------|------------------------ \n");
    printf("    BUF_SIZE  | 2048 (default)           | Buffer size (bytes) to  \n");
    printf("              | >0 and <=1048576         |  keep the information about\n");
    printf("              |                          |  the occurrences of the event.\n");
    printf("   ----------------------------------------------------------------\n\n");
    printf("Examples: \n");
    printf("   1: %s -i aha.inp -e \"user1\@abc.com;user2\@xyz.com\" \n", $0);
    printf("   2: %s -m /aha/fs/utilFs.monFactory/tmp.mon \"THRESH_HI=90\"\n", $0);
    printf("   3: %s -m /aha/fs/modFile.monFactory/etc/passwd.mon \"CHANGED=YES;INFO_LVL=3\" -e user\@abc.com\n", $0);
    printf("   4: %s -m /aha/mem/vmo.monFactory/npskill.mon \"CHANGED=YES\" \n", $0);
    exit (-1);
}

# 3 --------------------------------------------------------------------------
sub monitor_a_event
{
    my $str = &parse_key_values($monFileWrStr);
    my ($wrStr,$notifyCnt) = split (/:/,$str);

    #Make sure that the file is an AHA monitor file.
    if ( ! &aha_mon_file($monFile) )
    {
        exit (-1);
    }

    #Create the monFile and its parent directories if not already created.
    &create_parentdir($monFile);
    open($FHANDLE, "+>$monFile") or  die "Cannot open the file $monFile. Check the corresponding event object.\n";
    $FHANDLE->autoflush(1);

  
    print  $FHANDLE $wrStr or die "Cannot write $wrStr into the file $monFile\n"; ;

    print "Monitoring the AHAFS event \"$monFile\".\n";
 
    my ($rin, $rout, $nfound);
    $rin = "";
    vec($rin, fileno($FHANDLE),1) = 1;
    $nfound = select($rout=$rin, undef, undef, undef);
    if ($nfound <= 0) # No event occurred or an error was found.
      {
        print "ERROR: The select() returned $nfound.\n";
        print "Possible Cause: The object corresponding to the event might not be available!\n";
        close($FHANDLE);
        exit (-1);
      }
  
    # Create the temporary file.
    open (OUTFILE, "> $outFile") || die "Cannot create the file $outFile: $! \n";
 
    while (1)
    {
        &read_data($FHANDLE);
        
        if ($data_available > 0)  # Data is available.
        {
            #Print the data
            &print_data($monFile);
            
	    # IF only one notification is received after $notifyCnt occurrences of the event, THEN
            if  ($notifyCnt > 0)
            {
                # Remove the temporary file.
                close (OUTFILE);
                system "/usr/bin/rm -f $outFile >/dev/null 2>&1";
                exit 0;
            }

            # ELSE continous monitoring

            # Make sure the event (.mon) file is not deleted.
            if (! -e "$monFile" )
            {
                print "\nThe event file \"$monFile\" no longer exists! The event object might have been deleted.\n";
                
                # Remove the temporary file.
                close (OUTFILE);
                system "/usr/bin/rm -f $outFile >/dev/null 2>&1";
                exit;
            }
        }
    } # end of while loop
}

# 4 --------------------------------------------------------------------------
sub parse_key_values
  {
    #Default key-value pairs (if not provided).
    my $waitType="WAIT_IN_SELECT";
    my $changed="";
    my $threshHi="";
    my $threshLo="";
    my $infoLvl=1;
    my $notifyCnt=-1;
    my $bufSize=2048;
    my $str = shift;
    my $wrStr ="";
    my @key_values = split(/;/,$str);

    for (my $i=0; $i <= $#key_values; $i++)
    {
        if ($key_values[$i] =~ /CHANGED=(\S+)/)
        {
            $changed=$1;
            if ($changed ne "YES")
            {
                print "Invalid value of CHANGED!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] =~ /THRESH_HI=(\d+)/)
        {
            $threshHi=$1;
            if ($threshHi < 0)
            {
                print "Invalid value of THRESH_HI!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] =~ /THRESH_LO=(\d+)/)
        {
            $threshLo=$1;
            if ($threshLo < 0)
            {
                print "Invalid value of THRESH_LO!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] =~ /INFO_LVL=(\d+)/)
        {
            $infoLvl=$1;
            if ($infoLvl < 1 || $infoLvl > 3)
            {
                print "Invalid value of INFO_LVL!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] =~ /NOTIFY_CNT=(\S+)/)
        {
            $notifyCnt=$1;          
            if ($notifyCnt < -1 || $notifyCnt == 0 || $notifyCnt > 32767)
            {
                print "Invalid value of NOTIFY_CNT!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] =~ /BUF_SIZE=(\d+)/)
        {
            $bufSize=$1;
            if ($bufSize < 0 || $bufSize > 1048576)
            {
                print "Invalid value of BUF_SIZE!\n";
                exit (-1);
            }
        }
        elsif ($key_values[$i] eq "")
        {
            next;
        }
        else
        {
            print "Invalid key-value pair!\n";
            exit (-1);
        }
    }
    
    if ( $changed eq "" && $threshHi eq "" && $threshLo eq "" )
    {
        print "The value of the key CHANGED or THRESH_HI or THRESH_LO must be specified!\n";
        exit (-1);
    }
    
    if ( ($changed ne "") && ($threshHi ne "" || $threshLo ne "") )
    {
        print "The CHANGED and THRESH_* can not be specified together!\n";
        exit (-1);
    }
    
    if (($threshHi ne "") && ($threshLo ne "") )
    {
        if ( $threshHi <= $threshLo)
        {
            print "THRESH_HI must be greater than THRESH_LO!\n";
            exit (-1);
        }
    }

    if ($changed ne "")
    {
        $wrStr="WAIT_TYPE=$waitType;CHANGED=$changed;INFO_LVL=$infoLvl;NOTIFY_CNT=$notifyCnt;BUF_SIZE=$bufSize";
    }
    else
    {
        if (($threshHi ne "") && ($threshLo ne "") )
        {
            $wrStr="WAIT_TYPE=$waitType;THRESH_HI=$threshHi;THRESH_LO=$threshLo;INFO_LVL=$infoLvl;NOTIFY_CNT=$notifyCnt;BUF_SIZE=$bufSize";
        }
        elsif ($threshHi ne "")
        {
            $wrStr="WAIT_TYPE=$waitType;THRESH_HI=$threshHi;INFO_LVL=$infoLvl;NOTIFY_CNT=$notifyCnt;BUF_SIZE=$bufSize";
        }
        elsif ($threshLo ne "")
        {
            $wrStr="WAIT_TYPE=$waitType;THRESH_LO=$threshLo;INFO_LVL=$infoLvl;NOTIFY_CNT=$notifyCnt;BUF_SIZE=$bufSize";
        }
    }
    return ("$wrStr:$notifyCnt");
  }


# 5 ---------------------------------------------------------------------------
sub aha_mon_file
{
   my $cwd = $ENV{"PWD"};
   my $mfile = shift;
   my $aha = "";

   open (CMD_MOUNT,"mount |");
   while (<CMD_MOUNT>)
     {
       chomp;
       if (/(\S+)\s+(\S+)\s+ahafs\s+/)
         {
           $aha=$2;
         }
     }
   close (CMD_MOUNT);

   if ($aha eq "")
   {
       print "The ahafs filesystem is not mounted.\n";
       return 0;
   }

   if  ($mfile =~ /\.mon$/)
   {
       if ($mfile =~ /^$aha/)    # Absolute path that starts $aha
       {
          return 1;
       }
       elsif ( !($mfile =~ /^\//)      # Relative path and
               && ($cwd =~ /^$aha/)   #   cwd contains $aha
             )
       {
           return 1;
       }
   }
   print "The $mfile is not an AHA monitor file.\n";
   return 0;
}

# 6 --------------------------------------------------------------------------
sub create_parentdir
{
    my $mfile = shift;
    my $dirname=`/usr/bin/dirname $mfile`;
    if (! -d $dirname)
    {
        system "/usr/bin/mkdir -p $dirname ";
    }
}

# 7 --------------------------------------------------------------------------
sub read_data
{
    my $start = 0;
    my $tm0   = "";
    my $tm    = "";
    my $pid   = 0;
    my $uid   = 0;
    my $luid  = 0;
    my $gid   = 0;
    my $uName = "";
    my $lName = "";
    my $gName = "";
    my $prgName = "";
    my $fhandle  = shift;
    my $parse = 1;
    
  LOOP1:
    while (<$fhandle>)
    {
        $data_available++;	
	if ($parse == 1)
        {
            if  ($_ =~ /BEGIN_EVENT_INFO\s*/)
            {
                print OUTFILE "\n";
                print OUTFILE "$_";
            }
            elsif  ($_ =~ /NUM_EVDROPS_INTRCNTX=(\d+)\s*/)
            {
                print OUTFILE "NUM_EVDROPS_INTRCNTX: $1\n";
            }
            elsif  ($_ =~ /TIME0_tvsec=(\d+)\s*/)
            {
                $tm0    = localtime($1);
                print OUTFILE "Time0               : $tm0\n";
            }
            elsif  ($_ =~ /TIME0_tvnsec=(\d+)\s*/)
            {}
            elsif  ($_ =~ /TIME_tvsec=(\d+)\s*/)
            {
                $tm    = localtime($1);
                print OUTFILE "Time          : $tm\n";
            }
            elsif  ($_ =~ /TIME_tvnsec=(\d+)\s*/)
            {}
            elsif  ($_ =~ /SEQUENCE_NUM=(\d+)\s*/)
            {
                $seqNum = $1;
                print OUTFILE "Sequence Num  : $seqNum\n";
            }
            elsif( $_ =~ /PID=(\d+)\s*/ )
            {
                $pid = $1;
                print OUTFILE "Process ID    : $pid\n";
            }
            elsif ( $_ =~ /UID=(\d+)\s*/ )
            {
                $uid = $1;
                $uName = getpwuid($uid);
                if ($uName ne "")
                {
                    print OUTFILE "User Info     : userName=$uName";
                }
                else
                {
                    print OUTFILE "User Info     : UID=$uid";
                }
            }
            elsif ( $_ =~ /UID_LOGIN=(\d+)\s*/ )
            {
                $luid = $1;
                $lName = getpwuid($luid);
                if ($lName ne "")
                {
                    print OUTFILE ", loginName=$lName";
                }
                else
                {
                    print OUTFILE ", UID_LOGIN=$luid";      
                }
            }
            elsif ( $_ =~ /GID=(\d+)\s*/ )
            {
                $gid = $1;
                $gName = getgrgid($gid);
                if ($gName ne "")
                {
                    print OUTFILE ", groupName=$gName \n";
                }
                else
                {
                    print OUTFILE ", GID=$gid \n";
                }
            }
            elsif ( $_ =~ /PROG_NAME=(\S+)\s*/ )
            {
                $prgName = $1;
                print OUTFILE "Program Name  : $prgName\n";
            }
            elsif ( $_ =~ /CURRENT_VALUE=(\d+)\s*/ )
            {
                $curValue = $1;
                print OUTFILE "Current Value : $curValue\n";
            }
	    elsif ($_ =~ /RC_FROM_EVPROD=(\d+)\s*/) #Last record in the level1 info
	    {
                print OUTFILE "$_";
                $parse = 0;  # No more parsing
            }
        }
	else
        {
            print OUTFILE "$_";
	    if ($_ =~ /END_EVENT_INFO/)
	    {
		last LOOP1;
	    }
        }
    } # while loop ends
}

# 8 --------------------------------------------------------------------------
sub print_data
{
    $evfile = shift;

    #First, close the OUTFILE handle
    close (OUTFILE);

    print STDOUT "\nAHAFS event: $evfile \n";
    print STDOUT "---------------------------------------------------\n";
    if ( ! defined $emailList)
    {
        open (INFILE, "< $outFile");
        while (<INFILE>)
        {
            print STDOUT $_;
        }
        close (INFILE);
    }
    else
    {
        my @emailIds = split(/;/,$emailList);
        
        open (INFILE, "< $outFile");
        while (<INFILE>)
        {
            print STDOUT $_;
        }
        close (INFILE);

        for (my $i=0; $i <= $#emailIds; $i++)
        {
            &send_email($emailIds[$i],$evfile);
        }
        print STDOUT "\nEmail is sent to $emailList.\n";
    }

    # Open the temporary file again to save the report.
    open (OUTFILE, "> $outFile");
    $data_available = 0; 
}

# 9 --------------------------------------------------------------------------
sub send_email
{
    $emailId = shift;
    $evfile = shift;
    $subject = "AHAFS event has occurred!\n";

    $sendmail="/usr/sbin/sendmail";
    open(SENDMAIL,"|$sendmail -t") || die "Cannot create the file $sendmail: $! \n";
    print SENDMAIL "To: $emailId\n";
    print SENDMAIL "Subject: $subject \n\n";

    # Content of the mail
    print SENDMAIL "\nAHAFS event: $evfile \n";
    print SENDMAIL "---------------------------------------------------------------------------------\n";

    open (INFILE, "< $outFile");
    while (<INFILE>)
    {
        print SENDMAIL $_;
    }
    close (INFILE);

    if ( $evfile =~ /\/aha\/fs\/modFile\.monFactory(\S+)\.mon/)
    {
	$file=$1;
	if ( -f $file )
	{
	    $file_basename=`basename $file`;
	    open(FILE, "/usr/bin/uuencode $file $file_basename|");
	    while( <FILE> ) { print SENDMAIL; };
	    close(FILE);
        }
    }

    close(SENDMAIL);
}

# 10  --------------------------------------------------------------------------
sub monitor_a_set_of_events
{
   my $fhandle;
   my ($rin, $rout, $nout, $i); 
   my @FHANDLES=();
   my @notified= ();

   # Read the configuration file
   read_input_file();
   
   # Create the event files and specify the interests.
   for ($i=0; $i <= $#monFiles ; $i++)
   {
       #Make sure that the file is an AHA monitor file.
       if ( ! &aha_mon_file($monFiles[$i]) )
       {
           exit (-1);
       }
       &create_parentdir($monFiles[$i]);
       
       #Write the thresholds for the events
       open($FHANDLES[$i], "+>$monFiles[$i]") or die "Cannot open the file $monFiles[$i]. Check the corresponding event object.\n";
       $fhandle = $FHANDLES[$i];
       $fhandle->autoflush(1);
       print  $fhandle $wrStrs[$i] or die "Cannot write $wrStrs[$i] into the file $monFiles[$i]\n";

       print "Monitoring the AHAFS event \"$monFiles[$i]\".\n";
   }
 
   # Create the temporary file.
   open (OUTFILE, "> $outFile") || die "Cannot create the file $outFile: $! \n";
 
   # Event has occurred.
   my $num_stopped = 0;
   my @stop_evmon=();

   while (1)
   {
       # Start monitoring the events
       $rout = "";
       $rin = "";
       $curTime = time;
       $monitorTimeout = 0;

       for ($i=0; $i <= $#monFiles ; $i++)
       {
           # Ignore if the monitoring of this event is already stopped.
           if  ($stop_evmon[$i] == 1)
             { next; }
           
           if ($notifiedTime[$i] > 0) # Need to rearm
           {
               my $timeLeft = $notifiedTime[$i] + $rearmSecs[$i] - $curTime;
               if ($timeLeft > 0)
               {
                   if( ($monitorTimeout == 0) ||  ($monitorTimeout > $timeLeft))
                     {
                       $monitorTimeout = $timeLeft;
                     }
                   next;
               }
           }
           vec($rin, fileno($FHANDLES[$i]),1) = 1;
       }

       if ($monitorTimeout > 0 )
       {
           $nout = select($rout=$rin, undef, undef, $monitorTimeout);
       }
       else
       {
           $nout = select($rout=$rin, undef, undef, undef);
       }
       if ($nout < 0)           # Error occurred.
       {
           print "\nThe select() returned $nout.\n";
           for ($i=0; $i <= $#monFiles ; $i++)
           {
               # Ignore if the monitoring of this event is already stopped.
               if  ($stop_evmon[$i] == 1)
               { next; } 
           
               if (! -e "$monFiles[$i]" )
               {
                   print "The event file \"$monFiles[$i]\" no longer exists! The event object might have been deleted.\n";
                  
                   $stop_evmon[$i] = 1;
                   $num_stopped++;

                   # Exit if no more monitoring is left.
                   if ($num_stopped == ($#monFiles +1) )
                     {
                       close(OUTFILE);
                       # Remove the temporary file.
                       system "/usr/bin/rm -f $outFile >/dev/null 2>&1";
                       exit;
                     }
                   goto end;
               }
           }
       }
       
       # Handle the reports
       for ($i=0; $i <= $#monFiles ; $i++)
       {
           #Ignore if the monitoring of this event is already stopped.
           if  ($stop_evmon[$i] == 1)
             { next; } 
           
           $fhandle = $FHANDLES[$i];
           
           # Event has occurred.
           if ( vec($rout, fileno($fhandle),1) == 1 )
           {
               &read_data($FHANDLES[$i]);

               if ($data_available > 0)  # Data is available
                 {
                   # Print the data
                   &print_data($monFiles[$i]);
        
                   if ($notifyCnts[$i] > 0) # Only one notification
                   {
                       # See if we need to monitor the event or rearm it after some time.                   
                       if ($rearmSecs[$i] > 0)
                       {
                           $notifiedTime[$i] = time;
                           print "\nMonitoring of the AHAFS event \"$monFiles[$i]\" will be restarted after $rearmSecs[$i] seconds.\n";
                       }        
                       else
                       {
                           print "\nMonitoring of the AHAFS event \"$monFiles[$i]\" is stopped.\n";
                           close($fhandle);
                           $stop_evmon[$i] = 1;
                           $num_stopped++;

                           # Exit if no more monitoring is left.
                           if ($num_stopped == ($#monFiles +1) )
                           {
                               close (OUTFILE);
                               # Remove the temporary file.
                               system "/usr/bin/rm -f $outFile >/dev/null 2>&1";
                               exit;
                           }
                       }        
                   }
	     } # Data has been read.
           } # A particular event has occurred
       } # End of FOR-loop to handle the reports
     end:
   }# End of while loop
}

# 11 --------------------------------------------------------------------------
sub read_input_file
{
   # Open the configuration file
   print "\nAttempting to open the AHAFS configuration file \"$cfgFile\".\n";
   open($cfgHandle, "<$cfgFile") or die "Cannot open the file \"$cfgFile\"\n";

 LOOP1:
   while (<$cfgHandle>)
   {
      $_ =~ s/\s+/ /g;          # Remove extra white space characters
      $_ =~ s/^\s+//;           # Remove the spaces in beginning
      $_ =~ s/\s+$//;           # Remove the spaces the end
      if (/^\#/) { next LOOP1; }

      if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/)
      {
          my $mfile = $1;
          my $cols = "";
          my $secs = 0;

          if ( ($2 eq "YES") || ($2 eq "yes"))
          {
              $cols="CHANGED=YES";
          }
          if ($3 ne "--")
          {
              $cols="$cols;THRESH_HI=$3";
          }
          if ($4 ne "--")
          {
              $cols="$cols;THRESH_LO=$4";
          }
          if ($5 ne "--")
          {
              $cols="$cols;INFO_LVL=$5";
          }
          if ($6 ne "--")
          {
              $cols="$cols;NOTIFY_CNT=$6";
          }
          if ($7 ne "--")
          {
              $cols="$cols;BUF_SIZE=$7";
          }
          if ($8 ne "--")
          {
              my ($d,$h,$m,$s) = split(/:/,$8);
              $secs = $d * 24 * 3600 + $h * 3600 + $m * 60 + $s;
          }

          my $tmpStr = &parse_key_values($cols);
          my ($wrStr,$notifyCnt) = split (/:/,$tmpStr);

          push (@monFiles,$mfile);
          push (@wrStrs, $wrStr);
          push (@notifyCnts, $notifyCnt);
          push (@rearmSecs, $secs);
      }
   }
   # Close the configuration file
   close($cfgHandle);
}
