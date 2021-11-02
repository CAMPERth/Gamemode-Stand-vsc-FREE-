enum E_PLAYER_DATA // เราจะสร้าง enum ใหม่เพื่อเก็บข้อมูลผู้เล่น (ข้อมูล)
{
	ID,
	Password[129],
	Cash,
	Kills,
	Deaths
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];