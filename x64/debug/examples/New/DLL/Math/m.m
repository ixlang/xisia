// Exports for Dynamic Link Library

export IsInitialized();
	return(TRUE);
end;

export MathMul(dword N1,dword N2);
	return(N1 * N2);
end;

export MathDiv(dword N1,dword N2);
	return(N1 / N2);
end;

export MathAdd(dword N1,dword N2);
	return(N1 + N2);
end;

export MathSub(dword N1,dword N2);
	return(N1 - N2);
end;
