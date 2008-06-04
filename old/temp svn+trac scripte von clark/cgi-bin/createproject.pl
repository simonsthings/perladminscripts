#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $svnroot = "/srv/svn/repos";
my $tracroot = "/srv/trac";
my $cmd;
my $cmdoutput;

my @Feldnamen = $cgi->param();

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>Project Creation</title></head><body >\n";
print "<h1>Creating ISIP Software Project</h1>\n";
print "<h2>Listing Inputs...</h2>\n";
foreach my $Feld (@Feldnamen) 
{
	print "<b>$Feld: </b><br>\n";
	print $cgi->param($Feld),"<br><br>\n\n";
}

my $NiceName = $cgi->param('NiceName');
my $UnixName = $cgi->param('UnixName');
my $ProjectDescription = $cgi->param('Kommentartext');

print "<h2>Creating Subversion repository...</h2>\n";
	$cmd = "svnadmin create $svnroot/$UnixName";
	print "<code>$cmd</code><br>\n";
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

print "<h2>Creating Trac project...</h2>\n";
	$cmd = "trac-admin $tracroot/$UnixName/ initenv \"" . $NiceName . "\" sqlite:db/trac.db svn $svnroot/$UnixName";
	print "<code>$cmd</code><br>\n";
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

print "<h2>Finished!</h2>\n";
print "Please check the screen output above to see if there were any errors.<br>\n";
print "<br>\n";
print "You may now access your new trac project at http://clark/$UnixName .<br>\n";
print "Your Subversion repository is available under svn://clark/$UnixName .<br>\n";
print "</body></html>\n";

