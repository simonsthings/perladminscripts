#!/usr/bin/perl -w

use strict;           # Make us need to declare each variable for easier error tracking

# declare my variables:
my $cmd;
my $cmdoutput;

$cmd = "ssh -n nyquist.isip.uni-luebeck.de \"tail -n 1 /mnt/raid/projects/auslastung/*.csv\"";    # define unix shell command to execute
my @lines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

my $currentServer="none";  # temporary during loop
my $nextServer="none";     # will contain final server
my $minLoad="100.0";    # load of final server
foreach my $line (@lines)
{
    print "$line";
    # find current server:
    if ($line =~ m/==> \/mnt\/raid\/projects\/auslastung\/(\w*).csv <==/)
    {
	$currentServer = $1;
    }
    
    # check if this is better than last:
    if ($line =~ m/^(\d+\.\d+)\s.*/)
    {
	#print "scanning load line. comparing $1 to $minLoad ...\n";
        if ( ($1 < $minLoad) && ($currentServer ne "shannon") && ($currentServer ne "fermi") && ($currentServer ne "euler") && ($currentServer ne "cauchy") )
	{
	    #print "NEW MIN LOAD!\n";
	    $minLoad = $1;
    	    $nextServer = $currentServer;
        }
    }
    
    #print "current server is: $currentServer\n";
    #print "   next server is: $nextServer\n";
    #print "  minimum load is: $minLoad\n";
}

print "\nLowest load: ";
print "$minLoad%\n";
print   "Next Server: ";
print "$nextServer";
#print "\bye!";

