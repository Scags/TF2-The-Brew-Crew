#if !defined _sourcemod_included
#include <sourcemod>
#endif
#include <tf2_stocks>
// #include <morecolors>
// #include <dhooks>
// #include <tf2items>
// #include <profiler>
// #include <clientprefs>
// #include <steamworks>
// #include <steamtools>
// #include <socket>
// #include <smjansson>

#define UNASSIGNED 			0
#define NEUTRAL 			0
#define SPEC 				1
#define RED 				2
#define BLU 				3

#define int(%1)				view_as<int>(%1)
#define Handle(%1)			view_as<Handle>(%1)
#define Address(%1)			view_as<Address>(%1)

#define nullfunc			INVALID_FUNCTION
#define nullvec				NULL_VECTOR
#define nullstr				NULL_STRING
#define nullptr 			Address_Null
#define toggle(%1)			%1 = !%1

#define _buffer(%1)			%1, sizeof(%1)
#define _strbuffer(%1)		%1, sizeof(%1)
#define PLYR				MAXPLAYERS+1
#define	MAX_EDICT_BITS		11
//#define	MAX_EDICTS			(1 << MAX_EDICT_BITS)
#define IsEntityValid(%1)	(%1 > MaxClients && IsValidEntity(%1))
#define IsClientValid(%1)	(0 < %1 && %1 <= MaxClients && IsClientInGame(%1))
#define PATH				64
#define FULLPATH			PLATFORM_MAX_PATH
#define repeat(%1)			for (int xyz=0; xyz<%1; ++xyz)
#define Repeat(%1)			for (int xyz=0; xyz<%1; ++xyz)
#define MEDIGUN_RANGE 		450.0
#define Pointer 			Address
#define ptr 				Address

#define FULLTIMER			TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE
#define HALFTIMER1			TIMER_REPEAT
#define HALFTIMER2			TIMER_FLAG_NO_MAPCHANGE
#define TDHC 				TIMER_DATA_HNDL_CLOSE
#define TPACK 				TIMER_DATA_HNDL_CLOSE

#define RAD2DEG(%1) ((%1) * (180.0 / FLOAT_PI))
#define DEG2RAD(%1) ((%1) * FLOAT_PI / 180.0)

#define REPEAT() 			for (int i = MaxClients; i; --i) if IsClientInGame(i)

#define StateDisabled 		-1
#define StateStarting		0
#define StateRunning 		1
#define StateEnding 		2

#define IntGet(%1) 		public get()\
{\
	int i; this.GetValue(%1, i);\
	return i;\
} 
#define IntSet(%1) 		public set( const int i )\
{\
	this.SetValue(%1, i);\
}
#define BoolGet(%1) 	public get()\
{\
	bool i; this.GetValue(%1, i);\
	return i;\
}
#define BoolSet(%1) 	public set( const bool i )\
{\
	this.SetValue(%1, i);\
}
#define FloatGet(%1) 	public get()\
{\
	float i; this.GetValue(%1, i);\
	return i;\
}
#define FloatSet(%1) 	public set( const float i )\
{\
	this.SetValue(%1, i);\
}

//stock char snd[PLATFORM_MAX_PATH];
stock char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
stock char extensionsb[2][5] = { ".vtf", ".vmt" };
stock char strTargetEntities[][] =
{
	"player",
	"tank_boss",
	"headless_hatman",
	"eyeball_boss",
	"merasmus",
	"tf_zombie",
	"tf_robot_destruction_robot",
	"obj_sentrygun",
	"obj_dispenser",
	"obj_teleporter"
};

stock const int TF2_MaxSentryShells[]  = { 0, 100, 120, 144, 255 };
stock const int TF2_MaxSentryRockets[] = { 0,   0,   0,  20,  64 };
stock const int TF2_SentryHealth[]     = { 0, 150, 180, 216, 511 };


/*
	// 150 L; 149 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(149);
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((hWorldSpaceCenter = EndPrepSDKCall()) == null)
		SetFailState("Failed to prep CBaseEntity::WorldSpaceCenter");

	// 286 L; 280 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(280);
	if ((hSecondaryAttack = EndPrepSDKCall()) == null)
		SetFailState("Failed to prep CTFFlameThrower::SecondaryAttack");

	// 276 L; 270 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(270);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((hCanPerformSecondaryAttack = EndPrepSDKCall()) == null)
		SetFailState("Failed to prep CTFWeaponBase::CanPerformSecondaryAttack");

	// 490 L; 483 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(483);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if ((hGetTargetRange = EndPrepSDKCall()) == null)
		SetFailState("Failed to prep CWeaponMedigun::GetTargetRange");

	// 486 L; 479 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(479);
	if (!(hZoomIn = EndPrepSDKCall()))
		SetFailState("Failed to prep CTFWeaponBaseGun::ZoomIn");

	// 487 L; 480 W
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(480);
	if (!(hZoomOut = EndPrepSDKCall()))
		SetFailState("Failed to prep CTFWeaponBaseGun::ZoomOut");

	Flamethrower attributes are fucked up after Jungle Inferno, these static attribs are required whenever spawning them
"flame_gravity"                         "0"
"flame_drag"                            "8.5"
"flame_up_speed"                        "50"
"flame_speed"                           "2450"
"flame_spread_degree"                   "2.8"
"flame_lifetime"                        "0.6"
"flame_random_life_time_offset"         "0.1"

*/

methodmap Metronome < Handle
{
	public Metronome( float interval, Timer func, any data=INVALID_HANDLE, int flags=0 )
	{
		return view_as< Metronome >(CreateTimer(interval, func, data, flags));
	}
	public void Kill( bool autoClose=false )
	{
		KillTimer(this, autoClose);
	}
	public void Trigger( bool reset=false )
	{
		TriggerTimer(this, reset);
	}
};
#if defined _sdktools_included
methodmap TraceRay < Handle
{
	public TraceRay( const float pos[3], const float vec[3], int flags, RayType rtype, TraceEntityFilter filter, any data=0 )
	{
		return view_as< TraceRay >(TR_TraceRayFilterEx(pos, vec, flags, rtype, filter, data));
	}
	public static TraceRay AsHull( const float pos[3], const float vec[3], const float mins[3], const float maxs[3], int flags )
	{
		return view_as< TraceRay >(TR_TraceHullEx(pos, vec, mins, maxs, flags));
	}
	public static TraceRay AsHullFilter( const float pos[3], const float vec[3], const float mins[3], const float maxs[3], int flags, TraceEntityFilter filter, any data=0 )
	{
		return view_as< TraceRay >(TR_TraceHullFilterEx(pos, vec, mins, maxs, flags, filter, data));
	}
	property float Fraction
	{
		public get()
		{
			return TR_GetFraction(this);
		}
	}
	public void GetEndPosition( float pos[3] )
	{
		TR_GetEndPosition(pos, this);
	}
	property int EntityIndex
	{
		public get()
		{
			return TR_GetEntityIndex(this);
		}
	}
	property bool DidHit
	{
		public get()
		{
			return TR_DidHit(this);
		}
	}
	property int HitGroup
	{
		public get()
		{
			return TR_GetHitGroup(this);
		}
	}
	property bool AllSolid
	{
		public get()
		{
			return this.Fraction != 0.0;
		}
	}
	public void GetPlaneNormal( float normal[3] )
	{
		TR_GetPlaneNormal(this, normal);
	}
	// CGameTrace::DidHitWorld
	property bool DidHitWorld
	{
		public get()
		{
			return !this.EntityIndex;
		}
	}
};
#endif
methodmap SMPlugin < Handle
{
	public SMPlugin( Handle hPlugin )
	{
		return view_as< SMPlugin >(hPlugin);
	}
	public static SMPlugin FromPluginNumber( int order_num )
	{
		return view_as< SMPlugin >(FindPluginByNumber(order_num));
	}
	public static SMPlugin FromMyHandle()
	{
		return view_as< SMPlugin >(GetMyHandle());
	}
	property PluginStatus Status
	{
		public get()
		{
			return GetPluginStatus(this);
		}
	}
	property bool IsDebugging
	{
		public get()
		{
			return IsPluginDebugging(this);
		}
	}
	public void GetFileName( char[] buffer, int maxlength )
	{
		GetPluginFilename(this, buffer, maxlength);
	}
	public bool GetInfo( PluginInfo info, char[] buffer, int maxlength )
	{
		return GetPluginInfo(this, info, buffer, maxlength);
	}
};
methodmap PluginIterator < Handle
{
	public PluginIterator()
	{
		return view_as< PluginIterator >(GetPluginIterator());
	}
	property bool More
	{
		public get()
		{
			return MorePlugins(this);
		}
	}
	public Handle Read()
	{
		return ReadPlugin(this);
	}
};
#if defined _tf2items_included
methodmap TF2Item < Handle
{
	public TF2Item( int iFlags ) 
	{
		return view_as< TF2Item >(TF2Items_CreateItem(iFlags));
	}
	property int Flags
	{
		public get()
		{
			return TF2Items_GetFlags(this);
		}
		public set( int i )
		{
			TF2Items_SetFlags(this, i);
		}
	}
	property int Index
	{
		public get()
		{
			return TF2Items_GetItemIndex(this);
		}
		public set( int i )
		{
			TF2Items_SetItemIndex(this, i);
		}
	}
	property int Quality
	{
		public get()
		{
			return TF2Items_GetQuality(this);
		}
		public set( int i )
		{
			TF2Items_SetQuality(this, i);
		}
	}	
	property int Level 
	{
		public get()
		{
			return TF2Items_GetLevel(this);
		}
		public set( int i )
		{
			TF2Items_SetLevel(this, i);
		}
	}
	property int NumAttribs 
	{
		public get() 
		{
			return TF2Items_GetNumAttributes(this);
		}
		public set( int i )
		{
			TF2Items_SetNumAttributes(this, i);
		}
	}
	public int GiveNamedItem( int iClient )
	{
		return TF2Items_GiveNamedItem(iClient, this);
	}
	public void SetClassname( char[] strClassName )
	{
		TF2Items_SetClassname(this, strClassName);
	}
	public void GetClassname( char[] strDest, int iDestSize )
	{
		TF2Items_GetClassname(this, strDest, iDestSize);
	}
	public void SetAttribute( int iSlotIndex, int iAttribDefIndex, float flValue )
	{
		TF2Items_SetAttribute(this, iSlotIndex, iAttribDefIndex, flValue);
	}
	public int GetAttribID( int iSlotIndex )
	{
		return TF2Items_GetAttributeId(this, iSlotIndex);
	}
	public float GetAttribValue( int iSlotIndex )
	{
		return TF2Items_GetAttributeValue(this, iSlotIndex);
	}
	public TF2Item PrepareItemHandle( char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false )
	{
		static TF2Item hWeapon = null;
		int addattribs = 0;

		char weaponAttribsArray[32][32];
		int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

		int flags = OVERRIDE_ATTRIBUTES;
		if (!dontpreserve)
			flags |= PRESERVE_ATTRIBUTES;

		if ( !hWeapon )
			hWeapon = new TF2Item(flags);
		else hWeapon.Flags = flags;
	//	Handle hWeapon = TF2Items_CreateItem(flags);	//null;

		if (this != null) {
			addattribs = this.NumAttribs;
			if (addattribs) {
				for (int i=0; i < 2*addattribs; i+=2) {
					bool dontAdd = false;
					int attribIndex = this.GetAttribID(i);
					for (int z=0; z < attribCount+i; z += 2) {
						if (StringToInt(weaponAttribsArray[z]) == attribIndex)
						{
							dontAdd = true;
							break;
						}
					}
					if (!dontAdd) {
						IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
						FloatToString(this.GetAttribValue(i), weaponAttribsArray[i+1+attribCount], 32);
					}
				}
				attribCount += 2*addattribs;
			}
			delete this;
		}

		if (name[0] != '\0') {
			flags |= OVERRIDE_CLASSNAME;
			hWeapon.SetClassname(name);
		}
		if (index != -1) {
			flags |= OVERRIDE_ITEM_DEF;
			hWeapon.Index = index;
		}
		if (attribCount > 1) {
			hWeapon.NumAttribs = (attribCount/2);
			int i2 = 0;
			for (int i=0; i<attribCount && i<32; i += 2)
			{
				hWeapon.SetAttribute(i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		}
		else hWeapon.NumAttribs = 0;
		hWeapon.Flags = flags;
		return hWeapon;
	}
};
#endif
#if defined _SteamWorks_Included || defined _steamtools_included
methodmap HTTPRequest < Handle
{//	STEAMWORKS
  #if defined _SteamWorks_Included
	public HTTPRequest( EHTTPMethod method, const char[] sURL )
	{
		return view_as< HTTPRequest >(SteamWorks_CreateHTTPRequest(method, sURL));
	}
	public bool SetContextValue( any data1, any data2=0 )
	{
		return SteamWorks_SetHTTPRequestContextValue(this, data1, data2);
	}
	public bool SetNetworkActivityTimeout( int timeout )
	{
		return SteamWorks_SetHTTPRequestNetworkActivityTimeout(this, timeout);
	}
	public bool SetHeaderValue( const char[] sName, const char[] sValue )
	{
		return SteamWorks_SetHTTPRequestHeaderValue(this, sName, sValue);
	}
	public bool SetGetOrPostParameter( const char[] sName, const char[] sValue )
	{
		return SteamWorks_SetHTTPRequestGetOrPostParameter(this, sName, sValue);
	}
	public bool SetUserAgentInfo( const char[] sUserAgentInfo )
	{
		return SteamWorks_SetHTTPRequestUserAgentInfo(this, sUserAgentInfo);
	}
	property bool RequiresVerifiedCertificate
	{
		public set( bool bRequireVerifiedCertificate )
		{
			SteamWorks_SetHTTPRequestRequiresVerifiedCertificate(this, bRequireVerifiedCertificate);
		}
	}
	public bool SetAbsoluteTimeoutMS( int unMilliseconds )
	{
		return SteamWorks_SetHTTPRequestAbsoluteTimeoutMS(this, unMilliseconds);
	}
	public bool SetCallbacks( SteamWorksHTTPRequestCompleted fCompleted = INVALID_FUNCTION, SteamWorksHTTPHeadersReceived fHeaders = INVALID_FUNCTION, SteamWorksHTTPDataReceived fData = INVALID_FUNCTION, Handle hCalling = INVALID_HANDLE )
	{
		return SteamWorks_SetHTTPCallbacks(this, fCompleted, fHeaders, fData, hCalling);
	}
	public bool Send()
	{
		return SteamWorks_SendHTTPRequest(this);
	}
	public bool SendAndStreamResponse()
	{
		return SteamWorks_SendHTTPRequestAndStreamResponse(this);
	}
	public bool Defer()
	{
		return SteamWorks_DeferHTTPRequest(this);
	}
	public bool Prioritize()
	{
		return SteamWorks_PrioritizeHTTPRequest(this);
	}
	public bool GetHeaderSize( const char[] sHeader, int &size )
	{
		return SteamWorks_GetHTTPResponseHeaderSize(this, sHeader, size);
	}
	public bool GetHeaderValue( const char[] sHeader, char[] sValue, int size )
	{
		return SteamWorks_GetHTTPResponseHeaderValue(this, sHeader, sValue, size);
	}
	public bool GetBodySize( int &size )
	{
		return SteamWorks_GetHTTPResponseBodySize(this, size);
	}
	public bool GetBodyData( char[] sBody, int length )
	{
		return SteamWorks_GetHTTPResponseBodyData(this, sBody, length);
	}
	public bool GetStreamingResponseBodyData( int cOffset, char[] sBody, int length )
	{
		return SteamWorks_GetHTTPStreamingResponseBodyData(this, cOffset, sBody, length);
	}
	public bool GetDownloadProgressPct( float &percent )
	{
		return SteamWorks_GetHTTPDownloadProgressPct(this, percent);
	}
	public bool WasTimedOut( bool &bWasTimedOut )
	{
		return SteamWorks_GetHTTPRequestWasTimedOut(this, bWasTimedOut);
	}
	public bool SetRawPostBody( const char[] sContentType, const char[] sBody, int bodylen )
	{
		return SteamWorks_SetHTTPRequestRawPostBody(this, sContentType, sBody, bodylen);
	}
  #elseif defined _steamtools_included
 //	STEAMTOOLS
	public HTTPRequest( HTTPMethod HTTPRequestMethod, const char[] absoluteURL )
	{
		return view_as< HTTPRequest >(Steam_CreateHTTPRequest(HTTPRequestMethod, absoluteURL));
	}
	property int Timeout
	{
		public set( int timeoutSeconds )
		{
			Steam_SetHTTPRequestNetworkActivityTimeout(view_as< HTTPRequestHandle >(this), timeoutSeconds);
		}
	}
	public int SetHeaderValue( const char[] headerName, const char[] headerValue )
	{
		return Steam_SetHTTPRequestHeaderValue(view_as< HTTPRequestHandle >(this), headerName, headerValue);
	}
	public int SetGetOrPostParameter( const char[] paramName, const char[] paramValue )
	{
		return Steam_SetHTTPRequestGetOrPostParameter(view_as< HTTPRequestHandle >(this), paramName, paramValue);
	}
	public bool Send( HTTPRequestComplete callbackFunction, any contextData = 0 )
	{
		return Steam_SendHTTPRequest(view_as< HTTPRequestHandle >(this), callbackFunction, contextData);
	}
	public int Defer()
	{
		return Steam_DeferHTTPRequest(view_as< HTTPRequestHandle >(this));
	}
	public int Prioritize()
	{
		return Steam_PrioritizeHTTPRequest(view_as< HTTPRequestHandle >(this));
	}
	public int GetHeaderSize( const char[] headerName )
	{
		return Steam_GetHTTPResponseHeaderSize(view_as< HTTPRequestHandle >(this), headerName);
	}
	public int GetHeaderValue( const char[] headerName, char[] headerValueBuffer, int bufferSize )
	{
		return Steam_GetHTTPResponseHeaderValue(view_as< HTTPRequestHandle >(this), headerName, headerValueBuffer, bufferSize);
	}
	public int GetBodySize()
	{
		return Steam_GetHTTPResponseBodySize(view_as< HTTPRequestHandle >(this));
	}
	public int GetBodyData( char[] bodyDataBuffer, int bufferSize )
	{
		return Steam_GetHTTPResponseBodyData(view_as< HTTPRequestHandle >(this), bodyDataBuffer, bufferSize);
	}
	public int WriteBody( const char[] filePath )
	{
		return Steam_WriteHTTPResponseBody(view_as< HTTPRequestHandle >(this), filePath);
	}
	public int Release()
	{
		return Steam_ReleaseHTTPRequest(view_as< HTTPRequestHandle >(this));
	}
	property float DownloadProgressPercent
	{
		public get()
		{
			return Steam_GetHTTPDownloadProgressPercent(view_as< HTTPRequestHandle >(this));
		}
	}
	public bool SetRawPostBody( const char[] data, int dataLength, const char[] contentType="text/plain" )
	{
		return Steam_SetHTTPRequestRawPostBody(view_as< HTTPRequestHandle >(this), data, dataLength, contentType);
	}
	public bool SetRawPostBodyFile( const char[] filePath, const char[] contentType="text/plain" )
	{
		return Steam_SetHTTPRequestRawPostBodyFile(view_as< HTTPRequestHandle >(this), filePath, contentType);
	}
  #endif
};
#endif
methodmap HUD < Handle
{
	public HUD()
	{
		return view_as< HUD > (CreateHudSynchronizer());
	}
	public int Show( int client, const char[] message, any ... )
	{
		char buffer[220];	// Max HUD length
		VFormat(buffer, sizeof(buffer), message, 4);
		return ShowSyncHudText(client, this, buffer);
	}
	public void Clear( int client )
	{
		ClearSyncHud(client, this);
	}
};
#if defined _socket_included
methodmap Socket < Handle
{
	public Socket( SocketType protocol=SOCKET_TCP, SocketErrorCB efunc )
	{
		return view_as< Socket >(SocketCreate(protocol, efunc));
	}
	property bool Connected
	{
		public get()
		{
			return SocketIsConnected(this);
		}
	}
	public bool Bind( const char[] hostname, int port )
	{
		return SocketBind(this, hostname, port);
	}
	public void Connect( SocketConnectCB cfunc, SocketReceiveCB rfunc, SocketDisconnectCB dfunc, const char[] hostname, int port )
	{
		SocketConnect(this, cfunc, rfunc, dfunc, hostname, port);
	}
	public bool Disconnect()
	{
		return SocketDisconnect(this);
	}
	public bool Listen( SocketIncomingCB ifunc )
	{
		return SocketListen(this, ifunc);
	}
	public void Send( const char[] data, int size=-1 )
	{
		SocketSend(this, data, size);
	}
	public void SendTo( const char[] data, int size=-1, const char[] hostname, int port )
	{
		SocketSendTo(this, data, size, hostname, port);
	}
	public int SetOption( SocketOption option, int value )
	{
		return SocketSetOption(this, option, value);
	}
	public void SetReceiveCallback( SocketReceiveCB rfunc )
	{
		SocketSetReceiveCallback(this, rfunc);
	}
	public void SetDisconnectCallback( SocketDisconnectCB dfunc )
	{
		SocketSetDisconnectCallback(this, dfunc);
	}
	public void SetErrorCallback( SocketErrorCB efunc )
	{
		SocketSetErrorCallback(this, efunc);
	}
	public void SetArg( any arg )
	{
		SocketSetArg(this, arg);
	}
	public int GetHostName( char[] dest, int destlen )
	{
		return SocketGetHostName(this, dest, deslen);
	}
};
#endif
methodmap DString < DataPack
{
	public DString( const char[] str = "" )
	{
		DString handle = view_as< DString >(new DataPack());
		int len = strlen(str);
		if (len)
		{
			handle.WriteCell(len);
			handle.WriteString(str);
		}
		return handle;
	}
	property int Length
	{
		public get()
		{
			if (!this)
				return 0;
			this.Reset(false);
			if (!this.IsReadable(1))
				return 0;
			return this.ReadCell();
		}
	}
	public int Copy( const char[] str )
	{
		if (!this)
			return 0;
		this.Reset(true);
		int len = strlen(str);
		if (len)
		{
			this.WriteCell(len);
			this.WriteString(str);
		}
		return len;
	}
	public int Format( const char[] str, any ... )
	{
		char buffer[2048];
		VFormat(buffer, sizeof buffer, str, 3);
		return this.Copy(buffer);
	}
	public int Add( const char[] str )
	{
		if (!this)
			return 0;
		int len_base = this.Length;
		if (!len_base)
			return this.Copy(str);
		int len_add = strlen(str);
		if (!len_add)
			return len_base;
		int len_read;
		char[] buffer = new char[len_base + 1];
		while (this.IsReadable(1) && len_read < len_base)
		{
			this.ReadString(buffer, len_base + 1);
			len_read += strlen(buffer);
		}
		this.WriteString(str);
		this.Reset(false);
		int len_new = len_base + len_add;
		this.WriteCell(len_new);
		return len_new;
	}
	public int AddEx( const char[] str, any ... )
	{
		char buffer[2048];
		VFormat(buffer, sizeof(buffer), str, 3);
		return this.Add(buffer);
	}
	public int Read( char[] buffer, int buffersize )
	{
		int len_read;
		for (int len = this.Length; this.IsReadable(1) && len_read < len && buffersize > len_read; len_read += strlen(buffer[len_read]))
			this.ReadString(buffer[len_read], buffersize - len_read);
		return len_read;
	}
	public void Clear()
	{
		this.Reset(true);
	}
	public DString Clone()
	{
		if (!this)
			return null;

		int len = this.Length;
		if (!len)
			len++;
		char[] buffer = new char[len + 1];
		this.Read(buffer, len + 1);
		return new DString(buffer);
	}
};
stock char[] DStringReadEx(DString string)
{
	char buffer[2048];
	string.Read(buffer, sizeof(buffer));
	return buffer;
}
#if defined _jansson_included_
methodmap JSONObject < Handle
{
	public JSONObject()
	{
		return view_as< JSONObject >(json_object());
	}
	property json_type TypeOf
	{
		public get()
		{
			return json_typeof(this);
		}
	}
	property int Size
	{
		public get()
		{
			return json_object_size(this);
		}
	}
	public JSONObject Copy()
	{
		return view_as< JSONObject >(json_copy(this));
	}
	public JSONObject DeepCopy()
	{
		return view_as< JSONObject >(json_deep_copy(this));
	}
	public Handle Get( char[] sKey )
	{
		return json_object_get(this, sKey);
	}
	public bool Set( char[] sKey, Handle hValue )
	{
		return json_object_set(this, sKey, hValue);
	}
	public bool SetNew( char[] sKey, Handle hValue )
	{
		return json_object_set_new(this, sKey, hValue);
	}
	public bool Delete( char[] sKey )
	{
		return json_object_del(this, sKey);
	}
	public bool Clear()
	{
		return json_object_clear(this);
	}
	public bool Update( Handle hOther )
	{
		return json_object_update(this, hOther);
	}
	public bool UpdateExisting( Handle hOther )
	{
		return json_object_update_existing(this, hOther);
	}
	public bool UpdateMissing( Handle hOther )
	{
		return json_object_update_missing(this, hOther);
	}
	property Handle Iter
	{
		public get()
		{
			return json_object_iter(this);
		}
	}
	public Handle IterAt( char[] sKey )
	{
		return json_object_iter_at(this, sKey);
	}
	public Handle IterNext( Handle hIter )
	{
		return json_object_iter_next(this, hIter);
	}
	public bool IterSet( Handle hIter, Handle hValue)
	{
		return json_object_iter_set(this, hIter, hValue);
	}
	public bool IterSetNew( Handle hIter, Handle hValue )
	{
		return json_object_iter_set_new(this, hIter, hValue);
	}
	public int Dump( char[] sJSON, int maxlength, int iIndentWidth = 4, bool bEnsureAscii = false, bool bSortKeys = false, bool bPreserveOrder = false )
	{
		return json_dump(this, sJSON, maxlength, iIndentWidth, bEnsureAscii, bSortKeys, bPreserveOrder);
	}
	public bool DumpFile( const char[] sFilePath, int iIndentWidth, bool bEnsureAscii = false, bool bSortKeys = false, bool bPreserveOrder = false )
	{
		return json_dump_file(this, sFilePath, iIndentWidth, bEnsureAscii, bSortKeys, bPreserveOrder);
	}
	public bool GetBool( const char[] sKey )
	{
		return json_object_get_bool(this, sKey);
	}
	public float GetFloat( const char[] sKey )
	{
		return json_object_get_float(this, sKey);
	}
	public int GetInt( const char[] sKey )
	{
		return json_object_get_int(this, sKey);
	}
	public int GetString( const char[] sKey, char[] sBuffer, int maxlength )
	{
		return json_object_get_string(this, sKey, sBuffer, maxlength);
	}
};
methodmap JSONArray < Handle
{
	public JSONArray()
	{
		return view_as< JSONArray >(json_array());
	}
	property int Size
	{
		public get()
		{
			return json_array_size(this);
		}
	}
	public Handle Get( int iIndex )
	{
		json_array_get(this, iIndex);
	}
	public bool Set( int iIndex, Handle hValue )
	{
		return json_array_set(this, iIndex, hValue);
	}
	public bool SetNew( int iIndex, Handle hValue )
	{
		return json_array_set_new(this, iIndex, hValue);
	}
	public bool Append( Handle hValue )
	{
		return json_array_append(this, hValue);
	}
	public bool AppendNew( Handle hValue )
	{
		return json_array_append_new(this, hValue);
	}
	public bool Insert( int iIndex, Handle hValue )
	{
		return json_array_insert(this, iIndex, hValue);
	}
	public bool InsertNew( int iIndex, Handle hValue )
	{
		return json_array_insert_new(this, iIndex, hValue);
	}
	public bool Remove( int iIndex )
	{
		return json_array_remove(this, iIndex);
	}
	public bool Clear()
	{
		return json_array_clear(this);
	}
	public bool Extend( Handle hOther )
	{
		return json_array_extend(this, hOther);
	}
	public bool GetBool( int iIndex )
	{
		return json_array_get_bool(this, iIndex);
	}
	public float GetFloat( int iIndex )
	{
		return json_array_get_float(this, iIndex);
	}
	public int GetInt( int iIndex )
	{
		return json_array_get_int(this, iIndex);
	}
	public int GetString( int iIndex, char[] sBuffer, int maxlength )
	{
		return json_array_get_string(this, iIndex, sBuffer, maxlength);
	}
};
methodmap JSONBool < Handle
{
	public JSONBool( bool bState )
	{
		return view_as< JSONBool >(json_boolean(bState));
	}
	public static JSONBool AsFalse()
	{
		return view_as< JSONBool >(json_false());
	}
	public static JSONBool AsTrue()
	{
		return view_as< JSONBool >(json_true());
	}
	public static JSONBool AsNull()
	{
		return view_as< JSONBool >(json_null());
	}
};
methodmap JSONString < Handle
{
	public JSONString( const char[] sValue )
	{
		return view_as< JSONString >(json_string(sValue));
	}
	public int Value( char[] sValueBuffer, int maxlength )
	{
		return json_string_value(this, sValueBuffer, maxlength);
	}
	public bool Set( char[] sValue )
	{
		return json_string_set(this, sValue);
	}
	public static JSONString Format( const char[] sFormat, any ... )
	{
		char sTmp[4096];
		VFormat(sTmp, sizeof(sTmp), sFormat, 3);
		return new JSONString(sTmp);
	}
	public static JSONString FormatEx( int tmpBufferLength, const char[] sFormat, any ... )
	{
		char[] sTmp = new char[tmpBufferLength];
		VFormat(sTmp, sizeof(sTmp), sFormat, 3);
		return new JSONString(sTmp);
	}
};
methodmap JSONInt < Handle
{
	public JSONInt( int iValue )
	{
		return view_as< JSONInt >(json_integer(iValue));
	}
	property int Value
	{
		public get()
		{
			return json_integer_value(this);
		}
	}
	public bool Set( int iValue )
	{
		return json_integer_set(this, iValue);
	}
	property float NumVal
	{
		public get()
		{
			return json_number_value(this);
		}
	}
};
methodmap JSONReal < Handle
{
	public JSONReal( float fValue )
	{
		return view_as< JSONReal >(json_real(fValue));
	}
	property float Value
	{
		public get()
		{
			return json_real_value(this);
		}
	}
	public bool Set( float value )
	{
		return json_real_set(this, value);
	}
	property float NumVal
	{
		public get()
		{
			return json_number_value(this);
		}
	}
};
methodmap JSONLoad < Handle
{
	public JSONLoad( const char[] sJSON )
	{
		return view_as< JSONLoad >(json_load(sJSON));
	}
	public static JSONLoad Ex( const char[] sJSON, char[] sErrorText, int maxlen, int &iLine, int &iLevel )
	{
		return view_as< JSONLoad >(json_load_ex(sJSON, sErrorText, maxlen, iLine, iLevel));
	}
	public static JSONObject Load( const char sFilePath[PLATFORM_MAX_PATH] )
	{
		return view_as< JSONObject >(json_load_file(sFilePath));
	}
	public static JSONObject LoadEx( const char sFilePath[PLATFORM_MAX_PATH], char[] sErrorText, int maxlen, int &iLine, int &iColumn )
	{
		return view_as< JSONObject >(json_load_file_ex(sFilePath, sErrorText, maxlen, iLine, iColumn));
	}
};
#endif
stock int GetHealingTarget(const int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (medigun == -1)
		return -1;
	char cls[32]; GetEntityClassname(medigun, cls, sizeof(cls));
	if (!strncmp(cls, "tf_weapon_medi", 14, false)) {
		if ( GetEntProp(medigun, Prop_Send, "m_bHealing") )
			return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
	}
	return -1;
}
stock int GetActiveWep(const int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
		return weapon;
	return -1;
}
stock float GetMediCharge(const int medigun)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(const int medigun, const float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock bool IsNearSpencer(const int client)
{
	int medics = 0;
	for (int i=MaxClients ; i ; --i) {
		if (IsValidClient(i) && GetHealingTarget(i) == client)
			medics++;
	}
	return (GetEntProp(client, Prop_Send, "m_nNumHealers") > medics);
}
//Prepare content stocks
stock void CheckDownload(const char[] dlpath)
{
	if ( FileExists(dlpath) )
		AddFileToDownloadsTable(dlpath);
	// else LogError("Could not find %s ; ignoring...", dlpath);
}
//Following 'Prepare' stocks taken from VSH1
//'Prepare' stocks will precache AND add to the downloads table (if file exists).
stock void PrepareSound(const char[] szSoundPath) //For single custom sound files
{
	PrecacheSound(szSoundPath, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", szSoundPath);
	CheckDownload(s);
}
stock void DownloadSoundList(const char[][] szFileList, int iSize) //For arrays of custom sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrepareSound(szFileList[i]);
	}
}
stock void PrecacheSoundList(const char[][] szFileList, int iSize) //For arrays of stock TF2 sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrecacheSound(szFileList[i], true);
	}
}
stock void PrepareMaterial(const char[] szMaterialPath) //For single custom materials, omit file extensions as it prepares VMT + VTF
{
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vtf");
	CheckDownload(s);
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vmt");
	CheckDownload(s);
}
stock void DownloadMaterialList(const char[][] szFileList, int iSize) //For arrays of custom materials
{
	char s[PLATFORM_MAX_PATH];
	for (int i = 0; i < iSize; i++)
	{
		strcopy(s, sizeof(s), szFileList[i]);
		CheckDownload(s);
	}
}
stock int PrepareModel(const char[] szModelPath, bool bMdlOnly = false) // For custom models, do not omit .MDL extension
{
	char szBase[PLATFORM_MAX_PATH];
	char szPath[PLATFORM_MAX_PATH];
	int i;
	strcopy(szBase, sizeof(szBase), szModelPath);
	SplitString(szBase, ".mdl", szBase, sizeof(szBase));
	
	if (!bMdlOnly)
	{
		for (i = 0; i < sizeof(extensions); i++)
		{
			Format(szPath, PLATFORM_MAX_PATH, "%s%s", szBase, extensions[i]);
			CheckDownload(szPath);
		}
	}
	else CheckDownload(szModelPath);
	
	return PrecacheModel(szModelPath, true);
}
stock void PrepareDecal(char[] sOverlay)
{
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "%s.vmt", sOverlay);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", sOverlay);
	CheckDownload(sBuffer);

	Format(sBuffer, sizeof(sBuffer), "%s.vtf", sOverlay);
	PrecacheDecal(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", sOverlay);
	CheckDownload(sBuffer);
}
//End 'Prepare' stocks
stock void ForceTeamWin(const int team)
{
	int entity = FindEntityByClassname(-1, "team_control_point_master");
	if (entity <= 0) {
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int GetItemIndex(const int item)
{
	if (IsValidEdict(item) && IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetItemQuality(const int item)
{
	if (IsValidEdict(item) && IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iEntityQuality");
	return -1;
}
stock int GetIndexOfWeaponSlot(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return GetItemIndex(weapon);
}
stock bool IsInRange(const int entity, const int target, const float dist, bool pTrace = false)
{
	float entitypos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", entitypos);
	float targetpos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetpos);

	if ( GetVectorDistance(entitypos, targetpos) <= dist )
	{
		if (!pTrace)
			return true;
		else 
		{
			TR_TraceRayFilter( entitypos, targetpos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, entity );
			if ( TR_GetFraction() > 0.98 )
				return true;
		}
	}
	return false;
}
stock int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true, bool remove = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	if (remove)
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock int AttachParticle2(int iEntity, const char[] strParticleEffect, const char[] strAttachPoint = "", float flOffsetZ = 0.0, float flSelfDestruct = 0.0)
{
#if defined RemoveEnt
	int iParticle = CreateEntityByName("info_particle_system");
	if (iParticle > MaxClients && IsValidEntity(iParticle))
	{
		float flPos[3];
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flPos);
		flPos[2] += flOffsetZ;
		
		TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(iParticle, "effect_name", strParticleEffect);
		DispatchSpawn(iParticle);
		
		SetVariantString("!activator");
		AcceptEntityInput(iParticle, "SetParent", iEntity);
		ActivateEntity(iParticle);
		
		if (strAttachPoint[0] != '\0')
		{
			SetVariantString(strAttachPoint);
			AcceptEntityInput(iParticle, "SetParentAttachmentMaintainOffset");
		}
		
		AcceptEntityInput(iParticle, "start");
		
		if(flSelfDestruct > 0.0) CreateTimer(flSelfDestruct, RemoveEnt, EntIndexToEntRef(iParticle));
		
		return iParticle;
	}
#endif
	return 0;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time)
{
#if defined RemoveEnt
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle)) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, RemoveEnt, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
#endif
}
stock void SetWeaponInvis(const int client, const int alpha)
{
	int transparent = alpha;
	for (int i = 0; i < 5; i++) {
		int entity = GetPlayerWeaponSlot(client, i); 
		if ( IsValidEntity(entity) )
		{
			if (transparent > 255)
				transparent = 255;
			if (transparent < 0)
				transparent = 0;
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 150, 150, 150, transparent); 
		}
	}
	return;
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int ShootRocket(const int client, bool bCrit = false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model = "", bool arc=false)
{
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	
	if (!IsValidEdict(iProjectile))
		return 0;

	float vVelocity[3];
	GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);

	if (!arc)
		NormalizeVector(vVelocity, vVelocity);
	else
		vVelocity[2] -= 0.025;

	ScaleVector(vVelocity, flSpeed);
	SetEntPropEnt(iProjectile,	Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,		Prop_Send, "m_bCritical", (bCrit ? 1 : 0));
	SetEntProp(iProjectile,		Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,		Prop_Send, "m_nSkin", (iTeam-2));

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);

	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	if (arc)
		SetEntityMoveType(iProjectile, MOVETYPE_FLYGRAVITY);
	if ( model[0] != '\0' )
		SetEntityModel(iProjectile, model);
	return iProjectile;
}

stock void SetClientOverlay(const int client, const char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}

stock bool IsValidClient(const int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients)
		return false;
	if (!IsClientInGame(client))
		return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
		return false;
	if (replaycheck)
		if (IsClientSourceTV(client) || IsClientReplay(client))
			return false;
	if (TF2_GetPlayerClass(client) == TFClass_Unknown)
		return false;
	return true;
}
stock int GetOwner(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetBuilder(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
	return -1;
}
stock int GetGroundEntity(const int client)
{
	if ( IsValidClient(client, false) )
		return GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	return -1;
}
stock int FindTeleOwner(const int client)
{
	int teleporter = GetGroundEntity(client);
	char classname[32];
	if (IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
	{
		int owner = GetBuilder(teleporter);
		if (IsValidClient(owner, false))
			return owner;
	}
	return -1;
}
stock void TeleportToSpawn(const int client, int team = 0)	// Props to Chdata!
{
	int iEnt = -1;
	float vPos[3], vAng[3];
	ArrayList hArray = new ArrayList();
	while ((iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1)
	{
		if (GetEntProp(iEnt, Prop_Data, "m_bDisabled"))
			continue;
		if (team <= 1)
			hArray.Push(iEnt);
		else {
			int iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == team)
				hArray.Push(iEnt);
		}
	}
	iEnt = hArray.Get(GetRandomInt(0, hArray.Length - 1));
	hArray.Close();

	// Technically you'll never find a map without a spawn point. not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(client, vPos, vAng, nullvec);

	/*if (Special == VSHSpecial_HHH) //reserved for HHH boss
	{
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
		EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, nullvec, false, 0.0);
	}*/
}
stock void DoExplosion(const int owner, const int damage, const int radius, float pos[3], int inflictor = 0)
{
	int explode = CreateEntityByName("env_explosion");
	if (!IsValidEntity(explode))
		return;

	DispatchKeyValue(explode, "targetname", "exploder");
	DispatchKeyValue(explode, "spawnflags", "4");
	DispatchKeyValue(explode, "rendermode", "5");

	SetEntPropEnt(explode, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(explode, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(explode, Prop_Data, "m_iRadiusOverride", radius);
	if (inflictor) SetEntPropEnt(explode, Prop_Data, "m_hInflictor", inflictor);

	int team = GetClientTeam(owner);
	SetVariantInt(team); AcceptEntityInput(explode, "TeamNum");
	SetVariantInt(team); AcceptEntityInput(explode, "SetTeam");

	TeleportEntity(explode, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(explode);
	ActivateEntity(explode);
	AcceptEntityInput(explode, "Explode");
	AcceptEntityInput(explode, "Kill");
}

stock float[] nSubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] - vec2[0];
	result[1] = vec1[1] - vec2[1];
	result[2] = vec1[2] - vec2[2];
	return result;
}
stock float[] nAddVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] + vec2[0];
	result[1] = vec1[1] + vec2[1];
	result[2] = vec1[2] + vec2[2];
	return result;
}
stock float[] nScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] nNegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock bool VectorCompare (const float v1[3], const float v2[3])
{
	for (int i=0 ; i<3 ; i++)
		if (v1[i] != v2[i])
			return false;
			
	return true;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients ; i ; --i) {
		if ( !IsClientValid(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) != team)
			continue;

		if (TF2_GetPlayerClass(i) == TFClass_Scout)
			continue;

		return false;
	}
	return true;
}
stock bool OnlyScoutsAndSpiesLeft(const int team)
{
	for (int i=MaxClients ; i ; --i) {
		if ( !IsClientValid(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) != team)
			continue;

		if (TF2_GetPlayerClass(i) == TFClass_Scout || TF2_GetPlayerClass(i) == TFClass_Spy)
			continue;

		return false;
	}
	return true;
}
stock int GetLivingPlayers(const int team)
{
	int living;
	for (int i = MaxClients ; i; --i)
		if (IsClientInGame(i) && IsPlayerAlive(i) && (team && GetClientTeam(i) == team))
			++living;
	return living;
}
stock void IncrementHeadCount(const int client, bool addhealth = true, int addheads = 1)
{
	if ( (TF2_GetPlayerClass(client) == TFClass_DemoMan) &&  !TF2_IsPlayerInCondition(client, TFCond_DemoBuff) )
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite); // Apply this condition to Demomen to give them their glowing eye effect.
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if ( addhealth )
	{
		int health = GetClientHealth(client);
		//health += (decapitations >= 4 ? 10 : 15);
		if ( health + (15 * addheads) <= 300 ) // TODO: Replace this with an overheal calculation (MaxHP * 1.5) OR add a maxhealth arg. 
			health += 15 * addheads;
		else
			health = 300;
		SetEntProp(client, Prop_Data, "m_iHealth", health);
		SetEntProp(client, Prop_Send, "m_iHealth", health);
	}
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   // Recalc their speed
}
stock void SpawnSmallHealthPackAt(const int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	if ( IsValidEntity(healthpack) ) {
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
	}
	return;
}
stock void SpawnSmallAmmoPackAt(const int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	int pack = CreateEntityByName("item_ammopack_small");
	if (IsValidEntity(pack))
	{
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(pack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(pack);
		SetEntProp(pack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(pack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(pack, pos, NULL_VECTOR, vel);
	}
	return;
}
stock void SetNextAttack(const int weapon, float duration = 0.0)
{
	if (weapon <= MaxClients || !IsValidEntity(weapon))
		return;
	float next = GetGameTime()+duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}
stock void ResetPlayer(const int client)
{
	TF2_RegeneratePlayer(client);
	SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );
	SetEntProp( client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth") );
}


/**
 * Wrapper function for easily setting up non-repeating timers
 *
 * @param func			Function pointer to call desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */

/*
If you need to use this and your function uses 3 parameters, modify it if necessary.
BUG/GLITCH: For some strange reason, SetPawnTimer doesn't work when u attempt to callback stock functions, interesting...
*/
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);

	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

stock static Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();

	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);

	Call_Finish();
	return Plugin_Continue;
}
/*stock void Set3PawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999, any param3 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	thinkpack.WriteCell(param3);

	CreateTimer(thinktime, Do3Think, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action Do3Think(Handle hTimer, DataPack hndl)
{
	hndl.Reset();

	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);

	any param3 = hndl.ReadCell();
	if ( param3 != -999 )
		Call_PushCell(param3);

	Call_Finish();
	return Plugin_Continue;
}*/
stock bool DoSuperJump(const int client, const float charge, const float JumpAngle, int& changecharge, const int subtractCharge)
{
	float ang[3]; GetClientEyeAngles(client, ang);
	if ( ang[0] <= JumpAngle ) // default JumpAngle = -45.0
	{
		float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 750 + charge * 13.0;
		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1+Sine(charge * FLOAT_PI / 50));
		vel[1] *= (1+Sine(charge * FLOAT_PI / 50));
		TeleportEntity(client, nullvec, nullvec, vel);
		changecharge = subtractCharge;
		return true;
	}
	return false;
}
stock bool DoWeighdown(const int client, float& weighdowntime, const float AngleForWayDown, const float SetWeighdown)
{
#if defined TimerGravityCat
	if ( weighdowntime >= 1.0 ) {
		float ang[3]; GetClientEyeAngles(client, ang);
		if ( ang[0] >= AngleForWayDown ) {	//default AngleForWayDown = 60.0
			float fVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			fVelocity[2] = -1000.0;
			TeleportEntity(client, nullvec, nullvec, fVelocity);
			SetEntityGravity(client, 6.0);
			CreateTimer(2.0, TimerGravityCat, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			weighdowntime = SetWeighdown;
			return true;
		}
	}
#endif
	return false;
}
stock void ForceClientTeamChange(const int client, const int iTeam)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}
stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
stock bool IsVSHMap()	// just use arena maps as vsh/ff2 maps
{
	char config[FULLPATH], currentmap[99];
	GetCurrentMap(currentmap, sizeof(currentmap));
	if ( FileExists("bNextMapToFF2") )
		{return true;}
	else if ( FileExists("bNextMapToHale") )
		{return true;}

	BuildPath(Path_SM, config, FULLPATH, "configs/freak_fortress_2/maps.cfg");	// Compatibility :)
	if (!FileExists(config)) {
		BuildPath(Path_SM, config, FULLPATH, "configs/saxton_hale/saxton_hale_maps.cfg");
		if (!FileExists(config)) {
			LogError("[VSH 2] ERROR: **** Unable to find VSH/FF2 Compatibility Map Configs, Disabling VSH 2 ****");
			return false;
		}
	}

	File file = OpenFile(config, "r");
	if ( !file ) {
		LogError("[VSH 2] **** Error Reading Maps from %s Config, Disabling VSH Engine ****", config);
		return false;
	}

	int tries;
	while ( file.ReadLine(config, sizeof(config)) && tries < 100 )
	{
		++tries;
		if (tries == 100) {
			LogError("[VSH 2] **** Breaking Loop Looking For a Map ****");
			return false;
		}

		Format(config, strlen(config)-1, config);
		if ( !strncmp(config, "//", 2, false) )
			continue;

		if ( StrContains(currentmap, config, false) != -1 || StrContains(config, "all", false) != -1 )
		{
			file.Close();
			return true;
		}
	}
	delete file;
	return false;
	//if (FindEntityByClassname(-1, "tf_logic_arena") != -1) return true;
	//return false;
}
stock void SetArenaCapEnableTime(const float time)
{
	int ent = -1;
	char strTime[32]; FloatToString(time, strTime, sizeof(strTime));
	if ( (ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1 )
		DispatchKeyValue(ent, "CapEnableDelay", strTime);
}
stock void SetClientGlow(const int client, const float time1, float clampfl = 0.0, float &glowtimer)
{
	if (IsValidClient(client)) {
		glowtimer += time1;
		if (clampfl > 0.0)
			glowtimer = clampfl;
		if (glowtimer <= 0.0) {
			glowtimer = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
stock void SpawnRandomAmmo()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	while ( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 )
	{
		if ( GetRandomInt(0, 4) )
			continue;

		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

		int iEnt2 = CreateEntityByName("item_ammopack_small");
		TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(iEnt2);
		SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
	}
}
stock void SpawnRandomHealth()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	while ( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 )
	{
		if ( GetRandomInt(0, 4) )
			{continue;}
		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

		int iEnt2 = CreateEntityByName("item_healthkit_small");
		TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(iEnt2);
		SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
	}
}
stock int GetTeamPlayerCount(const int team)
{
	int count = 0;
	for (int i=MaxClients ; i ; --i) {
		if (IsValidClient(i) && GetClientTeam(i) == team)
			{count++;}
	}
	return count;
}
stock int GetClientCloakIndex(const int client)
{
	if (!IsValidClient(client))
		return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep))
		return -1;
	char classname[32];
	GetEntityClassname(wep, classname, sizeof(classname));
	if ( !strncmp(classname, "tf_wea", 6, false) )
		return GetItemIndex(wep);
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if ( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			{return i;}
	}
	return -1;
}
stock bool RemoveDemoShield(int iClient) //Taken from VSH1
{
	int iEnt = MaxClients + 1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable_demoshield")) != -1)
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && !GetEntProp(iEnt, Prop_Send, "m_bDisguiseWearable"))
		{
			TF2_RemoveWearable(iClient, iEnt);
			return true; //Returns true if Shield was removed...
		}
	}
	return false; //...and returns False if one wasn't found.
}
stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i=0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return -1;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	return -1;
}
stock int FindSentry(const int client)
{
	int i = -1;
	while ( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 )
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client)
			return i;
	return -1;
}
stock bool TF2_IsPlayerCritBuffed(const int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(34))
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(35))
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			);
}
stock void OverNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}
stock int GetMaxAmmo(const int client, const int slot)
{
	if (!IsValidClient(client))
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		switch (slot)
		{ //FindDataMapInfo(client, "m_iAmmo");
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool IsWeaponSlotActive(const int client, const int slot)
{
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}
stock bool MapHasMusic(bool forceRecalc = false)	// Does this even work?
{
	static bool hasMusic;
	static bool found = false;
	if (forceRecalc) {
		found = false;
		hasMusic = false;
	}
	if (!found) {
		int i = -1;
		char name[64];
		while ((i = FindEntityByClassname(i, "info_target")) != -1)
		{
			GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
			if ( !strcmp(name, "hale_no_music", false) )
				hasMusic = true;
		}
		found = true;
	}
	return hasMusic;
}
stock bool IsValidAdmin(const int client, const char[] flags)
{
	if (!IsClientInGame(client))
		return false;
	int ibFlags = ReadFlagString(flags);
	if (!StrEqual(flags, "")) {
		if ( (GetUserFlagBits(client) & ibFlags) == ibFlags )
			return true;
	}
	if ( GetUserFlagBits(client) & ADMFLAG_ROOT )
		return true;
	return false;
}
stock int AttachProjectileModel(const int entity, const char[] strModel, char[] strAnim = "")
{
	if (!IsValidEntity(entity))
		return -1;
	int model = CreateEntityByName("prop_dynamic");
	if (IsValidEdict(model)) {
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if (strAnim[0] != '\0') {
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	}
	else LogError("(AttachProjectileModel): Could not create prop_dynamic");
	return -1;
}
stock bool GetRandomBool()
{
	return ( !GetRandomInt(0, 1) ? false : true );
}
stock void SkipBossPanelNotify(const int client, bool newchoice = true)
{
#if defined SkipHalePanelH
	if (!IsValidClient(client) || IsFakeClient(client) || IsVoteInProgress())
		return;

	Panel panel = new Panel();
	char strNotify[64];

	panel.SetTitle("[VSH2] You're The Next Boss!");
	Format(strNotify, sizeof(strNotify), "You are going to be a Boss soon! Type /halenext to check/reset your queue points.\nAlternatively, use !resetq.");

	panel.DrawItem(strNotify);
	panel.Send(client, SkipHalePanelH, 30);
	delete panel;
#endif
}
stock void _SetCapOwner(const int iCapTeam, float flEnableTime = 30.0)
{
#if defined EnableCap
	int i = -1;
	int cap_master = FindEntityByClassname(-1, "team_control_point_master");
	while ( (i = FindEntityByClassname(i, "team_control_point")) != -1 )
	{
		if (IsValidEntity(i)) {	//Adapted from Arena:Respawn
			SetVariantInt(iCapTeam);
			AcceptEntityInput(i, "SetOwner", -1, cap_master); //Must have team_control_point_master as the activator, less it will just ignore the Input
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			SetPawnTimer(EnableCap, flEnableTime);
		}
	}
#endif
}
stock bool StrStarts(const char[] szStr, const char[] szSubStr, bool bCaseSensitive = true)
{
	return !StrContains(szStr, szSubStr, bCaseSensitive);
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i=0 ; i<length ; ++i) {
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores and normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_'))
			return false;
	}
	// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
stock int GetRandomPlayer(int team, bool alive = false)
{
	int[] clients = new int[MaxClients];  
	int clientCount;  
	for (int i = 1; i <= MaxClients; i++)  
	{
		if (!IsClientValid(i))
			continue;
		if (team && GetClientTeam(i) != team)
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		clients[clientCount++] = i;
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}
stock int GetRandomClient(const bool alive)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientValid(i))
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		clients[clientCount++] = i;
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}
stock void SetControlPoint(const bool enable)
{
	int CPm = -1;
	while ( (CPm = FindEntityByClassname(CPm, "team_control_point")) != -1 )
	{
		if ( CPm > MaxClients && IsValidEdict(CPm) ) 
		{
			AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}
stock int AccountIDToClient(const int iAccountID)
{
	for( int i=MaxClients ; i ; --i ) {
		if( !IsClientValid(i) )
			continue;
			
		if( GetSteamAccountID(i) == iAccountID )
			return i;
	}
	return -1;

}
public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return (entity != data);
}
stock float fmax(float a, float b)
{
	return (a > b) ? a : b ;
}
stock float Vec2DLength(float v[2])
{
	float length = 0.0;
	for (int i=0 ; i<2 ; ++i)
		length += v[i]*v[i];
	
	length = SquareRoot(length);
	return length;
}
stock bool CalcBuildPos(const int builder, const float flMins[3], const float flMaxs[3], float flBuildBuffer[3])
{
	if (builder <= 0)
		return false ;
	
	float vec_forward[3];
	float vec_angles[3];
	GetClientEyeAngles(builder, vec_angles);
	// we only need the y-angle
	vec_angles[0] = 0.0, vec_angles[2] = 0.0;
	GetAngleVectors(vec_angles, vec_forward, NULL_VECTOR, NULL_VECTOR);
	
	float vec_objradius[2];
	vec_objradius[0] = fmax( flMins[0], flMaxs[0] );
	vec_objradius[1] = fmax( flMins[1], flMaxs[1] );
	
	float vec_playerRadius[2];
	float vecPlayerMins[3], vecPlayerMaxs[3];
	
	GetClientMaxs(builder, vecPlayerMaxs);
	GetClientMins(builder, vecPlayerMins);
	vec_playerRadius[0] = fmax( vecPlayerMins[0], vecPlayerMaxs[0] );
	vec_playerRadius[1] = fmax( vecPlayerMins[1], vecPlayerMaxs[1] );
	
	float fldist = Vec2DLength(vec_objradius) + Vec2DLength(vec_playerRadius) + 4.0;
	
	float vecBuildOrigin[3];
	float vec_playerorigin[3];
	GetClientAbsOrigin(builder, vec_playerorigin);
	
	ScaleVector(vec_forward, fldist);
	AddVectors(vec_playerorigin, vec_forward, vecBuildOrigin);
	
	flBuildBuffer = vecBuildOrigin;
	
	float vBuildDims[3];
	SubtractVectors(flMaxs, flMins, vBuildDims);
	
	float vHalfBuildDims[3];
	vHalfBuildDims = vBuildDims;
	ScaleVector(vHalfBuildDims, 0.5);
	
	
	//Vector vErrorOrigin = vecBuildOrigin - (m_vecBuildMaxs - m_vecBuildMins) * 0.5f - m_vecBuildMins;
	float vErrorOrigin[3];
	{
		SubtractVectors(vecBuildOrigin, vHalfBuildDims, vErrorOrigin);
		SubtractVectors(vErrorOrigin, flMins, vErrorOrigin);
	}
	
	float vHalfPlayerDims[3];
	{
		float mins[3]; GetClientMins(builder, mins);
		float maxs[3]; GetClientMaxs(builder, maxs);
		SubtractVectors(maxs, mins, vHalfPlayerDims);
		ScaleVector(vHalfPlayerDims, 0.5);
	}
	float flBoxTopZ = vec_playerorigin[2] + vHalfPlayerDims[2] + vBuildDims[2];
	float flBoxBottomZ = vec_playerorigin[2] - vHalfPlayerDims[2] - vBuildDims[2];
	
	float bottomZ = 0.0;
	int nIterations = 8;
	float topZ = flBoxTopZ;
	float topZInc = (flBoxBottomZ - flBoxTopZ) / (nIterations-1);
	int iIteration;
		
	float endpos[3];
	for (iIteration=0 ; iIteration<nIterations ; ++iIteration) {
		//checkOriginTop[2] = topZ;
		//checkOriginBottom[2] = flBoxBottomZ;
		
		TR_TraceHull( vecBuildOrigin, vecBuildOrigin, flMins, flMaxs, MASK_SOLID );
		TR_GetEndPosition(endpos);
		bottomZ = endpos[2];
		
		if (TR_GetFraction() == 1.0 /*or TR_PointOutsideWorld(endpos)*/) {	// no ground, can't build here!
			flBuildBuffer = vErrorOrigin;
			return false;
		}
		
		// if we found enough space to fit our object, place here
		if ( topZ - bottomZ > vBuildDims[2]
			&& !(TR_GetPointContents(vecBuildOrigin) & MASK_SOLID)
			&& !(TR_GetPointContents(vecBuildOrigin) & MASK_SOLID) )
			break;
		
		++vecBuildOrigin[2];
		topZ += topZInc;
	}
	if ( iIteration == nIterations ) {
		flBuildBuffer = vErrorOrigin;
		return false;
	}
		
	// Now see if the range we've got leaves us room for our box.
	if ( topZ-bottomZ < vBuildDims[2] ) {
		flBuildBuffer = vErrorOrigin;
		return false;
	}
	
	// Ok, now we know the Z range where this box can fit.
	float vBottomLeft[3];
	SubtractVectors(vecBuildOrigin, vHalfBuildDims, vBottomLeft);
	vBottomLeft[2] = bottomZ;
	
	SubtractVectors(vBottomLeft, flMins, vecBuildOrigin);
	flBuildBuffer = vecBuildOrigin;
	return true;
	
	/*
	bool bSuccess;
	for ( int i=301 ; i ; --i ) {
		TR_TraceHull( vecBuildOrigin, vecBuildOrigin, flMins, flMaxs, MASK_SOLID );
		if (bSuccess)
			break;
		
		if (TR_GetFraction() == 0.99 or TR_GetFraction() == 0.98)
			bSuccess = true; //PrintToConsole(builder, "tr.fraction");
		else if (TR_DidHit())
			vecBuildOrigin[2] += 0.1;
	}
	flBuildBuffer = vecBuildOrigin;
	PrintToConsole(builder, "%i", (bSuccess == true));
	return bSuccess;
	*/
}
stock bool IsPlacementPosValid(const int builder, const float flMins[3], const float flMaxs[3], float flBuildBuffer[3])
{
	bool bValid = CalcBuildPos(builder, flMins, flMaxs, flBuildBuffer);

	if ( !bValid )
		return false;
	
	if ( builder <= 0 )
		return false;
	
	// Make sure we can see the final position
	float EyePos[3]; GetClientEyePosition(builder, EyePos);
	float BuildOriginSum[3];
	{
		float tempvec[3];
		tempvec[0] = 0.0, tempvec[1] = 0.0, tempvec[2] = flMaxs[2] * 0.5;
		AddVectors(flBuildBuffer, tempvec, BuildOriginSum);
	}
	TR_TraceRayFilter( EyePos, BuildOriginSum, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, TraceRayDontHitSelf, builder );
	if ( TR_GetFraction() < 1.0 )
		return false;

	return true;
}
stock bool CanBuildHere(float flPos[3], const float flMins[3], const float flMaxs[3])
{
	bool bSuccess;
	for ( int i=0 ; i<60 ; ++i ) {
		TR_TraceHull( flPos, flPos, flMins, flMaxs, MASK_SOLID );
		if ( TR_GetFraction() > 0.98 ) {
			bSuccess = true;
			break;
		}
		else flPos[2] += 1.0;
	}
	return bSuccess;
}
stock void TE_SendBeamBoxToAll (const float upc[3], const float btc[3], int ModelIndex, int HaloIndex, int StartFrame, int FrameRate, const float Life, const float Width, const float EndWidth, int FadeLength, const float Amplitude, const int Color[4], const int Speed)
{
	// Create the additional corners of the box
	float tc1[] = {0.0, 0.0, 0.0};
	float tc2[] = {0.0, 0.0, 0.0};
	float tc3[] = {0.0, 0.0, 0.0};
	float tc4[] = {0.0, 0.0, 0.0};
	float tc5[] = {0.0, 0.0, 0.0};
	float tc6[] = {0.0, 0.0, 0.0};

	AddVectors(tc1, upc, tc1);
	AddVectors(tc2, upc, tc2);
	AddVectors(tc3, upc, tc3);
	AddVectors(tc4, btc, tc4);
	AddVectors(tc5, btc, tc5);
	AddVectors(tc6, btc, tc6);

	tc1[0] = btc[0];
	tc2[1] = btc[1];
	tc3[2] = btc[2];
	tc4[0] = upc[0];
	tc5[1] = upc[1];
	tc6[2] = upc[2];

	// Draw all the edges
	TE_SetupBeamPoints(upc, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(upc, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(upc, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc6, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc6, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc6, btc, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc4, btc, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc5, btc, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc5, tc1, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc5, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc4, tc3, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
	TE_SetupBeamPoints(tc4, tc2, ModelIndex, HaloIndex, StartFrame, FrameRate, Life, Width, EndWidth, FadeLength, Amplitude, Color, Speed);
	TE_SendToAll();
}
stock float[] Vec_SubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3]; SubtractVectors(vec1, vec2, result);
	return result;
}
stock float[] Vec_AddVectors(const float vec1[3], const float vec2[3])
{
	float result[3]; AddVectors(vec1, vec2, result);
	return result;
}
stock float[] Vec_ScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] Vec_NegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock float[] Vec_GetVectorAngles(const float vec[3])
{
	float angResult[3]; GetVectorAngles(vec, angResult);
	return angResult;
}
stock float[] Vec_GetVectorCrossProduct(const float vec1[3], const float vec2[3])
{
	float result[3]; GetVectorCrossProduct(vec1, vec2, result);
	return result;
}
stock float[] Vec_MakeVectorFromPoints(const float pt1[3], const float pt2[3])
{
	float output[3]; MakeVectorFromPoints(pt1, pt2, output);
	return output;
}
stock float[] Vec_GetEntPropVector(const int entity, const PropType type, const char[] prop, int element=0)
{
	float output[3]; GetEntPropVector(entity, type, prop, output, element);
	return output;
}
stock float[] Vec_NormalizeVector(const float vec[3])
{
	float output[3]; NormalizeVector(vec, output);
	return output;
}
stock float[] Vec_GetAngleVecForward(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, output, NULL_VECTOR, NULL_VECTOR);
	return output;
}
stock float[] Vec_GetAngleVecRight(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, NULL_VECTOR, output, NULL_VECTOR);
	return output;
}
stock float[] Vec_GetAngleVecUp(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, NULL_VECTOR, NULL_VECTOR, output);
	return output;
}
stock bool IsClientStuck(const int iEntity, const float flOrigin[3])
{
	//float flOrigin[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flOrigin);
	float flMins[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMins", flMins);
	float flMaxs[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", flMaxs);

	TR_TraceHullFilter(flOrigin, flOrigin, flMins, flMaxs, MASK_PLAYERSOLID, TraceRayDontHitSelf, iEntity);
	return TR_DidHit();
}
stock bool IsClientStuck2(const int iEntity, const float flOrigin[3], TraceEntityFilter filter)
{
	//float flOrigin[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flOrigin);
	float flMins[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMins", flMins);
	float flMaxs[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", flMaxs);

	TR_TraceHullFilter(flOrigin, flOrigin, flMins, flMaxs, MASK_PLAYERSOLID, filter, iEntity);
	return TR_DidHit();
}
stock bool BringClientToSide(const int client, const float flOrigin[3])
{
	float vec_modifier[3];
	const float flMove = 70.0;
	vec_modifier = flOrigin; vec_modifier[0] += flMove;	// check x-axis
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[0] -= flMove;
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[1] += flMove;	// check y-axis
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[1] -= flMove;
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}

	vec_modifier = flOrigin; vec_modifier[2] += flMove;	// check z-axis
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[2] -= flMove;
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	return false;
}
stock float UnitToMeter(float distance)
{
	return distance / 50.00;
}

stock float GetVectorDistanceMeter(const float vec1[3], const float vec2[3], bool squared=false) 
{
	return UnitToMeter(GetVectorDistance(vec1, vec2, squared));
}

/*stock bool TraceFilter(int ent, int contentMask)
{
	return (ent == g_iFilteredEntity) ? false : true;
}*/
stock void PreModel(const int client)
{
	TF2_RemovePlayerDisguise(client);
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == client)
		{
			int idx = GetItemIndex(ent);
			if (idx != 405 && idx != 608) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == client) {
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
}
stock void KillShields(const int client)
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == client) 
		{
			TF2_RemoveWearable(client, ent);
			AcceptEntityInput(ent, "Kill");
		}
	}
}
stock float FloatToFixed(float f, float p) 
{
	float m = Pow(10.0, p);
	return float(RoundFloat(f * m)) / m;
}
stock bool IsFloatActuallyEqual(float a, float b, float c) 
{
	// a = value1
	// b = value2
	// c = places
	
	a = FloatToFixed(a, c);
	b = FloatToFixed(b, c);
	
	return (FloatAbs(a - b) < 0.000001);
}
stock void RemoveParachute(const int client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Parachute))
		TF2_RemoveCondition(client, TFCond_Parachute);
}
stock float GetTensValue(float value)
{
	float calc = (value/100)-RoundToFloor( (value/100) );
	return (calc *= 100.0);
}
stock float RoundToDecimal(float value)
{
	value /= 10.0;
	return (RoundToFloor(value)*10.0);
}
stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEdict(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
stock int GetDispenserLevel()
{
	int level, spencer = -1;
	while ((spencer = FindEntityByClassname2(spencer, "obj_dispenser")) != -1)
	{
		level = (IsValidEdict(spencer)) ? GetEntProp(spencer, Prop_Send, "m_iUpgradeLevel") : -1;
	}
	return level;
}
stock bool IsStringNumeric(const char[] MyString)
{
	int n;
	while (MyString[n] != '\0')
	{
		if (!IsCharNumeric(MyString[n]))
			return false;
		n++;
	}
	return true;
}
stock void RandomSlap(const int client) 
{
	float fEye[3];
	GetClientEyeAngles(client, fEye);
	fEye[0] += GetRandomFloat(-10.0,10.0) * 0.1;
	fEye[1] += GetRandomFloat(-10.0,10.0) * 0.1;
	fEye[2] += GetRandomFloat(-10.0,10.0) * 0.1;
	TeleportEntity(client, nullvec, fEye, nullvec);
}
stock void SetActive(const int client, const int wep)
{
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
}
stock int TF2_SpawnWeapon(const int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == null)
		return -1;
	
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	count &= ~1;
	if (count > 0) {
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2=0;
		for (int i=0 ; i<count ; i += 2) {
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete (hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock void StringToUpper(const char[] input, char[] output, int size)
{
	for (int i=0 ; i<size ; ++i)
		output[i] = CharToLower(input[i]);
}
stock bool GetTrieValueCaseInsensitive(StringMap trie, const char[] key, any& value)
{
	if (trie == null)
		return false;
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return trie.GetValue(trieKey, value); //GetTrieValue(trie, trieKey, value);
}
stock Handle GetSubPlugin(StringMap hndl)
{
	Handle plugin;
	if ( hndl.GetValue("Subplugin", plugin) )
		return plugin;
	// Shouldn't actually get here, but we keep it just incase
	return null;
}
stock void TF2_RemoveWeaponSlot2(int client, int slot)
{
	int ew, weaponIndex;
	while ((weaponIndex = GetPlayerWeaponSlot(client, slot)) != -1)
	{ 
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearable");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearableViewModel");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		RemovePlayerItem(client, weaponIndex);
		AcceptEntityInput(weaponIndex, "Kill");
	} 
}
stock void TF2_RemoveAllWeapons2(int client)
{
	for (int i = 0; i <= 5; i++)
	{
		TF2_RemoveWeaponSlot2(client, i);
	}
}
stock int GetSpellIndex(int book)
{
	if (IsValidEntity(book))
		return GetEntProp(book, Prop_Send, "m_iSelectedSpellIndex");
	return 0;
}
stock void SetSpellIndex(int book, int spell)
{
	if (IsValidEntity(book))
		SetEntProp(book, Prop_Send, "m_iSelectedSpellIndex", spell);
}
stock int GetSpellCharges(int book)
{
	if (IsValidEntity(book))
		return GetEntProp(book, Prop_Send, "m_iSpellCharges");
	return 0;
}
stock void SetSpellCharges(int book, int amount)
{
	if (IsValidEntity(book)) 
		SetEntProp(book, Prop_Send, "m_iSpellCharges", amount);
}
stock void SetSpell(int client, int spell, int charge)
{
	int spellbook = FindSpellbook(client);
	if (spellbook <= 0)
		LogError("[RPG Fortress] ErMac: Spellbook Doesn't Exist!");
	else
	{
		SetSpellCharges(spellbook, charge);
		if (spell >= 0) 
			SetSpellIndex(spellbook, spell);
	}
}
stock void TagsCheck(const char[] tag, bool remove = false) //DarthNinja
{
	ConVar hTags = FindConVar("sv_tags");
	char tags[255];
	hTags.GetString(tags, sizeof(tags)); //GetConVarString(hTags, tags, sizeof(tags));

	if (StrContains(tags, tag, false) == -1 && !remove)
	{
		char newTags[255];
		Format(newTags, sizeof(newTags), "%s,%s", tags, tag);
		ReplaceString(newTags, sizeof(newTags), ",,", ",", false);
		hTags.SetString(newTags); //SetConVarString(hTags, newTags);
		hTags.GetString(tags, sizeof(tags)); //GetConVarString(hTags, tags, sizeof(tags));
	}
	else if (StrContains(tags, tag, false) > -1 && remove)
	{
		ReplaceString(tags, sizeof(tags), tag, "", false);
		ReplaceString(tags, sizeof(tags), ",,", ",", false);
		hTags.SetString(tags); //SetConVarString(hTags, tags);
	}
	hTags.Close();
}
stock int FindSpellbook(int client)
{
	int i = -1;
	while ((i = FindEntityByClassname(i, "tf_weapon_spellbook")) != -1)
	{
		if (IsValidEntity(i) && GetOwner(i) == client && !GetEntProp(i, Prop_Send, "m_bDisguiseWeapon")) 
			return i;
	}
	return -1;
}
stock void GetServerIP(char[] sIP, int size, bool show_port = false)
{
	int ip = GetConVarInt(FindConVar("hostip"));

	int ips[4];
	ips[0] = (ip >> 24) & 0x000000FF;
	ips[1] = (ip >> 16) & 0x000000FF;
	ips[2] = (ip >> 8) & 0x000000FF;
	ips[3] = ip & 0x000000FF;

	Format(sIP, size, "%d.%d.%d.%d", ips[0], ips[1], ips[2], ips[3]);

	if (show_port)
	{
		Format(sIP, size, "%s:%d", sIP, FindConVar("hostport").IntValue);
	}
}
#if defined _tf2_stocks_included
stock void TF2_GetClassName(TFClassType class, char[] name, int size, bool capitalize)
{
	switch (class)
	{
		case TFClass_Unknown: strcopy(name, size, "unknown");
		case TFClass_Scout: strcopy(name, size, "scout");
		case TFClass_Sniper: strcopy(name, size, "sniper");
		case TFClass_Soldier: strcopy(name, size, "soldier");
		case TFClass_DemoMan: strcopy(name, size, "demoman");
		case TFClass_Medic: strcopy(name, size, "medic");
		case TFClass_Heavy: strcopy(name, size, "heavy");
		case TFClass_Pyro: strcopy(name, size, "pyro");
		case TFClass_Spy: strcopy(name, size, "spy");
		case TFClass_Engineer: strcopy(name, size, "engineer");
	}

	if (capitalize)
	{
		name[0] = CharToUpper(name[0]);
	}
}
#endif
stock void SetMetal(const int client, const int amount)
{
	int iMetalTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(client, iMetalTable + (4*3), 200, 4, true);
}
stock int BuildSentry(int iBuilder, const float fOrigin[3], const float fAngle[3], bool iDisabled=false, int iLevel=1, int iHealth=-1, int iMaxHealth=-1, int iShells=-1, int iRockets=-1)
{
	char sModel[64];

	static const float fBuildMaxs[3] = { 24.0, 24.0, 66.0 };
	//static const Float:fMdlWidth[3] = { 1.0, 0.5, 0.0 };

	int iTeam = GetClientTeam(iBuilder);

	int iSentryHealth;
	int iMaxSentryShells;
	int iMaxSentryRockets;
	if (iLevel >= 1 && iLevel <= 3)
	{
		iSentryHealth = TF2_SentryHealth[iLevel];
		iMaxSentryShells = TF2_MaxSentryShells[iLevel];
		iMaxSentryRockets = TF2_MaxSentryRockets[iLevel];
	}
	else if (iLevel < 1)
	{
		iLevel = 1;
		iShells = 0;
		iRockets = 0;
	}
	else if (iLevel == 4)
	{
		iLevel = 3;
		iSentryHealth = (TF2_SentryHealth[3]+TF2_SentryHealth[4])/2;
		iMaxSentryShells = (TF2_MaxSentryShells[3]+TF2_MaxSentryShells[4])/2;
		iMaxSentryRockets = (TF2_MaxSentryRockets[3]+TF2_MaxSentryRockets[4])/2;
	}
	else
	{
		iLevel = 3;
		iSentryHealth = TF2_SentryHealth[4];
		iMaxSentryShells = TF2_MaxSentryShells[4];
		iMaxSentryRockets = TF2_MaxSentryRockets[4];
	}

	if (iShells < 0)
		iRockets = iMaxSentryRockets;

	if (iShells < 0)
		iShells = iMaxSentryShells;

	if (iMaxHealth < 0)
		iMaxHealth = iSentryHealth;

	if (iHealth < 0 || iHealth > iMaxHealth)
		iHealth = iMaxHealth;

	Format(sModel, sizeof(sModel),"models/buildables/sentry%d.mdl", iLevel);

	int iSentry = CreateEntityByName("obj_sentrygun");
	if (iSentry)
	{
		DispatchSpawn(iSentry);

		TeleportEntity(iSentry, fOrigin, fAngle, NULL_VECTOR);

		SetEntityModel(iSentry,sModel);

		SetEntProp(iSentry, Prop_Send, "m_iMaxHealth", 				        iMaxHealth, 4);
		SetEntProp(iSentry, Prop_Send, "m_iHealth", 					    iHealth, 4);
		SetEntProp(iSentry, Prop_Send, "m_bDisabled", 				        iDisabled, 2);
		SetEntProp(iSentry, Prop_Send, "m_iObjectType", 				    2, 1);
		SetEntProp(iSentry, Prop_Send, "m_iUpgradeLevel", 			        iLevel, 4);
		SetEntProp(iSentry, Prop_Send, "m_iAmmoRockets", 				    iRockets, 4);
		SetEntProp(iSentry, Prop_Send, "m_iAmmoShells" , 				    iShells, 4);
		SetEntProp(iSentry, Prop_Send, "m_nSkin", 					        (iTeam-2), 1);
		SetEntProp(iSentry, Prop_Send, "m_iObjectMode", 				    0, 2);
		SetEntProp(iSentry, Prop_Send, "m_iUpgradeMetal", 			        0, 2);
		SetEntProp(iSentry, Prop_Send, "m_bBuilding", 				        0, 2);
		SetEntProp(iSentry, Prop_Send, "m_bPlacing", 					    0, 2);
		SetEntProp(iSentry, Prop_Send, "m_iState", 					        1, 1);
		SetEntProp(iSentry, Prop_Send, "m_bHasSapper", 				        0, 2);
		SetEntProp(iSentry, Prop_Send, "m_nNewSequenceParity", 		        4, 4);
		SetEntProp(iSentry, Prop_Send, "m_nResetEventsParity", 		        4, 4);
		SetEntProp(iSentry, Prop_Send, "m_bServerOverridePlacement", 	    1, 1);
		SetEntProp(iSentry, Prop_Send, "m_nSequence",                       0);

		SetEntPropEnt(iSentry, Prop_Send, "m_hBuilder", 	                iBuilder);

		SetEntPropFloat(iSentry, Prop_Send, "m_flCycle", 					0.0);
		SetEntPropFloat(iSentry, Prop_Send, "m_flPlaybackRate", 			1.0);
		SetEntPropFloat(iSentry, Prop_Send, "m_flPercentageConstructed", 	1.0);
		SetEntPropFloat(iSentry, Prop_Send, "m_flModelWidthScale", 	        1.0);

		SetEntPropVector(iSentry, Prop_Send, "m_vecOrigin", 			    fOrigin);
		SetEntPropVector(iSentry, Prop_Send, "m_angRotation", 		        fAngle);
		SetEntPropVector(iSentry, Prop_Send, "m_vecBuildMaxs", 		        fBuildMaxs);
		//SetEntDataVector(iSentry, FindSendPropOffs("CObjectSentrygun","m_flModelWidthScale"),	fMdlWidth, true);

		SetVariantInt(iTeam);
		AcceptEntityInput(iSentry, "TeamNum", -1, -1, 0);

		SetVariantInt(iTeam);
		AcceptEntityInput(iSentry, "SetTeam", -1, -1, 0); 

		Event event = CreateEvent("player_builtobject");
		if (event != null)
		{
			event.SetInt("userid", GetClientUserId(iBuilder));
			event.SetInt("object", 1);
			event.SetInt("index", iSentry);
			event.SetBool("sourcemod", true);
			event.Fire();
		}
	}
	return iSentry;
}

stock int BuildDispenser(int iBuilder, const float fOrigin[3], const float fAngle[3], bool iDisabled=false, int iLevel=1, int iHealth=-1, int iMaxHealth=-1, int iMetal=-1)
{
	static const float fBuildMaxs[3] = { 24.0, 24.0, 66.0 };

	int iTeam = GetClientTeam(iBuilder);

	if (iMaxHealth < 0)
		iMaxHealth = 150;

	if (iHealth < 0 || iHealth > iMaxHealth)
		iHealth = iMaxHealth;

	if (iMetal < 0)
		iMetal = 1000;

	if (iLevel < 1)
		iLevel = 1;
	else if (iLevel > 3)
		iLevel = 3;

	int iDispenser = CreateEntityByName("obj_dispenser");
	if (iDispenser)
	{
		DispatchSpawn(iDispenser);

		TeleportEntity(iDispenser, fOrigin, fAngle, NULL_VECTOR);

		SetEntityModel(iDispenser,"models/buildables/dispenser_light.mdl");

		SetEntProp(iDispenser, Prop_Send, "m_iMaxHealth", 				        iMaxHealth, 4);
		SetEntProp(iDispenser, Prop_Send, "m_iHealth", 				            iHealth, 4);
		SetEntProp(iDispenser, Prop_Send, "m_iAmmoMetal", 				        iMetal, 4);
		SetEntProp(iDispenser, Prop_Send, "m_bDisabled", 				        iDisabled, 2);
		SetEntProp(iDispenser, Prop_Send, "m_iObjectType", 			            0, 1);
		SetEntProp(iDispenser, Prop_Send, "m_nSkin", 					        (iTeam-2), 1);
		SetEntProp(iDispenser, Prop_Send, "m_iUpgradeLevel", 			        iLevel, 4);
		SetEntProp(iDispenser, Prop_Send, "m_iObjectMode", 				        0, 2);
		SetEntProp(iDispenser, Prop_Send, "m_bBuilding", 				        0, 2);
		SetEntProp(iDispenser, Prop_Send, "m_bPlacing", 				        0, 2);
		SetEntProp(iDispenser, Prop_Send, "m_bHasSapper", 				        0, 2);
		SetEntProp(iDispenser, Prop_Send, "m_nNewSequenceParity", 		        4, 4);
		SetEntProp(iDispenser, Prop_Send, "m_nResetEventsParity", 		        4, 4);
		SetEntProp(iDispenser, Prop_Send, "m_bServerOverridePlacement",         1, 1);
		SetEntProp(iDispenser, Prop_Send, "m_nSequence",                        0);

		SetEntPropEnt(iDispenser, Prop_Send, "m_hBuilder",                      iBuilder);

		SetEntPropFloat(iDispenser, Prop_Send, "m_flCycle", 					0.0);
		SetEntPropFloat(iDispenser, Prop_Send, "m_flPlaybackRate", 			    1.0);
		SetEntPropFloat(iDispenser, Prop_Send, "m_flPercentageConstructed", 	1.0);
		SetEntPropFloat(iDispenser, Prop_Send, "m_flModelWidthScale", 	        1.0);

		SetEntPropVector(iDispenser, Prop_Send, "m_vecOrigin", 		            fOrigin);
		SetEntPropVector(iDispenser, Prop_Send, "m_angRotation", 		        fAngle);
		SetEntPropVector(iDispenser, Prop_Send, "m_vecBuildMaxs",		        fBuildMaxs);

		SetVariantInt(iTeam);
		AcceptEntityInput(iDispenser, "TeamNum", -1, -1, 0);

		SetVariantInt(iTeam);
		AcceptEntityInput(iDispenser, "SetTeam", -1, -1, 0);

		if (!iDisabled)
			AcceptEntityInput(iDispenser, "TurnOn");

		Event event = CreateEvent("player_builtobject");
		if (event != null)
		{
			event.SetInt("userid", GetClientUserId(iBuilder));
			event.SetInt("object", 0);
			event.SetInt("index", iDispenser);
			event.SetBool("sourcemod", true);
			event.Fire();
		}
	}
	return iDispenser;
}

stock int BuildTeleporterEntry(int iBuilder, const float fOrigin[3], const float fAngle[3], bool iDisabled=false, int iLevel=1, int iHealth=-1, int iMaxHealth=-1)
{
	static const float fBuildMaxs[3] = { 28.0, 28.0, 66.0 };
	//static const Float:fMdlWidth[3] = { 1.0, 0.5, 0.0 };

	int iTeam = GetClientTeam(iBuilder);

	if (iMaxHealth < 0)
		iMaxHealth = 150;

	if (iHealth < 0 || iHealth > iMaxHealth)
		iHealth = iMaxHealth;

	if (iLevel < 1)
		iLevel = 1;
	else if (iLevel > 3)
		iLevel = 3;

	int iTeleporter = CreateEntityByName("obj_teleporter");
	if (iTeleporter)
	{
		DispatchSpawn(iTeleporter);

		TeleportEntity(iTeleporter, fOrigin, fAngle, NULL_VECTOR);

		SetEntityModel(iTeleporter,"models/buildables/teleporter_light.mdl");

		SetEntProp(iTeleporter, Prop_Send, "m_iMaxHealth", 				        iMaxHealth, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_iHealth", 					    iHealth, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_bDisabled", 				        iDisabled, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_iObjectType", 				    1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_nSkin", 					        (iTeam-2), 1);
		SetEntProp(iTeleporter, Prop_Send, "m_iUpgradeLevel", 			        iLevel, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_iObjectMode", 				    0, 0);
		SetEntProp(iTeleporter, Prop_Send, "m_bBuilding", 				        0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_bPlacing", 					    0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_bHasSapper", 				        0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_nNewSequenceParity", 		        4, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_nResetEventsParity", 		        4, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_bServerOverridePlacement", 	    1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_iState", 	                        1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_nSequence",                       0);

		SetEntPropEnt(iTeleporter, Prop_Send, "m_hBuilder", 	                iBuilder);

		SetEntPropFloat(iTeleporter, Prop_Send, "m_flCycle", 					0.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flPlaybackRate", 			1.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flPercentageConstructed", 	1.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flModelWidthScale", 	        1.0);

		SetEntPropVector(iTeleporter, Prop_Send, "m_vecOrigin", 			    fOrigin);
		SetEntPropVector(iTeleporter, Prop_Send, "m_angRotation", 		        fAngle);
		SetEntPropVector(iTeleporter, Prop_Send, "m_vecBuildMaxs", 		        fBuildMaxs);

		SetVariantInt(iTeam);
		AcceptEntityInput(iTeleporter, "TeamNum", -1, -1, 0);

		SetVariantInt(iTeam);
		AcceptEntityInput(iTeleporter, "SetTeam", -1, -1, 0); 

		if (!iDisabled)
			AcceptEntityInput(iTeleporter, "TurnOn");

		Event event = CreateEvent("player_builtobject");
		if (event != null)
		{
			event.SetInt("userid", GetClientUserId(iBuilder));
			event.SetInt("object", 1);
			event.SetInt("index", iTeleporter);
			event.SetBool("sourcemod", true);
			event.Fire();
		}
	}
	return iTeleporter;
}
stock int BuildTeleporterExit(int iBuilder, const float fOrigin[3], const float fAngle[3], bool iDisabled=false, int iLevel=1, int iHealth=-1, int iMaxHealth=-1)
{
	static const float fBuildMaxs[3] = { 28.0, 28.0, 66.0 };

	int iTeam = GetClientTeam(iBuilder);

	if (iMaxHealth < 0)
		iMaxHealth = 150;

	if (iHealth < 0 || iHealth > iMaxHealth)
		iHealth = iMaxHealth;

	if (iLevel < 1)
		iLevel = 1;
	else if (iLevel > 3)
		iLevel = 3;

	int iTeleporter = CreateEntityByName("obj_teleporter");
	if (iTeleporter)
	{
		DispatchSpawn(iTeleporter);

		TeleportEntity(iTeleporter, fOrigin, fAngle, NULL_VECTOR);

		SetEntityModel(iTeleporter,"models/buildables/teleporter_light.mdl");

		SetEntProp(iTeleporter, Prop_Send, "m_iMaxHealth", 				        iMaxHealth, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_iHealth", 				        iHealth, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_bDisabled", 				        iDisabled, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_iObjectType", 			        1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_nSkin", 					        (iTeam-2), 1);
		SetEntProp(iTeleporter, Prop_Send, "m_iUpgradeLevel", 			        iLevel, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_iObjectMode", 				    1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_bBuilding", 				        0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_bPlacing", 				        0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_bHasSapper", 				        0, 2);
		SetEntProp(iTeleporter, Prop_Send, "m_nNewSequenceParity", 		        4, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_nResetEventsParity", 		        4, 4);
		SetEntProp(iTeleporter, Prop_Send, "m_bServerOverridePlacement", 	    1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_iState", 	                        1, 1);
		SetEntProp(iTeleporter, Prop_Send, "m_nSequence",                       0);

		SetEntPropEnt(iTeleporter, Prop_Send, "m_hBuilder", 	                iBuilder);

		SetEntPropFloat(iTeleporter, Prop_Send, "m_flCycle", 					0.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flPlaybackRate", 			1.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flPercentageConstructed", 	1.0);
		SetEntPropFloat(iTeleporter, Prop_Send, "m_flModelWidthScale", 	        1.0);

		SetEntPropVector(iTeleporter, Prop_Send, "m_vecOrigin", 			    fOrigin);
		SetEntPropVector(iTeleporter, Prop_Send, "m_angRotation", 		        fAngle);
		SetEntPropVector(iTeleporter, Prop_Send, "m_vecBuildMaxs", 		        fBuildMaxs);

		SetVariantInt(iTeam);
		AcceptEntityInput(iTeleporter, "TeamNum", -1, -1, 0);

		SetVariantInt(iTeam);
		AcceptEntityInput(iTeleporter, "SetTeam", -1, -1, 0); 

		if (!iDisabled)
			AcceptEntityInput(iTeleporter, "TurnOn");

		Event event = CreateEvent("player_builtobject");
		if (event != null)
		{
			event.SetInt("userid", GetClientUserId(iBuilder));
			event.SetInt("object", 1);
			event.SetInt("index", iTeleporter);
			event.SetBool("sourcemod", true);
			event.Fire();
		}
	}
	return iTeleporter;
}
stock bool CheckAdminFlagsByString(int client, const char[] flagString)
{
	AdminId admin = GetUserAdmin(client);

	if (admin != INVALID_ADMIN_ID)
	{
		int count; int found; int flags = ReadFlagString(flagString);

		for (int i = 0; i <= 20; i++)
		{
			if (flags & (1 << i))
			{
				count++;

				if (GetAdminFlag(admin, view_as<AdminFlag>(i)))
					found++;
			}
		}

		if (count == found)
			return true;
	}

	return false;
}
stock void KvGet2DVector(Handle kv, const char[] key, float vec[2], const float defvalue[2]={0.0, 0.0})
{
	char sBuffer[512];
	KvGetString(kv, key, sBuffer, sizeof(sBuffer));

	if (sBuffer[0] == '\0')
	{
		vec[0] = defvalue[0];
		vec[1] = defvalue[1];
		return;
	}

	char sPart[2][32];
	int iReturned = ExplodeString(sBuffer, " ", sPart, 2, 32);

	if (iReturned != 2)
	{
		vec[0] = defvalue[0];
		vec[1] = defvalue[1];
		return;
	}

	vec[0] = StringToFloat(sPart[0]);
	vec[1] = StringToFloat(sPart[1]);
}
stock void GetRandomCharacterString(char[] buffer, int size, int length = 32, const char[] chrs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234556789")
{
	int random; int len;
	size--;

	if (chrs[0] != '\0')
		len = strlen(chrs) - 1;

	int n;
	while (n < length && n < size)
	{
		if (chrs[0] == '\0')
		{
			random = GetRandomInt(33, 126);
			buffer[n] = random;
		}
		else
		{
			random = GetRandomInt(0, len);
			buffer[n] = chrs[random];
		}

		n++;
	}

	buffer[length] = '\0';
}
stock int[] GetConVarColor(ConVar convar)
{
	int colors[4] = {255, 255, 255, 255};

	char sBuffer[128];
	convar.GetString(sBuffer, sizeof(sBuffer));

	if (sBuffer[0] == '\0')
		return colors;

	char sPart[4][6];
	int iReturned = ExplodeString(sBuffer, StrContains(sBuffer, ", ") != -1 ? ", " : " ", sPart, 4, 6);

	for (int i = 0; i < iReturned; i++)
		colors[i] = StringToInt(sPart[i]);

	return colors;
}
stock float[] GetConVarVector(ConVar convar)
{
	float vectors[3] = {0.0, 0.0, 0.0};

	char sBuffer[128];
	convar.GetString(sBuffer, sizeof(sBuffer));

	if (sBuffer[0] == '\0')
		return vectors;

	char sPart[3][12];
	int iReturned = ExplodeString(sBuffer, StrContains(sBuffer, ", ") != -1 ? ", " : " ", sPart, 3, 12);

	for (int i = 0; i < iReturned; i++)
		vectors[i] = StringToFloat(sPart[i]);

	return vectors;
}
stock float[] GetConVar2DVector(ConVar convar)
{
	float vectors[2] = {0.0, 0.0};

	char sBuffer[128];
	convar.GetString(sBuffer, sizeof(sBuffer));

	if (sBuffer[0] == '\0')
		return vectors;

	char sPart[2][12];
	int iReturned = ExplodeString(sBuffer, StrContains(sBuffer, ", ") != -1 ? ", " : " ", sPart, 2, 12);

	for (int i = 0; i < iReturned; i++)
		vectors[i] = StringToFloat(sPart[i]);

	return vectors;
}
stock void FillArrayToValue(any[] array, int size, any value, int start = 0)
{
	if (start < 0)
		start = 0;

	for (int i = start; i < size; i++)
		array[i] = value;
}
stock void FillArrayList(ArrayList array, int size, any value, int start = 0)
{
	if (start < 0)
		start = 0;

	for (int i = start; i < size; i++)
		array.Set(i, value);
}
stock void CopyArrayToArray(const any[] array, any[] newArray, int size)
{
	for (int i = 0; i < size; i++)
		newArray[i] = array[i];
}
stock void AttachParticleToClient(int client, const char[] particle, const char[] attachment, float life = 0.0, float vOffsets[3] = {0.0, 0.0, 0.0})
{
	float vecPosition[3];
	GetClientAbsOrigin(client, vecPosition);

	int entity = CreateEntityParticle(particle, vecPosition, life);

	if (IsValidEntity(entity))
		SetParent(client, entity, attachment, vOffsets);
}
stock int CreateEntityParticle(const char[] sParticle, const float pos[3], float life = 0.0)
{
	int entity = CreateEntityByName("info_particle_system");

	if (IsValidEntity(entity))
	{
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(entity, "effect_name", sParticle);
		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "start");

		if (life > 0.0)
			SetEntitySelfDestruct(entity, life);
	}

	return entity;
}
stock void SetEntitySelfDestruct(int entity, float fDuration)
{
	char output[64];
	Format(output, sizeof(output), "OnUser1 !self:kill::%.1f:1", fDuration);
	SetVariantString(output);
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
}
stock void SetParent(int iParented, int iChild, const char[] szAttachment = "", float vOffsets[3] = {0.0, 0.0, 0.0})
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParented, iChild);

	if (szAttachment[0] != '\0') // Use at least a 0.01 second delay between SetParent and SetParentAttachment inputs.
	{
		SetVariantString(szAttachment); // "head"

		if (VectorCompare(vOffsets, view_as< float >({0.0, 0.0, 0.0}))) // NULL_VECTOR
		{
			float vPos[3];
			GetEntPropVector(iParented, Prop_Send, "m_vecOrigin", vPos);
			
			AddVectors(vPos, vOffsets, vPos);
			
			TeleportEntity(iChild, vPos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(iChild, "SetParentAttachmentMaintainOffset", iParented, iChild);
		}
		else AcceptEntityInput(iChild, "SetParentAttachment", iParented, iChild);
	}
}
stock bool HasFlag(const int client)
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
	{
		if (GetOwner(ent) == client)
			return true;
	}
	return false;
}
stock int GetFlagCarrier(const int team)
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "item_teamflag")) != -1)
	{
		int owner = GetOwner(ent);
		if (owner)
			if (GetClientTeam(owner) == team)
				return owner;
	}
	return 0;
}
stock StringMap AsMap(Handle h)
{
	return view_as< StringMap >(h);
}
stock void FillReserves(const int wep, const int slot)
{
	int owner = GetOwner(wep);
	if (owner <= 0)
		return;

	SetWeaponClip(wep, GetWeaponClip(wep));
	SetWeaponAmmo(wep, GetMaxAmmo(owner, slot));
}
stock void SetEntityColor(int iEntity, int iColor[4])
{
	SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
}
stock float GetDistanceTotal(float vec1[3], float vec2[3])
{
	float vec[3];
	for (int i = 0; i < 3; i++)
	{
		vec[i] = (vec1[i] > vec2[i]) ? vec1[i] - vec2[i] : vec2[i] - vec1[i];
	}
	
	return SquareRoot(Pow(vec[0], 2.0) + Pow(vec[1], 2.0) + Pow(vec[2], 2.0));
}
stock bool VectorsEqual(float vec1[3], float vec2[3], float tolerance=0.0)
{	
	float distance = GetVectorDistance(vec1, vec2, true);
	
	return distance <= (tolerance * tolerance);
}
stock void Clamp(int &returner, const int lowest, const int highest)
{
	if (returner < lowest)
		returner = lowest;
	else if (returner > highest)
		returner = highest;
}
stock bool iIsWithin(const int num, const int lowest, const int highest, bool inclusion = false)
{
	return (inclusion ? num >= lowest && num <= highest : num > lowest && num < highest);
}
stock bool flIsWithin(const float fl, const float lowest, const float highest, bool inclusion = false)
{
	return (inclusion ? fl >= lowest && fl <= highest : fl > lowest && fl < highest);
}
stock void GetMiddleOfABox(const float vec1[3], const float vec2[3], float buffer[3])
{
	float mid[3];
	MakeVectorFromPoints(vec1, vec2, mid);
	mid[0] = mid[0] / 2.0;
	mid[1] = mid[1] / 2.0;
	mid[2] = mid[2] / 2.0;
	AddVectors(vec1, mid, buffer);
}
stock void RemoveFromStack(ArrayStack &stack, int value)
{
	if (stack.Empty)
		return;

	ArrayStack newstack = new ArrayStack();

	int data;
	while ((data = stack.Pop()))
	{
		if (data == value)
			continue;

		newstack.Push(data);
	}

	delete stack;
	stack = newstack;
}
stock bool GetAimPos(const int client, float vecPos[3])
{
	float StartOrigin[3], Angles[3];
	GetClientEyeAngles(client, Angles);
	GetClientEyePosition(client, StartOrigin);

	Handle trace = TR_TraceRayFilterEx(StartOrigin, Angles, MASK_NPCSOLID | MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	bool didhit = TR_DidHit(trace)
	if (didhit)
		TR_GetEndPosition(vecPos, trace);

	delete trace;
	return didhit;
}
stock bool TF2_IsKillable(int entity)
{
	bool bResult = true;

	if(entity > 0 && entity <= MaxClients)
	{
		if(TF2_IsPlayerInCondition(entity, TFCond_Ubercharged) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedHidden) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedCanteen)
		|| TF2_IsPlayerInCondition(entity, TFCond_Bonked))
		{
			bResult = false;
		}
	}

	if(GetEntProp(entity, Prop_Data, "m_takedamage") != 2)
	{
		bResult = false;
	}

	return bResult;
}
stock bool IsPointVisible(int client, float vecPos[3], int target, float end[3], TraceEntityFilter filter)
{
	//Trace from our eye pos to endpos
	TR_TraceRayFilter(vecPos, end, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, filter, client);
	if(!TR_DidHit() || TR_GetEntityIndex() == target)
	{
		return true;
	}

	return false;
}
stock void FixSilentAimMovement(int client, float vel[3], float angles[3], float aimbotAngles[3])
{
	float vecSilent[3];
	vecSilent = vel;
	
	float flSpeed = SquareRoot(vecSilent[0] * vecSilent[0] + vecSilent[1] * vecSilent[1]);
	float angMove[3];
	GetVectorAngles(vecSilent, angMove);
	
	float flYaw = DegToRad(aimbotAngles[1] - angles[1] + angMove[1]);
	vel[0] = Cosine( flYaw ) * flSpeed;
	vel[1] = Sine( flYaw ) * flSpeed;
}
stock float Min(float one, float two)
{
	if(one < two)
		return one;
	else if(two < one)
		return two;

	return two;
}
stock float Max(float one, float two)
{
	if(one > two)
		return one;
	else if(two > one)
		return two;

	return two;
}
stock float[] GetDeltaVector(const int client, const int target)
{
	float vec[3];

	float vecPlayer[3];	
	GetClientAbsOrigin(client, vecPlayer);
	
	float vecPos[3];	
	GetClientAbsOrigin(target, vecPos);
	
	SubtractVectors(vecPlayer, vecPos, vec);
	return vec;
}
stock void EnemyIsAimingAtYou(int client)
{
#if defined AimTargetFilter
	float flMyPos[3];
	GetClientEyePosition(client, flMyPos);
	
	float flMaxAngle = 999.0;
	float flAimingPercent;
	
	for (int i = MaxClients; i; --i)
	{
		if(i == client)
			continue;
		
		if(!IsClientInGame(i))
			continue;
			
		if(!IsPlayerAlive(i))
			continue;
		
		if(GetClientTeam(i) == GetClientTeam(client))
			continue;
		
		float flTheirPos[3];
		GetClientEyePosition(i, flTheirPos);
		
		TR_TraceRayFilter(flMyPos, flTheirPos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, AimTargetFilter, client);
		if(TR_DidHit())
		{
			int entity = TR_GetEntityIndex();
			if(entity == i)
			{
				float vDistance[3];
				SubtractVectors(flMyPos, flTheirPos, vDistance);
				NormalizeVector(vDistance, vDistance);
				
				float flTheirEyeAng[3];
				GetClientEyeAngles(i, flTheirEyeAng);
				
				float vForward[3];
				GetAngleVectors(flTheirEyeAng, vForward, NULL_VECTOR, NULL_VECTOR);
				
				float flAngle = RadToDeg(ArcCosine(GetVectorDotProduct(vForward, vDistance)));
				
				if(flMaxAngle > flAngle && flAngle <= 60)
				{
					flMaxAngle = flAngle;
					flAimingPercent = 100 - (flMaxAngle * (100 / 60));
				}
			}
		}
	}
	
	if(flMaxAngle != 999)
	{
		char cPlayerAim[120];
		
		if(flAimingPercent >= 85.0)
		{
			SetHudTextParams(-1.0, 0.0, UMSG_SPAM_DELAY + 0.5, 255, 0, 0, 0, 0, 0.0, 0.0, 0.0);
			Format(cPlayerAim, sizeof(cPlayerAim), "Enemy is AIMING at YOU %.0f%%", flAimingPercent);
		}
		else
		{
			SetHudTextParams(-1.0, 0.0, UMSG_SPAM_DELAY + 0.5, 0, 255, 0, 0, 0, 0.0, 0.0, 0.0);
			Format(cPlayerAim, sizeof(cPlayerAim), "Enemy can SEE YOU %.0f%%", flAimingPercent);
		}
		
		ShowHudText(client, -1, cPlayerAim);
	}
#endif
}
stock void Radar(int client, float playerAngles[3])
{
#if defined GetEnemyPosToScreen
	float flMyPos[3];
	GetClientAbsOrigin(client, flMyPos);
	
	float screenx, screeny;
	float vecGrenDelta[3];
	
	for (int i = MaxClients; i; --i)
	{
		if(i == client)
			continue;
		
		if(!IsClientInGame(i))
			continue;
		
		if(!IsPlayerAlive(i))
			continue;
		
		if(GetClientTeam(i) == GetClientTeam(client))
			continue;
		
		float flEnemyPos[3];
		GetClientAbsOrigin(i, flEnemyPos);
		
		flEnemyPos[2] = flMyPos[2]; //We only care about 2D
		
		vecGrenDelta = GetDeltaVector(client, i);
		NormalizeVector(vecGrenDelta, vecGrenDelta);
		GetEnemyPosToScreen(client, playerAngles, vecGrenDelta, screenx, screeny, GetVectorDistance(flMyPos, flEnemyPos) * 0.25);
		
		SetHudTextParams(screenx, screeny, UMSG_SPAM_DELAY + 0.5, 255, 0, 0, 0, 0, 0.0, 0.0, 0.0);
		ShowHudText(client, -1, "⬤");
	}
#endif
}
stock bool IsPlayerReloading(int client)
{
#if defined IsProjectileWeapon
	int PlayerWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	
	if(!IsValidEntity(PlayerWeapon))
		return false;
	
	if(IsProjectileWeapon(PlayerWeapon))
		return false;
	
	//Fix for pyro flamethrower aimbot not aiming.	
	if(TF2_GetPlayerClass(client) == TFClass_Pyro && GetPlayerWeaponSlot(client, 0) == PlayerWeapon)
		return false;
	
	//Wrangler doesn't reload
	if(GetIndexOfWeaponSlot(client, 1) == TF_WEAPON_LASER_POINTER)
		return false;
	
	//Melee weapons don't reload
	if (GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) == PlayerWeapon)
		return false;
	
	//Can't fire with 0 ammo
	int AmmoCur = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1");
	if(AmmoCur <= 0)
		return false;
	
	//if (GetEntPropFloat(PlayerWeapon, Prop_Send, "m_flLastFireTime") > GetEntPropFloat(PlayerWeapon, Prop_Send, "m_flReloadPriorNextFire"))
	if (GetEntPropFloat(PlayerWeapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime())
		return false;
	
	return true;
#else
	return false;
#endif
}
stock bool PhysicsApplyFriction(float input[3], float out[3], float flSurfaceFriction, float flTickRate)
{
	float sv_friction = GetConVarFloat(FindConVar("sv_friction"));
	float sv_stopspeed = GetConVarFloat(FindConVar("sv_stopspeed"));

	float speed = GetVectorLength(input) / flTickRate;

	if(speed < 0.1)
		return false;

	float drop = 0.0;

	if(flSurfaceFriction != -1.0)
	{
		float friction = sv_friction * flSurfaceFriction;
		float control = (speed < sv_stopspeed) ? sv_stopspeed : speed;
		drop += control * friction * flTickRate;
	}

	float newspeed = speed - drop;

	if(newspeed < 0.0)
		newspeed = 0.0;

	if(newspeed != speed)
	{
		newspeed /= speed;
		
		out[0] = input[0] * newspeed;
		out[1] = input[1] * newspeed;
		out[2] = input[2] * newspeed;
	}

	out[0] -= input[0] * (1.0 - newspeed);
	out[1] -= input[1] * (1.0 - newspeed);
	out[2] -= input[2] * (1.0 - newspeed);
	
	out[0] *= flTickRate;
	out[1] *= flTickRate;
	out[2] *= flTickRate;
	
	return true;
}
stock float[] VelocityExtrapolate(int client, float eyepos[3])		
{
	float absVel[3];		
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", absVel);		
	
	float v[3];		
	
	v[0] = eyepos[0] + (absVel[0] * GetTickInterval());		
	v[1] = eyepos[1] + (absVel[1] * GetTickInterval());		
	v[2] = eyepos[2] + (absVel[2] * GetTickInterval());		
	
	return v;		
}
stock float PlayerGravityMod(int client)
{
	if(GetEntityMoveType(client) == MOVETYPE_NOCLIP)
		return 0.0;

	if(TF2_IsPlayerInCondition(client, TFCond_Parachute))
		return 0.2;
		
	return 1.0;
}
/*stock float[] PredictCorrection(int iClient, int iWeapon, int iTarget, float vecFrom[3], int iQuality)
{
	if(!IsValidEntity(iWeapon))
		return vecFrom;
		
	float flSpeed = GetProjectileSpeed(iWeapon);
	if(flSpeed <= 0.0)
		return vecFrom;
		
	float sv_gravity = GetConVarFloat(FindConVar("sv_gravity")) * PlayerGravityMod(iTarget);
	
	float flLag = GetPlayerLerp(iClient);
	
	bool bOnGround = ((GetEntityFlags(iTarget) & FL_ONGROUND) != 0);
	
	float vecWorldGravity[3]; vecWorldGravity[2] = -sv_gravity * (bOnGround ? 0.0 : 1.0) * GetTickInterval() * GetTickInterval();
	float vecProjGravity[3];  vecProjGravity[2]  = sv_gravity  * GetProjectileGravity(iWeapon) * GetTickInterval() * GetTickInterval();
	
	float vecVelocity[3];
	GetEntPropVector(iTarget, Prop_Data, "m_vecAbsVelocity", vecVelocity);
//	vecVelocity = view_as<float>( { -0.000010, 239.999984, -160.999984 } );
	
	float vecProjVelocity[3]; vecProjVelocity = vecProjGravity;
	
	// get the current position
	// this is not important - any point inside the collideable will work.
	float vecStepPos[3]
	GetClientAbsOrigin(iTarget, vecStepPos);
	
	float vecMins[3], vecMaxs[3];
	GetClientMins(iTarget, vecMins);
	GetClientMaxs(iTarget, vecMaxs);
	
	// get velocity for a single tick
	ScaleVector(vecVelocity, GetTickInterval());
	ScaleVector(vecProjVelocity, GetTickInterval());
	
	float vecPredictedPos[3]; vecPredictedPos = vecStepPos;
	
	// get the current arival time
	float vecPredictedProjVel[3]; vecPredictedProjVel = vecProjVelocity; // TODO: rename - this is used for gravity
	
	float subtracted[3];
	SubtractVectors(vecFrom, vecPredictedPos, subtracted);
	
	float flArrivalTime = GetVectorLength(subtracted) / (flSpeed) + flLag + GetTickInterval();
	float vecPredictedVel[3]; vecPredictedVel = vecVelocity;
	
	Handle Trace = null;
	
	int iSteps = 0;
	
	if(flArrivalTime >= 2.0)
		return NULL_VECTOR;
	
	for(float flTravelTime = 0.0; flTravelTime < flArrivalTime; flTravelTime += (GetTickInterval() * iQuality))
	{
		// trace the velocity of the target
		float vecPredicted[3];
		AddVectors(vecPredictedPos, vecPredictedVel, vecPredicted);
		
		Trace = TR_TraceHullFilterEx(vecPredictedPos, vecPredicted, vecMins, vecMaxs, MASK_PLAYERSOLID, AimTargetFilter, iTarget);
		
		if(TR_GetFraction(Trace) != 1.0)
		{
			float vecNormal[3];
			TR_GetPlaneNormal(Trace, vecNormal);
			
			PhysicsClipVelocity(vecPredictedVel, vecNormal, vecPredictedVel, 1.0);
		}
		
		float vecTraceEnd[3];
		TR_GetEndPosition(vecTraceEnd, Trace);
		
		vecPredictedPos = vecTraceEnd;
		
		delete Trace;
		vecPredicted = NULL_VECTOR;
		
		// trace the gravity of the target
		AddVectors(vecPredictedPos, vecWorldGravity, vecPredicted);
		
		Trace = TR_TraceHullFilterEx(vecPredictedPos, vecPredicted, vecMins, vecMaxs, MASK_PLAYERSOLID, AimTargetFilter, iTarget);
		
		// this is important - we predict the world as moving up in order to predict for the projectile moving down
		AddVectors(vecPredictedVel, vecPredictedProjVel, vecPredictedVel);
		
		if(TR_GetFraction(Trace) == 1.0)
		{
			bOnGround = false;
			AddVectors(vecPredictedVel, vecWorldGravity, vecPredictedVel);
		}
		else if(!bOnGround)
		{
			float surfaceFriction = 1.0;
		//	gInts->PhysicsSurfaceProps->GetPhysicsProperties(tr.surface.surfaceProps, NULL, NULL, &surfaceFriction, NULL);
			
			if(PhysicsApplyFriction(vecPredictedVel, vecPredictedVel, surfaceFriction, GetTickInterval()))
			{
				break;
			}
		}
		
		delete Trace;
		
		float temp[3];
		SubtractVectors(vecFrom, vecPredictedPos, temp);
		
		flArrivalTime = GetVectorLength(temp) / (flSpeed) + flLag + GetTickInterval();
		
		// if they are moving away too fast then there is no way we can hit them - bail!!
		if(GetVectorLength(vecPredictedVel) > flSpeed)
		{
		//	PrintToChatAll("Target too fast! id = %d", iTarget);
			break;
		}
		
		iSteps++;
	}
	
//	PrintToServer("Simulation ran for %i steps", iSteps);

	//DrawDebugArrow(vecStepPos, vecPredictedPos, view_as<float>({255, 255, 0, 255}), 0.075);

	float flOut[3];
	SubtractVectors(vecPredictedPos, vecStepPos, flOut);
	
	return flOut;
}
*/
stock float[] SelectBestTargetPos(int client, float playerEyeAngles[3], int &iBestEnemy)
{
#if defined LookupBone
	float flBestDistance = 99999.0;
	float best_target_point[3];

	for (int i = MaxClients; i; --i)
	{
		if(i == client)
			continue;

		if(!IsClientInGame(i))
			continue;

		if(!IsPlayerAlive(i))
			continue;

		if(GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(client))
			continue;

		if(!TF2_IsKillable(i))
			continue;

		float target_point[3];
		
		if(IsProjectileWeapon(GetActiveWeapon(client)))
		{
			int iBone = IsHeadShotWeapon(GetActiveWeapon(client)) ? LookupBone(i, "bip_head") : LookupBone(i, "bip_pelvis");
			if(iBone == -1)
				continue;

			float vNothing[3];
			GetBonePosition(i, iBone, target_point, vNothing);

			float vecAbs[3]; vecAbs = GetAbsOrigin(i)
			vecAbs[2] += 5.0;

			if(GetEntityFlags(i) & FL_ONGROUND 
			&& IsExplosiveProjectileWeapon(GetActiveWeapon(client))
			&& IsPointVisible(client, playerEyeAngles, i, vecAbs))
			{
				//Aim at feet with explosive weapons.
				target_point = vecAbs;
			}

			AddVectors(target_point, PredictCorrection(client, GetActiveWeapon(client), i, GetAbsOrigin(client), 1), target_point);
		}
		else
		{
			int iBone = FindBestHitbox(client, playerEyeAngles, i);
			if(iBone == -1)
				continue;

			float vNothing[3];
			GetBonePosition(i, iBone, target_point, vNothing);
		}

		if(IsPointVisible(client, playerEyeAngles, i, target_point))
		{
			float flDistance = GetVectorDistance(target_point, best_target_point);

			if(flDistance < flBestDistance)
			{
				flBestDistance = flDistance;
				best_target_point = target_point;

				iBestEnemy = i;
			}
		}
	}

	return best_target_point;
#else
	return NULL_VECTOR;
#endif
}
stock bool IsHeadShotWeapon(int iWeapon)
{
	if (GetItemIndex(iWeapon) == TF_WEAPON_COMPOUND_BOW)
		return true;
	return false;
}
#if defined _sdkhooks_included
stock int TF2_CreateGlow(int iEnt, char[] strTargetname, SDKHookCB callback)
{
	char strGlowColor[18];
	switch (GetEntProp(iEnt, Prop_Send, "m_iTeamNum"))
	{
		case 2:Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", 255, 51, 51, 255);
		case 3:Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", 153, 194, 216, 255);
		default:return -1;
	}

	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);

	int ent = CreateEntityByName("tf_glow");
	if (IsValidEntity(ent))
	{
		SDKHook(ent, SDKHook_SetTransmit, callback);
		DispatchKeyValue(ent, "targetname", strTargetname);
		DispatchKeyValue(ent, "target", strName);
		DispatchKeyValue(ent, "Mode", "0");
		DispatchKeyValue(ent, "GlowColor", strGlowColor);	
		DispatchSpawn(ent);

		AcceptEntityInput(ent, "Enable");

		//Change name back to old name because we don't need it anymore.
		SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);
		return ent;
	}
	return -1;
}
#endif
/*public Action OnSetTransmit(int entity, int client) 
{
	SetEdictFlags(entity, GetEdictFlags(entity) & ~FL_EDICT_ALWAYS);
	
	char strName[64];
	GetEntPropString(entity, Prop_Data, "m_iName", strName, sizeof(strName));
	if(StrEqual(strName, "PlayersOutline"))
	{
		if (g_bPlayersOutline[client])
			return Plugin_Continue;
	}
	else if(StrEqual(strName, "BuildingsOutline"))
	{
		if (g_bBuildingOutline[client])
			return Plugin_Continue;
	}
	
	return Plugin_Handled;
}*/
stock bool TF2_HasGlow(int iEnt)
{
	int index = -1;
	while ((index = FindEntityByClassname(index, "tf_glow")) != -1)
		if (GetEntPropEnt(index, Prop_Send, "m_hTarget") == iEnt)
			return true;
	return false;
}
stock void TF2_KillAllGlow(char[] strTargetname)
{
	int index = -1;
	while ((index = FindEntityByClassname(index, "tf_glow")) != -1)
	{
		char strName[64];
		GetEntPropString(index, Prop_Data, "m_iName", strName, sizeof(strName));
		if (StrEqual(strName, strTargetname))
			AcceptEntityInput(index, "Kill");
	}
}
stock void TF2_CreateGlowToAll(char[] strTargetname, SDKHookCB callback)	
{
	if (StrEqual(strTargetname, "PlayersOutline"))
	{
		for (int i = MaxClients; i; --i) 	
		{
			if (IsClientInGame(i))
				TF2_CreateGlow(i, strTargetname, callback);
		}
	}
	else if (StrEqual(strTargetname, "BuildingsOutline"))
	{
		int index = -1;
		while ((index = FindEntityByClassname(index, "obj_*")) != -1)
			TF2_CreateGlow(index, strTargetname, callback);
	}
}
stock void SpawnReviveMarker(const int client) 
{
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	
	int reviveMarker = CreateEntityByName("entity_revive_marker");
	if (IsValidEntity(reviveMarker)) 
	{
		DispatchKeyValueVector(reviveMarker, "origin", flPos);
		DispatchKeyValueVector(reviveMarker, "angles", flAng);
		
		//Just in case it doesnt despawn for some reason
		SetVariantString("OnUser1 !self:kill::30:1");
		AcceptEntityInput(reviveMarker, "AddOutput");
		AcceptEntityInput(reviveMarker, "FireUser1");

		SetEntPropEnt(reviveMarker, Prop_Send, "m_hOwner", client);
		SetEntProp(reviveMarker, Prop_Send, "m_nSolidType", 2);
		SetEntProp(reviveMarker, Prop_Send, "m_usSolidFlags", 8);
		SetEntProp(reviveMarker, Prop_Send, "m_fEffects", 16);
		SetEntProp(reviveMarker, Prop_Send, "m_iTeamNum", GetClientTeam(client));
		SetEntProp(reviveMarker, Prop_Send, "m_CollisionGroup", 1);
		SetEntProp(reviveMarker, Prop_Send, "m_bSimulatedEveryTick", 1);
		SetEntDataEnt2(client, FindSendPropInfo("CTFPlayer", "m_nForcedSkin") + 4, reviveMarker);
		SetEntProp(reviveMarker, Prop_Send, "m_nBody", (view_as<int>(TF2_GetPlayerClass(client))) - 1);
		SetEntProp(reviveMarker, Prop_Send, "m_nSequence", 1);
		SetEntPropFloat(reviveMarker, Prop_Send, "m_flPlaybackRate", 1.0);
		SetEntProp(reviveMarker, Prop_Data, "m_iInitialTeamNum", GetClientTeam(client));
		if(TF2_GetClientTeam(client) == TFTeam_Blue)
			SetEntityRenderColor(reviveMarker, 0, 0, 255); // make the BLU Revive Marker distinguishable from the red one
		
		DispatchSpawn(reviveMarker);
		
		// g_iPlayerMarker[client] = EntIndexToEntRef(reviveMarker);
	}
}
stock bool IsBehindAndFacingTarget( int client, int pTarget )
{
#if defined WorldSpaceCenter
	// Get the forward view vector of the target, ignore Z
	float vecVictimForward[3];
	GetAngleVectors( EntityEyeAngles(pTarget), vecVictimForward, NULL_VECTOR, NULL_VECTOR );
	vecVictimForward[2] = 0.0;
	NormalizeVector(vecVictimForward, vecVictimForward);

	// Get a vector from my origin to my targets origin
	float vecToTarget[3];
	SubtractVectors( WorldSpaceCenter(pTarget), WorldSpaceCenter(client), vecToTarget);
	vecToTarget[2] = 0.0;
	NormalizeVector(vecToTarget, vecToTarget);

	// Get a forward vector of the attacker.
	float vecOwnerForward[3];
	GetAngleVectors( EntityEyeAngles(client), vecOwnerForward, NULL_VECTOR, NULL_VECTOR );
	vecOwnerForward[2] = 0.0;
	NormalizeVector(vecOwnerForward, vecOwnerForward);

	float flDotOwner = GetVectorDotProduct( vecOwnerForward, vecToTarget );
	float flDotVictim = GetVectorDotProduct( vecVictimForward, vecToTarget );

	// Make sure they're actually facing the target.
	// This needs to be done because lag compensation can place target slightly behind the attacker.
	if ( flDotOwner > 0.5 )
		return ( flDotVictim > -0.1 );

#endif
	return false;
}
stock float [] EntityEyeAngles(int entity)
{
	float vecTargetEyeAng[3]; 
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vecTargetEyeAng);
	
	return vecTargetEyeAng;
}
stock float [] PlayerEyePosition(int client)
{
	float vec[3]; 
	GetClientEyePosition(client, vec);
	
	return vec;
}
stock void TE_ShowPole(float flPos[3], int Color[4])
{
#if defined g_iLaserMaterial
	float flToPos[3];
	flToPos[0] = flPos[0];
	flToPos[1] = flPos[1];
	flToPos[2] = flPos[2];
	flToPos[2] += 30.0;
	
	//Show a giant vertical beam at our goal node
	TE_SetupBeamPoints(flPos, flToPos, g_iLaserMaterial, g_iHaloMaterial, 0, 0, 0.1, 2.0, 2.0, 5, 0.0, Color, 30);
	TE_SendToAll();
#endif
}
stock void DropWeapon(int client, int iItemDefinitionIndex, char[] model)
{
	char strName[64];
	Format(strName, sizeof(strName), "[TF2]WeaponDrops;%i", iItemDefinitionIndex);
	
	float vecPPos[3];
	GetClientEyePosition(client, vecPPos);

	int ent = CreateEntityByName("tf_ammo_pack");
	if (IsValidEntity(ent))
	{
		DispatchKeyValue(ent, "targetname", strName);
		DispatchKeyValueVector(ent, "origin", vecPPos);
		DispatchKeyValueVector(ent, "basevelocity", {0.0, 10.0, 0.0});
		DispatchKeyValueVector(ent, "velocity", {0.0, 10.0, 0.0});
		DispatchKeyValue(ent, "model", model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); 		
		DispatchSpawn(ent);

		SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
		if(TF2_GetClientTeam(client) != TFTeam_Red)
			SetEntProp(ent, Prop_Send, "m_nSkin", GetEntProp(ent, Prop_Send, "m_nSkin") + 1);

		char addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::60:1");
		SetVariantString(addoutput);

		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}
}
stock int TF2_PlayerGiveWearable(int iClient, int iItemIndex, int iQuality = 9, int iLevel = 0, int iPaintColor = -1) 
{
#if defined TF2_EquipPlayerWearable
	char szBuffer[64];
	Handle hItem = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION);
	TF2Items_SetClassname(hItem, "tf_wearable");
	TF2Items_SetItemIndex(hItem, 0);
	TF2Items_SetQuality(hItem, iQuality);
	TF2Items_SetLevel(hItem, iLevel);
	TF2Items_SetNumAttributes(hItem, 0);

	if (iPaintColor != -1) 
	{
		IntToString(iPaintColor, szBuffer, sizeof(szBuffer));
		float flPaintColor = StringToFloat(szBuffer);
		TF2Items_SetNumAttributes(hItem, TF2Items_GetNumAttributes(hItem) + 2);
		TF2Items_SetAttribute(hItem, TF2Items_GetNumAttributes(hItem) - 2, 261, flPaintColor);
		TF2Items_SetAttribute(hItem, TF2Items_GetNumAttributes(hItem) - 1, 142, flPaintColor);
	}

	int iEntity = TF2Items_GiveNamedItem(iClient, hItem);
	SetEntProp(iEntity, Prop_Send, "m_iItemDefinitionIndex", iItemIndex);
	TF2_EquipPlayerWearable(iClient, iEntity);
	delete hItem;

	return iEntity;
#else
	return -1;
#endif
}
stock int ConnectWithBeam(int client, int iEnt2, int iRed = 255, int iGreen = 255, int iBlue = 255, float fStartWidth = 1.0, float fEndWidth = 1.0)
{
#if defined LASERBEAM
	int iEyeAttachment = CreateEntityByName("info_target");
	DispatchSpawn(iEyeAttachment);
	
	SetVariantString("!activator");
	AcceptEntityInput(iEyeAttachment, "SetParent", client);
	
	SetVariantString("righteye");
	AcceptEntityInput(iEyeAttachment, "SetParentAttachment", client);
	
	g_iEyeProp[client] = EntIndexToEntRef(iEyeAttachment);
	
	int iBeam = CreateEntityByName("env_beam");
	SetEntityModel(iBeam, LASERBEAM);
	
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d 1", iRed, iGreen, iBlue);
	
	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");
	DispatchSpawn(iBeam);
	
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEyeAttachment));
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);
	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);
	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	AcceptEntityInput(iBeam, "TurnOn");
	
	SetVariantString("!activator");
	AcceptEntityInput(iBeam, "SetParent", iEnt2);
	
	return iBeam;
#else
	return -1;
#endif
}
stock bool TF2_AddMarkerHealth(int iReviver, int iMarker, int iHealthAdd)
{
	int iHealth = GetEntProp(iMarker, Prop_Send, "m_iHealth");
	int iMaxHealth = GetEntProp(iMarker, Prop_Send, "m_iMaxHealth");
	int iOwner = GetEntPropEnt(iMarker, Prop_Send, "m_hOwner");
	
	SetEntProp(iMarker, Prop_Send, "m_iHealth", iHealth + iHealthAdd);
	iHealth += iHealthAdd;
	
	if(iHealth >= iMaxHealth && IsClientInGame(iOwner))
	{
		//Do revive
		float vecMarkerPos[3];
		GetEntPropVector(iMarker, Prop_Send, "m_vecOrigin", vecMarkerPos);
		
		EmitGameSoundToAll("MVM.PlayerRevived", iMarker);
		
		float flMins[3], flMaxs[3];
		GetEntPropVector(iOwner, Prop_Send, "m_vecMaxs", flMaxs);
		GetEntPropVector(iOwner, Prop_Send, "m_vecMins", flMins);
		
		Handle TraceRay = TR_TraceHullFilterEx(vecMarkerPos, vecMarkerPos, flMins, flMaxs, MASK_PLAYERSOLID, TraceRayDontHitSelf, iMarker);
		if(TR_DidHit(TraceRay)) //Can't spawn the player here or they would get stuck, teleport to reviver.
		{
			float vecReviverPos[3];
			GetClientAbsOrigin(iReviver, vecReviverPos);
			
			TF2_RespawnPlayer(iOwner);
			TeleportEntity(iOwner, vecReviverPos, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			TF2_RespawnPlayer(iOwner);
			TeleportEntity(iOwner, vecMarkerPos, NULL_VECTOR, NULL_VECTOR);
		}
		
		delete TraceRay;
		
		return true;
	}

	return false;
}
stock bool LookupOffset(int &iOffset, const char[] strClass, const char[] strProp)
{
	iOffset = FindSendPropInfo(strClass, strProp);
	if (iOffset <= 0)
	{
		LogMessage("Could not locate offset for %s::%s!", strClass, strProp);
		return false;
	}

	return true;
}
stock bool IsLineOfFireClear(float from[3], float to[3])
{
#if defined FilterPlayers
	Handle trace = TR_TraceRayFilterEx(from, to, CONTENTS_SOLID|CONTENTS_MOVEABLE|0x40|CONTENTS_MONSTER, RayType_EndPoint, FilterPlayers);
	float flFraction = TR_GetFraction(trace);

	delete trace;

	if (flFraction >= 1.0/* && !trace.allsolid*/) 
	{
		return !(flFraction == 0.0);    //allsolid
	}
#endif
	return false;
}
stock int MakeCEIVEnt(int client, int itemdef, int particle=0)
{
	static Handle hItem;
	if (hItem == INVALID_HANDLE)
	{
		hItem = TF2Items_CreateItem(OVERRIDE_ALL|PRESERVE_ATTRIBUTES|FORCE_GENERATION);
		TF2Items_SetClassname(hItem, "tf_wearable_vm");
		TF2Items_SetQuality(hItem, 6);
		TF2Items_SetLevel(hItem, 1);
	}
	TF2Items_SetItemIndex(hItem, itemdef);
	TF2Items_SetNumAttributes(hItem, particle ? 1 : 0);
	if (particle) TF2Items_SetAttribute(hItem, 0, 2041, float(particle));
	return TF2Items_GiveNamedItem(client, hItem);
}
stock void GetConVarArray(ConVar convar, int[] array, int size)
{
	char[][] sArray = new char[size][16];
	char buffer[32]; convar.GetString(buffer, sizeof(buffer));
	int stats = ExplodeString(buffer, ",", sArray, size, 16);
	int i;
	for (i = 0; i < stats; ++i)
	{
		TrimString(buffer[i]);
		array[i] = StringToInt(buffer[i]);
	}
}
stock int GetHealerByIndex(int client, int index)
{
	int m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;

	Address m_Shared = GetEntityAddress(client) + view_as<Address>(m_aHealers);
	Address aHealers = view_as<Address>(LoadFromAddress(m_Shared, NumberType_Int32));

	return (LoadFromAddress(aHealers + view_as<Address>(index * 0x24), NumberType_Int32) & 0xFFF);
}
stock bool ReplaceStringNth(char[] text, int maxlength, const char[] search, int occurance, const char[] replace, bool caseSensitive=true)
{
	int found, position, offset;

	while ((offset = StrContains(text[position + (found > 0 ? 1 : 0)], search, caseSensitive)) != -1 && found < occurance)
	{
		position += offset + (found > 0 ? 1 : 0);
		found++;
	}

	if (found == occurance)
	{
		ReplaceStringEx(text[position], maxlength, search, replace, _, _, caseSensitive);
		return true;
	}

	return false;
}
stock bool TF2_IsNextToWall(int client)
{
#if defined TraceFilterSelf
	float flPos[3];
	GetClientAbsOrigin(client, flPos);
	
	float flMaxs[3], flMins[3];
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
	GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
	
	flMaxs[0] += 2.5;
	flMaxs[1] += 2.5;
	flMins[0] -= 2.5;
	flMins[1] -= 2.5;
	
	flPos[2] += 18.0;
	
	//Perform a wall check to see if we are near any obstacles we should try jump over
	Handle trace = TR_TraceHullFilterEx(flPos, flPos, flMins, flMaxs, MASK_SOLID, TraceFilterSelf, client);
	
	bool bHit = TR_DidHit(trace);	
	
	delete trace;
	
	return bHit;
#else
	return false;
#endif
}
stock float GetConditionDuration(int client, TFCond cond)
{
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = view_as< Address >(ReadInt(GetEntityAddress(client) + view_as< Address >(m_Shared + 8)));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = 0.0;
	if(TF2_IsPlayerInCondition(client, cond))
	{
		flDuration = view_as<float>(LoadFromAddress(aCondDuration, NumberType_Int32));
	}
	
	return flDuration;
}
stock void SetConditionDuration(int client, TFCond cond, float time)
{
	if(!TF2_IsPlayerInCondition(client, cond))
		return;

	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = view_as< Address >(ReadInt(GetEntityAddress(client) + view_as< Address >(m_Shared + 8)));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	StoreToAddress(aCondDuration, view_as< int >(time), NumberType_Int32);
}
stock int GetConditionProvider(int client, TFCond cond)
{
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = Address(ReadInt(GetEntityAddress(client) + Address(m_Shared + 8)));
	Address aCondProvider = Address(int(aCondSource) + (int(cond) * 20) + (3 * 4));
	
	int iProvider = 0;
	if(TF2_IsPlayerInCondition(client, cond))
	{
		iProvider = (ReadInt(aCondProvider) & 0xFFF);
	}
	
	return iProvider;
}
stock int FindMatchingTeleporter(int client)
{
	int target = GetClientAimTarget(client, false);
	if(!IsValidEntity(target) || !HasEntProp(target, Prop_Send, "m_bMatchBuilding"))
		return -1;
		
	//Windows 2748
	//Linux 2768
	
	int offset = FindSendPropInfo("CObjectTeleporter", "m_bMatchBuilding");
	offset += 4;
	
	return GetEntDataEnt2(target, offset);
}
stock bool ConvertSteamID32ToSteamID64(char[] AuthID, char[] FriendID, int size)
{
	if(strlen(AuthID) < 11 || AuthID[0]!='S' || AuthID[6]=='I')
	{
		FriendID[0] = 0;
		return false;
	}

	int iUpper = 765611979;
	int iFriendID = StringToInt(AuthID[10])*2 + 60265728 + AuthID[8]-48;

	int iDiv = iFriendID/100000000;
	int iIdx = 9-(iDiv?iDiv/10+1:0);
	iUpper += iDiv;

	IntToString(iFriendID, FriendID[iIdx], size-iIdx);
	iIdx = FriendID[9];
	IntToString(iUpper, FriendID, size);
	FriendID[9] = iIdx;

	return true;
}
stock float DamageForce(const float size[3], const float damage, const float scale)
{ 
	float force = damage * ((48 * 48 * 82.0) / (size[0] * size[1] * size[2])) * scale;

	if (force > 1000.0)
		force = 1000.0;

	return force;
}
stock void FindHullIntersection(float vecSrc[3], TraceRay &tr, float mins[3], float maxs[3], int client)
{
#if defined Check4Bosses
	int            i, j, k;
	float        distance;
	float        minmaxs[2][3];

	// I know there's an easier way to do this but I'm far too mentally challenged
	minmaxs[0][0] = mins[0];
	minmaxs[0][1] = mins[1];
	minmaxs[0][2] = mins[2];
	minmaxs[1][0] = maxs[0];
	minmaxs[1][1] = maxs[1];
	minmaxs[1][2] = maxs[2];


	TraceRay tmpTrace;
	float        vecHullEnd[3]; tr.GetEndPosition(vecHullEnd);
	float        vecEnd[3];
	float        vecEnd2[3];

	distance = 1000000.0;	// 1e6f

	vecHullEnd = (Vec_AddVectors(vecSrc, ((Vec_ScaleVector(Vec_SubtractVectors(vecHullEnd, vecSrc), 2.0)))));	// That's a mouthful
	tmpTrace = new TraceRay(vecSrc, vecHullEnd, MASK_SOLID, RayType_EndPoint, Check4Bosses, client);

	if (tmpTrace.Fraction < 1.0)
	{
		tr = tmpTrace;
		delete tmpTrace;
		return;
	}

	for (i = 0; i < 2; i++)
	{
		for (j = 0; j < 2; j++)
		{
			for (k = 0; k < 2; k++)
			{
				vecEnd[0] = vecHullEnd[0] + minmaxs[i][0];
				vecEnd[1] = vecHullEnd[1] + minmaxs[j][1];
				vecEnd[2] = vecHullEnd[2] + minmaxs[k][2];

				delete tmpTrace;
				tmpTrace = new TraceRay(vecSrc, vecEnd, MASK_SOLID, RayType_EndPoint, Check4Bosses, client);
				if (tmpTrace.Fraction < 1.0)
				{
					tmpTrace.GetEndPosition(vecEnd2);
					delete tmpTrace;
					float thisDistance = GetVectorLength(vSubtractVectors(vecEnd2, vecSrc));
					if (thisDistance < distance)
					{
						delete tr;
						tr = tmpTrace;
						distance = thisDistance;
					}
				}
			}
		}
	}
#endif
}
stock int GetSignMask(const float v[3])
{
	int ret=0;
	if (v[0]<0.0)
		ret++;
	if (v[1]<0)
		ret+=2;
	if (v[2]<0)
		ret+=4;
	return ret;
}
stock int ReadByte(Pointer pAddr)
{
	if (pAddr == nullptr)
	{
		return -1;
	}
	
	return LoadFromAddress(pAddr, NumberType_Int8);
}

stock int ReadWord(Pointer pAddr)
{
	if (pAddr == nullptr)
	{
		return -1;
	}
	
	return LoadFromAddress(pAddr, NumberType_Int16);
}

stock int ReadInt(Pointer pAddr)
{
	if (pAddr == nullptr)
	{
		return -1;
	}
	
	return LoadFromAddress(pAddr, NumberType_Int32);
}
stock Pointer Transpose(Pointer pAddr, int iOffset)
{
	return ptr(int(pAddr) + iOffset);
}
stock int Dereference(Pointer pAddr, int iOffset = 0)
{
	if (pAddr == nullptr)
	{
		return -1;
	}

	return ReadInt(Transpose(pAddr, iOffset));
}
stock void PrintToScag2(char[] s)
{
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetSteamAccountID(i) != 125236808)
			continue;

		PrintToChat(i, s);
		break;
	}
}
stock void PrintToScagC(char[] s, any ...)
{
	char buffer[256];
	VFormat(buffer, sizeof(buffer), s, 2);
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetSteamAccountID(i) != 125236808)
			continue;

		PrintToConsole(i, s);
		break;
	}
}
stock bool IsClientScag(const int client)
{
	return GetSteamAccountID(client) == 125236808;
}
stock void SecondsToTime(int time, char[] buffer, int maxlength)
{
	static int dims[] = {60, 60, 24, 30, 365, cellmax};
	static char sign[][] = {"s", "m", "h", "d", "m", "y"};
	static char form[][] = {"%02i%s%s", "%02i%s %s", "%i%s %s"};
	buffer[0] = '\0';
	int i = 0, f = -1;
	bool cond = false;
	while (!cond)
	{
		if (f++ == 1)
			cond = true;
		do
		{
			Format(buffer, maxlength, form[f], time % dims[i], sign[i], buffer);
			if (time /= dims[i++], time == 0)
				return;
		} while (cond);
	}
}
stock char[] TF2_GetPlayerClassname(const int client, bool capitalize = false)
{
	char s[16];
	switch (TF2_GetPlayerClass(client))
	{
		case TFClass_Scout:s = "scout";
		case TFClass_Soldier:s = "soldier";
		case TFClass_Pyro:s = "pyro";
		case TFClass_DemoMan:s = "demoman";
		case TFClass_Medic:s = "medic";
		case TFClass_Heavy:s = "heavy";
		case TFClass_Spy:s = "spy";
		case TFClass_Engineer:s = "engineer";
	}

	if (capitalize)
		CharToUpper(s[0]);

	return s;
}
stock float GetFov(const float viewAngle[3], const float aimAngle[3])
{
	float ang[3], aim[3];
	
	GetAngleVectors(viewAngle, aim, NULL_VECTOR, NULL_VECTOR);
	GetAngleVectors(aimAngle, ang, NULL_VECTOR, NULL_VECTOR);
	
	return RadToDeg(ArcCosine(GetVectorDotProduct(aim, ang) / GetVectorLength(aim, true)));
}
stock float[] CalcAngle(float src[3], float dst[3])
{
	float angles[3];
	float delta[3];
	SubtractVectors(dst, src, delta);
	
	GetVectorAngles(delta, angles);
	
	return angles;
}
stock float[] GetEyePosition(int client)
{
	float v[3];
	GetClientEyePosition(client, v);
	return v;
}
stock float[] GetAbsOrigin(int client)
{
	float v[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", v);
	return v;
}
stock float GetDistance(float src[3], float dst[3])
{
	return SquareRoot(Pow(src[0] - dst[0], 2.0) + Pow(src[1] - dst[1], 2.0) + Pow(src[2] - dst[2], 2.0));
}
stock float clamp( float val, float minVal, float maxVal )
{
	if ( maxVal < minVal )
		return maxVal;
	else if( val < minVal )
		return minVal;
	else if( val > maxVal )
		return maxVal;
	else
		return val;
}
stock float RemapVal( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	return C + (D - C) * (val - A) / (B - A);
}
stock float RemapValClamped( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	cVal = clamp( cVal, 0.0, 1.0 );

	return C + (D - C) * cVal;
}
stock float SimpleSpline( float value )
{
	float valueSquared = value * value;

	// Nice little ease-in, ease-out spline-like curve
	return (3 * valueSquared - 2 * valueSquared * value);
}
// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
stock float SimpleSplineRemapVal( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	return C + (D - C) * SimpleSpline( cVal );
}
// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
stock float SimpleSplineRemapValClamped( float val, float A, float B, float C, float D )
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	cVal = clamp( cVal, 0.0, 1.0 );
	return C + (D - C) * SimpleSpline( cVal );
}
stock void VectorFill(float a[3], float b)
{
	a[0]=a[1]=a[2]=b;
}
stock float VectorAvg(float a[3])
{
	return ( a[0] + a[1] + a[2] ) / 3.0;
}
stock bool IsIntegralValue( float flValue, float flTolerance = 0.001 )
{
	return FloatAbs( RoundFloat( flValue ) - flValue ) < flTolerance;
}
enum
{
    TF_AMMO_DUMMY = 0,    // Dummy index to make the CAmmoDef indices correct for the other ammo types.
    TF_AMMO_PRIMARY,
    TF_AMMO_SECONDARY,
    TF_AMMO_METAL,
    TF_AMMO_GRENADES1,
    TF_AMMO_GRENADES2,
    TF_AMMO_COUNT
};
stock void SetAmmoPackData(int pack, int type, int val)
{
	int Offset = ((type * 4) + (FindDataMapInfo(pack, "m_vOriginalSpawnAngles") + 20));

	SetEntData(pack, Offset, val, _, true);
}
stock void PrepareSoundDir(bool valve = false, char[] dir = "sound")
{
	DirectoryListing l = OpenDirectory(dir, valve);
//	if (!l)
//		return;

	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	int len;
	l.GetNext(buffer, sizeof(buffer));

	while (l.GetNext(buffer, sizeof(buffer), type))
	{
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;

		if (type == FileType_Directory)
		{
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareSoundDir(valve, buffer);
		}
		else if (type == FileType_File)
		{
			if ((len = strlen(buffer)) < 5)			/// .mp3, .wav, etc
				continue;

			if (StrContains(buffer[len-4], ".mp3") == -1 && StrContains(buffer[len-4], ".wav") == -1 && StrContains(buffer[len-4], ".ogg") == -1)		/// Don't think TF2 supports .ogg but w/e
				continue;

			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);

			PrecacheSound(buffer[6]);
		}
	}
	delete l;
}
stock void PrepareModelDir(bool valve = false, char[] dir = "models")
{
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));

	while (l.GetNext(buffer, sizeof(buffer), type))
	{
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;

		if (type == FileType_Directory)
		{
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareModelDir(valve, buffer);
		}
		else if (type == FileType_File)
		{
			if (strlen(buffer) < 5)
				continue;

			if (StrContains(buffer, ".dx80.vtx") == -1 && StrContains(buffer, ".dx90.vtx") == -1 && StrContains(buffer, ".mdl") == -1
			 && StrContains(buffer, ".phy") == -1 && StrContains(buffer, ".sw.vtx") == -1 && StrContains(buffer, ".vvd") == -1)
				continue;

			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
			if (StrContains(buffer, ".mdl", false) != -1 && !IsModelPrecached(buffer))
				PrecacheModel(buffer);
		}
	}
	delete l;
}
stock void PrepareMaterialDir(bool valve = false, char[] dir = "materials")
{
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));

	while (l.GetNext(buffer, sizeof(buffer), type))
	{
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;

		if (type == FileType_Directory)
		{
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareMaterialDir(valve, buffer);
		}
		else if (type == FileType_File)
		{
			if (strlen(buffer) < 5)
				continue;

			if (StrContains(buffer, ".vmt") == -1 && StrContains(buffer, ".vtf") == -1)
				continue;

			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
		}
	}
	delete l;
}
stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock int GetRandomIntExcept(const int start, const int end, const int exception)
{
	int endnum = GetRandomInt(start, end);
	if (endnum == exception)
		return GetRandomIntExcept(start, end, exception);
	return endnum;
}
stock int GetEntityFromAddress(Address pEntity)
{
	return ReadInt(pEntity + ptr(FindDataMapInfo(0, "m_angRotation") + 12)) & 0xFFF;
}
stock int TF2_GetNumWearables(int client)
{
	// 3552 linux
	// 3532 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20 + 12;
	return GetEntData(client, offset);
}

stock int TF2_GetWearable(int client, int wearableidx)
{
	// 3540 linux
	// 3520 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20;
	Address m_hMyWearables = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(offset), NumberType_Int32));
	return LoadFromAddress(m_hMyWearables + view_as< Address >(4 * wearableidx), NumberType_Int32) & 0xFFF;
}

stock bool FindNonCollideHullPosition(const float vecPosition[3], const float vecMins[3], const float vecMaxs[3], float vecDestination[3], 
	int flags, TraceEntityFilter filter, any data, float searchScale = 1.0)
{
	
	Handle trace = TR_TraceHullFilterEx(vecPosition, vecPosition, vecMins, vecMaxs,
			flags, filter, data);
	
	bool valid = !TR_DidHit(trace);
	delete trace;
	
	if (valid)
	{
		vecDestination = vecPosition;
		return true;
	}
	
	return FindNonCollideHullPositionExtent(vecPosition, vecMins, vecMaxs, vecDestination,
			flags, filter, data, searchScale);
}
enum EHullExtent
{
	HullExtent_Center,
	HullExtent_Minimum,
	HullExtent_Maximum
};
stock bool FindNonCollideHullPositionExtent(const float vecPosition[3],
		const float vecMins[3], const float vecMaxs[3], float vecDestination[3],
		int flags, TraceEntityFilter filter, any data, float searchScale = 1.0)
{
	float vecCenter[3];
	for (int i; i < sizeof(vecCenter); i++)
		vecCenter[i] = (vecMaxs[i] + vecMins[i]) / 2;
	
	float vecScaledMins[3], vecScaledMaxs[3];
	vecScaledMins = vecMins;
	vecScaledMaxs = vecMaxs;
	
	ScaleVector(vecScaledMins, searchScale);
	ScaleVector(vecScaledMaxs, searchScale);
	
	/** 
	 * Basically we treat the corners and center edges of the bounding box as potential
	 * unstuck position candidates.
	 */
	
	for (EHullExtent x = HullExtent_Center; x <= HullExtent_Maximum; x++)
	{
		for (EHullExtent y = HullExtent_Center; y <= HullExtent_Maximum; y++)
		{
			// we assume the center has already been checked
			if (x == HullExtent_Center && y == HullExtent_Center)
				continue;
			
			float vecOffset[] = { 0.0, 0.0, 10.0 };
			
			switch (x)
			{
				case HullExtent_Minimum: { vecOffset[0] = vecScaledMins[0]; }
				case HullExtent_Maximum: { vecOffset[0] = vecScaledMaxs[0]; }
				case HullExtent_Center:  { vecOffset[0] = vecCenter[0]; }
			}
			
			switch (y)
			{
				case HullExtent_Minimum: { vecOffset[1] = vecScaledMins[1]; }
				case HullExtent_Maximum: { vecOffset[1] = vecScaledMaxs[1]; }
				case HullExtent_Center:  { vecOffset[0] = vecCenter[0]; }
			}
			
			float vecTestPosition[3];
			AddVectors(vecPosition, vecOffset, vecTestPosition);
			
			Handle trace = TR_TraceHullFilterEx(vecTestPosition, vecTestPosition,
					vecMins, vecMaxs, flags, filter, data);
			
			bool valid = !TR_DidHit(trace);
			
			delete trace;
			
			if (valid)
			{
				vecDestination = vecTestPosition;
				return true;
			}
		}
	}
	return false;
}

stock bool TF2_UnstuckPlayer(int client, float scale = 1.0, float searchScale = 1.0, const float position[3] = NULL_VECTOR)
{
	float vecMins[3], vecMaxs[3], vecPosition[3], vecDestination[3];
	GetEntPropVector(client, Prop_Data, "m_vecMinsPreScaled", vecMins);
	GetEntPropVector(client, Prop_Data, "m_vecMaxsPreScaled", vecMaxs);
	
	ScaleVector(vecMins, scale);
	ScaleVector(vecMaxs, scale);
	
	if (IsNullVector(position))
		GetClientAbsOrigin(client, vecPosition);
	else
		vecPosition = position;
	
	if (FindNonCollideHullPosition(vecPosition, vecMins, vecMaxs, vecDestination, MASK_SOLID, UnstuckTraceFilter, client))
	{
		TeleportEntity(client, vecDestination, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	
	// check a little higher for slopes
	vecPosition[2] += 10.0;
	if (FindNonCollideHullPositionExtent(vecPosition, vecMins, vecMaxs, vecDestination, MASK_SOLID, UnstuckTraceFilter, client, searchScale))
	{
		TeleportEntity(client, vecDestination, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	
	return false;
}
static stock bool UnstuckTraceFilter(int entity, int contents, int self)
{
	return !(0 < entity <= MaxClients);
}

stock int GetDeadPlayer(int team = 0)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || IsPlayerAlive(i))
			continue;
		if (team && GetClientTeam(i) != team)
			continue;
		clients[clientCount++] = i;
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}