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
print " Welcome to $hostname!\n";
print " Working in $cwd\n";

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
my @subfolders = `$cmd 2>&1`;
if ($?) {print "\n@subfolders\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print " @subfolders";
chomp(@subfolders);
my @simstartdates;
my @simstarttimes;
my @simstatuses;
#foreach my $subfolder (@subfolders)
for (my $i = 0; $i <= $#subfolders; $i++)
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
	    $simstatus = "still running... <br>"; 
	
    	    my $cmd4 = "tail -n 3 ./$simtype/$subfolder/results/screenoutput.txt"; #print "${cmd4}\n";
    	    my @cmdoutput4 = "lala";
    	    @cmdoutput4 = `$cmd4 2>&1`;
    	    if ($?) {print "\n@{cmdoutput4}\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    	    chomp(@cmdoutput4);
    	    if ( (@cmdoutput4) && ($cmdoutput4[0] =~ m/((remaining): (.*))\s*/) ) { $simstatus .= "($3 $2)"; }
    	    else {$simstatus .= "(no data on remaining time available yet)";}
        
    	    #print " @{cmdoutput4}";
	}
	else
	{
	    $simstatus = "error! <br> (see below)";
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
print " Generating html summary file... ";

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

print SUMMARYFILE "<table border=1 rules='all' frame='outer' cellspacing=0 cellpadding=0><tr>\n";
# headers:
for (my $i = ($#subfolders); $i >= 0; $i--)
{
    print SUMMARYFILE "<th border=0> $simstartdates[$i] <br> $simstarttimes[$i] </th>\n";
}
print SUMMARYFILE "</tr><tr>\n";
for (my $i = ($#subfolders); $i >= 0; $i--)
{
    print SUMMARYFILE "<th> $simstatuses[$i] </th>\n";
}
print SUMMARYFILE "</tr><tr>\n";
# data:
for (my $i = ($#subfolders); $i >= 0; $i--)
{
    my $fullscreenlink = generateFullscreen(\@subfolders,$i,\@simstartdates,\@simstarttimes,\@simstatuses);
    my $iframelink = generateiFrame(\@subfolders,$i);
    
    print SUMMARYFILE "<td>";
    print SUMMARYFILE "<center><a href='$fullscreenlink'>View full screen...</a></center> ";
    print SUMMARYFILE "<iframe src='$iframelink' frameborder=0 width=300 height=400 > no iframe support? </iframe>";
    print SUMMARYFILE "</td>\n";
}

print SUMMARYFILE "</tr></table>\n\n";

my $timestring = scalar( localtime(time));
print SUMMARYFILE "This page was generated at $timestring .<br>\n";
print SUMMARYFILE "</body></html>\n";
close(SUMMARYFILE);

print "Done.\n";


## Pack into tgz archive for transfer ##
print " Now packaging into ${simtype}_webview.tgz for transfer... ";

$cmd = "tar czf ./webview/${simtype}_webview.tgz ./webview/$simtype"; #print "$cmd\n";
@cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
#print "@cmdoutput";

print "Done.\n";


## End of script! ##


## Helper Functions: ##
sub generateFullscreen
{
    my ($subfolders_ref,$i,$simstartdates_ref,$simstarttimes_ref,$simstatuses_ref) = @_;
    my @subfolders = @$subfolders_ref;
    my @simstartdates = @$simstartdates_ref;
    my @simstarttimes = @$simstarttimes_ref;
    my @simstatuses = @$simstatuses_ref;
    
    open(FULLSCREENFILE, "> ./webview/$simtype/$subfolders[$i]/fullscreen.html") or die "Can't write to file ./webview/$simtype/index.html: $!";

    # Make HTML header:
    print FULLSCREENFILE '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
    print FULLSCREENFILE "<html><head><title>$simtype Simulation Results</title>";
    #print OUTKFILE "<meta HTTP-EQUIV=\"REFRESH\" content=\"2; url=/$mainmenucache#$ENV{QUERY_STRING}\">";
    print FULLSCREENFILE "</head><body link='#000000' vlink='#000000' alink='blue' bgcolor='#E0E0E0'>\n";
    print FULLSCREENFILE "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
    
    print FULLSCREENFILE "<h1>Viewing trial: $simstartdates[$i], $simstarttimes[$i] </h1>";
    print FULLSCREENFILE "<h3>Status: $simstatuses[$i]</h3>";

    if ($simstatuses[$i] eq "finished!")
    {
	print FULLSCREENFILE "To access the results, type: <pre>rm ./RemoteResults/* ; scp nyquist.isip.uni-luebeck.de:$cwd/$simtype/$subfolders[$i]/results/* ./RemoteResults </pre>";
    }
    
    # HTML table
    #print FULLSCREENFILE "<table border=0 ><tr><td valign='top'>";

    ## Images:
    print FULLSCREENFILE "<h2>Images:</h2>\n";    
    $cmd = "cd ./webview/$simtype/$subfolders[$i]/; ls -1 *.png"; #print "$cmd\n";
    my @imagefiles = `$cmd 2>&1`; 
    if ($?) 
    {
	print FULLSCREENFILE "No images (yet)... <br><br>";
	## just ignore if no images were found..
	#print "\n$!"; 
	#die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';
    }
    else
    {
	chomp(@imagefiles);
	#print FULLSCREENFILE "@imagefiles";
	foreach my $imagefile (@imagefiles)
	{
	    print FULLSCREENFILE "<a name='$imagefile'></a><img src='./$imagefile' > <br>";
	    print FULLSCREENFILE "$imagefile <br><br>\n";
	}
    }

    # HTML table
    #print FULLSCREENFILE "</td><td valign='top'>";

    ## Errors:
    $cmd = "cat ./webview/$simtype/$subfolders[$i]/screenerrors.txt"; #print "$cmd\n";
    my @anyerrors = `$cmd 2>&1`; if ($?) {print "\n@anyerrors\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    #print "@anyerrors";
    print FULLSCREENFILE "<h2>Errors:</h2>";    
    if ("@anyerrors" ne "")
    {
	print FULLSCREENFILE "<pre>@anyerrors</pre>"; 
    }
    else
    {
	print FULLSCREENFILE "No Errors (yet)...<br><br>";
    }

    ## Screen Outputs:
    print FULLSCREENFILE "<h2>Screen Outputs:</h2>";
    $cmd = "cat ./webview/$simtype/$subfolders[$i]/screenoutput.txt"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print FULLSCREENFILE "<pre>@cmdoutput</pre>"; 

    ## Server & PID:
    print FULLSCREENFILE "<h2>Server and PID:</h2>\n";
    $cmd = "cat ./$simtype/$subfolders[$i]/results/hostnamepid.txt"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print FULLSCREENFILE "<pre>@cmdoutput</pre>"; 
    print FULLSCREENFILE "To access the results, type: <pre>scp nyquist.isip.uni-luebeck.de:$cwd/$simtype/$subfolders[$i]/results/results.mat . </pre>";

    
    # HTML table
    #print FULLSCREENFILE "</td></tr></table>";
    
    close FULLSCREENFILE;
    
    return "./$subfolders[$i]/fullscreen.html";
}

sub generateiFrame
{
    my ($subfolders_ref,$i) = @_;
    my @subfolders = @$subfolders_ref;
    
    open(IFRAMEFILE, "> ./webview/$simtype/$subfolders[$i]/iframe.html") or die "Can't write to file ./webview/$simtype/index.html: $!";

    # Make HTML header:
    print IFRAMEFILE '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
    print IFRAMEFILE "<html><head><title>Simulation Results</title>";
    #print OUTKFILE "<meta HTTP-EQUIV=\"REFRESH\" content=\"2; url=/$mainmenucache#$ENV{QUERY_STRING}\">";
    print IFRAMEFILE "</head><body link='#000000' vlink='#000000' alink='blue' bgcolor='#E0E0E0'>\n";
    print IFRAMEFILE "<font size=2>";# FACE='Helvetica, Arial, Verdana, Tahoma'>";
    
    #print IFRAMEFILE "i=$i,<br> $subfolders[$i]";
    #print IFRAMEFILE "Status: lala";

    # HTML table
    #print IFRAMEFILE "<table border=0 ><tr><td valign='top'>";

    ## Simulation Commands:
    print IFRAMEFILE "<b>Simulation Command:</b><br>\n";
    $cmd = "cat ./$simtype/$subfolders[$i]/codeandinputdata/remoteCommand.m"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print IFRAMEFILE "<pre>@cmdoutput</pre>"; 


    ## Images:
    print IFRAMEFILE "<b>Images:</b><br>\n";    
    $cmd = "cd ./webview/$simtype/$subfolders[$i]/; ls -1 *.png"; #print "$cmd\n";
    my @imagefiles = `$cmd 2>&1`; 
    if ($?) 
    {
	## just ignore if no images were found..
	#print "\n$!"; 
	#die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';
	print IFRAMEFILE "No images (yet)...<br><br>";
    }
    else
    {
	chomp(@imagefiles);
	#print IFRAMEFILE "@imagefiles";
	foreach my $imagefile (@imagefiles)
	{
	    print IFRAMEFILE "<a href='fullscreen.html#$imagefile' target='_top'><img src='./$imagefile' width=250 ></a><br>";
	    print IFRAMEFILE "$imagefile <br><br>\n";
	}
    }

    # HTML table
    #print IFRAMEFILE "</td><td valign='top'>";

    ## Errors:
    $cmd = "cat ./webview/$simtype/$subfolders[$i]/screenerrors.txt"; #print "$cmd\n";
    my @anyerrors = `$cmd 2>&1`; if ($?) {print "\n@anyerrors\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    #print "@anyerrors";
    print IFRAMEFILE "<b>Errors:</b><br>";    
    if ("@anyerrors" ne "")
    {
	print IFRAMEFILE "<pre>@anyerrors</pre><br>"; 
    }
    else
    {
	print IFRAMEFILE "No Errors (yet)...<br><br>";
    }

    ## Screen Outputs:
    print IFRAMEFILE "<b>Screen Outputs:</b><br>";
    $cmd = "cat ./webview/$simtype/$subfolders[$i]/screenoutput.txt"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print IFRAMEFILE "<pre>@cmdoutput</pre>"; 

    ## Server & PID:
    print IFRAMEFILE "<b>Server and PID:</b><br>\n";
    $cmd = "cat ./$simtype/$subfolders[$i]/results/hostnamepid.txt"; #print "$cmd\n";
    @cmdoutput = `$cmd 2>&1`; if ($?) {print "\n@cmdoutput\n"; die 'ERROR: It seems that the above command has not worked! Read the screen output to find out why';};
    print IFRAMEFILE "<pre>@cmdoutput</pre>"; 
    print IFRAMEFILE "The results were stored in the file nyquist.isip.uni-luebeck.de:$cwd/$simtype/$subfolders[$i]/results/results.mat .";

    
    # HTML table
    #print IFRAMEFILE "</td></tr></table>";
    
    
    close IFRAMEFILE;
    
    return "./$subfolders[$i]/iframe.html";
}



