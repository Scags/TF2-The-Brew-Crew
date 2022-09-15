
//defines
/*
#define VagineerModel		"models/player/saxton_hale/vagineer_v134.mdl"
#define VagineerModelPrefix	"models/player/saxton_hale/vagineer_v134"
*/

#define VagineerModel		"models/player/saxton_hale/vagineer_v150.mdl"
// #define VagineerModelPrefix	"models/player/saxton_hale/vagineer_v150"


//Vagineer voicelines
#define VagineerLastA		"saxton_hale/lolwut_0.wav"
#define VagineerRageSound	"saxton_hale/lolwut_2.wav"
#define VagineerStart		"saxton_hale/lolwut_1.wav"
#define VagineerKSpree		"saxton_hale/lolwut_3.wav"
#define VagineerKSpree2		"saxton_hale/lolwut_4.wav"
#define VagineerHit		"saxton_hale/lolwut_5.wav"
#define VagineerRoundStart	"saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump		"saxton_hale/vagineer_responce_jump_"		//1-2
#define VagineerRageSound2	"saxton_hale/vagineer_responce_rage_"		//1-4
#define VagineerKSpreeNew	"saxton_hale/vagineer_responce_taunt_"		//1-5
#define VagineerFail		"saxton_hale/vagineer_responce_fail_"		//1-2
#define VagTheme			"saxton_hale/vagtheme.mp3"
#define VagTheme2			"saxton_hale/georgia.mp3"
#define VagTheme3			"saxton_hale/vagtheme3_fix2.mp3"

#define VAGRAGEDIST		533.333


methodmap CVagineer < BaseBoss
{
	public CVagineer(const int ind, bool uid = false)
	{
		if (uid)
			return view_as<CVagineer>( BaseBoss(ind, true) );
		return view_as<CVagineer>( BaseBoss(ind) );
	}

	public void PlaySpawnClip()
	{
		char snd[PLATFORM_MAX_PATH];
		if (!GetRandomInt(0, 1))
			strcopy(snd, PLATFORM_MAX_PATH, VagineerStart);
		else strcopy(snd, PLATFORM_MAX_PATH, VagineerRoundStart);

		EmitSoundToAll(snd);
	}

	public void Think ()
	{
		this.DoGenericThink(true, true, VagineerJump, 2, false);

		if (TF2_IsPlayerInCondition(this.index, TFCond_Ubercharged))
			SetEntProp(this.index, Prop_Data, "m_takedamage", 0);
		else SetEntProp(this.index, Prop_Data, "m_takedamage", 2);
	}
	public void SetModel ()
	{
		SetVariantString(VagineerModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		char snd[PLATFORM_MAX_PATH];
		Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}

	public void Equip ()
	{
		this.PreEquip();
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 436 ; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_wrench", 169, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if ( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); //MakeModelTimer(null);
		}
		TF2_AddCondition(this.index, TFCond_Ubercharged, 10.0);
		this.DoGenericStun(VAGRAGEDIST);

		char snd[PLATFORM_MAX_PATH];
		if (GetRandomInt(0, 2))
			strcopy(snd, PLATFORM_MAX_PATH, VagineerRageSound);
		else Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));

		float pos[3]; GetClientAbsOrigin(this.index, pos);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, pos, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, pos, NULL_VECTOR, false, 0.0);
		for (int i = MaxClients; i; --i)
		{
			if (IsClientInGame(i) && !BaseBoss(i).bIsBoss)
			{
				EmitSoundToClient(i, snd, this.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, pos, NULL_VECTOR, true, 0.0);
				EmitSoundToClient(i, snd, this.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, pos, NULL_VECTOR, true, 0.0);
			}
		}
	}

	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		char snd[PLATFORM_MAX_PATH];
		strcopy(snd, PLATFORM_MAX_PATH, VagineerHit);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

		this.iKills++;
		
		if (!(this.iKills % 3)) {
			switch (GetRandomInt(0, 4))
			{
				case 1, 3: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree);
				case 2: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree2);
				default: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			}
			EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, this.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
	public void Help()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[] = "Vagineer:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Uber): Call for medic (e) when the Rage Meter is full to stun fairly close-by enemies.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
	}
	public void LastPlayerSoundClip()
	{
		EmitSoundToAll(VagineerLastA);
	}
};

public CVagineer ToCVagineer (const BaseBoss guy)
{
	return view_as<CVagineer>(guy);
}

public void AddVagToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	
	int i;

	PrepareModel(VagineerModel);

	PrepareSound(VagineerLastA);
	PrepareSound(VagineerStart);
	PrepareSound(VagineerRageSound);
	PrepareSound(VagineerKSpree);
	PrepareSound(VagineerKSpree2);
	PrepareSound(VagineerHit);
	PrepareSound(VagineerRoundStart);
	PrepareSound(VagTheme);
	PrepareSound(VagTheme2);
	PrepareSound(VagTheme3);

	for (i = 1; i <= 5; i++)
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
		PrepareSound(s);
	}

	PrecacheSound("vo/engineer_positivevocalization01.mp3", true);
}

public void AddVagToMenu ( Menu& menu )
{
	menu.AddItem("1", "Vagineer");
}

