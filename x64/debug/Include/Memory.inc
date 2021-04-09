//Memory.inc

func MemAlloc(dword Size);
	dword hVA;
	hVA = VirtualAlloc(0,Size,$1000,4);
	if (hVA = NULL) {
		return(FALSE); 
	} else {
		return(hVA);
	}
end;

func MemFree(dword Handle);
	VirtualFree(Handle,0,$8000);
end;

func Space(dword Size) as string;
	var dword tmp;
	tmp = MemAlloc(Size+1);
	return(@tmp);
end;