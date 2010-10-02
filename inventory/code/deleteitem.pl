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
print "<h1>Delete '$item_name'...</h1>\n";
#print "The photo folder \"$item_folder\" for item <i>$item_name</i> was not found.";


# Action B ComboBox: All Items
my $selallitems = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items ;");
if ($selallitems->err()) { die "$DBI::errstr\n"; }
$selallitems->execute();
my $actionBComboboxAllItems = "<select name='actionB_itemID' size='1'>\n";
while(my @row = $selallitems->fetchrow_array())
{
#	if (@row[1] eq @row[0])
	{$actionBComboboxAllItems .= "<option value=@row[2]>@row[0]</option>\n";}
#	else
#	{$actionBComboboxAllItems .= "<option value=@row[2]>@row[0] (\"@row[0]\")</option>\n";}
}
$actionBComboboxAllItems .= "</select>";

# Check if the folder is empty (ignore hidden files)
my @nonhiddenFiles = `ls -1 $itemroot/$item_folder`;
if (@nonhiddenFiles >= 1)
{
print "<h3>No, I will not delete this item. Why? Because its folder still contains some files:</h3>\n";
#chomp(@nonhiddenFiles);
print "<pre>";
print " @nonhiddenFiles";
print "</pre>";
#print "I only allow items with no more files to be deleted.<br>\n";
print "<a href='/itemmenu.pl?itemID=$cgi_item_uniqueID'>Back to item / Cancel</a>";
}
else
{
# Ask why the item must be deleted (for the record):
print "<h3>So, you want to delete this item? Why??</h3>\n";
print "<form action='/folderoperations.pl' method='get'>\n";
print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";
print "<tr><td bgcolor='white'  ><input type='radio' name='deleteaction' value='A'> The item is old and has been de-inventorised. </td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='deleteaction' value='B'> It is now part of $actionBComboboxAllItems </td></tr>";
print "<tr><td bgcolor='white'  ><input type='radio' name='deleteaction' value='C'> Cleaning up the database after edits. This \"item\", as you call it, never existed! </td></tr>";
#print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='deleteaction' value='D' disabled> I want to link this item to the folder $actionDComboboxAllItems! A new empty folder for this item will still be created. </td></tr>";
#print "<tr><td bgcolor='white'  ><input type='radio' name='deleteaction' value='E' disabled> I deleted it on purpose and want to delete this item from the database! Only possible for uncategorised items! An email will be sent to the system administrator. </td></tr>";
print "";
print "";
print "</table>";
print "    <input type='hidden' name='itemID' value='$cgi_item_uniqueID'>\n";
print "    <input type='hidden' name='itemaction' value='delete'>\n";
# Save button:
print "    <br><input type='submit' value='Delete!'>";
print "	<a href='/itemmenu.pl?itemID=$cgi_item_uniqueID'>Cancel</a>";
# End of form
print "</form>";
}

$dbh->disconnect();

print "</body></html>\n";


