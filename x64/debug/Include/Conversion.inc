//Conversion.inc

import StrToInt alias StrToIntA lib "shlwapi.dll",1;

string nStr;

func Str2Int(dword ptrString) as dword;
	return(StrToInt(ptrString));
end;

func Int2Str(dword Value) as string;
	Format(nStr,"%d",Value);
	return(nStr);
end;

func CStr(dword Value) as string;
	return(Int2Str(Value));
end;

func CInt(dword ptrString) as dword;
	return(Str2Int(ptrString));
end;

func LoWord(dword Value) as dword;
	return(Value & $0000FFFF);
end;

func HiWord(dword Value) as dword;
	return(Value >> 16);
end;
