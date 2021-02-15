unit _define;

interface

uses
  Graphics;

const
  // Allgemein
  COMMON_EXT_PROJECT           = '.mdb';
  COMMON_EXT_MSACCESS          = '.mdb';
  COMMON_EXT_MAP               = '.zip';

  // Tabellen
  TABLE_COMMON                 = 'common';
  TABLE_CUSTOMERS              = 'customers';
  TABLE_CUSTOMERTYPES          = 'customertypes';
  TABLE_SHOPS                  = 'shops';
  TABLE_SHOPTYPES              = 'shoptypes';
  TABLE_DATES                  = 'dates';
  TABLE_DATESHOP               = 'dateshop';


  // Ansicht
  ROTATE_POINT_RADIUS          = 4;
  SHOP_PAINTER_OFFSET          = 80;
  SHOP_SIZE_MAXWIDTH           = 20.0; {Float!}
  SHOP_SIZE_MAXHEIGHT          = 10.0; {Float!}

  COLOR_SHOP_SELECTION         = clBlue;
  COLOR_SHOP_SELECTION_BORDER  = clFuchsia;

  COLOR_SHOP_NOCUSTOMER        = clRed;




  // Access Connection String
  ACCESS_CONNECTION_STRING     = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source="%s";Password="%s"';


  
  // *.jidb [*.mdb]
  TABLE_CREATE_COMMON          = 'CREATE TABLE `'+TABLE_COMMON+'` ('
                               + '  name VARCHAR PRIMARY KEY,'
                               + '  value VARCHAR'
                               + ')';

  TABLE_CREATE_CUSTOMERS       = 'CREATE TABLE `'+TABLE_CUSTOMERS+'` ('
                               + '  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
                               + '  firstname VARCHAR NOT NULL,'
                               + '  lastname VARCHAR NOT NULL,'
                               + '  company VARCHAR,'
                               + '  address VARCHAR,'
                               + '  zip INTEGER,'
                               + '  city VARCHAR,'
                               + '  phone VARCHAR,'
                               + '  email VARCHAR,'
                               + '  other VARCHAR'
                               + ')';

  TABLE_CREATE_SHOPS           = 'CREATE TABLE `'+TABLE_SHOPS+'` ('
                               + '  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
                               + '  customerid INTEGER DEFAULT 0,'
                               + '  width INTEGER NOT NULL DEFAULT 0,'
                               + '  height INTEGER NOT NULL DEFAULT 0,'
                               + '  x INTEGER NOT NULL DEFAULT 0,'
                               + '  y INTEGER NOT NULL DEFAULT 0,'
                               + '  angle INTEGER NOT NULL DEFAULT 0,'
                               + '  color VARCHAR DEFAULT "",'
                               + '  address VARCHAR DEFAULT ""'
                               + ')';



                               
  // Common
  QUERY_COMMON_LOAD            = 'SELECT * FROM `'+TABLE_COMMON+'`';
  QUERY_COMMON_SET_FIELD       = 'UPDATE `'+TABLE_COMMON+'` '
                               + 'SET `value`=''%s'' '
                               + 'WHERE `name`=''%s''';



  // Customers
  QUERY_CUSTOMERS_LOAD         = 'SELECT * FROM `'+TABLE_CUSTOMERS+'`';
  QUERY_CUSTOMERS_NEW          = 'INSERT INTO `'+TABLE_CUSTOMERS+'` '
                               + '( `cid`, `firstname`, `lastname`, `company`, `address`, `zip`, `city`, `sex`, `typeid`, `phone`, `email`, `other` ) '
                               + 'VALUES ( %d, ''%s'', ''%s'', ''%s'', ''%s'', %d, ''%s'', ''%s'', %d, ''%s'', ''%s'', ''%s'')';
  QUERY_CUSTOMERS_EDIT         = 'UPDATE `'+TABLE_CUSTOMERS+'` '
                               + 'SET `cid` = %d, `firstname` = ''%s'', `lastname` = ''%s'', `company` = ''%s'', `address` = ''%s'', `zip` = %d, `city` = ''%s'',`sex` = ''%s'',`typeid` = %d, `phone` = ''%s'', `email` = ''%s'', `other` = ''%s'' '
                               + 'WHERE `id` = %d';
  QUERY_CUSTOMERS_DELETE       = 'DELETE FROM `'+TABLE_CUSTOMERS+'` '
                               + 'WHERE id = %d';
  QUERY_CUSTOMERS_LASTID       = 'SELECT max(`id`) FROM `'+TABLE_CUSTOMERS+'`';
  QUERY_CUSTOMERS_LASTCID      = 'SELECT max(`cid`) FROM `'+TABLE_CUSTOMERS+'`';


  // Customer-Typen
  QUERY_CUSTOMERTYPES_LOAD     = 'SELECT * FROM `'+TABLE_CUSTOMERTYPES+'` '
                               + 'ORDER BY `title` ASC';
  QUERY_CUSTOMERTYPES_NEW      = 'INSERT INTO `'+TABLE_CUSTOMERTYPES+'` '
                               + '( `title`, `multiplier` ) '
                               + 'VALUES ( ''%s'', ''%f'' )';
  QUERY_CUSTOMERTYPES_EDIT     = 'UPDATE `'+TABLE_CUSTOMERTYPES+'` '
                               + 'SET `title`=''%s'', `multiplier`=''%f'' '
                               + 'WHERE `id`=%d';
  QUERY_CUSTOMERTYPES_DELETE   = 'DELETE FROM `'+TABLE_CUSTOMERTYPES+'` '
                               + 'WHERE `id` = %d';
  QUERY_CUSTOMERTYPES_LASTID   = 'SELECT max(`id`) FROM `'+TABLE_CUSTOMERTYPES+'`';




  // Shops
  QUERY_SHOPS_LOAD             = //'SELECT * FROM `'+TABLE_SHOPS+'`';
  
                                 'SELECT s.*, st.title AS `typestr` '
                               + 'FROM `'+TABLE_SHOPS+'` AS s '
                               + 'INNER JOIN `'+TABLE_SHOPTYPES+'` AS st ON s.typeid=st.id';

  QUERY_SHOPS_NEW              = 'INSERT INTO `'+TABLE_SHOPS+'` '
                               + '( `customerid`, `typeid`, `locationid`, `width`, `height`, `x`, `y`, `angle`, `address`, `price`, `other` ) '
                               + 'VALUES ( %d, %d, %d, ''%f'', ''%f'', %d, %d, %d, ''%s'', ''%f'', ''%s'' )';
  QUERY_SHOPS_EDIT             = 'UPDATE `'+TABLE_SHOPS+'` '
                               + 'SET `customerid`=%d, `typeid`=%d, `locationid`=%d, `width`=''%f'', `height`=''%f'', `x` = %d, `y` = %d, `angle` = %d, `address` = ''%s'', `price` = ''%f'', `other` = ''%s'' '
                               + 'WHERE `id` = %d';
  QUERY_SHOPS_DELETE           = 'DELETE FROM `'+TABLE_SHOPS+'` '
                               + 'WHERE `id` = %d';
  QUERY_SHOPS_LASTID           = 'SELECT MAX(`id`) FROM `'+TABLE_SHOPS+'`';

  QUERY_SHOPDATE_CHECK         = 'SELECT `dateid` FROM `'+TABLE_DATESHOP+'` '
                               + 'WHERE `dateid`=%d AND `shopid`=%d';



  // Dates
  QUERY_DATES_LOAD             = 'SELECT * FROM `'+TABLE_DATES+'` '
                               + 'ORDER BY `date` ASC';
  QUERY_DATES_NEW              = 'INSERT INTO `'+TABLE_DATES+'` '
                               + '( `active`, `title`, `short`, `date`, `price` ) '
                               + 'VALUES ( %d, ''%s'', ''%s'', ''%s'', ''%s'' )';
  QUERY_DATES_EDIT             = 'UPDATE `'+TABLE_DATES+'` '
                               + 'SET `active`=%d, `title`=''%s'', `short`=''%s'', `date`=''%s'', `price`=''%s'' '
                               + 'WHERE `id`=%d';
  QUERY_DATES_DELETE           = 'DELETE FROM `'+TABLE_DATES+'` '
                               + 'WHERE `id` = %d';
  QUERY_DATES_LASTID           = 'SELECT max(`id`) FROM `'+TABLE_DATES+'`';



  // Shop-Dates
  QUERY_SHOPDATES_LOAD         = 'SELECT * FROM `'+TABLE_DATESHOP+'`';
  QUERY_SHOPDATES_NEW          = 'INSERT INTO `'+TABLE_DATESHOP+'` '
                               + '( `dateid`, `shopid` ) '
                               + 'VALUES ( %d, %d )';
  QUERY_SHOPDATES_EDIT         = 'UPDATE `'+TABLE_DATESHOP+'` '
                               + 'SET `dateid`=%d, `shopid`=%d '
                               + 'WHERE `dateid` = %d AND `shopid` = %d';
  QUERY_SHOPDATES_DELETE       = 'DELETE FROM `'+TABLE_DATESHOP+'` '
                               + 'WHERE `dateid` = %d AND `shopid` = %d';
  QUERY_SHOPDATES_DELETESHOP   = 'DELETE FROM `'+TABLE_DATESHOP+'` '
                               + 'WHERE `shopid` = %d';
  QUERY_SHOPDATES_DELETEDATE   = 'DELETE FROM `'+TABLE_DATESHOP+'` '
                               + 'WHERE `dateid` = %d';



  // Shop-Typen
  QUERY_SHOPTYPES_LOAD         = 'SELECT * FROM `'+TABLE_SHOPTYPES+'` '
                               + 'ORDER BY `title` ASC';
  QUERY_SHOPTYPES_NEW          = 'INSERT INTO `'+TABLE_SHOPTYPES+'` '
                               + '( `title`, `color`, `bcolor`, `visible`, `alpha`) '
                               + 'VALUES ( ''%s'', ''%s'', ''%s'', %d, %d )';
  QUERY_SHOPTYPES_EDIT         = 'UPDATE `'+TABLE_SHOPTYPES+'` '
                               + 'SET `title`=''%s'', `color`=''%s'', `bcolor`=''%s'', `visible`=%d, `alpha`=%d '
                               + 'WHERE `id`=%d';
  QUERY_SHOPTYPES_DELETE       = 'DELETE FROM `'+TABLE_SHOPTYPES+'` '
                               + 'WHERE `id` = %d';
  QUERY_SHOPTYPES_LASTID       = 'SELECT max(`id`) FROM `'+TABLE_SHOPTYPES+'`';



  // Map
  DLL_SQLITE              = 'sqlite3.dll';
  DLL_UNZIP               = 'UnzDll.dll';

  FILE_SETTINGS           = 'settings.ini';
  FILE_NAVIGATOR          = 'navi.jpg';
  FILE_LOCATIONS          = 'locations.ini';

  INI_SECTION_MAP         = 'map';
  INI_SECTION_PIECES      = 'pieces';
  INI_SECTION_LOCATIONS   = 'locations';

implementation
initialization

end.
 