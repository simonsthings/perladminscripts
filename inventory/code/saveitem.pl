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

#my $item_folder = $cgi->param('itemfolder');

my $cmd;
my $cmdoutput;


my $item_folder = "left empty";
my $item_basedon = "left empty";
my $item_name = "left empty";
my $item_description = "left empty";
my $item_state = "left empty";
my $item_wikiurl = "left empty";
my $item_room = "left empty";
my $item_shelf = "left empty";
my $item_currentuser = "left empty";
my $item_invoicedate = "left empty";
my $item_inventorynumber = "left empty";
my $item_category = "left empty";
my $item_versionnumber = "left empty";
my $item_serialnumber = "left empty";

 $item_folder 		= $cgi->param('item_folder');
 $item_basedon 		= $cgi->param('item_basedon');
 $item_name 		= $cgi->param('item_name');
 $item_description 	= $cgi->param('item_description');
 $item_state 		= $cgi->param('item_state');
 $item_wikiurl 		= $cgi->param('item_wikiurl');
 $item_room 		= $cgi->param('item_room');
 $item_shelf 		= $cgi->param('item_shelf');
 $item_currentuser 	= $cgi->param('item_currentuser');
 $item_invoicedate 	= $cgi->param('item_invoicedate');
 $item_inventorynumber 	= $cgi->param('item_inventorynumber');
 $item_category 	= $cgi->param('item_category');
 $item_versionnumber	= $cgi->param('item_versionnumber');
 $item_serialnumber 	= $cgi->param('item_serialnumber');

 if (!(defined $item_state)){$item_state = "Functional";}
 
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head>";
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0.5; url=/#$item_folder\"><body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<h1>ISIP Inventory: Saving Item...</h1>\n";

#print "saving...<br><br>";

print "<font color='grey'> item_folder:</font> 	$item_folder <br>\n";
print "<font color='grey'> item_basedon:</font> 	$item_basedon <br>\n";
print "<font color='grey'> item_name:</font> 		$item_name <br>\n";
print "<font color='grey'> item_description:</font> $item_description <br>\n";
print "<font color='grey'> item_state:</font> 		$item_state <br>\n";
print "<font color='grey'> item_wikiurl:</font> 	$item_wikiurl <br>\n";
print "<font color='grey'> item_room:</font> 		$item_room <br>\n";
print "<font color='grey'> item_shelf:</font> 		$item_shelf <br>\n";
print "<font color='grey'> item_currentuser:</font> $item_currentuser <br>\n";
print "<font color='grey'> item_invoicedate:</font> $item_invoicedate <br>\n";
print "<font color='grey'> item_inventorynumber:</font> $item_inventorynumber <br>\n";
print "<font color='grey'> item_category:</font> 	$item_category <br>\n";
print "<font color='grey'> item_versionnumber:</font> $item_versionnumber <br>\n";
print "<font color='grey'> item_serialnumber:</font> $item_serialnumber <br>\n";
 
#my $rc = $dbh->do("INSERT INTO items (item_folder,based_on_folder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,current_user,item_invoicedate,item_uniinvnum,item_category) VALUES ('$item_folder','$item_basedon','$item_name','$item_description','$item_state','$item_wikiurl','$item_room','$item_shelf','$item_currentuser','$item_invoicedate','$item_inventorynumber','$item_category') ;");

my $rc = $dbh->do("UPDATE items SET item_linkedfolder = '$item_basedon',item_name='$item_name',item_description='$item_description',item_state='$item_state',item_wikiurl='$item_wikiurl',item_room='$item_room',item_shelf='$item_shelf',item_currentuser='$item_currentuser',item_invoicedate='$item_invoicedate',item_uniinvnum='$item_inventorynumber',item_category='$item_category',item_versionnumber='$item_versionnumber',item_serialnumber='$item_serialnumber' WHERE item_folder = '$item_folder' ;");

$dbh->commit();

$dbh->disconnect();

print "<br>saved.<br><br>";

#print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
print "<a href='/#$item_folder'> Redirecting to Main Menu ... </a> <br>\n";

print "</body></html>\n";
