#!/usr/bin/perl -w

use strict;           # Make us need to declare each variable for easier error tracking
#use Cwd;
#my $currDir = cwd;

my $remotefolder = "/home/simon/Work/Projects/Simulations/remote";
my $remotefilename = "controlscripts/checkSimulationStatus.pl";
my $localfilepath = "/Users/simon/Documents/MATLAB/runMatlabCodeOnRechenknecht/forServer";
my $cmd;
my @cmdoutput;

#$cmd = "scp $localfilepath/$remotefilename nyquist.isip.uni-luebeck.de:$remotefolder/controlscripts/"; #print "$cmd\n";
#@cmdoutput = `$cmd 2>&1`; print "@cmdoutput";

$cmd = "ssh -n nyquist.isip.uni-luebeck.de \"cd $remotefolder ; ./$remotefilename @ARGV \""; #print "$cmd\n";
@cmdoutput = `$cmd 2>&1`; print " @cmdoutput";

