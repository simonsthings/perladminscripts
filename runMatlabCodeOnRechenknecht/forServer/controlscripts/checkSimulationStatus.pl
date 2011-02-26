#!/usr/bin/perl -w

use strict;	# Make us need to declare each variable for easier error tracking
use Cwd;

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

$cmd = "ls -1 $simtype/";
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
    if (substr($subfolder, 0, 10) eq $today ) {print        "    today, ";}
    elsif (substr($subfolder, 0, 10) eq $yesterday ) {print " yesterday, ";} 
    else {print " " . substr($subfolder, 0, 10) . ", ";}
    
    $subfolder =~ m/.{11}(..).(..).(..)/;
    print "$1:$2: ";
    #print substr($subfolder, 11, 8) . ": ";
    
    $cmd2 = "ls ./$simtype/$subfolder/results/results.mat";
    #print "${cmd2}\n";
    @cmdoutput2 = `$cmd2 2>&1`;
    unless ($?) {print "finished!\n"; }
    else 
    { 
	print "still running... "; 
	
        my $cmd3 = "tail -n 3 ./$simtype/$subfolder/results/screenoutput.txt";
        #print "${cmd3}\n";
        my @cmdoutput3 = `$cmd3 2>&1`;
        if ($?) {print "\n@{cmdoutput3}\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
        chomp(@cmdoutput3);
        if ($cmdoutput3[0] =~ m/((remaining): (.*))\s*/) { print "($1)\n"; }
        else {print "(no data on remaining time available yet)\n";}
        
        #print " @{cmdoutput3}";
	
    }
    #print " @{cmdoutput2}";
    
    
}

#$cmd = "date";
#print "$cmd\n";
#@cmdoutput = `$cmd 2>&1`;
#if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print "@cmdoutput";

