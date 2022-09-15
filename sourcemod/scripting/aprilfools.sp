#include <sdktools>
#include <dhooks>
#include <scag>

static const char g_Sounds[][] = {
	"misc/happy_birthday_tf_01.wav",
	"misc/happy_birthday_tf_02.wav",
	"misc/happy_birthday_tf_03.wav",
	"misc/happy_birthday_tf_04.wav",
	"misc/happy_birthday_tf_10.wav",
	"misc/happy_birthday_tf_11.wav",
	"misc/happy_birthday_tf_12.wav",
	"misc/happy_birthday_tf_13.wav",
	"misc/happy_birthday_tf_14.wav",
	"misc/happy_birthday_tf_15.wav",
	"misc/happy_birthday_tf_16.wav",
}

public void OnPluginStart()
{
	GameData conf = new GameData("tf2.vsh2");
	DynamicDetour.FromConf(conf, "CTFFlameThrower::ComputeCrayAirBlastForce").Enable(Hook_Post, CTFFlameThrower_ComputeCrayAirBlastForce);
	DynamicDetour.FromConf(conf, "CTFPlayer::ApplyAbsVelocityImpulse").Enable(Hook_Pre, CTFPlayer_ApplyAbsVelocityImpulse);
	delete conf;
}

public void OnMapStart()
{
	PrecacheSoundList(g_Sounds, sizeof(g_Sounds));
}

static bool go;
public MRESReturn CTFFlameThrower_ComputeCrayAirBlastForce(Address pThis, DHookReturn hReturn, DHookParam params)
{
	if (!GetRandomInt(0, 10))
	{
		go = true;
	}
}

public MRESReturn CTFPlayer_ApplyAbsVelocityImpulse(int pThis, DHookParam params)
{
	if (go)
	{
		EmitSoundToAll(g_Sounds[GetRandomInt(0, sizeof(g_Sounds)-1)], pThis);
		float v[3]; params.GetVector(1, v);
		NegateVector(v);
		params.SetVector(1, v);
		go = false;
		return MRES_ChangedHandled;
	}
	return MRES_Ignored;
}