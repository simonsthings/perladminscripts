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

 if (!(defined $item_state)){$item_state = "Functional";}
 
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>ISIP Inventory: Saving Item!</h1>\n";

 print "the item_folder: $item_folder <br>\n";
  print "the item_basedon: $item_basedon <br>\n";
 print "the item_name: $item_name <br>\n";
 print "the item_description: $item_description <br>\n";
  print "the item_state: $item_state <br>\n";
 print "the item_wikiurl: $item_wikiurl <br>\n";
  print "the item_room: $item_room <br>\n";
 print "the item_shelf: $item_shelf <br>\n";
 print "the item_currentuser: $item_currentuser <br>\n";
 print "the item_invoicedate: $item_invoicedate <br>\n";
 print "the item_inventorynumber: $item_inventorynumber <br>\n";
  print "the item_category: $item_category <br>\n";
 
#my $rc = $dbh->do("INSERT INTO items (item_folder,based_on_folder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,current_user,item_invoicedate,item_uniinvnum,item_category) VALUES ('$item_folder','$item_basedon','$item_name','$item_description','$item_state','$item_wikiurl','$item_room','$item_shelf','$item_currentuser','$item_invoicedate','$item_inventorynumber','$item_category') ;");

my $rc = $dbh->do("UPDATE items SET based_on_folder = '$item_basedon',item_name='$item_name',item_description='$item_description',item_state='$item_state',item_wikiurl='$item_wikiurl',item_room='$item_room',item_shelf='$item_shelf',current_user='$item_currentuser',item_invoicedate='$item_invoicedate',item_uniinvnum='$item_inventorynumber',item_category='$item_category' WHERE item_folder = '$item_folder' ;");

$dbh->commit();

$dbh->disconnect();

print "<br>saved.<br><br>";

print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
print "<a href='/'> back to list </a> <br>\n";

print "</body></html>\n";
