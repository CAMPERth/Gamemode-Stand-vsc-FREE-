enum E_PLAYER_DATA // เราจะสร้าง enum ใหม่เพื่อเก็บข้อมูลผู้เล่น (ข้อมูล)
{
	user_id,
	user_password[129],
	user_money,
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];