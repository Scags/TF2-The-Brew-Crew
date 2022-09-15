#pragma semicolon 1
#pragma newdecls required

#include <smmem>

float g_Value;
Address g_Addr;
Address g_Old;

ConVar cvMilk;

public void OnPluginStart()
{
    DynLib lib = new DynLib("./tf/bin/server_srv.so");
    g_Addr = lib.ResolveSymbol("_ZN13CTFWeaponBase20ApplyOnHitAttributesEP11CBaseEntityP9CTFPlayerRK15CTakeDamageInfo") + view_as<Address>(5431);
  	delete lib;

    cvMilk = CreateConVar("sm_milk_pct", "0.3", "Milk damage to health %", FCVAR_NOTIFY);
    cvMilk.AddChangeHook(OnMilkCVarChange);
    AutoExecConfig(true, "TF2Milk");
    Patch();
}

public void OnMilkCVarChange(ConVar convar, const char[] old, const char[] neww)
{
    Patch();
}

public void Patch()
{
    // This method *requires* the var to be global, otherwise Very Bad Things will happen!
    g_Value = cvMilk.FloatValue;
    Address addr = AddressOf(g_Value);
    WriteVal(g_Addr, addr);
}

public void OnPluginEnd()
{
    WriteVal(g_Addr, g_Old);
} 