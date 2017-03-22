echo "*** MySQL - Creating global user lxr"
mysql -u root -p <<END_OF_USER
drop user 'cgrtl'@'localhost';
END_OF_USER
mysql -u root -p <<END_OF_USER
create user 'cgrtl'@'localhost' identified by '9-410';
grant all on *.* to 'cgrtl'@'localhost';
END_OF_USER

echo "*** MySQL - Creating tree database callgraph"
mysql -u cgrtl -p9-410 <<END_OF_CREATE
drop database if exists callgraph;
create database callgraph;
END_OF_CREATE

echo "*** MySQL - Creating tree database linux_3_5_4"
mysql -u cgrtl -p9-410 <<END_OF_CREATE
drop database if exists linux_3_5_4;
create database linux_3_5_4;
END_OF_CREATE

echo "*** MySQL - Configuring tables lxr_ in database linux_3_5_4"
mysql -u cgrtl -p9-410 <<END_OF_TEMPLATE
use linux_3_5_4;

/* Base version of files */
/*	revision:	a VCS generated unique id for this version
				of the file
 */
create table lxr_files
	( fileid    int auto_increment not null primary key
	, filename  varbinary(255)     not null
	, revision  varbinary(255)     not null
	, constraint lxr_uk_files
		unique (filename, revision)
	, index lxr_filelookup (filename)
	)
	engine = MyISAM;

/* Status of files in the DB */
/*	fileid:		refers to base version
 *	relcount:	number of releases associated with base version
 *	indextime:	time when file was parsed for references
 *	status:		set of bits with the following meaning
 *		1	declaration have been parsed
 *		2	references have been processed
 *	Though this table could be merged with 'files',
 *	performance is improved with access to a very small item.
 */
/* Deletion of a record automatically removes the associated
 * base version files record.
 */
create table lxr_status
	( fileid    int     not null primary key
	, relcount  int
	, indextime int
	, status    tinyint not null
	, constraint lxr_fk_sts_file
		foreign key (fileid)
		references lxr_files(fileid)
	)
	engine = MyISAM;

/* The following trigger deletes no longer referenced files
 * (from releases), once status has been deleted so that
 * foreign key constrained has been cleared.
 */
drop trigger if exists lxr_remove_file;
create trigger lxr_remove_file
	after delete on lxr_status
	for each row
		delete from lxr_files
			where fileid = old.fileid;

/* Aliases for files */
/*	A base version may be known under several releaseids
 *	if it did not change in-between.
 *	fileid:		refers to base version
 *	releaseid:	"public" release tag
 */
create table lxr_releases 
	( fileid    int            not null
	, releaseid varbinary(255) not null
	, constraint lxr_pk_releases
		primary key (fileid, releaseid)
	, constraint lxr_fk_rls_fileid
		foreign key (fileid)
		references lxr_files(fileid)
	)
	engine = MyISAM;

/* The following triggers maintain relcount integrity
 * in status table after insertion/deletion of releases
 */
drop trigger if exists lxr_add_release;
create trigger lxr_add_release
	after insert on lxr_releases
	for each row
		update lxr_status
			set relcount = relcount + 1
			where fileid = new.fileid;
/* Note: a release is erased only when option --reindexall
 * is given to genxref; it is thus necessary to reset status
 * to cause reindexing, especially if the file is shared by
 * several releases
 */
drop trigger if exists lxr_remove_release;
create trigger lxr_remove_release
	after delete on lxr_releases
	for each row
		update lxr_status
			set	relcount = relcount - 1
-- 			,	status = 0
			where fileid = old.fileid
			and relcount > 0;

/* Types for a language */
/*	declaration:	provided by generic.conf
 */
create table lxr_langtypes
	( typeid       smallint         not null auto_increment
	, langid       tinyint unsigned not null
	, declaration  varchar(255)     not null
	, constraint lxr_pk_langtypes
		primary key  (typeid, langid)
	)
	engine = MyISAM;

/* Symbol name dictionary */
/*	symid:		unique symbol id for name
 * 	symcount:	number of definitions and usages for this name
 *	symname:	symbol name
 */
create table lxr_symbols
	( symid    int            not null auto_increment primary key
	, symcount int
	, symname  varbinary(255) not null unique
	)
	engine = MyISAM;

/* The following function decrements the symbol reference count
 * (to be used in triggers).
 */
delimiter //
create procedure lxr_decsym(in whichsym int)
begin
	update lxr_symbols
		set	symcount = symcount - 1
		where symid = whichsym
		and symcount > 0;
end//
delimiter ;

/* Definitions */
/*	symid:	refers to symbol name
 *  fileid and line define the location of the declaration
 *	langid:	language id
 *	typeid:	language type id
 *	relid:	optional id of the englobing declaration
 *			(refers to another symbol, not a definition)
 */
create table lxr_definitions
	( symid   int              not null
	, fileid  int              not null
	, line    int              not null
	, typeid  smallint         not null
	, langid  tinyint unsigned not null
	, relid   int
	, index lxr_i_definitions (symid)
	, constraint lxr_fk_defn_symid
		foreign key (symid)
		references lxr_symbols(symid)
	, constraint lxr_fk_defn_fileid
		foreign key (fileid)
		references lxr_files(fileid)
	, index (typeid, langid)
	, constraint lxr_fk_defn_type
		foreign key (typeid, langid)
		references lxr_langtypes(typeid, langid)
	, constraint lxr_fk_defn_relid
		foreign key (relid)
		references lxr_symbols(symid)
	)
	engine = MyISAM;

/* The following trigger maintains correct symbol reference count
 * after definition deletion.
 */
drop trigger if exists lxr_remove_definition;
create trigger lxr_remove_definition
	after delete on lxr_definitions
	for each row
	call lxr_decsym(old.symid);

/* Usages */
create table lxr_usages
	( symid   int not null
	, fileid  int not null
	, line    int not null
	, index lxr_i_usages (symid)
	, constraint lxr_fk_use_symid
		foreign key (symid)
		references lxr_symbols(symid)
	, constraint lxr_fk_use_fileid
		foreign key (fileid)
		references lxr_files(fileid)
	)
	engine = MyISAM;

/* The following trigger maintains correct symbol reference count
 * after usage deletion.
 */
drop trigger if exists lxr_remove_usage;
create trigger lxr_remove_usage
	after delete on lxr_usages
	for each row
	call lxr_decsym(old.symid);

delimiter //
create procedure lxr_PurgeAll ()
begin
	set @old_check = @@session.foreign_key_checks;
	set session foreign_key_checks = OFF;
	truncate table lxr_definitions;
	truncate table lxr_usages;
	truncate table lxr_langtypes;
	truncate table lxr_symbols;
	truncate table lxr_releases;
	truncate table lxr_status;
	truncate table lxr_files;
	set session foreign_key_checks = @old_check;
end//
delimiter ;
END_OF_TEMPLATE

