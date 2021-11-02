#include <a_samp>

#include <a_mysql>
#include <easyDialog>

main()
{
	print("\n----------------------------------");
	print("By CAMPERth");
	print("----------------------------------\n");
}

#include "src/enums.pwn"

#include "src/mysql/connect.pwn"
#include "src/mysql/main.pwn"

public OnGameModeInit()
{
	Load_MYSQL();
	SetGameModeText("SERVER VERSION");
	return 1;
}
 
public OnPlayerConnect(playerid)
{
	Checkid_Account(playerid);
	return 1;
}
 
public OnPlayerDisconnect(playerid, reason)
{
	mysql_close(sql_handle);
	SavePlayer(playerid); // เซฟข้อมูล
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response) 
		return Kick(playerid); // หากผู้เล่นกดออก ให้เตะพวกเขา
 
	new password[129], query[100];
	WP_Hash(password, 129, inputtext); // แฮชรหัสผ่านที่ผู้เล่นเขียนในช่องโต้ตอบการเข้าสู่ระบบ
	if(!strcmp(password, PlayerData[playerid][Password])) // ตรวจสอบว่ารหัสผ่านที่เราใช้ในการลงทะเบียนกับการแข่งขัน
	{ // ถ้ามันตรงกัน
		mysql_format(sql_handle, query, sizeof(query), "SELECT * FROM `users` WHERE `Username` = '%e' LIMIT 0, 1", PlayerName[playerid]);
		mysql_tquery(sql_handle, query, "LoadPlayer", "i", playerid); //เรียก LoadPlayer 
	}
	else // หากรหัสผ่านไม่ตรงกัน
	{
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "เข้าสู่ระบบ", "{FF0000}รหัสผ่านไม่ถูกต้อง!\n{FFFFFF}พิมพ์รหัสผ่านที่ถูกต้องด้านล่างเพื่อดำเนินการต่อและลงชื่อเข้าใช้บัญชีของคุณ", "เข้าสู่ระบบ", "ออก");
		// เราจะแสดงกล่องโต้ตอบนี้ให้ผู้เล่นทราบและแจ้งว่าพวกเขาได้เขียนรหัสผ่านที่ไม่ถูกต้อง
	}
	return 1;
}
 
Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if(!response)
		return Kick(playerid);
 
	if(strlen(inputtext) < 3) return Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "ลงทะเบียน", "{FF0000}รหัสผ่านสั้น!\n{FFFFFF}พิมพ์รหัสผ่าน 3 ตัวขึ้นไปหากคุณต้องการลงทะเบียนและเล่นบนเซิร์ฟเวอร์นี้", "ลงทะเบียน", "ออก");
	// หากรหัสผ่านมีอักขระน้อยกว่า 3 ตัว ให้แสดงกล่องโต้ตอบที่บอกให้ป้อนรหัสผ่าน 3 ตัวขึ้นไป
	new query[300];
	WP_Hash(PlayerData[playerid][Password], 129, inputtext); // แฮชรหัสผ่านที่ผู้เล่นเขียนลงในกล่องโต้ตอบการลงทะเบียนโดยใช้ Whirlpool
	mysql_format(sql_handle, query, sizeof(query), "INSERT INTO `users` (`Username`, `Password`, `IP`, `Cash`, `Kills`, `Deaths`) VALUES ('%e', '%e', '%e', 0, 0, 0)", PlayerName[playerid], PlayerData[playerid][Password], PlayerIP[playerid]);
	// แทรกข้อมูลผู้เล่นลงในฐานข้อมูล MySQL เพื่อให้เราสามารถโหลดได้ในภายหลัง
	mysql_pquery(sql_handle, query, "RegisterPlayer", "i", playerid); // เรียกสิ่งนี้ทันทีที่ผู้เล่นลงทะเบียนสำเร็จ
	return 1;
}
 
forward Check_Account(playerid);
public Check_Account(playerid)
{
	new rows, string[150];
	cache_get_row_count(rows);
 
	if(rows) // If row exists 
	{
		cache_get_value_name(0, "Password", PlayerData[playerid][Password], 129); // โหลดรหัสผ่านของผู้เล่น
		cache_get_value_name_int(0, "ID", PlayerData[playerid][ID]); // โหลด ID ผู้เล่น
		format(string, sizeof(string), "ยินดีต้อนรับกลับสู่เซิร์ฟเวอร์\nโปรดพิมพ์รหัสผ่านของคุณด้านล่างเพื่อเข้าสู่ระบบบัญชีของคุณ"); // กล่องโต้ตอบจะปรากฏขึ้นเพื่อบอกให้ผู้เล่นเขียนรหัสผ่านด้านล่างเพื่อเข้าสู่ระบบ
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Exit");
	}
	else // หากไม่มีแถว เราต้องแสดงไดอะล็อกรีจิสเตอร์!
	{	
		format(string, sizeof(string), "ยินดีต้อนรับสู่เซิร์ฟเวอร์ของเรา\nหากคุณต้องการเล่นที่นี่ คุณต้องลงทะเบียนบัญชี พิมพ์รหัสผ่านที่คาดเดายากด้านล่างเพื่อลงทะเบียน"); // กล่องโต้ตอบที่มีบันทึกย่อนี้จะปรากฏขึ้นเพื่อแจ้งให้ผู้เล่นลงทะเบียนบัญชีของเขา
		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", string, "Register", "Exit");
	}
	return 1;
}
 
// โหลดข้อมูล
forward LoadPlayer(playerid);
public LoadPlayer(playerid)
{
	cache_get_value_name_int(0, "Cash", PlayerData[playerid][Cash]);
	cache_get_value_name_int(0, "Kills", PlayerData[playerid][Kills]);
	cache_get_value_name_int(0, "Deaths", PlayerData[playerid][Deaths]);
	return 1;
}
 
// เซฟข้อมูล 
forward SavePlayer(playerid);
public SavePlayer(playerid)
{
	new query[140];
	mysql_format(sql_handle, query, sizeof(query), "UPDATE `users` SET `Cash` = '%d', `Kills` = '%d', `Deaths` = '%d' WHERE `ID` = '%d'", PlayerData[playerid][Cash], PlayerData[playerid][Kills], PlayerData[playerid][Deaths], PlayerData[playerid][ID]);
	mysql_tquery(sql_handle, query);
	return 1;
}

// หลังจากกด สมัคร 
forward RegisterPlayer(playerid);
public RegisterPlayer(playerid)
{
	PlayerData[playerid][ID] = cache_insert_id();
	printf("> playerid %d has been registered!", PlayerData[playerid][ID]);
	return 1;
}