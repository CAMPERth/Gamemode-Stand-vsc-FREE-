new
    MySQL:sql_handle, // �����
    PlayerName[MAX_PLAYERS][30], // ��Ҩ�����͹�������纪��ͼ�����
    PlayerIP[MAX_PLAYERS][17] // ��Ҩ�������Ź�������� IP Address �ͧ������
;

native WP_Hash(buffer[], len, const str[]); // ����Ϳѧ��ѹ Whirlpool ���繵�ͧ�����������ʼ�ҹ

Load_MYSQL()
{
	new MySQLOpt: option_id = mysql_init_options();
 
	mysql_set_option(option_id, AUTO_RECONNECT, true); // �ѹ�����������������ѵ��ѵ�����͢Ҵ����������͡Ѻ��������� mysql
 
	sql_handle = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, option_id); // AUTO_RECONNECT �١�Դ��ҹ����Ѻ��ǨѴ��á���������͹����ҹ��
	if (sql_handle == MYSQL_INVALID_HANDLE || mysql_errno(sql_handle) != 0)
	{
		print("MySQL connection failed. Server is shutting down."); // ��ҹ��ҹ��ҧ
		SendRconCommand("exit"); // �Դ����������ҡ����ա����������
		return 1;
	}

	print("MySQL connection is successful."); // �ҡ����������� MySQL ����� ��Ҩо�����ôպѡ!
    return 1;
}

Checkid_Account(playerid)
{
	new query[140];
	GetPlayerName(playerid, PlayerName[playerid], 30); // ���ͼ�����
	GetPlayerIp(playerid, PlayerIP[playerid], 16); // ������� IP �ͧ������
 
	mysql_format(sql_handle, query, sizeof(query), "SELECT `Password`, `ID` FROM `users` WHERE `Username` = '%e' LIMIT 0, 1", PlayerName[playerid]); // ���ʼ�ҹ��� ID �ҡ���ͼ�����
	mysql_tquery(sql_handle, query, "Check_Account", "i", playerid);    
    return 1;
}