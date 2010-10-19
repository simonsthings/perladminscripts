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

my $itemaction = $cgi->param('itemaction');
my $repairaction = $cgi->param('repairaction');
my $createaction = $cgi->param('createaction');
my $deleteaction = $cgi->param('deleteaction');
my $actionA_itemID = $cgi->param('actionA_itemID');
my $actionB_itemID = $cgi->param('actionB_itemID');
my $actionC_itemID = $cgi->param('actionC_itemID');
my $actionD_itemID = $cgi->param('actionD_itemID');

#my $item_folder = $cgi->param('itemfolder');
my $cgi_item_uniqueID = $cgi->param('itemID');

my $cgi_item_folder           = $cgi->param('item_folder');                                                                                          
my $cgi_item_linkedfolder     = $cgi->param('item_basedon');                                                                                         
my $cgi_item_name             = $cgi->param('item_name');                                                                                            
my $cgi_item_description      = $cgi->param('item_description');                                                                                     
my $cgi_item_state            = $cgi->param('item_state');                                                                                           
my $cgi_item_wikiurl          = $cgi->param('item_wikiurl');                                                                                         
my $cgi_item_room             = $cgi->param('item_room');                                                                                            
my $cgi_item_shelf            = $cgi->param('item_shelf');                                                                                           
my $cgi_item_currentuser      = $cgi->param('item_currentuser');                                                                                     
my $cgi_item_invoicedate      = $cgi->param('item_invoicedate');                                                                                     
my $cgi_item_inventorynumber  = $cgi->param('item_inventorynumber');                                                                                 
my $cgi_item_category         = $cgi->param('item_category');                                                                                        
my $cgi_item_versionnumber    = $cgi->param('item_versionnumber');                                                                                   
my $cgi_item_serialnumber     = $cgi->param('item_serialnumber');                                                                                    
my $cgi_item_workgroup        = $cgi->param('item_workgroup');                                                                                    
my $cgi_item_responsibleperson = $cgi->param('item_responsibleperson');                                                                                    

my $cmd;
my $cmdoutput;

my @itemrow = $dbh->selectrow_array("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber FROM items WHERE item_uniqueID='$cgi_item_uniqueID';");
my $dbid_item_folder = @itemrow[0];
#my $dbid_item_linkedfolder = @itemrow[1];
my $dbid_item_name = @itemrow[2];
#my $dbid_item_description = @itemrow[3];
#my $dbid_item_state = @itemrow[4];
#my $dbid_item_wikiurl = @itemrow[5];
#my $dbid_item_room = @itemrow[6];
#my $dbid_item_shelf = @itemrow[7];
#my $dbid_item_currentuser = @itemrow[8];
#my $dbid_item_invoicedate = @itemrow[9];
#my $dbid_item_inventorynumber = @itemrow[10];
#my $dbid_item_category = @itemrow[11];
#my $dbid_item_versionnumber = @itemrow[12];
#my $dbid_item_serialnumber = @itemrow[13];
#my $dbid_item_workgroup = @itemrow[14];
#my $dbid_item_responsibleperson = @itemrow[15];


print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker - Operations Feedback</title></head><body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
#print "apache user: $apacheuser<br>\n";
# foreach my $key (keys %ENV) {#
#               print "$key --> $ENV{$key}<br>";
#	            }
#print "User name: $ENV{'REMOTE_USER'}";


if ($itemaction eq "repair")
{

    print "<h1>ISIP Inventory: Repair missing folder...</h1>\n";
    print "The folder of \"$dbid_item_name\" was not found.";
    if ($repairaction eq "A")
    {
        my @itemrow = $dbh->selectrow_array("SELECT item_name,item_folder FROM items WHERE item_uniqueID = '$actionA_itemID' ;");
	my $other_item_name = @itemrow[0];
	my $other_item_folder = @itemrow[1];
	
	# Safeguard against reloading of page:
	if ($other_item_folder eq "") {print "ERROR: The given item that was supposed to be deleted doesn't exist anymore!"; return;}
	if ($dbid_item_folder eq "") {print "ERROR: The given item that was supposed to be given a new folder doesn't exist anymore!"; return;}

    	print "<h3>I renamed it to \"$other_item_folder\" and want to delete the existing (auto-created) item for that folder!</h3>\n";
    	print "Deleting existing database entry for folder \"$other_item_folder\" and changing item $dbid_item_name from folder \"$dbid_item_folder\" to \"$other_item_folder\"...";

	# Save history before deletion (if we weren't deleting, we would be saving AFTER edit):
	saveHistory($actionA_itemID,'DELETED_REPAIROTHER',$cgi_item_uniqueID);
	
    	$dbh->do("DELETE FROM items WHERE item_uniqueID='$actionA_itemID';"); # This either deletes one (if auto-item was already created) or no rows.
	my $rows_affected = $dbh->do("UPDATE items SET item_folder = '$other_item_folder' WHERE item_uniqueID = '$cgi_item_uniqueID' ;");
	
	# Save History after change:
	saveHistory($cgi_item_uniqueID,'REPAIR_FOLDERRENAMED',$actionA_itemID);

	if ($rows_affected == 1)
	{
	    #commit
	    $dbh->commit;
	}
	else
	{
	    $dbh->rollback; 
    	    die "Problem during transaction: Exactly 1 item should have been updated but $rows_affected were. You must not reload the current page! If you did not do that, this is an error!" . $dbh->errstr 
	}

	print "OK!<br>\n";
	print "<br>\n";
	print "The item $dbid_item_name now points to the folder \"$other_item_folder\" instead of \"$dbid_item_folder\"!<br>\n";
	print "You can now see the items photos again if \"$other_item_folder\" contains any.<br>\n";
    }
    elsif ($repairaction eq "B")
    {
	print "<h3>I deleted it by accident and want to create a new empty folder!</h3>\n";
	print "Creating the folder $dbid_item_folder in the shared network drive...";
	$cmd = "mkdir \"$itemroot/$dbid_item_folder\"";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $dbid_item_folder has not worked! Read the gray screen output to find out why.</font>';}
	else
	{
		print "OK!<br>\n";
		print "<br>\n";
		print "The item folder $dbid_item_folder has been created on the shared network drive!<br>\n";
		print "You can now fill it with photos of the item and any other files you like.<br>\n";
	}
    }
    elsif ($repairaction eq "C")
    {
    	# Get Name and Folder of item that is to be copied:
        my $sth = $dbh->prepare("SELECT item_name,item_folder,item_uniqueID FROM items WHERE item_uniqueID = ? ;");
        my @itemToCopyRow = $sth->selectrow_array($actionC_itemID);
	my $orig_item_name = @itemToCopyRow[0];
	my $orig_item_folder = @itemToCopyRow[1];
	my $orig_item_uniqueID = @itemToCopyRow[2];
    
	print "<h3>I want to copy the contents of item \"$orig_item_name\" (folder '\"$orig_item_folder\"')!</h3>\n";
	print "Copying the folder \"$orig_item_folder\" to \"$dbid_item_folder\" in the shared network drive...";
	$cmd = "cp \"$itemroot/$orig_item_folder\" \"$itemroot/$dbid_item_folder\" -R -v";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $dbid_item_folder has not worked! Read the gray screen output to find out why.</font>';}
	else
	{
		print "<pre>@mkdirerror</pre> <br>\n";
		print "OK!<br>\n";
		print "<br>\n";
		print "The item folder \"$orig_item_folder\" has been copied to \"$dbid_item_folder\" on the shared network drive!<br>\n";
		print "You can now add photos of the item to it and throw in any other files you like.<br>\n";
	}
    }
    elsif ($repairaction eq "D")
    {
	print "<h3>I want to link this item to some other folder!</h3>\n";
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
    #print "The folder of \"$dbid_item_name\" was not found.";
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
	my $a_next_item_folder = reduceNameToUnixFolder($cgi_item_name);
	print "<h3>I want to create a new empty item!</h3>\n";
	
	print "Creating the item '$cgi_item_name' in the database.";
	# update DB
        my $rows_affected = $dbh->do("INSERT INTO items(item_folder,item_name,item_category,item_state) VALUES ('$a_next_item_folder','$cgi_item_name','0','Functional');");    
	if ($dbh->err()) { die "$DBI::errstr\n"; }
	my $dberror = "$DBI::errstr\n";
	
	# Get the uniqueID if the newly created item:
        my @newitemrow = $dbh->selectrow_array("SELECT item_uniqueID FROM items WHERE item_folder = '$a_next_item_folder' ;");
	my $new_item_uniqueID = @newitemrow[0];
	
        # Save History after change:                                                                                                                                          
        saveHistory($new_item_uniqueID,'CREATE_MANUALEMPTY');
	
        if ($rows_affected == 1)                                                                                                                                              
	{                                                                                                                                                                     
            #commit                                                                                                                                                           
            $dbh->commit;                                                                                                                                                     
	
	    print "<br>\n";
    	    print "Creating the item folder...<br>\n";
	    $cmd = "mkdir \"$itemroot/$a_next_item_folder\"";
	    my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	    if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $a_next_item_folder has not worked! Read the gray screen output to find out why.</font>';}
	    else
	    {
		print "A folder called '$a_next_item_folder' was created in the shared network drive.<br>\n";
		print "You can now fill it with photos of the item and any other files you like.<br>\n";
		print "<br>\n";
		print "<br>\n";
		print "The new item has been created! Forwarding to item...<br>\n";
	        print "<a href='/itemmenu.pl?itemID=$new_item_uniqueID'> Continue to item now! </a> <br>\n";
	    }
        }                                                                                                                                                                     
	else                                                                                                                                                                  
        {                                                                                                                                                                     
            $dbh->rollback;                                                                                                                                                   
            die "Problem during transaction: Exactly 1 item should have been updated but $rows_affected were. Your changes to the item $cgi_item_name may not have been saved. Please check!" . $DBI::errstr ;
        }
	
    }
    elsif ($createaction eq "C")
    {
#    print "$actionC_itemID";
	# Get all data of item that is to be copied:
	my $origsth = $dbh->prepare("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber,item_workgroup,item_responsibleperson FROM items WHERE item_uniqueID= ? ;");
	$origsth->execute($actionC_itemID);
	my @origitemrow = $origsth->fetchrow_array();
	my $orig_item_folder = @origitemrow[0];
	my $orig_item_linkedfolder = @origitemrow[1];
	my $orig_item_name = @origitemrow[2];
	my $orig_item_description = @origitemrow[3];
	my $orig_item_state = @origitemrow[4];
	my $orig_item_wikiurl = @origitemrow[5];
	my $orig_item_room = @origitemrow[6];
	my $orig_item_shelf = @origitemrow[7];
	my $orig_item_currentuser = @origitemrow[8];
	my $orig_item_invoicedate = @origitemrow[9];
	my $orig_item_inventorynumber = @origitemrow[10];
	my $orig_item_category = @origitemrow[11];
	my $orig_item_versionnumber = @origitemrow[12];
	my $orig_item_serialnumber = @origitemrow[13];
	my $orig_item_workgroup = @origitemrow[14];
	my $orig_item_responsibleperson = @origitemrow[15];

	print "Orig_Name: $orig_item_name, Orig_Workgroup: $orig_item_workgroup <br>\n";
	
#	die;

	# update DB
#        my $sth = $dbh->prepare("UPDATE items SET item_folder=?,item_name=?, item_linkedfolder=?, item_description=?, item_state=?, item_wikiurl=?, item_room=?, item_shelf=?, item_currentuser=?, item_invoicedate=?, item_uniinvnum=?,       item_category=?, item_versionnumber=?, item_serialnumber=?, item_workgroup=?, item_responsibleperson=? WHERE item_uniqueID = ? ;");
#	$rows_affected = $sth->execute(       $newFoldername,$cgi_item_name,$cgi_item_linkedfolder,$cgi_item_description,$cgi_item_state,$cgi_item_wikiurl,$cgi_item_room,$cgi_item_shelf,$cgi_item_currentuser,$cgi_item_invoicedate,$cgi_item_inventorynumber,$cgi_item_category,$cgi_item_versionnumber,$cgi_item_serialnumber,$cgi_item_workgroup,$cgi_item_responsibleperson,     $cgi_item_uniqueID);
	
        # Save History after change:                                                                                                                                          
#        saveHistory($cgi_item_uniqueID,'EDIT_AUTOFOLDERRENAME');
	

#	$actionC_folder =~ m/^(\w*\D)(\d*)$/;
#	my $folderbase = $1 ;
#	if ($folderbase eq "") {$folderbase = "item";} # if the matching totally fails.
	#print "bla = $folderbase"; 
#	my $the_next_item_folder = findNextFoldername("$folderbase");

	my $new_item_name;
	if ($cgi_item_name eq "")
	{
	    $new_item_name = "$orig_item_name Copy";
	}
	else
	{
	    $new_item_name = $cgi_item_name;
	}

	my $the_next_item_folder = reduceNameToUnixFolder($new_item_name);
        print "<h3>I want to make a  copy of the item \"$orig_item_name\" (folder '$orig_item_folder')!</h3>\n";                                                                                                                                                                                    
        print "Copying the folder \"$orig_item_folder\" to \"$the_next_item_folder\" in the shared network drive...";                                                                                                                                                                    
        $cmd = "cp \"$itemroot/$orig_item_folder\" \"$itemroot/$the_next_item_folder\" -R -v";                                                                                                                                                                                           
        my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.                                                                                                                                                                         
        if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the item folder $dbid_item_folder has not worked! Read the gray screen output to find out why.</font>';}                                                                    
        else                                                                                                                                                                                                                                                                  
        {                                                                                                                                                                                                                                                                     
            print "<pre>@mkdirerror</pre> <br>\n";                                                                                                                                                                                                                        
            print "OK!<br>\n";                                                                                                                                                                                                                                            
            print "<br>\n";                                                                                                                                                                                                                                               
            print "The item folder \"$orig_item_folder\" has been copied to \"$the_next_item_folder\" on the shared network drive!<br>\n";                                                                                                                                           
            print "You can now add photos of the item to it and throw in any other files you like.<br>\n";                                                                                                                                                                
	    print "<br><br>Folder was created on the drive.<br>";	    
	    print "Implementation needs to be continued to actually copy the database entries ;-)<br>\n";
	    #print "<a href='/itemmenu.pl?itemID=$cgi_item_uniqueID'> Continue to item! </a> <br>\n";
        }                                                                                                                                                                                                                                                                     
																		    
    }
    else
    {
	print "<br>\n";
	print "<br>\n";
	print "Unknown create action. Please choose an option using the option buttons on the previous screen.";
    }

}
elsif ($itemaction eq "editsave")                                                                                                                                                  
{                                                                                                                                                                             
                                    
    print "<h1>Saving Item '$cgi_item_name'...</h1>\n";
    
    # Check DB to see if the item Name has changed:
    my @itemrow = $dbh->selectrow_array("SELECT item_name,item_folder FROM items WHERE item_uniqueID = '$cgi_item_uniqueID' ;");
    my $db_item_name = @itemrow[0];
    my $db_item_folder = @itemrow[1];
    
    my $rows_affected;
    my $newFoldername;
    if ($cgi_item_name eq $db_item_name)
    { # Name was not changed, so do not rename folder!
    
	# update DB
        my $sth = $dbh->prepare("UPDATE items SET item_linkedfolder = ?, item_description=?,   item_state=?,   item_wikiurl=?,   item_room=?,   item_shelf=?,   item_currentuser=?,   item_invoicedate=?,   item_uniinvnum=?,         item_category=?,   item_versionnumber=?,   item_serialnumber=?,   item_workgroup=?,   item_responsibleperson=? WHERE item_uniqueID = ? ;");    
        $rows_affected = $sth->execute(      $cgi_item_linkedfolder,$cgi_item_description,$cgi_item_state,$cgi_item_wikiurl,$cgi_item_room,$cgi_item_shelf,$cgi_item_currentuser,$cgi_item_invoicedate,$cgi_item_inventorynumber,$cgi_item_category,$cgi_item_versionnumber,$cgi_item_serialnumber,$cgi_item_workgroup,$cgi_item_responsibleperson,   $cgi_item_uniqueID);
    
        # Save History after change:                                                                                                                                          
        saveHistory($cgi_item_uniqueID,'EDIT_NORMAL');
    }
    else
    { # Item Name has changed!
    
	# Find new folder name:
	$newFoldername = reduceNameToUnixFolder($cgi_item_name);	
	print "The item name has changed. So I am renaming its unix folder from '$db_item_folder' to '$newFoldername'.<br>\n";
	
	# update DB
        my $sth = $dbh->prepare("UPDATE items SET item_folder=?,item_name=?, item_linkedfolder=?, item_description=?, item_state=?, item_wikiurl=?, item_room=?, item_shelf=?, item_currentuser=?, item_invoicedate=?, item_uniinvnum=?,       item_category=?, item_versionnumber=?, item_serialnumber=?, item_workgroup=?, item_responsibleperson=? WHERE item_uniqueID = ? ;");
	$rows_affected = $sth->execute(       $newFoldername,$cgi_item_name,$cgi_item_linkedfolder,$cgi_item_description,$cgi_item_state,$cgi_item_wikiurl,$cgi_item_room,$cgi_item_shelf,$cgi_item_currentuser,$cgi_item_invoicedate,$cgi_item_inventorynumber,$cgi_item_category,$cgi_item_versionnumber,$cgi_item_serialnumber,$cgi_item_workgroup,$cgi_item_responsibleperson,     $cgi_item_uniqueID);
	
        # Save History after change:                                                                                                                                          
        saveHistory($cgi_item_uniqueID,'EDIT_AUTOFOLDERRENAME');
    }
    
    if ($rows_affected == 1)                                                                                                                                              
    {                                                                                                                                                                     
        #commit                                                                                                                                                           
        $dbh->commit;                                                                                                                                                     
	
	if ($cgi_item_name ne $db_item_name)
	{
    	    # rename folder on hard disk
    	    $cmd = "mv $itemroot/$db_item_folder $itemroot/$newFoldername";
	    my @stdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.                                                                                                                                                      
	    if ($?) {print "<font color=\"red\">Careful here: Renaming folder '$db_item_folder' to '$newFoldername' has not worked! Read the gray screen output to find out why.</font>";};                                                                                               
	}

    print "<br>saved.<br><br>";
    }                                                                                                                                                                     
    else                                                                                                                                                                  
    {                                                                                                                                                                     
        $dbh->rollback;                                                                                                                                                   
        die "Problem during transaction: Exactly 1 item should have been updated but $rows_affected were. Your changes to the item $cgi_item_name may not have been saved. Please check!" 
    }

    print "<a href='/itemmenu.pl?itemID=$cgi_item_uniqueID'> Back to item </a> <br>\n";
#    print "<a href='/mainmenu.pl?itemID=$cgi_item_uniqueID'> Redirecting to Main Menu ... </a> <br>\n";
}
elsif ($itemaction eq "delete")
{                                                                                                                                          
    # Check if the folder is empty (ignore hidden files)                                                                                           
    my @nonhiddenFiles = `ls -1 $itemroot/$dbid_item_folder`;                                                                                           
    if (@nonhiddenFiles >= 1)                                                                                                                      
    {  
	print "How did you get here? The folder for this item still isn't empty!! Not deleting anything.";
        print "<pre>";                                                                                                                                 
	print " @nonhiddenFiles";                                                                                                                      
	print "</pre>";                                                                                                                                
        print "<a href='/itemmenu.pl?itemID=$cgi_item_uniqueID'>Back to item / Cancel</a>";                                                            
    }                                                                                                                                              
    else                                                                                                                                           
    {                                                                                                                                              
        print "<h1>Deleting item '$dbid_item_name'</h1>\n";                                                                                    
	print "Deleting empty folder...<br>\n";
	`rm $itemroot/$dbid_item_folder -R`;
	die("Removing the folder didn't work! $@") unless($@ eq "");
	
	print "Deleting DB entry...<br>\n";
	# Save history before deletion (if we weren't deleting, we would be saving AFTER edit):
	if ($deleteaction eq "A")
	{
	    # Item de-inventorised:
	    saveHistory($cgi_item_uniqueID,'DELETED_DEINVENTORISED');
	}
	elsif ($deleteaction eq "B")
	{
	    # Item merged into other:
	    saveHistory($cgi_item_uniqueID,'DELETED_MERGEDINTO',$actionB_itemID);
	}
	elsif ($deleteaction eq "C")
	{
	    # Database cleanup:
	    saveHistory($cgi_item_uniqueID,'DELETED_DBCLEANUP');
	}
	else
	{
	    print "<br>\n";
	    print "<br>\n";
	    print "Unknown create action. Please choose an option using the option buttons on the previous screen.";
	}

	# Do the deletion:
    	my $rows_affected = $dbh->do("DELETE FROM items WHERE item_uniqueID='$cgi_item_uniqueID';"); # This either deletes one (if auto-item was already created) or no rows.

	# Commit!	
	if ($rows_affected == 1)
	{
	    #commit
	    $dbh->commit;
	}
	else
	{
	    $dbh->rollback; 
    	    die "Problem during transaction: Exactly 1 item should have been updated but $rows_affected were. You must not reload the current page! If you did not do that, this is an error!" . $dbh->errstr 
	}

	print "OK!<br>\n";
	print "<br>\n";
	
    }                                                                                                                                              
    
    
    
}
else
{
	print "<br>\n";
	print "<br>\n";
	print "Unknown action. Either you manually called this script or there is a bug in the implementation..";
}



#print "<br>\n";
#print "<br>\n";
print "	<a href='/mainmenu.pl?itemID=$cgi_item_uniqueID'>Back to Main List</a>";



print "</body></html>\n";

$dbh->disconnect();







#################################################
# Sub-Procedures: 
#################################################

sub reduceNameToUnixFolder
{
    my $given_itemname = @_[0];
    
    # Make it start and end with a letter:                                                                                      
    my $numberOfMatches = $given_itemname =~ s/^[^A-Z,a-z]*([A-Z,a-z]+.*[A-Z,a-z]+)[^A-Z,a-z]*$/$1/;
    if ($numberOfMatches != 1)
    {
        # handle awful item names:
	$given_itemname = "weirditem";
    }
    
    # Throw away special characters:
    $given_itemname =~ s/[^\w]//g;
    
    # The given_itemname can now be used as the base for a unix folder!
    
    return findNextFoldername($given_itemname);
}

sub findNextFoldername
{
    my $folderbase = @_[0];
    #print "folderbase = $folderbase";
    my $next_item_folder;
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
	    #my $one;
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
	if ($newID < 10) {$next_item_folder = "${folderbase}000".($newID);}
	elsif ($newID < 100) {$next_item_folder = "${folderbase}00".($newID);}
	elsif ($newID < 1000) {$next_item_folder = "${folderbase}0".($newID);}
	else  {$next_item_folder = "${folderbase}".($newID);}

    return $next_item_folder;
}


sub saveHistory
{
    my ($givenItemID,$operation_string,$otherItemID) = @_;
    
    # Double-check against implementation errors:    
    if ($givenItemID eq $otherItemID) {die("givenid and otherid are equal!");}
    
    my @itemrow = $dbh->selectrow_array("SELECT 
    item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber,item_workgroup,item_responsibleperson,item_uniqueID,
    room_id,room_number,room_floor,room_building,room_name,
    category_id,category_name
    FROM items LEFT JOIN rooms ON items.item_room=rooms.room_id LEFT JOIN categories ON items.item_category=categories.category_id 
    WHERE items.item_uniqueID='$givenItemID';");
    my $item_folderDB = @itemrow[0];
    my $item_basedonID = @itemrow[1];
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

    my $xmlblob = "\
	<td nowrap title=\"LDAP User\">&nbsp; by <b>$ENV{'REMOTE_USER'}</b> ($ENV{'REMOTE_ADDR'}) &nbsp;</td>\
	<td nowrap title=\"Item Name\">$item_name</td> \
	<td nowrap title=\"Room\">$room_name</td>\
	<td nowrap title=\"Shelf\">$item_shelf</td> \
	<td nowrap title=\"State\">$item_state</td> \
	<td nowrap title=\"Current User\">$item_currentuser</td> \
 	<td nowrap title=\"-\">-</td> \
	<td nowrap title=\"Responsible Person\">$item_responsibleperson</td> \ 
	<td nowrap title=\"Unix Folder\">$item_folderDB</td> \
	<td nowrap title=\"Description\">$item_description</td> \
	<td nowrap title=\"LinkedItem\">$item_basedonID</td> \
	<td nowrap title=\"Wiki URL\">$item_wikiurl</td> \
	<td nowrap title=\"Invoice Date\">$item_invoicedate</td> \
	<td nowrap title=\"University Inventory #\">$item_inventorynumber</td> \
	<td nowrap title=\"Serial Number\">$item_serialnumber</td> \
	<td nowrap title=\"Version\">$item_versionnumber</td> \
	<td nowrap title=\"Workgroup\">$item_workgroup</td> \
	<td nowrap title=\"Category\">$category_name</td> \
	<td nowrap title=\"Item Unique ID\">$item_uniqueID</td> 
	<td nowrap title=\"Room ID\">$item_room</td> 
	<td nowrap title=\"Category ID\">$item_category</td>";

    print "<table border=0><tr><td nowrap>History Blob:</td>$xmlblob</tr></table>";
    	
    my $time = time();
    #my $ar =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_operationtime,history_xmlblob) VALUES ('$item_uniqueID','$operation_string','$time','$xmlblob')"); 
    my $ar =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_otherItemID,history_operationtime,history_xmlblob) VALUES ('$item_uniqueID','$operation_string','$otherItemID','$time','$xmlblob')"); 

    # Do not commit here: Do it in calling code only when thte actual operation succeeded!
    #$dbh->commit();
}
