create table items (
        item_folder      text,
	item_linkedfolder  text,
        item_name        text,
        item_description text,
	item_state       text,
	item_wikiurl     text,
        item_room        integer,
	item_shelf	 text,
	item_currentuser text,
	item_invoicedate text,
	item_uniinvnum   text,
	item_category	 integer,
	item_versionnumber	text,
	item_serialnumber	text,
	item_workgroup	text,
	item_lent_by	text,
	item_lent_to_email	text
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
	history_operation	text,
        history_folder      	text,
	history_linkedfolder 	text,
        history_name        	text,
        history_description 	text,
	history_state       	text,
	history_wikiurl     	text,
        history_room        	integer,
	history_shelf	 	text,
	history_currentuser	text,
	history_invoicedate 	text,
	history_uniinvnum   	text,
	history_category	integer,
	history_versionnumber	text,
	history_serialnumber	text,
	history_workgroup	text,
	history_lent_by		text,
	history_lent_to_email	text
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
insert into categories (category_id,category_name) values (1,'Laboratory Equipment & Self-Manufactured Hardware');
insert into categories (category_id,category_name) values (2,'Office Hardware');
insert into categories (category_id,category_name) values (3,'Software');
insert into categories (category_id,category_name) values (4,'Books & Papers'); 

