
package Xisia {
    static class Expressions
    {
        public static bool Isdouble = false;
        public static String Relation = "";
        public static int eUniqueID = 0;
        public static String CompareOne = "";
        public static String CompareTwo = "";
        public static String Assignment = "";
        public static byte BracketsOpen = 0;
        public static int EvaluateCount = 0;
        public static bool IsStringCompare = false;

        public static void ChooseRelation(int iID, String LabelElse) {
            if (Relation .equals("=")) {
                comAssembler.ExprJNE(LabelElse + iID);
            } else
                if (Relation .equals( "!=")) {
                    comAssembler.ExprJE(LabelElse + iID);
                } else
                    if (Relation .equals( "<>")) {
                        comAssembler.ExprJE(LabelElse + iID);
                    } else
                        if (Relation .equals( "<")) {
                            comAssembler.ExprJAE(LabelElse + iID);
                        } else
                            if (Relation .equals( ">")) {
                                comAssembler.ExprJLE(LabelElse + iID);
                            } else
                                if (Relation .equals( ">=")) {
                                    comAssembler.ExprJL(LabelElse + iID);
                                } else
                                    if (Relation .equals( "<=")) {
                                        comAssembler.ExprJA(LabelElse + iID);
                                    } else
                                        if (Relation .equals( "=>")) {
                                            comAssembler.ExprJL(LabelElse + iID);
                                        } else
                                            if (Relation .equals( "=<")) {
                                                comAssembler.ExprJA(LabelElse + iID);
                                            }
        }

        static bool IsOperatorAdd() {
            return Parser.IsSymbol('+') || Parser.IsSymbol('-') || Parser.IsIdent("add") || Parser.IsIdent("sub");
        }

        static bool IsOperatorBool() {
            return Parser.IsSymbol("|") || Parser.IsSymbol("~") || Parser.IsSymbol("&") || Parser.IsIdent("or") || Parser.IsIdent("xor") || Parser.IsIdent("and");
        }

        static bool IsOperatorMul() {
            return Parser.IsSymbol('*') || Parser.IsSymbol('/') || Parser.IsSymbol("%") || Parser.IsSymbol(">>") || Parser.IsSymbol("<<") || Parser.IsIdent("mul") || Parser.IsIdent("div") || Parser.IsIdent("mod") || Parser.IsIdent("shr") || Parser.IsIdent("shl");
        }

        static bool IsOperatorRelation() {
            return Parser.IsSymbol('=') || Parser.IsSymbol("!=") || Parser.IsSymbol("<>") || Parser.IsSymbol(">=") || Parser.IsSymbol("<=") || Parser.IsSymbol("=>") || Parser.IsSymbol("=<") || Parser.IsSymbol(">") || Parser.IsSymbol("<");
        }

        public static void Expression(String AssignTo) {
            Parser.SkipBlank();
            Assignment = AssignTo;
            EvaluateCount = 0;
            Isdouble = false;
            EvalRelation();

            if (AssignTo.length() != 0) {
                if (AssignTo.equals("$Intern.Compare.One") && (CompareOne.length() != 0)) {
                    return;
                }

                if (AssignTo.equals("$Intern.Compare.Two") && (CompareTwo.length() != 0)) {
                    return;
                }

                if (Symbols.GetSymbolSize(AssignTo) == 1) {
                    comAssembler.PopEDX();
                    Compiler.AddCodeWord(0x1588); //mov [variable],dl
                    Fixups.AddFixup(AssignTo, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
                    Compiler.AddCodeBytes(new byte[4]);
                } else
                    if (Symbols.GetSymbolSize(AssignTo) == 2) {
                        comAssembler.PopEDX();
                        Compiler.AddCodeWord(0x8966); //mov [variable],cx
                        Compiler.AddCodeByte(0x15);
                        Fixups.AddFixup(AssignTo, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
                        Compiler.AddCodeBytes(new byte[4]);
                    } else {
                        comAssembler.PopEAX();
                        comAssembler.AssignEAX(AssignTo);
                    }
            }
        }

        public static void EvalRelation() {
            Parser.SkipBlank();
            EvalBool();

            while (IsOperatorRelation()) {
                if (Parser.IsSymbol("<>")) {
                    Relation = "<>";
                    Parser.Position += 2;
                    return;
                } else
                    if (Parser.IsSymbol(">=")) {
                        Relation = ">=";
                        Parser.Position += 2;
                        return;
                    } else
                        if (Parser.IsSymbol("<=")) {
                            Relation = "<=";
                            Parser.Position += 2;
                            return;
                        } else
                            if (Parser.IsSymbol("=>")) {
                                Relation = "=>";
                                Parser.Position += 2;
                                return;
                            } else
                                if (Parser.IsSymbol("=<")) {
                                    Relation = "=<";
                                    Parser.Position += 2;
                                    return;
                                } else
                                    if (Parser.IsSymbol('=')) {
                                        Relation = "=";
                                        Parser.Position++;
                                        return;
                                    } else
                                        if (Parser.IsSymbol(">")) {
                                            Relation = ">";
                                            Parser.Position++;
                                            return;
                                        } else
                                            if (Parser.IsSymbol("<")) {
                                                Relation = "<";
                                                Parser.Position++;
                                                return;
                                            } else
                                                if (Parser.IsSymbol("!=")) {
                                                    Relation = "!=";
                                                    Parser.Position += 2;
                                                    return;
                                                }
            }

            /*
            while (IsOperatorRelation()) {
                char c1 = Parser.getChar(0), c2;
                switch(c1){
                    case '<':
                        c2 = Parser.getChar(1);
                        switch(c2){
                            case '>':
                                Relation = "<>";
                                Parser.Position += 2;
                            break;
                            case '=':
                                Relation = "<=";
                                Parser.Position += 2;
                            break;
                            default:
                                Relation = "<";
                                Parser.Position++;
                            break;
                        }
                    break;
                    case '>':
                        c2 = Parser.getChar(1);
                        if (c2 == '='){
                            Relation = ">=";
                            Parser.Position += 2;
                        }else{
                            Relation = ">";
                            Parser.Position++;
                        }
                    break;
                    case '=':
                        switch(c2){
                            case '>':
                                Relation = "=>";
                                Parser.Position += 2;
                            break;
                            case '<':
                                Relation = "=<";
                                Parser.Position += 2;
                            break;
                            default:
                                Relation = "=";
                                Parser.Position++;
                            break;
                        }
                    break;
                    case '!':
                        c2 = Parser.getChar(1);
                        if (c2 == '='){
                            Relation = "!=";
                            Parser.Position += 2;
                        }
                    break;
                }
            }*/

        }

        public static void EvalBool() {
            Parser.SkipBlank();
            EvalExpression();

            while (IsOperatorBool()) {
                if (Parser.IsSymbol("|") || Parser.IsIdent("or")) {
                    Parser.SkipIdent();
                    Parser.Position++;
                    EvalExpression();
                    comAssembler.ExprOr();
                } else
                    if (Parser.IsSymbol("~") || Parser.IsIdent("xor")) {
                        Parser.SkipIdent();
                        Parser.Position++;
                        EvalExpression();
                        comAssembler.ExprXor();
                    } else
                        if (Parser.IsSymbol("&") || Parser.IsIdent("and")) {
                            Parser.SkipIdent();
                            Parser.Position++;
                            EvalExpression();
                            comAssembler.ExprAnd();
                        }

                comAssembler.PushEAX();
            }
        }

        public static void EvalExpression() {
            Parser.SkipBlank();
            EvalTerm();

            while (IsOperatorAdd()) {
                if (Parser.IsSymbol('+') || Parser.IsIdent("add")) {
                    Parser.SkipIdent();
                    Parser.Position++;
                    EvalTerm();

                    if (Isdouble) {
                        comAssembler.ExprdoubleAdd();
                    } else {
                        comAssembler.ExprAdd();
                    }
                } else
                    if (Parser.IsSymbol('-') || Parser.IsIdent("sub")) {
                        Parser.SkipIdent();
                        Parser.Position++;
                        EvalTerm();

                        if (Isdouble) {
                            comAssembler.ExprdoubleSub();
                        } else {
                            comAssembler.ExprSub();
                        }
                    }

                comAssembler.PushEAX();
            }
        }

        public static void EvalTerm() {
            Parser.SkipBlank();
            EvalFactor();

            while (IsOperatorMul()) {
                if (Parser.IsSymbol('*') || Parser.IsIdent("mul")) {
                    Parser.SkipIdent();
                    Parser.Position++;
                    EvalFactor();

                    if (Isdouble) {
                        comAssembler.ExprdoubleMul();
                    } else {
                        comAssembler.ExprMul();
                    }
                } else
                    if (Parser.IsSymbol('/') || Parser.IsIdent("div")) {
                        Parser.SkipIdent();
                        Parser.Position++;
                        EvalFactor();

                        if (Isdouble) {
                            comAssembler.ExprdoubleDiv();
                        } else {
                            comAssembler.ExprDiv();
                        }
                    } else
                        if (Parser.IsSymbol("%") || Parser.IsIdent("mod")) {
                            Parser.SkipIdent();
                            Parser.Position++;
                            EvalFactor();

                            if (Isdouble) {
                                comAssembler.ExprdoubleMod();
                            } else {
                                comAssembler.ExprMod();
                            }
                        } else
                            if (Parser.IsSymbol("<<")) {
                                Parser.SkipIdent();
                                Parser.Position += 2;
                                EvalFactor();
                                comAssembler.ExprShl();
                            } else
                                if (Parser.IsIdent("shl")) {
                                    Parser.SkipIdent();
                                    Parser.Position++;
                                    EvalFactor();
                                    comAssembler.ExprShl();
                                } else
                                    if (Parser.IsSymbol(">>")) {
                                        Parser.SkipIdent();
                                        Parser.Position += 2;
                                        EvalFactor();
                                        comAssembler.ExprShr();
                                    } else
                                        if (Parser.IsIdent("shr")) {
                                            Parser.SkipIdent();
                                            Parser.Position++;
                                            EvalFactor();
                                            comAssembler.ExprShr();
                                        }

                comAssembler.PushEAX();
            }
        }

        public static void EvalFactor() {
            String Ident = "";
            bool IsPtr = Parser.IsSymbol('^');
            bool IsNot = Parser.IsSymbol('!');

            if (IsPtr || IsNot) {
                Parser.Position++;
            }

            String myAssign = Assignment;
            Parser.SkipBlank();

            if (EvaluateCount > 0) {
                if (CompareOne.length() != 0) {
                    comAssembler.PushContent(CompareOne);
                    CompareOne = "";

                    if (CompareTwo.length() != 0) {
                        comAssembler.PushContent(CompareTwo);
                        CompareTwo = "";
                    }
                }
            }

            Isdouble = false;
            IsStringCompare = false;

            String StringValue = "";
            String VarIdentII = "";

            if (Parser.IsdoubleExpression()) {
                comAssembler.PushF(Parser.NumberExpression().parseDouble());
                Isdouble = true;
            } else
                if (Parser.IsNumberExpression()) {
                    String value = Parser.NumberExpression();

                    if (value.indexOf('.') != -1) {
                        comAssembler.Push(value.parseDouble());
                    } else {
                        comAssembler.Push(value.parseLong());
                    }
                } else
                    if (Parser.IsStringExpression()) {
                        IsStringCompare = true;
                        DataManager.dUniqueID++;
                        StringValue = Parser.StringExpression();
                        DataManager.DeclareDataString("$UniqueString" + DataManager.dUniqueID, StringValue, (StringValue).length());

                        if (Function.IsCallFrame) {
                            if (Function.IsCallFrame) {
                                comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                            } else {
                                comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                                comAssembler.PushAddress(myAssign);
                                comAssembler.InvokeByName("lstrcpy");
                                comAssembler.PushContent(myAssign);
                            }
                        } else {

                            if (Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_DWORD || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_WORD || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_BYTE || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_SINGLE || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_US_DWORD || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_US_WORD || Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_US_BYTE) {
                                comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                            } else
                                if (Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                    if (Function.IsCallFrame) {
                                        comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                                    } else {
                                        comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                                        comAssembler.PushAddress(myAssign);
                                        comAssembler.InvokeByName("lstrcpy");
                                        comAssembler.PushContent(myAssign);
                                    }
                                } else {
                                    comAssembler.PushAddress("$UniqueString" + DataManager.dUniqueID);
                                }
                        }
                    } else
                        if (Parser.IsSymbol('(')) {
                            Parser.Symbol('(');
                            Expression("");
                            Parser.Symbol(')');
                        } else
                            if (Parser.IsSymbol(')')) {
                                return;
                            } else
                                if (Parser.IsSymbol(',')) {
                                    return;
                                } else
                                    if (Parser.IsSymbol(';')) {
                                        return;
                                    } else
                                        if (Parser.IsSymbol("@")) {
                                            Parser.Symbol('@');
                                            VarIdentII = Parser.Identifier();

                                            if (Symbols.GetSymbolType(Function.CurrentFrame + "." + VarIdentII) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD || Symbols.GetSymbolType(Function.CurrentFrame + "." + VarIdentII) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT) {
                                                Compiler.AddCodeByte(0x55); //push ebp
                                                comAssembler.Push(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + VarIdentII));
                                                comAssembler.ExprAdd();
                                                comAssembler.PushEAX();
                                            } else
                                                if (Symbols.GetSymbolType(Function.CurrentFrame + "." + VarIdentII) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING) {
                                                    Compiler.AddCodeWord(0x858D);
                                                    Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + VarIdentII));
                                                    Compiler.AddCodeWord(0x8B);
                                                    comAssembler.PushEAX();
                                                } else {
                                                    if (Symbols.GetSymbolType(VarIdentII) == Symbols.ENUM_SYMBOL_TYPE.ST_FRAME) {
                                                        VarIdentII = VarIdentII + ".Address";
                                                    }

                                                    if (Symbols.GetSymbolType(VarIdentII) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                                        comAssembler.PushAddress(VarIdentII);
                                                        //Call popeax: AddCodeWord &H8B: PushEAX
                                                    } else {
                                                        comAssembler.PushAddress(VarIdentII);
                                                    }
                                                }
                                        } else {
                                            Ident = Parser.Identifier();

                                            if (Imports.IsImport(Ident)) {
                                                CallImport(Ident, true);
                                                comAssembler.PushEAX();
                                            } else
                                                if (Parser.IsVariable(Ident)) {
                                                    if (Parser.IsSymbol('(')) {
                                                        Parser.Symbol('(');
                                                        Memory.GetArray(Ident);
                                                        Parser.Symbol(')');
                                                    } else
                                                        if (myAssign .equals("$Intern.Compare.One") && Symbols.GetSymbolSize(Ident) == 4 && EvaluateCount == 0) {
                                                            CompareOne = Ident;
                                                        } else
                                                            if (myAssign .equals( "$Intern.Compare.Two") && Symbols.GetSymbolSize(Ident) == 4 && EvaluateCount == 0) {
                                                                CompareTwo = Ident;
                                                            } else {
                                                                if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING && Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                                                    IsStringCompare = true;
                                                                    comAssembler.PushContent(Ident);
                                                                } else
                                                                    if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                                                        IsStringCompare = true;
                                                                        comAssembler.PushAddress(Ident);
                                                                    } else {
                                                                        if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_BYTE) {
                                                                            Compiler.AddCodeByte(0xF);
                                                                            Compiler.AddCodeByte(0xBE);
                                                                            Compiler.AddCodeByte(0x5);
                                                                        } else
                                                                            if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_US_BYTE) {
                                                                                Compiler.AddCodeByte(0xF);
                                                                                Compiler.AddCodeByte(0xB6);
                                                                                Compiler.AddCodeByte(0x5);
                                                                            } else
                                                                                if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_WORD) {
                                                                                    Compiler.AddCodeByte(0xF);
                                                                                    Compiler.AddCodeByte(0xBF);
                                                                                    Compiler.AddCodeByte(0x5);
                                                                                } else
                                                                                    if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_US_WORD) {
                                                                                        Compiler.AddCodeByte(0xF);
                                                                                        Compiler.AddCodeByte(0xB7);
                                                                                        Compiler.AddCodeByte(0x5);
                                                                                    } else
                                                                                        if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_DWORD) {
                                                                                            Compiler.AddCodeByte(0xA1);
                                                                                        } else
                                                                                            if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_US_DWORD) {
                                                                                                Compiler.AddCodeByte(0xA1);
                                                                                            } else
                                                                                                if (Symbols.GetSymbolType(Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_SINGLE) {
                                                                                                    Isdouble = true;
                                                                                                    Compiler.AddCodeByte(0xA1);
                                                                                                }

                                                                        Fixups.AddFixup(Ident, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
                                                                        Compiler.AddCodeDWord(0);
                                                                        comAssembler.PushEAX();

                                                                    }
                                                            }
                                                } else
                                                    if (Function.IsLocalVariable(Ident)) {
                                                        if ((Symbols.GetSymbolType(Function.CurrentFrame + "." + Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING) && (myAssign .equals( "") == false)) {
                                                            Compiler.AddCodeWord(0x858D);
                                                            Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Ident));
                                                            comAssembler.PushEAX();

                                                            if (Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                                                Compiler.AddCodeWord(0x8B);
                                                            }

                                                            comAssembler.PushEAX();
                                                            comAssembler.PushAddress(myAssign);
                                                            comAssembler.InvokeByName("lstrcpy");
                                                            comAssembler.PushContent(myAssign);
                                                        } else
                                                            if (Symbols.GetSymbolType(Function.CurrentFrame + "." + Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING) {

                                                                Compiler.AddCodeWord(0x858D);
                                                                Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Ident));
                                                                Compiler.AddCodeWord(0x8B);
                                                                comAssembler.PushEAX();
                                                            } else
                                                                if (Symbols.GetSymbolType(Function.CurrentFrame + "." + Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD) {
                                                                    //mov eax,[ebp+number]
                                                                    Compiler.AddCodeWord(0x858D);
                                                                    Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Ident));
                                                                    //mov eax,[eax]
                                                                    Compiler.AddCodeWord(0x8B);
                                                                    comAssembler.PushEAX();
                                                                } else
                                                                    if (Symbols.GetSymbolType(Function.CurrentFrame + "." + Ident) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT) {
                                                                        Isdouble = true;
                                                                        Compiler.AddCodeWord(0x858D);
                                                                        Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Ident));
                                                                        //mov eax,[eax]
                                                                        Compiler.AddCodeWord(0x8B);
                                                                        comAssembler.PushEAX();
                                                                    }
                                                    } else
                                                        if (Types.IsAssignedType(Ident)) {
                                                            comAssembler.PushAddress(Ident);
                                                        } else
                                                            if (Function.IsProperty(Ident + ".get")) {
                                                                Function.CallProperty(Ident + ".get", true);
                                                                comAssembler.PushEAX();
                                                                IsStringCompare = false;
                                                            } else
                                                                if (Function.IsFrame(Ident)) {
                                                                    Function.CallFrame(Ident, true);

                                                                    switch(Function.GetReturnType(Ident)) {
                                                                    case "float" :
                                                                        Isdouble = true;
                                                                        break;

                                                                    case "string" :
                                                                        IsStringCompare = true;
                                                                        break;

                                                                    case "dword" :
                                                                    case "property" :
                                                                        IsStringCompare = false;
                                                                        Isdouble = false;
                                                                        break;

                                                                    default:
                                                                        break;
                                                                    }

                                                                    if (Function.GetReturnType(Ident) .equals(  "float")) {
                                                                        Isdouble = true;
                                                                    }

                                                                    if (Symbols.GetSymbolType(myAssign) == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                                                                        comAssembler.PushEAX();
                                                                        comAssembler.PushAddress(myAssign);
                                                                        comAssembler.InvokeByName("lstrcpy");
                                                                        comAssembler.PushContent(myAssign);
                                                                    } else {
                                                                        comAssembler.PushEAX();
                                                                        IsStringCompare = false;
                                                                    }
                                                                } else
                                                                    if (Ident .equals( "") == false) {
                                                                        Parser.Position -= Ident.length();
                                                                        Parser.CodeBlock();
                                                                    } else {
                                                                        if (Ident .equals("")) {
                                                                            Summary.ErrMessage("unknow symbol " + Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(1, Parser.Source.length() - (Parser.Position - 1))) + "'");
                                                                            return;
                                                                        } else {
                                                                            Summary.ErrMessage("undefined identifier" + Ident + "'");
                                                                            return;
                                                                        }
                                                                    }
                                        }

            while (Parser.IsSymbol(" ")) {
                Parser.Position++;
            }

            if (IsPtr) {
                comAssembler.PopEAX();
                Compiler.AddCodeWord(0x8B);
                comAssembler.PushEAX();
            } //mov eax,[eax]

            if (IsNot) {
                comAssembler.ExprNot();
                comAssembler.PushEAX();
            }

            EvaluateCount++;
        }

        public static void CallImport(String Ident, bool FromExpression) {
            int pCount = Imports.ImportPCountByName(Ident);

            if (pCount == -1) {
                pCount = UserDefinedParameters();
            }

            ReverseParams();
            Parser.Symbol('(');

            while (pCount > 0) {
                Parser.SkipBlank();
                Expression("");

                if (pCount > 1) {
                    Parser.Symbol(',');
                }

                pCount--;
            }

            Parser.Symbol(')');

            if (!FromExpression) {
                Parser.Terminator();
            }

            comAssembler.InvokeByName(Ident);

            if (!FromExpression) {
                Parser.CodeBlock();
            }
        }

        public static String ReverseParams() {

            int OPosition = Parser.Position;
            BracketsOpen = 0;

            if (Parser.IsSymbol('(')) {
                Parser.Position++;
            }

            String Content = RevParams();
            String Header = Parser.Source.substring(0, Math.min(OPosition, OPosition + Parser.Source.length()));
            String Footer = Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(Strings.Len(Parser.Source) - Parser.Position + 1, Parser.Source.length() - (Parser.Position - 1)));
            Parser.Source = Header + Content + Footer;
            Parser.Position = OPosition;
            return "";
        }

        public static String ParamsBrackets() {
            BytesBuffer result = new BytesBuffer();
            result.pop(1);

            while (!Parser.IsSymbol(')')) {
                if (Parser.IsSymbol('(')) {
                    Parser.Position++;
                    result.add(("(" + ParamsBrackets()).getBytes());
                }

                result.add(Parser.Source.charAt(Parser.Position - 1));
                Parser.Position++;

                if (Parser.Position >= Strings.Len(Parser.Source)) {
                    Summary.ErrMessage("found end of code. but expected ')' or ','");
                    return result.toString();
                }
            }

            return result.toString();
        }

        public static String RevParams() {
            int i = 0;
            String[] Params = {""};
            BytesBuffer strExpr = new BytesBuffer();
            strExpr.pop(1);

            while (!Parser.IsSymbol(')')) {
                if (Parser.IsSymbol('(')) {
                    Parser.Position++;
                    strExpr.add('(');
                    strExpr.add(ParamsBrackets().getBytes());
                }

                if (Parser.IsSymbol("\"")) {
                    strExpr.add(Parser.Source.charAt(Parser.Position - 1));
                    Parser.Position++;

                    int c = Parser.Source.charAt(Parser.Position - 1);

                    while (c != '"') {
                        strExpr.add(c);

                        if (++Parser.Position >= Strings.Len(Parser.Source)) {
                            Summary.ErrMessage("found end of code. but expected ')' or ','");
                            return "";
                        }

                        c = Parser.Source.charAt(Parser.Position - 1);
                    }
                }

                if (Parser.IsSymbol(',')) {
                    if (strExpr.get(0) == ',') {
                        BytesBuffer nbb = new BytesBuffer();
                        nbb.pop(1);
                        nbb.add(strExpr.getBuffer(), 1, strExpr.length() - 1);
                        strExpr = nbb;
                    }

                    Params = StringArraysHelper.RedimPreserve(Params, new String[Params.length + 1]);
                    Params[Params.length - 1] = strExpr.toString();
                    strExpr.clear();
                }

                strExpr.add(Parser.Source.charAt(Parser.Position - 1));
                Parser.Position++;

                if (Parser.Position >= Strings.Len(Parser.Source)) {
                    Summary.ErrMessage("found end of code. but expected ')' or ','");
                    return "";
                }
            }

            if (strExpr.get(0) == ',') {
                BytesBuffer nbb = new BytesBuffer();
                nbb.pop(1);
                nbb.add(strExpr.getBuffer(), 1, strExpr.length() - 1);
                strExpr = nbb;
            }

            Params = StringArraysHelper.RedimPreserve(Params, new String[Params.length + 1]);
            Params[Params.length - 1] = strExpr.toString();

            String strReversed =  "";

            for (i = Params.length - 1; i >= 1; i--) {
                strReversed = strReversed  + Params[i] + ((i > 1) ? "," : "");
            }

            return strReversed;
        }

        public static int UserDefinedParameters() {

            int result = 0;
            int i = Parser.Position;
            bool InStringExpr = false;
            result = 1;

            char c = Parser.Source.charAt(i - 1);

            while (c != ')') {
                if (c == '"') {
                    InStringExpr = !InStringExpr;
                    i++;
                    c = Parser.Source.charAt(i - 1);
                }

                if (c == ',') {
                    if (!InStringExpr) {
                        result++;
                    }
                }

                i++;

                if (Parser.Position >= Strings.Len(Parser.Source)) {
                    Summary.ErrMessage("found end of code. but expected ')' or ','");
                    return result;
                }

                c = Parser.Source.charAt(i - 1);
            }

            return result;
        }
    };
};