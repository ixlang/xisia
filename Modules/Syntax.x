
package Xisia {
    static class Syntax
    {
        public static String CurrentSection = "";
        public static String CurrentModule = "";

        public static void DirectiveModule() {
            String ModName = "";

            if (Parser.IsIdent("module")) {
                Parser.SkipIdent();
                CurrentModule = Parser.StringExpression();
                Parser.Terminator();
            }
        }

        public static void DirectiveApplication() {
            if (Parser.IsIdent("application")) {
                Compiler.bLibrary = false;
                Parser.SkipIdent();

                if (Parser.IsIdent("PE")) {
                    Parser.SkipIdent();

                    if (Parser.IsIdent("GUI")) {
                        Parser.SkipIdent();
                        Linker.AppType = Linker.ENUM_APP_TYPE.GUI;
                    } else
                        if (Parser.IsIdent("CUI")) {
                            Parser.SkipIdent();
                            Linker.AppType = Linker.ENUM_APP_TYPE.CUI;
                        } else {
                            Summary.ErrMessage("invalid format '" + Parser.Identifier() + "' expected 'GUI' or 'CUI'");
                            return;
                        }

                    Parser.SkipBlank();

                    if (Parser.IsIdent("DLL")) {
                        Parser.SkipIdent();
                        Exports.IsDLL = true;
                    }

                    if (Parser.IsIdent("entry")) {
                        DeclareEntryPoint();
                    } else {
                        Parser.Terminator();
                    }
                } else {
                    Summary.ErrMessage("expected 'PE' but found '" + Parser.Identifier() + "'");
                    return;
                }
            } else
                if (Parser.IsIdent("library")) {
                    Parser.SkipIdent();
                    Compiler.bLibrary = true;
                    Parser.SkipBlank();
                    Compiler.LibraryName = Parser.StringExpression();
                    Parser.Terminator();
                } else {
                    Summary.ErrMessage("expected 'application' or 'library' but found '" + Parser.Identifier() + "'");
                    return;
                }
        }

        public static void EntryBlock() {
            if ((Parser.EntryPoint .equals( "") == false)  || (Parser.EntryPoint .equals( "entry"))) {
                return;
            }

            String Ident = Parser.Identifier();

            if (Ident .equals( "entry")) {
                Symbols.AddSymbol("$entry", Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            } else {
                Summary.ErrMessage("expected 'entry' but found '" + Ident + "'");
                return;
            }

            Parser.CodeBlock();
            Ident = Parser.Identifier();

            if (Ident .equals( "end.") == false) {
                Summary.ErrMessage("expected 'end.' but found '" + Ident + "'");
                return;
            } else {
                comAssembler.Push(0);
                comAssembler.InvokeByName("ExitProcess");
            }
        }

        public static void DeclareEntryPoint() {
            Parser.SkipIdent();
            Parser.EntryPoint = Parser.Identifier();
            Parser.Terminator();
        }

        public static void DirectiveSection() {
            String Ident = "";
            Linker.ENUM_SECTION_TYPE ST = (Linker.ENUM_SECTION_TYPE) 0;
            Linker.ENUM_SECTION_CHARACTERISTICS CH = (Linker.ENUM_SECTION_CHARACTERISTICS) 0;

            String Name = Parser.StringExpression();

            if (!Linker.SectionExists(Name)) {
                Parser.Blank();
                Ident = Parser.Identifier();

                switch(Ident.lower()) {
                case "data" :
                    ST = Linker.ENUM_SECTION_TYPE.Data;
                    //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                    CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA));
                    break;

                case "code" :
                    ST = Linker.ENUM_SECTION_TYPE.Code;
                    //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                    CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_CODE));
                    break;

                case "import" :
                    ST = Linker.ENUM_SECTION_TYPE.Import;
                    break;

                case "export" :
                    ST = Linker.ENUM_SECTION_TYPE.Export;
                    break;

                case "resource" :
                    ST = Linker.ENUM_SECTION_TYPE.Resource;
                    break;

                default:
                    Summary.ErrMessage("invalid section type '" + Ident + "'");
                    return;
                }

                while (Parser.IsSymbol(" ")) {

                    Parser.Blank();
                    Ident = Parser.Identifier();

                    switch(Ident.lower()) {
                    case "code" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_CODE));
                        break;

                    case "data" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA));
                        break;

                    case "udata" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_UNINITIALIZED_DATA));
                        break;

                    case "discardable" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_DISCARDABLE));
                        break;

                    case "executable" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_EXECUTE));
                        break;

                    case "notchached" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_NOT_CHACHED));
                        break;

                    case "notpaged" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_NOT_PAGED));
                        break;

                    case "readable" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ));
                        break;

                    case "shared" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_SHARED));
                        break;

                    case "writeable" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        CH = (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) CH) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_WRITE));
                        break;

                    default:
                        Summary.ErrMessage("invalid characteristic '" + Ident + "'");
                        return;
                    }
                }

                CurrentSection = Name;
            }

            CreateSection(Name, ST, CH);
            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void CreateSection(String Name, Linker.ENUM_SECTION_TYPE SectionType, Linker.ENUM_SECTION_CHARACTERISTICS Characteristics) {
            int i = 0;

            if (Linker.SectionExists(Name)) {
                CurrentSection = Linker.Section[Linker.SectionID(Name)].Name;
            } else {

                Linker.TYPE_SECTION s = Linker.Section.addOne();
                s.Name = Name;
                s.SectionType = SectionType;
                s.Characteristics = Characteristics;
            }
        }

        public static void DeclareLabel(String Name) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.Symbol(':');
        }

        public static void StatementGoto() {
            comAssembler.ExprJump(Parser.Identifier());
            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void DeclareString(String CurrentType, bool FrameExpression, bool NoCodeBlock ) {
            int Space = 0;
            String Value = "";

            String Ident = Parser.Identifier();
            //UPGRADE_WARNING: (1068) Switch() of type Variant is being forced to String. More Information: https://docs.mobilize.net/vbuc/ewis#1068
            String FullName = ((CurrentType.length() == 0) ? Ident : ((CurrentType.length() != 0) ? CurrentType + "." + Ident : ""));

            if (Parser.IsSymbol('=')) {
                Parser.Symbol('=');
                Value = Parser.StringExpression();
            } else {
                Value = "";
            }

            if (Parser.IsSymbol('[')) {
                Parser.Symbol('[');
                Space = (Parser.NumberExpression().parseInt());
                Parser.Symbol(']');
            } else {
                Space = 256;
            }

            if (Parser.IsSymbol('(')) {
                Parser.Symbol('(');

                if (!Parser.IsSymbol(')')) {
                    if (Function.CurrentFrame .equals("")) {
                        Summary.ErrMessage("you cannot dimension the array outside of a frame. use '()' instead and \"reserve " + FullName + "([Size])\" inside a frame.");
                        return;
                    }
                }

                DataManager.DeclareDataString(FullName, Value, Space);
                Memory.ReserveArray(FullName, (Parser.NumberExpression().parseInt()));
                Parser.Symbol(')');
            }

            if (!FrameExpression) {
                Parser.Terminator();

                if (!Symbols.SymbolExists(FullName)) {
                    DataManager.DeclareDataString(FullName, Value, Space);
                }
            } else {
                if (!Symbols.SymbolExists(Function.CurrentFrame + "." + FullName)) {
                    //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                    Symbols.AddSymbol(Function.CurrentFrame + "." + FullName, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING, false);
                    Function.AddFrameDeclare(FullName);
                }
            }

            if (!NoCodeBlock) {
                Parser.CodeBlock();
            }
        }

        public static void DeclareVariable(String CurrentType, String Size, bool FrameExpression, bool NoCodeBlock ) {
            double Value = 0;

            String Ident = Parser.Identifier();

            //UPGRADE_WARNING: (1068) Switch() of type Variant is being forced to String. More Information: https://docs.mobilize.net/vbuc/ewis#1068
            String FullName = ((CurrentType.length() == 0) ? Ident : ((CurrentType.length() != 0) ? CurrentType + "." + Ident : ""));

            if (Parser.IsSymbol('=')) {
                Parser.Symbol('=');
                Value = Parser.NumberExpression().parseDouble();
            } else {
                Value = 0;
            }

            if (Parser.IsSymbol('(')) {
                Parser.Symbol('(');

                if (!Parser.IsSymbol(')')) {
                    if (Function.CurrentFrame .equals("")) {
                        Summary.ErrMessage("you cannot dimension the array outside of a frame. use '()' instead and \"reserve " + FullName + "([Size])\" inside a frame.");
                        return;
                    }
                }

                if (Parser.UnsignedDeclare) {
                    switch(Size) {
                    case "byte" :
                        DataManager.DeclareDataUnsignedByte(FullName, (byte)(Value));
                        break;

                    case "word" :
                        DataManager.DeclareDataUnsignedWord(FullName, (int)(Value));
                        break;

                    default:
                        Summary.ErrMessage("invalid size '" + FullName + "'");
                        return;
                    }
                } else {
                    switch(Size) {
                    case "byte" :
                        DataManager.DeclareDataByte(FullName, (byte)(Value));
                        break;

                    case "word" :
                        DataManager.DeclareDataWord(FullName, (int)(Value));
                        break;

                    case "dword" :
                        DataManager.DeclareDataDWord(FullName, (int)(Value));
                        break;

                    case "float" :
                        DataManager.DeclareDataSingle(FullName, Value);
                        break;

                    default:
                        Summary.ErrMessage("invalid size '" + FullName + "'");
                        return;
                    }
                }

                Memory.ReserveArray(FullName, (Parser.NumberExpression().parseInt()));
                Parser.Symbol(')');
            }

            if (!FrameExpression) {
                if (!Symbols.SymbolExists(FullName)) {
                    if (Parser.UnsignedDeclare) {
                        switch(Size) {
                        case "byte" :
                            DataManager.DeclareDataUnsignedByte(FullName, (byte)(Value));
                            break;

                        case "word" :
                            DataManager.DeclareDataUnsignedWord(FullName, (int)(Value));
                            break;

                        default:
                            Summary.ErrMessage("invalid size '" + FullName + "'");
                            return;
                        }
                    } else {
                        switch(Size) {
                        case "byte" :
                            DataManager.DeclareDataByte(FullName, (byte)(Value));
                            break;

                        case "word" :
                            DataManager.DeclareDataWord(FullName, (int)(Value));
                            break;

                        case "dword" :
                            DataManager.DeclareDataDWord(FullName, (int)(Value));
                            break;

                        case "float" :
                            DataManager.DeclareDataSingle(FullName, Value);
                            break;

                        default:
                            Summary.ErrMessage("invalid size '" + FullName + "'");
                            return;
                        }
                    }
                }

                if (Parser.IsSymbol(',')) {
                    Parser.Symbol(',');
                    DeclareVariable(CurrentType, Size, FrameExpression, false);
                    return;
                }

                Parser.Terminator();
            } else {
                if (!Symbols.SymbolExists(Function.CurrentFrame + "." + FullName)) {
                    switch(Size) {
                    case "float" :
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        Symbols.AddSymbol(Function.CurrentFrame + "." + FullName, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT, false);
                        break;

                    default:
                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        Symbols.AddSymbol(Function.CurrentFrame + "." + FullName, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD, false);
                        break;
                    }

                    Function.AddFrameDeclare(Ident);
                }
            }

            if (!NoCodeBlock) {
                Parser.CodeBlock();
            }
        }

        public static void DeclareLocal() {
            Object Value = nilptr;
            int Space = 0;
            int ArrayValue = 0;

            String Ident = Parser.Identifier();
            String IdentII = Parser.Identifier();

            if (Function.CurrentFrame .equals("")) {
                Summary.ErrMessage("cannot declare local variable '" + IdentII + "' outside of a frame");
                return;
            }

            if (Ident  .equals( "byte" ) || Ident  .equals( "word") || Ident  .equals( "bool" ) || Ident  .equals( "dword") || Ident  .equals( "boolean")) {
                //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                Symbols.AddSymbol(Function.CurrentFrame + "." + IdentII, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD, false);
                Function.ArgCount++;
            } else
                if (Ident  .equals( "float")) {
                    //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                    Symbols.AddSymbol(Function.CurrentFrame + "." + IdentII, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT, false);
                    Function.ArgCount++;
                } else
                    if (Ident  .equals( "string")) {
                        if (Parser.IsSymbol('[')) {
                            Parser.Symbol('[');
                            Space = (Parser.NumberExpression().parseInt());
                            Parser.Symbol(']');
                        } else {
                            Space = 256;
                        }

                        //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                        Symbols.AddSymbol(Function.CurrentFrame + "." + IdentII, 8 + (Function.ArgCount * 4), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING, false);
                        Expressions.eUniqueID++;
                        DataManager.DeclareDataString("Local.String" + Expressions.eUniqueID, "", Space);
                        comAssembler.MovEAXAddress("Local.String" + Expressions.eUniqueID);
                        //mov [ebp+number],eax
                        Compiler.AddCodeWord(0x8589);
                        Compiler.AddCodeDWord(8 + (Function.ArgCount * 4));
                        Function.ArgCount++;
                    } else {
                        Summary.ErrMessage("expected identifier 'byte','word','dword','single' or 'String' but found" + Ident);
                        return;
                    }

            Parser.Terminator();


            Parser.CodeBlock();
        }

        public static void DeclareConstant() {
            String Name = Parser.Identifier();
            Parser.Symbol('=');
            Parser.SkipBlank();

            if (Parser.IsStringExpression()) {
                Symbols.AddConstant(Name, Parser.StringExpression());
            } else
                if (Parser.IsNumberExpression()) {
                    Symbols.AddConstant(Name, "" + Parser.NumberExpression());
                } else
                    if (Parser.IsConstantExpression()) {
                        Symbols.AddConstant(Name, "" + Parser.ConstantExpression());
                    } else {
                        Summary.ErrMessage("invalid constant value. '" + Name + " '");
                        return;
                    }

            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void DeclareType() {
            String Name = "";
            String Ident = "";
            String TypeSource = "";

            Types.Types.addOne().Name = Parser.Identifier();

            Parser.Symbol('{');

            while (!Parser.IsSymbol('}')) {
                Parser.SkipBlank();

                if (Parser.IsIdent("string") || Parser.IsIdent("dword") || Parser.IsIdent("word") || Parser.IsIdent("byte") || Parser.IsIdent("bool") || Parser.IsIdent("boolean") || Parser.IsIdent("float")) {
                    TypeSource = TypeSource + (Parser.Identifier() + " " + Parser.Identifier());

                    if (Parser.IsSymbol('[')) {
                        Parser.Symbol('[');
                        TypeSource = TypeSource + ("[");
                        TypeSource = TypeSource + ("" + Parser.NumberExpression() + "]");
                        Parser.Symbol(']');
                    } else
                        if (Parser.IsSymbol('(')) {
                            Parser.Symbol('(');
                            TypeSource = TypeSource + ("(");
                            Parser.Symbol(')');
                            TypeSource = TypeSource + (")");
                        }

                    TypeSource = TypeSource + (";");
                    Parser.Terminator();
                    Parser.SkipBlank();
                } else {
                    Ident = Parser.Identifier();

                    if (Types.IsType(Ident)) {
                        TypeSource = TypeSource + (Ident + " " + Parser.Identifier());
                        TypeSource = TypeSource + (";");
                        Parser.Terminator();
                        Parser.SkipBlank();
                    } else {
                        Parser.Symbol('}');
                        return;
                    }
                }
            }

            Types.Types[Types.Types.length() - 1].Source = TypeSource;
            Parser.Symbol('}');
            Parser.CodeBlock();
        }

        public static void StatementInclude() {
            String FileName = Parser.StringExpression();
            Parser.Position = Parser.Position - (Strings.Len(FileName)) - 2;
            int start = Math.max(FileName.length() - 4, 0);

            if (FileName.substring(start, FileName.length()) .equals( ".lib")) {
                Imports.ImportLibrary();
            } else {
                IncludeFile();
            }
        }

        public static String getFileContent(String file) {
            FileInputStream fis = new FileInputStream(file);
            byte [] data  = fis.read();
            fis.close();
            return new String(data);
        }
        public static void IncludeFile() {
            int i = 0;
            String[] Files = {""};
            String Content = "";


            for (;;) {
                Files = StringArraysHelper.RedimPreserve(Files, new String[Files.length + 1]);
                Files[Files.length - 1] = Parser.StringExpression();

                if (Parser.IsSymbol(',')) {
                    Parser.Position++;
                    Parser.SkipBlank();
                } else {
                    break;
                }
            }

            Parser.Terminator();

            for (i = Files.length - 1; i >= 1; i--) {
                Content = getFileContent(_system_.getAppDirectory().appendPath("include").appendPath(Files[i]));
                Parser.InsertSource(Content);
                Summary.LenIncludes += Content.length();
            }

            Parser.CodeBlock();
        }

        public static void StatementIf() {
            int iID = 0;
            iID += DataManager.lUniqueID;
            DataManager.lUniqueID++;
            int elseifcount = 0;

            Parser.Symbol('(');

            Expressions.Expression("$Intern.Compare.One");
            Expressions.Expression("$Intern.Compare.Two");

            if (Expressions.IsStringCompare) {
                comAssembler.ExprCompareS("$Intern.Compare.One", "$Intern.Compare.Two");
            } else {
                comAssembler.ExprCompare("$Intern.Compare.One", "$Intern.Compare.Two");
            }

            Expressions.ChooseRelation(iID, "$else");
            Parser.Symbol(')');
            Parser.Symbol('{');
            Symbols.AddSymbol("$then" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
            comAssembler.ExprJump("$out" + iID);
            Parser.Symbol('}');
            Parser.SkipBlank();

            if (Parser.IsIdent("else")) {
                Parser.SkipIdent();
                Parser.Symbol('{');
                Symbols.AddSymbol("$else" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
                Parser.CodeBlock();
                Parser.Symbol('}');
            } else {
                Symbols.AddSymbol("$else" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            }

            Symbols.AddSymbol("$out" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
        }

        public static void StatementWhile() {
            int wID = 0;
            wID += DataManager.lUniqueID;
            DataManager.lUniqueID++;
            Parser.Symbol('(');

            Symbols.AddSymbol("$swhile" + wID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);

            Expressions.Expression("$Intern.Compare.One");
            Expressions.Expression("$Intern.Compare.Two");

            if (Expressions.IsStringCompare) {
                comAssembler.ExprCompareS("$Intern.Compare.One", "$Intern.Compare.Two");
            } else {
                comAssembler.ExprCompare("$Intern.Compare.One", "$Intern.Compare.Two");
            }

            Expressions.ChooseRelation(wID, "$endwhile");

            Parser.Symbol(')');
            Parser.Symbol('{');

            Symbols.AddSymbol("$while" + wID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
            comAssembler.ExprJump("$swhile" + wID);
            Parser.Symbol('}');
            Parser.SkipBlank();

            Symbols.AddSymbol("$endwhile" + wID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
        }

        public static void StatementFor() {
            int fID = 0;
            fID += DataManager.lUniqueID;
            DataManager.lUniqueID++;
            String sExpression = "";

            Parser.Symbol('(');

            String Ident = Parser.Identifier();
            Parser.SkipBlank();

            if (Parser.IsSymbol('(')) {
                Memory.SetArray(Ident);
            } else {
                if (Parser.IsVariable(Ident)) {
                    EvalVariable(Ident, true);
                } else
                    if (Function.IsLocalVariable(Ident)) {
                        EvalLocalVariable(Ident, true);
                    }
            }

            Expressions.IsStringCompare = false;
            Symbols.AddSymbol("$sfor" + fID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);

            Expressions.Expression("$Intern.Compare.One");
            Expressions.Expression("$Intern.Compare.Two");

            if (Expressions.IsStringCompare) {
                comAssembler.ExprCompareS("$Intern.Compare.One", "$Intern.Compare.Two");
            } else {
                comAssembler.ExprCompare("$Intern.Compare.One", "$Intern.Compare.Two");
            }


            Expressions.ChooseRelation(fID, "$endfor");
            Parser.Terminator();

            while (!Parser.IsSymbol(')')) {
                sExpression = sExpression + (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 +  Math.min(1, Parser.Source.length() - (Parser.Position - 1))));

                if (Parser.IsSymbol('(')) {
                    Parser.Position++;

                    while (!Parser.IsSymbol(')')) {
                        sExpression = sExpression + (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 +  Math.min(1, Parser.Source.length() - (Parser.Position - 1))));
                        Parser.Position++;
                    }

                    sExpression = sExpression + (Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(1, Parser.Source.length() - (Parser.Position - 1))));
                }

                if (Parser.Position >= Strings.Len(Parser.Source)) {
                    Summary.ErrMessage("found end of code. but expected ')' or ','");
                    return;
                }

                Parser.Position++;
            }

            Parser.Symbol(')');
            Parser.Symbol('{');
            Symbols.AddSymbol("$for" + fID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
            Parser.InsertSource(sExpression + ";");
            Parser.CodeBlock();
            comAssembler.ExprJump("$sfor" + fID);
            Parser.Symbol('}');
            Parser.SkipBlank();
            Symbols.AddSymbol("$endfor" + fID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            Parser.CodeBlock();
        }

        public static void StatementLoop() {
            String Ident = "";
            int iID = 0;

            iID += DataManager.lUniqueID;
            DataManager.lUniqueID++;

            String Mode = Parser.Identifier();

            if (Mode.equals( "until")) {
                Parser.Symbol('(');
                Expressions.Expression("$Intern.Compare.One");
                Expressions.Expression("$Intern.Compare.Two");
                Parser.Symbol(')');

                Symbols.AddSymbol("$loop" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
                Parser.Symbol('{');
                Parser.CodeBlock();
                Parser.Symbol('}');

                comAssembler.ExprCompare("$Intern.Compare.One", "$Intern.Compare.Two");
                Expressions.ChooseRelation(iID, "$loop");

                Symbols.AddSymbol("$loopout" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
            } else
                if (Mode.equals(  "down") || Mode .equals("")) {
                    Parser.Symbol('(');
                    Expressions.Expression("");
                    comAssembler.PopECX();

                    if (Parser.IsSymbol(',')) {
                        Parser.Skip(0);
                        Ident = Parser.Identifier();
                    }

                    Parser.Symbol(')');

                    Symbols.AddSymbol("$loop" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);

                    Parser.Symbol('{');
                    Parser.CodeBlock();
                    Parser.Symbol('}');
                    comAssembler.DecECX();

                    if (Ident .length() != 0) {
                        //mov [Variable],ecx
                        Compiler.AddCodeWord(0xD89);
                        Fixups.AddCodeFixup(Ident);
                    }

                    //cmp ecx,0
                    Compiler.AddCodeWord(0xF983);
                    Compiler.AddCodeByte(0);
                    comAssembler.ExprJA("$loop" + iID);
                } else
                    if (Mode  .equals( "up")) {
                        Compiler.AddCodeByte(0xB9);
                        Compiler.AddCodeDWord(0); //mov ecx,0

                        Parser.Symbol('(');
                        Expressions.Expression("$Intern.Count");

                        if (Parser.IsSymbol(',')) {
                            Parser.Skip(0);
                            Ident = Parser.Identifier();
                        }

                        Parser.Symbol(')');

                        Symbols.AddSymbol("$loop" + iID, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);

                        Parser.Symbol('{');
                        Parser.CodeBlock();
                        Parser.Symbol('}');
                        comAssembler.IncECX();

                        if (Ident .length() != 0) {
                            //mov [Variable],ecx
                            Compiler.AddCodeWord(0xD89);
                            Fixups.AddCodeFixup(Ident);
                        }

                        //cmp ecx,[variable]
                        Compiler.AddCodeWord(0xD3B);
                        Fixups.AddCodeFixup("$Intern.Count");
                        comAssembler.ExprJL("$loop" + iID);
                    } else {
                        Summary.ErrMessage("expected loop 'up' or 'down' but found '" + Mode + "'");
                        return;
                    }

            Parser.CodeBlock();
        }

        public static void StatementDirect() {
            String AddrIdent = "";

            String Variable = "";

            Parser.Symbol('[');
            String Ident = Parser.Identifier();

            for (;;) {
                switch(Ident) {
                case "float":
                    Compiler.AddCodeSingle(Parser.NumberExpression().parseDouble());
                    break;

                case "dword":
                    Compiler.AddCodeDWord(Parser.NumberExpression().parseInt());
                    break;

                case "word":
                    Compiler.AddCodeWord(Mather.LoWord(Parser.NumberExpression().parseInt()));
                    break;

                case "byte":
                    Compiler.AddCodeByte(Mather.LoByte(Mather.LoWord(Parser.NumberExpression().parseInt())));
                    break;

                case "address":
                    AddrIdent = Parser.Identifier();
                    Fixups.AddCodeFixup(AddrIdent);
                    break;

                default:
                    Summary.ErrMessage("data type must be specified 'float', 'dword', 'word', 'byte', 'address'");
                    break;
                }

                Parser.SkipBlank();

                if (Parser.IsSymbol(',')) {
                    Parser.Position++;
                } else {
                    break;
                }
            }

            Parser.Symbol(']');
            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void StatementBytes() {
            int bByte = 0;
            String Ident = Parser.Identifier();
            Parser.Symbol('[');

            for (;;) {
                Compiler.AddDataByte((byte)(Parser.NumberExpression().parseInt()));

                if (Parser.IsSymbol("@")) {
                    Parser.Position++;
                    Symbols.AddSymbol(Ident, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_DWORD, false);
                }

                if (Parser.IsSymbol(',')) {
                    Parser.Position++;
                } else {
                    break;
                }
            }

            Parser.Symbol(']');
            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void EvalVariable(String Name, bool OnlySet ) {
            Parser.SkipBlank();

            if (Parser.IsSymbol('(')) {
                Memory.SetArray(Name);
                Parser.Terminator();
                Parser.CodeBlock();
                return;
            }

            if (Parser.IsSymbol('=')) {
                Parser.Symbol('=');
                Expressions.Expression(Name);
            } else
                if (Parser.IsSymbol('+')) {
                    Parser.Symbol('+');

                    if (Parser.IsSymbol('+')) {
                        Parser.Symbol('+');
                        //inc [Variable]
                        Compiler.AddCodeWord(0x5FF);
                        Fixups.AddCodeFixup(Name);
                    } else {
                        //add [Name],Value
                        Compiler.AddCodeWord(0x581);
                        Fixups.AddCodeFixup(Name);
                        Compiler.AddCodeDWord((Parser.NumberExpression().parseInt()));
                    }
                } else
                    if (Parser.IsSymbol('-')) {
                        Parser.Symbol('-');

                        if (Parser.IsSymbol('-')) {
                            Parser.Symbol('-');
                            //dec [Variable]
                            Compiler.AddCodeWord(0xDFF);
                            Fixups.AddCodeFixup(Name);
                        } else {
                            //sub [Name],Value
                            Compiler.AddCodeWord(0x2D81);
                            Fixups.AddCodeFixup(Name);
                            Compiler.AddCodeDWord((int)(Parser.NumberExpression().parseInt()));
                        }
                    }

            Parser.Terminator();

            if (!OnlySet) {
                Parser.CodeBlock();
            }
        }

        public static void EvalLocalVariable(String Name, bool OnlySet ) {
            int iLabel = 0;
            Parser.SkipBlank();

            if (Parser.IsSymbol('=')) {
                Parser.Symbol('=');
                Expressions.Expression("");
                comAssembler.PopEAX();
            } else
                if (Parser.IsSymbol('+')) {
                    Parser.Symbol('+');
                    //mov eax, [ebp+number]
                    Compiler.AddCodeWord(0x858B);
                    Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Name));
                    Compiler.AddCodeByte(0x5);

                    if (Parser.IsSymbol('+')) {
                        Parser.Symbol('+');
                        Compiler.AddCodeDWord(0x1);
                    } else {
                        Compiler.AddCodeDWord((int)(Parser.NumberExpression().parseInt()));
                    }
                } else
                    if (Parser.IsSymbol('-')) {
                        Parser.Symbol('-');
                        Compiler.AddCodeWord(0x858B);
                        Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Name));
                        Compiler.AddCodeByte(0x2D);

                        if (Parser.IsSymbol('-')) {
                            Parser.Symbol('-');
                            Compiler.AddCodeDWord(0x1);
                        } else {
                            Compiler.AddCodeDWord((int)(Parser.NumberExpression().parseInt()));
                        }
                    }

            //mov [ebp+number], eax
            Compiler.AddCodeWord(0x8589);
            Compiler.AddCodeDWord(Symbols.GetSymbolOffset(Function.CurrentFrame + "." + Name));
            Parser.Terminator();

            if (!OnlySet) {
                Parser.CodeBlock();
            }
        }

        public static void StatementWith() {
            Parser.WithIdent = Parser.Identifier();
            Parser.Symbol('{');
            Parser.CodeBlock();
            Parser.Symbol('}');
            Parser.WithIdent = "";
            Parser.CodeBlock();
        }

        public static void DeclareImport() {
            String FunctionName = "";
            String Library = "";
            int ParamCount = 0;

            String FunctionAlias = "";
            String Ident = Parser.Identifier();
            String OIdent = Parser.Identifier();

            if (OIdent  .equals( "alias")) {
                FunctionAlias = Ident;
                FunctionName = Parser.Identifier();
                OIdent = Parser.Identifier();
            } else {
                FunctionAlias = Ident;

                if (OIdent  .equals( "ascii")) {
                    OIdent = Parser.Identifier();
                    FunctionName = Ident + "A";
                } else
                    if (OIdent  .equals( "unicode")) {
                        OIdent = Parser.Identifier();
                        FunctionName = Ident + "W";
                    } else {
                        FunctionName = Ident;
                    }
            }

            if (OIdent  .equals( "lib") || OIdent  .equals( "library")) {
                Library = Parser.StringExpression();
            } else {
                Summary.ErrMessage("expected 'lib' but found '" + Ident + "'");
                return;
                return;
            }

            if (Parser.IsSymbol(',')) {
                Parser.Position++;
                ParamCount = (Parser.NumberExpression().parseInt());
            } else {
                ParamCount = 0;
            }

            Parser.Terminator();

            Imports.AddImport(FunctionName, Library, ParamCount, FunctionAlias, false);

            Parser.CodeBlock();

        }
    };
};