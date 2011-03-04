#!/usr/bin/perl -w

use strict;	# Make us need to declare each variable for easier error tracking
use Cwd;

my $cmd;
my @cmdoutput;
my $cwd = cwd;

my $hostname = `hostname`;
chomp($hostname);
print " Welcome to $hostname!\n";
print " Working in $cwd\n";

$cmd = "date +%F_%H.%M.%S.%N";
my $nowstring = `$cmd 2>&1`;
if ($?) {print "\n$nowstring\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
chomp($nowstring);
my $folder = "./singletrials/${nowstring}-singletrial";

$cmd = "mkdir -p $folder";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

$cmd = "mv m-files.tgz $folder";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

$cmd = "mkdir $folder/codeandinputdata \n mkdir $folder/results";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

$cmd = "tar xzf $folder/m-files.tgz -C $folder/codeandinputdata/";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

$cmd = "cat ./controlscripts/header.m $folder/codeandinputdata/remoteCommand.m ./controlscripts/footer.m > $folder/codeandinputdata/remoteMain.m";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

chdir("$folder/codeandinputdata");
print " Now in folder " . cwd . "\n";

#sleep(5);

$cmd = "nohup /usr/local/bin/matlab -nodisplay -r remoteMain.m > ../results/screenoutput.txt  2> ../results/screenerrors.txt &";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

#sleep(5);

$cmd = "cat /proc/cpuinfo | grep processor | tail -n 1"; #print " $cmd\n";
my $cpus = `$cmd 2>&1`; if ($?) {print "\n$cpus\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
if ($cpus =~ m/(\d+)/) {$cpus = $1+1;}
#print "CPUs: $cpus \n";

$cmd = "ps | grep 'matlab'"; #print " $cmd\n";
my $pid = `$cmd 2>&1`; if ($?) {print "\n$pid\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
chomp($pid);
#print "PID: $pid \n";
if ($pid =~ m/^(\d+)/) {$pid = "$1";} else {$pid="unknown";}
#print "PID: $pid \n";

$cmd = "echo '$hostname ($cpus cores), PID $pid' > ../results/hostnamepid.txt ; ps | grep -i 'matlab' >> ../results/hostnamepid.txt";
print " $cmd\n";
@cmdoutput = `$cmd 2>&1`;
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
print "@cmdoutput";

