#!/usr/bin/perl -w

use strict;	# Make us need to declare each variable for easier error tracking
use Cwd;

my $lastN = 20;
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
    print " Copying last $lastN results of $simtype... ";                                                                                                                                 
}                                                                                                                                                                                         
else                                                                                                                                                                                      
{                                                                                                                                                                                        
    $cmd = "ls -1 $simtype/";                                                                                                                                                             
    print " Copying all results of $simtype... ";
}
#print "$cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print "@cmdoutput";
chomp(@cmdoutput);
print "$simtype:\n";
foreach my $subfolder (@cmdoutput)
{
    my $cmd2;
    my @cmdoutput2;

    #my $folderdate = substr($subfolder, 0, 10);
    #print "folderdate: $folderdate";
    if (substr($subfolder, 0, 10) eq $today ) {print        "     today, ";}
    elsif (substr($subfolder, 0, 10) eq $yesterday ) {print " yesterday, ";} 
    else {print substr($subfolder, 0, 10) . ", ";}
    
    $subfolder =~ m/.{11}(..).(..).(..)/;
    print "$1:$2";
    #print substr($subfolder, 11, 8) . ": ";
    
    ## Also show server on which the simulation was run:
    $cmd = "head -n 1 ./$simtype/$subfolder/results/hostnamepid.txt"; #print "$cmd\n";
    my $targethostname = `$cmd 2>&1`;
    if ($?) {print "\n$targethostname\n"; print 'WARNING: It seems that the above command did not work ';};
    chomp($targethostname);
    print ", $targethostname:\t ";
    
    $cmd2 = "ls ./$simtype/$subfolder/results/results.mat";
    #print "${cmd2}\n";
    @cmdoutput2 = `$cmd2 2>&1`;
    unless ($?) { print "finished!\n"; }
    else 
    { 
	# check if there was an error or if it is just still running:
        my $cmd3 = "ls ./$simtype/$subfolder/results/screenerrors.txt -s"; #print "${cmd3}\n";
        my $cmdoutput3 = `$cmd3 2>&1`;
        #if ($?) {print "\n${cmdoutput3}\n"; print 'WARNING: It seems that the above folder does not contain a file called "screenerrors.txt". Old folder?';};
        if (substr($cmdoutput3,0,1) eq "0")
        {        
	    print "still running... "; 
	
    	    my $cmd4 = "tail -n 3 ./$simtype/$subfolder/results/screenoutput.txt"; #print "${cmd4}\n";
    	    my @cmdoutput4 = "lala";
    	    @cmdoutput4 = `$cmd4 2>&1`;
    	    if ($?) {print "\n@{cmdoutput4}\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    	    chomp(@cmdoutput4);
    	    if ( (@cmdoutput4) && ($cmdoutput4[0] =~ m/((remaining): (.*))\s*/) ) { print "($1)\n"; }
    	    else {print "(no data on remaining time available yet)\n";}
        
    	    #print " @{cmdoutput4}";
	}
	else
	{
	    print "error! (see ./$simtype/$subfolder/results/screenerrors.txt on server)\n";
	}


	
    }
    #print " @{cmdoutput2}";
    
}

#$cmd = "date";
#print "$cmd\n";
#@cmdoutput = `$cmd 2>&1`;
#if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print "@cmdoutput";

