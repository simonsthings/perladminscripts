#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

use DBI;    
my $dbargs = {AutoCommit => 0,
              PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=../db/iteminfos.db","","",$dbargs);
    if ($dbh->err()) { die "$DBI::errstr\n"; }
        

my $itemroot = "/var/www/inventory/items";

my $cmd;
my $cmdoutput;

my $cgi_item_uniqueID = $cgi->param('itemID');

#my @itemrow = $dbh->selectrow_array("SELECT item_name FROM items WHERE item_folder='$item_folder';");
#my $item_name = @itemrow[0];

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker - Complete History</title></head>";
print "<body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";


# History:
if ($cgi_item_uniqueID eq "")
{
    ## Stand-alone mode:
    print "<h1>Viewing complete History of all items</h1>\n";
    print "<u>Item History:</u><br>";
    my $historystatement = $dbh->prepare("SELECT history_itemuniqueid,history_operation,history_otheritemid,history_operationtime,history_xmlblob,hop_nicename,thisitem.item_name,otheritem.item_name FROM history LEFT JOIN history_operations ON history_operation=hop_operation LEFT JOIN items AS thisitem ON thisitem.item_uniqueID=history_itemuniqueid LEFT JOIN items AS otheritem ON otheritem.item_uniqueID=history_otheritemid ORDER BY history_operationtime DESC ;");
    if ($historystatement->err()) { die "Cannot prepare statement: $DBI::errstr\n"; }                                                                                                                                     
    $historystatement->execute();

    print "<table border=1 cellpadding=2 cellspacing=0>";
    while ( (my $history_itemuniqueid, my $history_operation,my $history_otheritemid, my $history_operationtime, my $history_xmlblob, my $historyop_nicename, my $item_name, my $otheritem_name)  = $historystatement->fetchrow())
    {
	my $otheritemhtml="";
	if ($history_otheritemid ne "")
	{
	    if ($otheritem_name ne "")
	    {
		$otheritemhtml = ", affecting <a href='itemmenu.pl?itemID=$history_otheritemid'> $otheritem_name</a>";
	    }
	    else
	    {
		$otheritemhtml = ", affecting $history_otheritemid";
	    }	    
	}
    
        my $timestring = scalar( localtime($history_operationtime));
	if ($item_name eq "")
	{
	    print "<tr><td align=center title='ID of deleted item'>$history_itemuniqueid $otheritemhtml</td><th nowrap>$timestring</th><th nowrap title=\"$history_operation\">$historyop_nicename</th> $history_xmlblob </tr>";
	}
	else
	{
	    print "<tr><td nowrap align=center title='Item Name'><a title='Item ID: $history_itemuniqueid' href=itemmenu.pl?itemID=$history_itemuniqueid> $item_name </a>$otheritemhtml</td><th nowrap>$timestring</th><th nowrap title=\"$history_operation\">$historyop_nicename</th> $history_xmlblob </tr>";
	}
    }
    $historystatement->finish();
    print "</table>";
    
}
else
{
    ## iFrame in itemmenu.pl
    my $historystatement = $dbh->prepare("SELECT history_itemuniqueid,history_operation,history_operationtime,history_xmlblob,hop_nicename FROM history LEFT JOIN history_operations ON history_operation=hop_operation WHERE history_itemuniqueid = ? ORDER BY history_operationtime DESC ;");
    if ($historystatement->err()) { die "Cannot prepare statement: $DBI::errstr\n"; }                                                                                                                                     
    $historystatement->execute($cgi_item_uniqueID);
    
    print "<table border=1 frame=box rules=all cellpadding=2 cellspacing=0>";
    while ( (my $history_itemuniqueid, my $history_operation, my $history_operationtime, my $history_xmlblob, my $historyop_nicename)  = $historystatement->fetchrow())
    {
        my $timestring = scalar( localtime($history_operationtime));
        print "<tr><th nowrap>$timestring</th><th nowrap title=\"$history_operation\">$historyop_nicename</th> $history_xmlblob </tr>";
    }
    $historystatement->finish();
    print "</table>";

}




$dbh->disconnect();


#print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
#print "<a href='/#$item_folder'> Redirecting to Main Menu ... </a> <br>\n";

print "</font></body></html>\n";
