#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $svnroot = "/srv/svn/repos";
my $tracroot = "/srv/trac";
my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>Project Creation</title></head><body >\n";
print "<h1>Starting stand-alone servers!</h1>\n";

my $projectunixname = $cgi->param('projectunixname');
my $svnport = $cgi->param('svnport');
my $tracdport = $cgi->param('tracdport');

print "<h2>Starting SVNServe...</h2>\n";
	$cmd = "svnserve -d --listen-port $svnport -r $svnroot/$projectunixname";
	print "<code>$cmd</code><br>\n";
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

print "<h2>Starting Trac daemon...</h2>\n";
	$cmd = " tracd --port $tracdport $tracroot/$projectunixname/ -d -s";
	print "<code>$cmd</code><br>\n";
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	print "Careful: Tracd doesn't complain if the port is already in use!";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

print "<h2>Finished!</h2>\n";
print "Please check the screen output above to see if there were any errors.<br>\n";
print "<br>\n";
my $traclink = "http://clark:$tracdport";
my $svnlink = "svn://clark:$svnport";
print "You may now access your new trac project at <a href='$traclink'>$traclink</a> .<br>\n";
print "Your Subversion repository is available under <a href='$svnlink'>$svnlink</a> (maybe) .<br>\n";
print "</body></html>\n";

