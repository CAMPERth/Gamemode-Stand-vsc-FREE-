new
    MySQL:sql_handle, // ตัวแปร
    PlayerName[MAX_PLAYERS][30], // เราจะใช้ชื่อนี้เพื่อเก็บชื่อผู้เล่น
    PlayerIP[MAX_PLAYERS][17] // เราจะใช้ข้อมูลนี้เพื่อเก็บ IP Address ของผู้เล่น
;

native WP_Hash(buffer[], len, const str[]); // นี่คือฟังก์ชัน Whirlpool จำเป็นต้องใช้เพื่อเก็บรหัสผ่าน

Load_MYSQL()
{
	new MySQLOpt: option_id = mysql_init_options();
 
	mysql_set_option(option_id, AUTO_RECONNECT, true); // มันจะเชื่อมต่อใหม่โดยอัตโนมัติเมื่อขาดการเชื่อมต่อกับเซิร์ฟเวอร์ mysql
 
	sql_handle = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, option_id); // AUTO_RECONNECT ถูกเปิดใช้งานสำหรับตัวจัดการการเชื่อมต่อนี้เท่านั้น
	if (sql_handle == MYSQL_INVALID_HANDLE || mysql_errno(sql_handle) != 0)
	{
		print("MySQL connection failed. Server is shutting down."); // อ่านด้านล่าง
		SendRconCommand("exit"); // ปิดเซิร์ฟเวอร์หากไม่มีการเชื่อมต่อ
		return 1;
	}

	print("MySQL connection is successful."); // หากการเชื่อมต่อ MySQL สำเร็จ เราจะพิมพ์การดีบัก!
    return 1;
}

Checkid_Account(playerid)
{
	new query[140];
	GetPlayerName(playerid, PlayerName[playerid], 30); // ชื่อผู้เล่น
	GetPlayerIp(playerid, PlayerIP[playerid], 16); // ที่อยู่ IP ของผู้เล่น
 
	mysql_format(sql_handle, query, sizeof(query), "SELECT `Password`, `ID` FROM `users` WHERE `Username` = '%e' LIMIT 0, 1", PlayerName[playerid]); // รหัสผ่านและ ID จากชื่อผู้เล่น
	mysql_tquery(sql_handle, query, "Check_Account", "i", playerid);    
    return 1;
}