import MessageBox ascii lib "USER32.DLL",4;

func MsgBox(string message,dword style,string title) as dword;
	MessageBox(0,message,title,style);
end;
