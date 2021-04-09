// Math.inc

import sprintf lib "MSVCRT.DLL", -1;

type TMathInternal {
    string strFormat[16];
    string strReturned[32];
    float fOneEighty;
    word CntlWrdSave;
    word CntlWrdNew;
    dword fFloatL;
    dword fFloatH;
    float fReturned;
    dword dwReturned;
}

TMathInternal mi;
float fTrunc;

func Sin(float fAngle) as float;
// fld [fAngle]
    direct[word $45D9]; direct[byte $08];
// fsin
    direct[word $FED9];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Cos(float fAngle) as float;
    direct[word $45D9]; direct[byte $08];
// fcos
    direct[word $FFD9];
    direct[word $1DD9]; direct[address mi.fReturned];
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Tan(float fAngle) as float;
    direct[word $45D9]; direct[byte $08];
// fptan
    direct[word $F2D9];
// Pop the 1.0
    direct[word $1DD9]; direct[address mi.fReturned];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Pi() as float;
// fldpi
    direct[word $EBD9];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func RadToDeg(float fValue) as float;
    mi.fOneEighty = 180.0;
// fld1
    direct[word $E8D9];
// fldpi
    direct[word $EBD9];
// fdivp s1,s
    direct[word $F9DE];
// fld [fOneEighty]
    direct[word $05D9]; direct[address mi.fOneEighty];
// fmulp s1,s
    direct[word $C9DE];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fmulp s1,s
    direct[word $C9DE];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func DegToRad(float fValue) as float;
    mi.fOneEighty = 180.0;
// fldpi
    direct[word $EBD9];
// fld [fOneEighty]
    direct[word $05D9]; direct[address mi.fOneEighty];
// fdivp s1,s
    direct[word $F9DE];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fmulp s1,s
    direct[word $C9DE];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Float(dword dwValue) as float;
// fild [dwValue]
    direct[word $45DB]; direct[byte $08];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Trunc(float fValue) as float;
// fwait
    direct[byte $9B];
// fstcw [mi.CntlWrdSave]
    direct[word $3DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// mov ax,[mi.CntlWrdSave]
    direct[byte $66]; direct[byte $A1]; direct[address mi.CntlWrdSave]; 
// or ax,$0C00
    direct[byte $66]; direct[byte $0D]; direct[word $0C00]; 
// mov [mi.CntlWrdNew],ax
    direct[byte $66]; direct[byte $A3]; direct[address mi.CntlWrdNew]; 
// fldcw [mi.CntlWrdNew]
    direct[word $2DD9]; direct[address mi.CntlWrdNew];
// fwait
    direct[byte $9B];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// frndint
    direct[word $FCD9];
// fldcw [mi.CntlWrdSave]
    direct[word $2DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Integer(float fValue) as dword;
    fTrunc = Trunc(fValue);
// fld [fTrunc]
    direct[word $05D9]; direct[address fTrunc];
// fistp [mi.dwReturned]
    direct[word $1DDB]; direct[address mi.dwReturned];  
// mov eax,[mi.dwReturned]
    direct[byte $A1]; direct[address mi.dwReturned];
end;

func Frac(float fValue) as float;
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fwait
    direct[byte $9B];
// fstcw [mi.CntlWrdSave]
    direct[word $3DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// mov ax,[mi.CntlWrdSave]
    direct[byte $66]; direct[byte $A1]; direct[address mi.CntlWrdSave]; 
// or ax,$0C00
    direct[byte $66]; direct[byte $0D]; direct[word $0C00]; 
// mov [mi.CntlWrdNew],ax
    direct[byte $66]; direct[byte $A3]; direct[address mi.CntlWrdNew]; 
// fldcw [mi.CntlWrdNew]
    direct[word $2DD9]; direct[address mi.CntlWrdNew];
// fwait
    direct[byte $9B];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// frndint
    direct[word $FCD9];
// fldcw [mi.CntlWrdSave]
    direct[word $2DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// fsubp s1,st
    direct[word $E9DE];
// fstp dword[mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Round(float fValue) as float;
// fwait
    direct[byte $9B];
// fstcw [mi.CntlWrdSave]
    direct[word $3DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// mov ax,[mi.CntlWrdSave]
    direct[byte $66]; direct[byte $A1]; direct[address mi.CntlWrdSave]; 
// or ax,$F3FF
    direct[byte $66]; direct[byte $0D]; direct[word $FF3F]; 
// mov [mi.CntlWrdNew],ax
    direct[byte $66]; direct[byte $A3]; direct[address mi.CntlWrdNew]; 
// fldcw [mi.CntlWrdNew]
    direct[word $2DD9]; direct[address mi.CntlWrdNew];
// fwait
    direct[byte $9B];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// frndint
    direct[word $FCD9];
// fldcw [mi.CntlWrdSave]
    direct[word $2DD9]; direct[address mi.CntlWrdSave];
// fwait
    direct[byte $9B];
// fistp [mi.dwReturned]
    direct[word $1DDB]; direct[address mi.dwReturned];  
// mov eax,[mi.dwReturned]
    direct[byte $A1]; direct[address mi.dwReturned];
end;

func Floor(float fValue) as float;
    dword dwFloor;
    dwFloor = Integer(fValue);
    if (Frac(fValue) < 0.0) {
        dwFloor--;
    }
    return(dwFloor);
end;

func Ceiling(float fValue) as float;
    dword dwCeiling;
    dwCeiling = Integer(fValue);
    if (Frac(fValue) > 0.0) {
        dwCeiling++;
    }
    return(dwCeiling);
end;

func AbsF(float fValue) as float;
    direct[word $45D9]; direct[byte $08];
// fabs
    direct[word $E1D9];
    direct[word $1DD9]; direct[address mi.fReturned];
    direct[byte $A1]; direct[address mi.fReturned];
end;

func SqrF(float fValue) as float;
    direct[word $45D9]; direct[byte $08];
// fsqrt
    direct[word $FAD9];
    direct[word $1DD9]; direct[address mi.fReturned];
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Ln(float fValue) as float;

// ln(x) = ln(2) * log2(x)

// fldln2
    direct[word $EDD9];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fyl2x
    direct[word $F1D9];
// fstp [mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Log(float fValue) as float;
// fldlg2
    direct[word $ECD9];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fyl2x
    direct[word $F1D9];
// fstp [mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Log2(float fValue) as float;
// fld1
    direct[word $E8D9];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fyl2x
    direct[word $F1D9];
// fstp [mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func LogN(float fBase, float fValue) as float;
// fld1
    direct[word $E8D9];
// fld [fBase]
    direct[word $45D9]; direct[byte $0C];
// fyl2x
    direct[word $F1D9];
// fld1
    direct[word $E8D9];
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fyl2x
    direct[word $F1D9];
// fdivp s1,s
    direct[word $F9DE];
// fstp [mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func Exp(float fValue) as float;
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fldl2e
    direct[word $EAD9];
// fmulp st1,st0
    direct[word $C9DE];
// fst st1
    direct[word $D1DD];
// frndint
    direct[word $FCD9];
// fsub st1,st0
    direct[word $E9DC];
// fxch 
    direct[word $C9D9];
// fx2xm1
    direct[word $F0D9];
// fld1
    direct[word $E8D9];
// faddp st1,st0
    direct[word $C1DE];
// fscale
    direct[word $FDD9];
// fstp st1
    direct[word $D9DD];
// fstp [mi.fReturned]
    direct[word $1DD9]; direct[address mi.fReturned];
// mov eax,[mi.fReturned]
    direct[byte $A1]; direct[address mi.fReturned];
end;

func PowF(float fBase, float fExponent) as float;
    float fFloat;
 
    if (fBase = 0.0) {
        return(0.0);
    } 
    if (fExponent = 0.0) {
        return(1.0);
    }
    fFloat = Ln(fBase) * fExponent;
    fFloat = Exp(fFloat);
    if (fBase < 0.0) {
        fFloat = fFloat * (-1.0);
    }
    if (fExponent < 0.0) {
        fFloat = 1.0 / fFloat;
    }
    return(fFloat);
end;

func StrI(dword dwValue) as string;
    mi.strReturned = ""; 
    mi.strFormat = "%ld%c";
    sprintf(@mi.strReturned, @mi.strFormat, dwValue, 0);
    return(@mi.strReturned);
end;

func StrU(dword dwValue) as string;
    mi.strReturned = ""; 
    mi.strFormat = "%lu%c";
    sprintf(@mi.strReturned, @mi.strFormat, dwValue, 0);
    return(@mi.strReturned);
end;

func StrF(float fValue) as string;
    mi.strReturned = ""; 
    mi.strFormat = "%f%c";
// fld [fValue]
    direct[word $45D9]; direct[byte $08];
// fstp qword[mi.fFloatL] 
    direct[word $1DDD]; direct[address mi.fFloatL];
    sprintf(@mi.strReturned, @mi.strFormat, mi.fFloatL, mi.fFloatH, 0);
    return(@mi.strReturned);
end;


func Sng2Str(float fValue) as string;
    return(StrF(fValue));
end;

func Sng2Int(float fValue) as dword;
    return(Integer(fValue));
end;

func Int2Sng(float fValue) as float;
    return(Float(fValue));
end;