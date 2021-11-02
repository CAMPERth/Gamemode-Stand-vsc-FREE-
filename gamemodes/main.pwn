/* 
   ʤ�Ի���ǹ��١�Ѳ����дѴ�ŧ�ա�ըҡ  https://pastebin.com/ETNALFd6 

   CAMPERth (2021) MYSQL R41-4 Login/Register/ Basic

*/ 


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
public OnGameModeExit()
{
    //mysql_close(sql_handle);
	return 1;
}
 
public OnPlayerConnect(playerid)
{
	Checkid_Account(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	// ����¹�ش�Դ�ç���
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerFacingAngle(playerid, 269.1425);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SavePlayer(playerid); // ૿������
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response) 
		return Kick(playerid); // �ҡ�����蹡��͡ ����оǡ��
 
	new password[129], query[100];
	WP_Hash(password, 129, inputtext); // �Ϊ���ʼ�ҹ����������¹㹪�ͧ��ͺ����������к�
	if(!strcmp(password, PlayerData[playerid][user_password])) // ��Ǩ�ͺ������ʼ�ҹ��������㹡��ŧ����¹�Ѻ����觢ѹ
	{ // ����ѹ�ç�ѹ
		mysql_format(sql_handle, query, sizeof(query), "SELECT * FROM `users` WHERE `Username` = '%e' LIMIT 0, 1", PlayerName[playerid]);
		mysql_tquery(sql_handle, query, "LoadPlayer", "i", playerid); //���¡ LoadPlayer 
	}
	else // �ҡ���ʼ�ҹ���ç�ѹ
	{
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "�������к�", "{FF0000}���ʼ�ҹ���١��ͧ!\n{FFFFFF}��������ʼ�ҹ���١��ͧ��ҹ��ҧ���ʹ��Թ��õ�����ŧ���������ѭ�բͧ�س", "�������к�", "�͡");
		// ��Ҩ��ʴ����ͧ��ͺ����������蹷�Һ�������Ҿǡ������¹���ʼ�ҹ������١��ͧ
	}
	return 1;
}
 
Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if(!response)
		return Kick(playerid);
 
	if(strlen(inputtext) < 3) return Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "ŧ����¹", "{FF0000}���ʼ�ҹ���!\n{FFFFFF}��������ʼ�ҹ 3 ��Ǣ����ҡ�س��ͧ���ŧ����¹�����蹺������������", "ŧ����¹", "�͡");
	// �ҡ���ʼ�ҹ���ѡ��й��¡��� 3 ��� ����ʴ����ͧ��ͺ���͡����͹���ʼ�ҹ 3 ��Ǣ���
	new query[300];
	WP_Hash(PlayerData[playerid][user_password], 129, inputtext); // �Ϊ���ʼ�ҹ����������¹ŧ㹡��ͧ��ͺ���ŧ����¹���� Whirlpool
	mysql_format(sql_handle, query, sizeof(query), "INSERT INTO `users` (`Username`, `Password`, `IP`) VALUES ('%e', '%e', '%e')", PlayerName[playerid], PlayerData[playerid][user_password], PlayerIP[playerid]);
	// �á�����ż�����ŧ㹰ҹ������ MySQL ��������������ö��Ŵ��������ѧ
	mysql_pquery(sql_handle, query, "RegisterPlayer", "i", playerid); // ���¡��觹��ѹ�շ�������ŧ����¹�����
	return 1;
}
 
forward Check_Account(playerid);
public Check_Account(playerid)
{
	new rows, string[150];
	cache_get_row_count(rows);
 
	if(rows) // If row exists 
	{
		cache_get_value_name(0, "Password", PlayerData[playerid][user_password], 129); // ��Ŵ���ʼ�ҹ�ͧ������
		cache_get_value_name_int(0, "ID", PlayerData[playerid][user_id]); // ��Ŵ ID ������
		format(string, sizeof(string), "�Թ�յ�͹�Ѻ��Ѻ������������\n�ô��������ʼ�ҹ�ͧ�س��ҹ��ҧ�����������к��ѭ�բͧ�س"); // ���ͧ��ͺ�л�ҡ�������ͺ͡����������¹���ʼ�ҹ��ҹ��ҧ�����������к�
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Exit");
	}
	else // �ҡ������� ��ҵ�ͧ�ʴ������͡�ը������!
	{	
		format(string, sizeof(string), "�Թ�յ�͹�Ѻ������������ͧ���\n�ҡ�س��ͧ�����蹷���� �س��ͧŧ����¹�ѭ�� ��������ʼ�ҹ���Ҵ���ҡ��ҹ��ҧ����ŧ����¹"); // ���ͧ��ͺ����պѹ�֡��͹��л�ҡ������������������ŧ����¹�ѭ�բͧ��
		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", string, "Register", "Exit");
	}
	return 1;
}
 
// ��Ŵ������
forward LoadPlayer(playerid);
public LoadPlayer(playerid)
{
	cache_get_value_name_int(0, "user_money", PlayerData[playerid][user_money]);
	return 1;
}
 
// ૿������ 
forward SavePlayer(playerid);
public SavePlayer(playerid)
{
	new query[140];
	mysql_format(sql_handle, query, sizeof(query), "UPDATE `users` SET `user_money` = '%d' WHERE `ID` = '%d'", PlayerData[playerid][user_money], PlayerData[playerid][user_id]);
	mysql_tquery(sql_handle, query);
	return 1;
}

// ��ѧ�ҡ�� ��Ѥ� 
forward RegisterPlayer(playerid);
public RegisterPlayer(playerid)
{
	new string[150];
	format(string, sizeof(string), "�Թ�յ�͹�Ѻ��Ѻ������������\n�ô��������ʼ�ҹ�ͧ�س��ҹ��ҧ�����������к��ѭ�բͧ�س"); // ���ͧ��ͺ�л�ҡ�������ͺ͡����������¹���ʼ�ҹ��ҹ��ҧ�����������к�
	Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Exit");	

	PlayerData[playerid][user_id] = cache_insert_id();
	printf("> playerid %d has been registered!", PlayerData[playerid][user_id]);
	return 1;
}