create table items (
	item_uniqueID		integer primary key autoincrement,
        item_name        	text,
        item_folder      	text,
	item_linkedfolder  	text,
        item_description 	text,
	item_state       	text,
	item_wikiurl     	text,
        item_room        	integer,
	item_shelf	 	text,
	item_currentuser 	text,
	item_invoicedate 	text,
	item_uniinvnum   	text,
	item_category	 	integer,
	item_versionnumber	text,
	item_serialnumber	text,
	item_workgroup		text,
	item_responsibleperson	text
);

create table rooms (
	room_id   	integer,
	room_number	text,
	room_floor	text,
	room_building	text,
	room_name	text
);

create table categories (
	category_id	integer,
	category_name	text
);

create table history (
	history_itemuniqueid	integer,
	history_operation	text,
	history_operationtime	integer,
	history_otheritemid	integer,
	history_xmlblob		text	
);

create table history_operations (
	hop_operation		text,
	hop_nicename		text
);

insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (1,'27','1. Stock','Haus 64','Biosignal Lab');                        
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (2,'XX','1. Stock','Haus 64','Software Lab');                         
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (3,'XX','1. Stock','Haus 64','Audio Lab');                            
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (4,'XX','2. Stock','Haus 12','Neurosurgery Lab');                     
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (5,'26','1. Stock','Haus 64','Office of Thomas');                     
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (6,'25','1. Stock','Haus 64','Office of Simon, Alex, Radek');          
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (7,'XX','1. Stock','Haus 64','Office of Florian, Ole');               
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (8,'XX','1. Stock','Haus 64','Office of Alfred');                     
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (9,'XX','1. Stock','Haus 64','Office of Christiane');                 
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (10,'XX','1. Stock','Haus 64','Office of Uli');                        
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (11,'XX','1. Stock','Haus 64','Office of Yijing, Mehrnatz, Felix, Chen');
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (12,'XX','1. Stock','Haus 64','ISIP Seminar Room');                    
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (13,'XX','1. Stock','Haus 64','Former Archive');                       
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (14,'XX','1. Stock','Haus 64','ISIP Server Room');                       
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (15,'XX','1. Stock','Haus 64','Kitchen');                              
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (16,'XX','Erdgeschoss','Haus 64','Leihgabe an die Robotik');                        
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (17,'XX','Erdgeschoss','Haus 26','Leihgabe an die Neurologie');


insert into categories (category_id,category_name) values (0,'New Items (unspecified Category)');
insert into categories (category_id,category_name) values (10,'Laboratory Equipment & Tools');
insert into categories (category_id,category_name) values (20,'Self-Manufactured Hardware & Small Parts');
insert into categories (category_id,category_name) values (30,'Office Hardware & Supplies');
insert into categories (category_id,category_name) values (40,'Software');
insert into categories (category_id,category_name) values (50,'Books & Papers'); 

INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('CREATE_AUTOWEBDAV','Created');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('CREATE_MANUALEMPTY','Created');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('CREATE_MANUALCOPY','Created');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('REPAIR_FOLDERRENAMED','Repaired');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('EDIT_NORMAL','Edited');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('EDIT_AUTOFOLDERRENAME','Edited');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('DELETED_REPAIROTHER','Deleted');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('DELETED_DEINVENTORISED','Deleted');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('DELETED_MERGEDINTO','Deleted');
INSERT INTO history_operations(hop_operation,hop_nicename) VALUES('DELETED_DBCLEANUP','Deleted');


