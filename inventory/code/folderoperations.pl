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

my $item_folder = $cgi->param('itemfolder');
my $itemaction = $cgi->param('itemaction');
my $repairaction = $cgi->param('repairaction');
my $createaction = $cgi->param('createaction');
my $actionA_folder = $cgi->param('actionA_folder');
my $actionC_folder = $cgi->param('actionC_folder');
my $actionD_folder = $cgi->param('actionD_folder');

my $cmd;
my $cmdoutput;

my @itemrow = $dbh->selectrow_array("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber FROM items WHERE item_folder='$item_folder';");
my $item_folderDB = @itemrow[0];
my $item_basedon = @itemrow[1];
my $item_name = @itemrow[2];
my $item_description = @itemrow[3];
my $item_state = @itemrow[4];
my $item_wikiurl = @itemrow[5];
my $item_room = @itemrow[6];
my $item_shelf = @itemrow[7];
my $item_currentuser = @itemrow[8];
my $item_invoicedate = @itemrow[9];
my $item_inventorynumber = @itemrow[10];
my $item_category = @itemrow[11];
my $item_versionnumber = @itemrow[12];
my $item_serialnumber = @itemrow[13];


print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head><body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";


sub saveHistory
{
    my ($item_folder,$operation_string) = @_;
    
    my @itemrow = $dbh->selectrow_array("SELECT 
    item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber,item_workgroup,item_responsibleperson,item_uniqueID,
    room_id,room_number,room_floor,room_building,room_name,
    category_id,category_name
    FROM items LEFT JOIN rooms ON items.item_room=rooms.room_id LEFT JOIN categories ON items.item_category=categories.category_id 
    WHERE items.item_folder='$item_folder';");
    my $item_folderDB = @itemrow[0];
    my $item_linkedfolder = @itemrow[1];
    my $item_name = @itemrow[2];
    my $item_description = @itemrow[3];
    my $item_state = @itemrow[4];
    my $item_wikiurl = @itemrow[5];
    my $item_room = @itemrow[6];
    my $item_shelf = @itemrow[7];
    my $item_currentuser = @itemrow[8];
    my $item_invoicedate = @itemrow[9];
    my $item_inventorynumber = @itemrow[10];
    my $item_category = @itemrow[11];
    my $item_versionnumber = @itemrow[12];
    my $item_serialnumber = @itemrow[13];
    my $item_workgroup = @itemrow[14];
    my $item_responsibleperson = @itemrow[15];
    my $item_uniqueID = @itemrow[16];
    my $room_id = @itemrow[17];
    my $room_number = @itemrow[18];
    my $room_floor = @itemrow[19];
    my $room_building = @itemrow[20];
    my $room_name = @itemrow[21];
    my $category_id = @itemrow[22];
    my $category_name = @itemrow[23];
    
#    my $roomString = "Unspecified";
#    if ($item_room != 0)
#    {
#	$roomString = $room_name;
#    }    
#    my $categoryString;

    my $time = time();
    my $ar =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_operationtime,history_xmlblob) 
	VALUES ($item_uniqueID,$operation_string,$time,'
	<td title=\"Room\">$room_name</td>
	<td title=\"Shelf\">$item_shelf</td>
	<td title=\"State\">$item_state</td>
	<td title=\"Current User\">$item_currentuser</td>
	<td title=\"Responsible Person\">$item_responsibleperson</td>
	<td title=\"-\"> </td>
	<td title=\"Item Name\">$item_name</td>
	<td title=\"Unix Folder\">$item_folder</td>
	<td title=\"Description\">$item_description</td>
	<td title=\"LinkedFolder\">$item_linkedfolder</td>
	<td title=\"Wiki URL\">$item_wikiurl</td>
	<td title=\"Invoice Date\">$item_invoicedate</td>
	<td title=\"University Inventory #\">$item_inventorynumber</td>
	<td title=\"Serial Number\">$item_serialnumber</td>
	<td title=\"Version\">$item_versionnumber</td>
	<td title=\"Workgroup\">$item_workgroup</td>
	<td title=\"Category\">$category_name</td>
	<td title=\"Room ID\">$item_room</td>
	<td title=\"Category ID\">$item_category</td>
	')"); 

	$dbh->commit();
}

if ($itemaction eq "repair")
{

    print "<h1>ISIP Inventory: Repair missing folder...</h1>\n";
    print "The folder of \"$item_name\" was not found.";
    if ($repairaction eq "A")
    {
    	print "<h3>I renamed it to \"$actionA_folder\" and want to delete the existing item for that folder!</h3>\n";
    	print "Deleting existing database entry for folder \"$actionA_folder\" and changing item $item_name from folder \"$item_folder\" to \"$actionA_folder\"...";

	# Save history before deletion (if we weren't deleting, we would be saving AFTER edit):
	saveHistory($actionA_folder,'DELETED_REPAIROTHER');
	
    	$dbh->do("DELETE FROM items WHERE item_folder='$actionA_folder';");
	$dbh->do("UPDATE items SET item_folder = '$actionA_folder' WHERE item_folder = '$item_folder' ;");
	#$dbh->commit();
	my $success;
	my $result = ($success ? $dbh->commit : $dbh->rollback);
	unless ($result) { 
    	    die "Couldn't finish transaction: " . $dbh->errstr 
	}

	# Save History after change:
	saveHistory($item_folder,'UPDATED_REPAIRFOLDER_MANUALRENAME');

	print "OK!<br>\n";
	print "<br>\n";
	print "The item $item_name now points to the folder \"$actionA_folder\" instead of \"$item_folder\"!<br>\n";
	print "You can now see the items photos again if \"$actionA_folder\" contains any.<br>\n";
    }
    elsif ($repairaction eq "B")
    {
	print "<h3>I deleted it by accident and want to create a new empty folder!</h3>\n";
	print "Creating the folder $item_folder in the shared network drive...";
	$cmd = "mkdir \"$itemroot/$item_folder\"";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $item_folder has not worked! Read the gray screen output to find out why.</font>';}
	else
	{
		print "OK!<br>\n";
		print "<br>\n";
		print "The item folder $item_folder has been created on the shared network drive!<br>\n";
		print "You can now fill it with photos of the item and any other files you like.<br>\n";
	}
    }
    elsif ($repairaction eq "C")
    {
	print "<h3>I want to copy the contents of the folder \"$actionD_folder\"!</h3>\n";
	print "Copying the folder \"$actionC_folder\" to \"$item_folder\" in the shared network drive...";
	$cmd = "cp \"$itemroot/$actionC_folder\" \"$itemroot/$item_folder\" -R -v";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $item_folder has not worked! Read the gray screen output to find out why.</font>';}
	else
	{
		print "<pre>@mkdirerror</pre> <br>\n";
		print "OK!<br>\n";
		print "<br>\n";
		print "The item folder \"$actionC_folder\" has been copied to \"$item_folder\" on the shared network drive!<br>\n";
		print "You can now add photos of the item to it and throw in any other files you like.<br>\n";
	}
    }
    elsif ($repairaction eq "D")
    {
	print "<h3>I want to link this item to the folder \"$actionD_folder\"!</h3>\n";
	print "This repair action is not implemented yet!";
    }
    elsif ($repairaction eq "E")
    {
	print "<h3>I deleted it on purpose and want to delete this item from the database!</h3>\n";
	print "The folder will be moved to trash and an email will be sent to the system administrators!";
	print "This repair action is not implemented yet!";
    }
    else
    {
	print "<br>\n";
	print "<br>\n";

	print "Unknown repair action. Please choose an option using the option buttons on the previous screen.";
    }

}
elsif ($itemaction eq "create")
{
    print "<h1>ISIP Inventory: Creating a new item...</h1>\n";
    #print "The folder of \"$item_name\" was not found.";
    if ($createaction eq "A")
    {
	print "<h3>Create via shared folder.</h3>\n";
	print "You said you will copy a folder of photos to the shared network drive. So nothing was done here.<br>\n";
	print "<br>\n";
	print "For a hint on how to mount the shared network drive on your computer, look <a href='http://en.wikipedia.org/wiki/WebDAV#Implementations'>here</a>.<br>\n";
	print "The URL of our shared network drive is https://inventory.isip.uni-luebeck.de/items/ <br>\n";
    }
    elsif ($createaction eq "B")
    {
	$item_folder = findNextFoldername("item");
	print "<h3>I want to create a new empty item!</h3>\n";
	print "Creating the folder $item_folder in the shared network drive...";
	$cmd = "mkdir \"$itemroot/$item_folder\"";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $item_folder has not worked! Read the gray screen output to find out why.</font>';}
	else
	{
		print "OK!<br>\n";
		print "<br>\n";
		print "The item folder $item_folder has been created on the shared network drive!<br>\n";
		print "You can now fill it with photos of the item and any other files you like.<br>\n";
	}
    }
    elsif ($createaction eq "C")
    {
	$actionC_folder =~ m/^(\w*\D)(\d*)$/;
	my $folderbase = $1 ;
	if ($folderbase eq "") {$folderbase = "item";} # if the matching totally fails.
	#print "bla = $folderbase"; 
	$item_folder = findNextFoldername("$folderbase");
        print "<h3>I want to make a  copy of the item \"$actionC_folder\"!</h3>\n";                                                                                                                                                                                    
        print "Copying the folder \"$actionC_folder\" to \"$item_folder\" in the shared network drive...";                                                                                                                                                                    
        $cmd = "cp \"$itemroot/$actionC_folder\" \"$itemroot/$item_folder\" -R -v";                                                                                                                                                                                           
        my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.                                                                                                                                                                         
        if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $item_folder has not worked! Read the gray screen output to find out why.</font>';}                                                                    
        else                                                                                                                                                                                                                                                                  
        {                                                                                                                                                                                                                                                                     
            print "<pre>@mkdirerror</pre> <br>\n";                                                                                                                                                                                                                        
            print "OK!<br>\n";                                                                                                                                                                                                                                            
            print "<br>\n";                                                                                                                                                                                                                                               
            print "The item folder \"$actionC_folder\" has been copied to \"$item_folder\" on the shared network drive!<br>\n";                                                                                                                                           
            print "You can now add photos of the item to it and throw in any other files you like.<br>\n";                                                                                                                                                                
        }                                                                                                                                                                                                                                                                     
																		    
    }
    else
    {
	print "<br>\n";
	print "<br>\n";
	print "Unknown create action. Please choose an option using the option buttons on the previous screen.";
    }
    

}
else
{
	print "<br>\n";
	print "<br>\n";
	print "Unknown action. Either you manually called this script or there is a bug in the implementation..";
}



print "<br>\n";
print "<br>\n";
print "	<a href='/#$item_folder'>Back to Main List</a>";

print "</body></html>\n";


sub findNextFoldername
{
    my $folderbase = @_[0];
    #print "folderbase = $folderbase";
    my $item_folder;
	# list items dir
        $cmd = "ls -1A $itemroot";                                                                                                                                                                                                               
	my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.                                                                                                                                                      
	if ($?) {print '<font color="red">Careful here: Listing contents of item folder has not worked! Read the gray screen output to find out why.</font>';};                                                                                               
	# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):                                                                                                                                                
	chomp(@allitemsfiles);                                                                                                                                                                                                                                
	
	# extract all folders starting with "item..."
	my @itemindices;
	foreach my $anitemfolder (@allitemsfiles)                                                                                                                                                                                                            
	{
	my $one;
	    if ( $anitemfolder =~ m/^$folderbase(\d*)$/ )
	    {
		#print "index: $1 <br>";
		push @itemindices , $1 ;
	    }
	}																       	
	
	# find highest index and add 1
	@itemindices = sort{$a<=>$b}(@itemindices);
	#print "@itemindices ...";
	my $newID = pop(@itemindices) + 1;
	
	# concatenate with leading zeros -> 4 digits = itemfolder
	if ($newID < 10) {$item_folder = "${folderbase}000".($newID);}
	elsif ($newID < 100) {$item_folder = "${folderbase}00".($newID);}
	elsif ($newID < 1000) {$item_folder = "${folderbase}0".($newID);}
	else  {$item_folder = "${folderbase}".($newID);}

    return $item_folder;
}