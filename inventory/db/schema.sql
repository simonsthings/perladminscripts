create table items (
        item_folder      text,
	based_on_folder  text,
        item_name        text,
        item_description text,
	item_state       text,
	item_wikiurl     text,
        item_room        integer,
	item_shelf	 text,
	current_user	 text,
	item_invoicedate text,
	item_uniinvnum   text,
	item_category	 integer
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


insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (1,25,1,'Haus 64','simons,radeks and alexs room')
insert into rooms (room_id,room_number,room_floor,room_building,room_name) values (2,27,1,'Haus 64','Biosignal Lab');
