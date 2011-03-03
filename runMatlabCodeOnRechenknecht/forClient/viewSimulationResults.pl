#!/usr/bin/perl -w

use strict;           # Make us need to declare each variable for easier error tracking
#use Cwd;
#my $currDir = cwd;

my $remotefolder = "/home/simon/Work/Projects/Simulations/remote";
my $remotefilename = "controlscripts/packWebView.pl";
my $localServerscriptPath = "/Users/simon/Documents/MATLAB/runMatlabCodeOnRechenknecht/forServer";
my $localResultsPath = "/Users/simon/Documents/MATLAB/rechenknechtWebViewResults";
my $simtype = "singletrials";
my $cmd;
my @cmdoutput;

print "Packing & Fetching simulation results from server. \n";

#$cmd = "scp $localServerscriptPath/$remotefilename nyquist.isip.uni-luebeck.de:$remotefolder/controlscripts/"; #print "$cmd\n";
#@cmdoutput = `$cmd 2>&1`; print "@cmdoutput";

$cmd = "ssh -n nyquist.isip.uni-luebeck.de \"cd $remotefolder ; ./$remotefilename @ARGV \""; #print "$cmd\n";
@cmdoutput = `$cmd 1>&2`; #print " @cmdoutput";
if ($?) {die ("ERROR: The remote script execution failed! Please check what went wrong!\n");};

$cmd = "scp nyquist.isip.uni-luebeck.de:$remotefolder/webview/${simtype}_webview.tgz $localResultsPath/"; #print "$cmd\n";
@cmdoutput = `$cmd 2>&1`; print "@cmdoutput";

$cmd = "tar xzf $localResultsPath/${simtype}_webview.tgz -C $localResultsPath/"; #print "$cmd\n";
@cmdoutput = `$cmd 2>&1`; print "@cmdoutput";

print "Opening results in web browser: $localResultsPath/webview/$simtype/index.html !\n";
print " \n";

# Works on Mac (linux not tested):
$cmd = "open $localResultsPath/webview/$simtype/index.html"; #print "$cmd\n";
@cmdoutput = `$cmd 1>&2`; #print "@cmdoutput";

