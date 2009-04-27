#!/usr/bin/perl -w


use strict;           # Make us need to declare each variable for easier error tracking
use CGI;              # Use GCI interface (as found in some examples on the internet)
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);   # I guess this sends any error messages to the browser.

# declare my variables:
my $svnroot = "/srv/repositories/svn";
my $tracroot = "/srv/trac";
my $cmd;
my $cmdoutput;
my $OwnerName = "Own";
my $NiceName = "NN";

$cmd = "ls -1A $svnroot/";    # define unix shell command to execute
my @svnrepos = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
#print "<code>$cmd</code><br>\n";
#print "<i><font color='gray'><pre>";
#foreach my $outputline (@svnrepos) 
#{
#	print $outputline ;
#}
#print "</pre></font></i>\n";


# send web page header to browser:
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head>";
print "<meta http-equiv='refresh' content='10'>";
print "<title>Start Trac and SVN server</title></head><body bgcolor='#FFFFFF'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<center>";
print "<h1>Accessing your SVN repository</h1>\n";
print "Here is the URL you need to give your SVN client so that it can access the Subversion repository:<br>\n";
print "<br>";
print "<font color='grey'>( Copy&Paste the <b>SVN client URL</b> to your svn client. )</font><br>\n";
print "<br><br>";

#print "jzgfghfbbbbbbbbbbbbbbbbbbbbbbbfhzuti<br>";
print "<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 width='100%'>";
print "<TR ALIGN='middle' VALIGN='middle' bgcolor='#6b7f93' text='#ffffff' >    <TH><font color='white'>Project Name</font></TH>  <TH><font color='white'>SVN client URL</font></TH>  <TH><font color='white'>Project Owner</font></TH>    </TR>";
my $tablerowbgcolor = "#ffffff";
my @ownerfilelines;
foreach my $UnixName (@svnrepos) 
{
	chomp($UnixName);
	
	#print "   $svnroot/$UnixName/owner.txt <br>\n";
	
	open(SETTINGSFILE, "<$svnroot/$UnixName/ISIPsettings.conf");	# Open for reading
	@ownerfilelines = <SETTINGSFILE>;
	chomp(@ownerfilelines);
	$OwnerName = @ownerfilelines[2];   # line 3 of the file
	$NiceName = @ownerfilelines[3];    # line 4 of the file
	close (SETTINGSFILE);
	
	print "<TR ALIGN='middle' VALIGN='middle' bgcolor='$tablerowbgcolor'>";
	print "<TD>$NiceName&nbsp;&nbsp;&nbsp;&nbsp;</TD>    <TD align='left'>https://sourcecode.isip.uni-luebeck.de/svn/$UnixName</TD>    <TD>$OwnerName</TD>";
	print "</TR>";
	
	if ($tablerowbgcolor eq "#edf4f9")
	{
		$tablerowbgcolor = "#ffffff";
	}
	else
	{
		$tablerowbgcolor = "#edf4f9"
	}
}
print "</TABLE>";


print "</center>";
print "</font>";
print "</body></html>\n";
