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

my @itemrow = $dbh->selectrow_array("SELECT item_name,item_folder FROM items WHERE item_uniqueID='$cgi_item_uniqueID';");
my $item_name = @itemrow[0];
my $item_folder = @itemrow[1];

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head>";
print "<body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<h1>Repair missing folder...</h1>\n";
print "The photo folder \"$item_folder\" for item <i>$item_name</i> was not found.";


# Action A ComboBox: New Items
my $selnewitems = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items WHERE item_category=0 ;");
if ($selnewitems->err()) { die "$DBI::errstr\n"; }
$selnewitems->execute();
my $actionAComboboxNewItems = "<select name='actionA_itemID' size='1'>\n";
while(my @row = $selnewitems->fetchrow_array())
{
    if (@row[2] != $cgi_item_uniqueID)
    {
	if (@row[1] eq @row[0])
	{$actionAComboboxNewItems .= "<option value=@row[2]>@row[1]</option>\n";}
	else
	{$actionAComboboxNewItems .= "<option value=@row[2]>@row[1] (\"@row[0]\")</option>\n";}
    }
}
$actionAComboboxNewItems .= "</select>";


# Action D ComboBox: All Items
my $selallitems = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items ;");
if ($selallitems->err()) { die "$DBI::errstr\n"; }
$selallitems->execute();
my $actionCComboboxAllItems = "<select name='actionC_folder' size='1'>\n";
while(my @row = $selallitems->fetchrow_array())
{
	if (@row[1] eq @row[0])
	{$actionCComboboxAllItems .= "<option value=@row[1]>@row[1]</option>\n";}
	else
	{$actionCComboboxAllItems .= "<option value=@row[1]>@row[1] (\"@row[0]\")</option>\n";}
}
$actionCComboboxAllItems .= "</select>";

# Action E ComboBox: All Items
my $selallitems = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items ;");
if ($selallitems->err()) { die "$DBI::errstr\n"; }
$selallitems->execute();
my $actionDComboboxAllItems = "<select disabled name='actionD_folder' size='1'>\n";
while(my @row = $selallitems->fetchrow_array())
{
	if (@row[1] eq @row[0])
	{$actionDComboboxAllItems .= "<option value=@row[1]>@row[1]</option>\n";}
	else
	{$actionDComboboxAllItems .= "<option value=@row[1]>@row[1] (\"@row[0]\")</option>\n";}
}
$actionDComboboxAllItems .= "</select>";



print "<h3>So, what happened to it? Do you know?</h3>\n";
print "<form action='/folderoperations.pl' method='get'>\n";
print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";
print "<tr><td bgcolor='white'><input type='radio' name='repairaction' value='A'> I renamed it to: $actionAComboboxNewItems. The existing item for that folder will be deleted!</td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='repairaction' value='B'> I deleted it by accident and want to create a new empty folder! </td></tr>";
print "<tr><td bgcolor='white'><input type='radio' name='repairaction' value='C'> I want to make a copy of $actionCComboboxAllItems! </td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='repairaction' value='D' disabled> I want to link this item to the folder $actionDComboboxAllItems! A new empty folder for this item will still be created. </td></tr>";
print "<tr><td bgcolor='white'><input type='radio' name='repairaction' value='E' disabled> I deleted it on purpose and want to delete this item from the database! Only possible for uncategorised items! An email will be sent to the system administrator. </td></tr>";
print "";
print "";
print "</table>";
print "    <input type='hidden' name='itemID' value='$cgi_item_uniqueID'>\n";
print "    <input type='hidden' name='itemaction' value='repair'>\n";
# Save button:
print "    <br><input type='submit' value='Repair!'>";
print "	<a href='/mainmenu.pl?itemID=$cgi_item_uniqueID'>Cancel</a>";
# End of form
print "</form>";

#$dbh->commit();

$dbh->disconnect();


#print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
#print "<a href='/#$item_folder'> Redirecting to Main Menu ... </a> <br>\n";

print "</body></html>\n";
