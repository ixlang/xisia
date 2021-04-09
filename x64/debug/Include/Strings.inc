// Strings.inc

func Left(dword ptrString, dword Length) as string;
	lstrcpyn(ptrString,ptrString,Length+1);
	return(ptrString);
end;

func Mid(dword ptrString, dword Start, dword Length) as string;
	lstrcpyn(ptrString,ptrString+(Start-1),Length+1);
	return(ptrString);
end;

func Right(dword ptrString, dword Length) as string;
	ptrString = ptrString + lstrlen(ptrString) - Length;
	return(lstrcpy(ptrString,ptrString));
end;

func UCase(dword ptrString) as string;
	return(CharUpper(ptrString));
end;

func LCase(dword ptrString) as string;
	return(CharLower(ptrString));
end;

func Len(dword ptrString) as string;
	return(lstrlen(@ptrString));

end;