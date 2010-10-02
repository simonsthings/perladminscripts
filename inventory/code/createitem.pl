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

my $item_folder = $cgi->param('item_folder');

my @itemrow = $dbh->selectrow_array("SELECT item_name FROM items WHERE item_folder='$item_folder';");
my $item_name = @itemrow[0];

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker - Create New Item</title></head>";
print "<body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<h1>Create New Item:</h1>\n";


# Action C ComboBox: All Items
my $selallitems = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items WHERE item_category != '0';");
if ($selallitems->err()) { die "$DBI::errstr\n"; }
$selallitems->execute();
my $actionCComboboxAllItems = "<select name='actionC_itemID' size='1'>\n";
while(my @row = $selallitems->fetchrow_array())
{
	if (@row[1] eq @row[0])
	{$actionCComboboxAllItems .= "<option value=@row[2]>@row[1]</option>\n";}
	else
	{$actionCComboboxAllItems .= "<option value=@row[2]>@row[1] (\"@row[0]\")</option>\n";}
}
$actionCComboboxAllItems .= "</select>";


print "<form action='/folderoperations.pl' method='get'>\n";
#print "Unix folder name: <input type='text' name='itemfolder'> Please enter a unix folder name that be be used as an ID to the new item!";
print "<h3>So how exactly do you want to create a new item?</h3>\n";
print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";
#print "<tr><td bgcolor='white'  ><input disabled type='radio' name='createaction' value='A'> I have a photo folder on my computer and will copy it to the shared network drive. (A new item will be created automatically.) </td></tr>";
print "<tr><td bgcolor='white'  ><input disabled type='radio' name='createaction' value='A'> I will use Drag&Drop and a network drive. My item will then appear automatically in the \"New Items\" category. </td></tr>";
print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='createaction' value='B'> I want to create a new empty item now and care about the photos later! </td></tr>";
print "<tr><td bgcolor='white'  ><input type='radio' name='createaction' value='C'> I want to create a new item and copy all information and photos from $actionCComboboxAllItems! </td></tr>";
#print "<tr><td bgcolor='white'><input type='radio' name='createaction' value='D' disabled> I want to link this item to the folder $actionEComboboxAllItems! A new empty folder for this item will still be created. </td></tr>";
#print "<tr><td bgcolor='#d1e8f9'><input type='radio' name='createaction' value='E' disabled> I deleted it on purpose and want to delete this item from the database! Only possible for uncategorised items! An email will be sent to the system administrator. </td></tr>";
print "";
print "";
print "";
print "";
print "</table>";
print "";
print "Name of New Item:<br>\n";
print "<input type=text name='item_name'><br>\n";
#print "    <input type='hidden' name='itemfolder' value='$item_folder'>\n";
print "    <input type='hidden' name='itemaction' value='create'>\n";
# Save button:
print "    <br><input type='submit' value='Create!'>";
print "	<a href='/mainmenu.pl'>Cancel</a>";
# End of form
print "</form>";

#$dbh->commit();

$dbh->disconnect();


#print "<a href='/itemmenu.pl?itemfolder=$item_folder'> back to item </a> <br>\n";
#print "<a href='/#$item_folder'> Redirecting to Main Menu ... </a> <br>\n";

print "</body></html>\n";
