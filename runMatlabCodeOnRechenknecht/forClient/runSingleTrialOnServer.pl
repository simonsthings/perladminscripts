#!/usr/bin/perl -w

use strict;           # Make us need to declare each variable for easier error tracking
use Cwd;

my $remotefolder = "/home/simon/Work/Projects/Simulations/remote/";
my $cmd;
my @cmdoutput;
my $currDir = cwd;

# compress all .m-files:
print "Packaging all m-files in $currDir...\n";
$cmd = "tar czvf m-files.tgz *.m";
@cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page. 
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why.\n';};
#print "@cmdoutput";
print "The m-files have been packaged to 'm-files.tgz'\n\n";

my ($nextServer,$minLoad);
if ($ARGV[0] ne "")
{
    # use given server
    $nextServer = $ARGV[0];
    $minLoad = "unknown";
    print "Using given server: $ARGV[0] \n";
}
else
{
    # find free server:
    ($nextServer,$minLoad) = findNextServer();
    print "Detected free server (load: $minLoad%): $nextServer \n";
}

# Send .tgz file to server:
my $serverURI = "$nextServer.isip.uni-luebeck.de:$remotefolder";
$cmd = "scp m-files.tgz $serverURI";
print "Uploading m-files.tgz package to $serverURI ...\n";
@cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page. 
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why.\n';};
print "@cmdoutput";
print "Upload seems to have been successful!\n\n";

# execute script on server:
$cmd = "ssh -n $nextServer.isip.uni-luebeck.de \"cd $remotefolder ; controlscripts/run_singletrail.pl\" ";
print "Executing startup script on the server ...\n";
@cmdoutput = `$cmd 1>&2`;  # The 2>&1 makes all screen output be written to the web page. 
if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why.\n';};
#print "@cmdoutput";
#print "\n";
print "The simulation seems to have been started successfully!\n";

## End of script. ##

## Helper functions: ##
sub findNextServer
{

    my $cmd = "ssh -n nyquist.isip.uni-luebeck.de \"tail -n 1 /mnt/raid/projects/auslastung/*.csv\"";    # define unix shell command to execute
    my @lines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
    if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

    my $currentServer="none";  # temporary during loop
    my $nextServer="none";     # will contain final server
    my $minLoad=100;    # load of final server
    foreach my $line (@lines)
    {
        # find current server:
        if ($line =~ m/==> \/mnt\/raid\/projects\/auslastung\/(\w*).csv <==/)
        {
        $currentServer = $1;
        }

        # check if this is better than last:
        if ($line =~ m/^(\d+\.\d+)\s.*/)
        {
            if ( ($1 < $minLoad) && ($currentServer ne "shannon") && ($currentServer ne "fermi") && ($currentServer ne "euler") && ($currentServer ne "cauchy") )
        {
            #print "NEW MIN LOAD!";
            $minLoad = $1;
                $nextServer = $currentServer;
            }
        }

        #print "current server is: $currentServer\n";
        #print "   next server is: $nextServer\n";
        #print "  minimum load is: $minLoad\n";
    }
    return $nextServer, $minLoad;
}
