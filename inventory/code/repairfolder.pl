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
print "<body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<h1>ISIP Inventory: Repair missing folder...</h1>\n";

# NewItem ComboBox
my $selnewitems = $dbh->prepare("SELECT item_name,item_folder FROM items WHERE item_category=0 ;");
if ($selnewitems->err()) { die "$DBI::errstr\n"; }
$selnewitems->execute();
my $newItemsComboBox = "<select name='A_new_folder' size='1'>\n";
while(my @row = $selnewitems->fetchrow_array())
{
	if (@row[1] eq @row[0])
	{$newItemsComboBox .= "<option value=@row[1]>@row[1]</option>\n";}
	else
	{$newItemsComboBox .= "<option value=@row[1]>@row[1] (\"@row[0]\")</option>\n";}
}
$newItemsComboBox .= "</select>";


# AllItems ComboBox
my $selallitems = $dbh->prepare("SELECT item_name,item_folder FROM items ;");
if ($selallitems->err()) { die "$DBI::errstr\n"; }
$selallitems->execute();
my $allItemsComboBox = "<select name='D_new_folder' size='1'>\n";
while(my @row = $selallitems->fetchrow_array())
{
	if (@row[1] eq @row[0])
	{$allItemsComboBox .= "<option value=@row[1]>@row[1]</option>\n";}
	else
	{$allItemsComboBox .= "<option value=@row[1]>@row[1] (\"@row[0]\")</option>\n";}
}
$allItemsComboBox .= "</select>";



print "<h3>So, what happened to it? Do you know?</h3>\n";
print "<form action='/style/notimplemented.html' method='get'>\n";
print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";
print "<tr><td bgcolor='white'><input type='radio' name='item_state' value='A'> I renamed it to: $newItemsComboBox. The existing item for that folder will be deleted!</td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='item_state' value='B'> I deleted it by accident and want to create a new empty folder! </td></tr>";
print "<tr><td bgcolor='white'><input type='radio' name='item_state' value='C' disabled> I deleted it on purpose and want to delete this item from the database! Only possible for uncategorised items! An email will be sent to the system administrator.
 </td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='item_state' value='D'> I want to make a copy of $allItemsComboBox! </td></tr>";
print "<tr><td bgcolor='white'><input type='radio' name='item_state' value='E' disabled> I want to link this item to the folder ComboBox! A new empty folder for this item will still be created.
 </td></tr>";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "";
print "</table>";
# Save button:
print "    <br><input type='submit' value='Repair!'>";
print "	<a href='/#$item_folder'>Cancel</a>";
# End of form
print "</form>";

#$dbh->commit();

$dbh->disconnect();


#print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
#print "<a href='/#$item_folder'> Redirecting to Main Menu ... </a> <br>\n";

print "</body></html>\n";
