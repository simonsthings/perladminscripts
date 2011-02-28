#!/usr/bin/perl -w

use strict;	# Make us need to declare each variable for easier error tracking
use Cwd;

my $lastN = 10;
my $cmd;
my @cmdoutput;
my $cwd = cwd;
my $today = `date --rfc-3339=date`; 
chomp($today);
$today =~ m/(.{8})(.{2})/;
my $yesterday =  $1 . ($2 - 1);

my $hostname = `hostname`;
chomp($hostname);
print "Welcome to $hostname!\n";
print "Working in $cwd\n";

my $simtype = "singletrials";

if ($#ARGV >= 0)
{
    if ($ARGV[0] eq "-a") {$lastN=0;}
    elsif ($ARGV[0] eq "-n") {$lastN=$ARGV[1];}
    else {die("Unrecognised command line option. Please use either '-a' or '-n #' (where # is number of last trials)");}
}

# show last 20 entries or all if wanted:
if ( $lastN > 0 )
{
    $cmd = "ls -1 $simtype/ | tail -n $lastN";
    print "Copying last $lastN results of $simtype... ";
}
else
{ 
    $cmd = "ls -1 $simtype/";
    print "Copying all results of $simtype... ";
}
#print "$cmd\n";
my @subfolders = `$cmd 2>&1`;
if ($?) {print "\n@subfolders\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print " @subfolders";
chomp(@subfolders);
my @simstartdates;
my @simstarttimes;
my @simstatuses;
#foreach my $subfolder (@subfolders)
for (my $i = 0; $i < $#subfolders; $i++)
{
    my $subfolder = $subfolders[$i];
    my $cmd2;
    my @cmdoutput2;

    #my $folderdate = substr($subfolder, 0, 10);
    #print "folderdate: $folderdate";
    my $simstartdate;
    my $simstarttime;
    if (substr($subfolder, 0, 10) eq $today ) { $simstartdate = "today";}
    elsif (substr($subfolder, 0, 10) eq $yesterday ) {$simstartdate = "yesterday";} 
    else {$simstartdate =  substr($subfolder, 0, 10);}
    
    $subfolder =~ m/.{11}(..).(..).(..)/;
    $simstarttime = "$1:$2";
    #print substr($subfolder, 11, 8) . ": ";
    
    my $simstatus;
    $cmd2 = "ls ./$simtype/$subfolder/results/results.mat";
    #print "${cmd2}\n";
    @cmdoutput2 = `$cmd2 2>&1`;
    if ($?)
    {
	# check if there was an error or if it is just still running:
        my $cmd3 = "ls ./$simtype/$subfolder/results/screenerrors.txt -s"; #print "${cmd3}\n";
        my $cmdoutput3 = `$cmd3 2>&1`;
        #if ($?) {print "\n${cmdoutput3}\n"; print 'WARNING: It seems that the above folder does not contain a file called "screenerrors.txt". Old folder?';};
        if (substr($cmdoutput3,0,1) eq "0")
        {        
	    $simstatus = "still running... "; 
	
    	    my $cmd4 = "tail -n 3 ./$simtype/$subfolder/results/screenoutput.txt"; #print "${cmd4}\n";
    	    my @cmdoutput4 = "lala";
    	    @cmdoutput4 = `$cmd4 2>&1`;
    	    if ($?) {print "\n@{cmdoutput4}\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    	    chomp(@cmdoutput4);
    	    if ( (@cmdoutput4 ne "") && ($cmdoutput4[0] =~ m/((remaining): (.*))\s*/) ) { $simstatus .= "($1)"; }
    	    else {$simstatus .= "(no data on remaining time available yet)";}
        
    	    #print " @{cmdoutput4}";
	}
	else
	{
	    $simstatus = "error! (see ./$simtype/$subfolder/results/screenerrors.txt on server)";
	}
    }
    else
    {
	$simstatus = "finished!";
    }
    #print " @{cmdoutput2}";
    
    ## Store sim metadata: ##
    $simstartdates[$i] = $simstartdate;
    $simstarttimes[$i] = $simstarttime;
    $simstatuses[$i] = $simstatus;
    
    ## Copy to web folder ##
    $cmd = "mkdir -p ./webview/$simtype/$subfolder"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print "@cmdoutput";
    
    $cmd = "cp $simtype/$subfolder/results/*.png ./webview/$simtype/$subfolder"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; #if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    #print "@cmdoutput";
    
    $cmd = "cp $simtype/$subfolder/results/*.txt ./webview/$simtype/$subfolder"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; #if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    #print "@cmdoutput";
    
    
}

print "Done.\n";


    
## Generate HTML file ##
print "Generating html summary file... ";

open(SUMMARYFILE, "> ./webview/$simtype/index.html") or die "Can't write to file ./webview/$simtype/index.html: $!";

# Make HTML header:
print SUMMARYFILE '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print SUMMARYFILE "<html><head><title>$simtype Simulation Results</title>";
#print OUTKFILE "<meta HTTP-EQUIV=\"REFRESH\" content=\"2; url=/$mainmenucache#$ENV{QUERY_STRING}\">";
print SUMMARYFILE "</head><body link='#000000' vlink='#000000' alink='blue' bgcolor='#E0E0E0'>\n";
print SUMMARYFILE "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print SUMMARYFILE "<h1>Simulation Results</h1>\n";
print SUMMARYFILE "<h2>Last $lastN $simtype:</h2>\n";
#print OUTKFILE "<br>\n";

print SUMMARYFILE "<table><tr>\n";
# headers:
for (my $i = 0; $i < $#subfolders; $i++)
{
    print SUMMARYFILE "<th> $simstartdates[$i], $simstarttimes[$i] </th>\n";
}
print SUMMARYFILE "</tr><tr>\n";
for (my $i = 0; $i < $#subfolders; $i++)
{
    print SUMMARYFILE "<th> $simstatuses[$i] </th>\n";
}
print SUMMARYFILE "</tr><tr>\n";
# data:
for (my $i = 0; $i < $#subfolders; $i++)
{
    print SUMMARYFILE "<td> images... textfiles... </td>\n";
}

print SUMMARYFILE "</tr></table>\n\n";

my $timestring = scalar( localtime(time));
print SUMMARYFILE "This page was generated at $timestring .<br>\n";
print SUMMARYFILE "</body></html>\n";
close(SUMMARYFILE);

print "Done.\n";


## Pack into tgz archive for transfer ##
print "Now packaging into ${simtype}_webview.tgz for transfer... ";

$cmd = "tar czf ./webview/${simtype}_webview.tgz ./webview/$simtype"; #print "$cmd\n";
@cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print "@cmdoutput";

print "Done.\n";



