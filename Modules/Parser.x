package Xisia {
    static class Parser
    {
        public static String Source = "";
        public static int Position = 0;
        public static String WithIdent = "";
        public static String EntryPoint = "";
        public static bool UnsignedDeclare = false;

        public static void InitParser() {
            int i = 0;
            Linker.AppType = (Linker.ENUM_APP_TYPE) 0;
            Summary.pError = false;
            Compiler.bLibrary = false;
            UnsignedDeclare = false;
            Expressions.CompareOne = "";
            Expressions.CompareTwo = "";
            Source = "";
            int __e = MemoryFiles.VirtualFiles.length - 1;

            for (i = 1; i <= __e; i++) {
                if (MemoryFiles.VirtualFiles[i].Extension != MemoryFiles.EX_DIALOG) {
                    Source = Source + "module " + "\"" + MemoryFiles.VirtualFiles[i].Name + "\"" + ";" + "\r\n" + MemoryFiles.VirtualFiles[i].Content + "\r\n";
                }
            }

            Source = Source.replace("\t", " ")
                            .replace("\\\r\n", " ")
                            .replace("\\\n", " ")
                            .replace("\\\r", " ")
                            + "\r\n" ;
            Position = 1;
        }

        public static void Parse() {
            General.StartCounter();
            Syntax.CurrentModule = "";
            Function.CurrentFrame = "";
            Types.CurrentType = "";
            EntryPoint = "";

            if (!Compiler.bLibrary) {
                Syntax.CreateSection(".data", Linker.ENUM_SECTION_TYPE.Data, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_WRITE)));
                Syntax.CreateSection(".code", Linker.ENUM_SECTION_TYPE.Code, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_CODE) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_EXECUTE)));
                Syntax.CreateSection(".idata", Linker.ENUM_SECTION_TYPE.Import, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_WRITE)));
                Syntax.CreateSection(".edata", Linker.ENUM_SECTION_TYPE.Export, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ)));
                Syntax.CreateSection(".rsrc", Linker.ENUM_SECTION_TYPE.Resource, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_READ)));
                Syntax.CreateSection(".reloc", Linker.ENUM_SECTION_TYPE.Relocate, (Linker.ENUM_SECTION_CHARACTERISTICS) (((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_MEM_DISCARDABLE) + ((int) Linker.ENUM_SECTION_CHARACTERISTICS.CH_INITIALIZED_DATA)));

                Protos.AssignProtoTypes();
                Syntax.DirectiveModule();
                Syntax.DirectiveApplication();

                Imports.AddImport("lstrcpyA", "KERNEL32.DLL", 2, "lstrcpy", false);
                Imports.AddImport("lstrcmpA", "KERNEL32.DLL", 2, "lstrcmp", false);
                Imports.AddImport("wsprintfA", "USER32.DLL", -1, "Format", false);
                Imports.AddImport("ExitProcess", "KERNEL32.DLL", 1, "",  false);
                Imports.AddImport("GetModuleHandleA", "KERNEL32.DLL", 1, "GetModuleHandle", false);
                Imports.AddImport("HeapCreate", "KERNEL32.DLL", 3, "",  false);
                Imports.AddImport("HeapAlloc", "KERNEL32.DLL", 3, "",  false);
                Imports.AddImport("HeapDestroy", "KERNEL32.DLL", 1, "",  false);
                Imports.AddImport("RtlMoveMemory", "KERNEL32.DLL", 3, "MoveMemory",  false);
                Imports.AddImport("MessageBoxA", "USER32.DLL", 4, "MessageBox", false);


                DataManager.DeclareDataDWord("Instance", 0);
                DataManager.DeclareDataDWord("$Intern.Property", 0);
                DataManager.DeclareDataDWord("$Intern.Compare.One", 0);
                DataManager.DeclareDataDWord("$Intern.Compare.Two", 0);
                DataManager.DeclareDataDWord("$Intern.double", 0);
                DataManager.DeclareDataDWord("$Intern.Array", 0);
                DataManager.DeclareDataDWord("$Intern.Loop", 0);
                DataManager.DeclareDataDWord("$Intern.Count", 0);
                DataManager.DeclareDataDWord("$Intern.Return", 0);

                Symbols.AddConstant("TRUE", "-1");
                Symbols.AddConstant("FALSE", "0");
                Symbols.AddConstant("NULL", "0");

                Compiler.AddCodeWord(0x6A);
                comAssembler.InvokeByName("GetModuleHandle");
                Compiler.AddCodeByte(0xA3);
                Fixups.AddCodeFixup("Instance");

                if (!Exports.IsDLL) {
                    if (EntryPoint .equals( "")) {
                        comAssembler.ExprCall("$entry");
                    } else {
                        comAssembler.ExprCall(EntryPoint);
                        comAssembler.Push(0);
                        comAssembler.InvokeByName("ExitProcess");
                    }
                } else {
                    comAssembler.InitializeDLL();
                }
            }

            CodeBlock();

            if (!Compiler.bLibrary && !Exports.IsDLL) {
                Syntax.EntryBlock();
                CodeBlock();
            }
        }

        
        public static void CodeBlock() {

            String Ident = Identifier();

            if (Ident.length() == 0 || Summary.pError) {
                return;
            }

            switch(Ident.lower()) {
                case "import" :
                    Syntax.DeclareImport();
                    break;

                case "const" :
                    Syntax.DeclareConstant();
                    break;

                case "type" :
                    Syntax.DeclareType();
                    break;

                case "func" :
                    Function.DeclareFrame(false, false, false, false);
                    break;

                case "property" :
                    Function.DeclareFrame(false, false, false, true);
                    break;

                case "export" :
                    Function.DeclareFrame(true, false, false, false);
                    break;

                case "return" :
                    Function.StatementReturn();
                    break;

                case "if" :
                    Syntax.StatementIf();
                    break;

                case "while" :
                    Syntax.StatementWhile();
                    break;

                case "for" :
                    Syntax.StatementFor();
                    break;

                case "loop" :
                    Syntax.StatementLoop();
                    break;

                case "goto" :
                case "jump" :
                    Syntax.StatementGoto();
                    break;

                case "include" :
                case "library" :
                    Syntax.StatementInclude();
                    break;

                case "var" :
                    Syntax.DeclareLocal();
                    break;

                case "preserve" :
                    Memory.StatementPreserve();
                    break;

                case "reserve" :
                    Memory.StatementReserve();
                    break;

                case "destroy" :
                    Memory.StatementDestroy();
                    break;

                case "direct" :
                    Syntax.StatementDirect();
                    break;

                case "bytes" :
                    Syntax.StatementBytes();
                    break;

                case "with" :
                    Syntax.StatementWith();
                    break;

                case "ubound" :
                    Memory.StatementUBound();
                    break;

                case "lbound" :
                    Memory.StatementLBound();
                    break;

                case "bitmap" :
                    Resources.DeclareBitmap();
                    break;

                case "module" :
                    Position -= 6;
                    Syntax.DirectiveModule();
                    CodeBlock();
                    return;

                case "end" :
                    Position -= 3;
                    return;

                case "end." :
                    Position -= 4;
                    return;

                case "entry" :
                    Position -= 6;
                    return;

                default:
                    if (Imports.IsImport(Ident)) {
                        Expressions.CallImport(Ident, false);
                    } else if (Function.IsLocalVariable(Ident)) {
                        Syntax.EvalLocalVariable(Ident, false);
                    } else if (Function.IsProperty(Ident + ".set")) {
                        Function.CallProperty(Ident + ".set", false);
                    } else if (Function.IsFrame(Ident)) {
                        Function.CallFrame(Ident, false);
                    } else if (IsVariable(Ident)) {
                        Syntax.EvalVariable(Ident, false);
                    } else {
                        VariableBlock(Ident, false, false);
                    }

                    break;
            }


        }

        public static void VariableBlock(String Ident, bool FrameExpression, bool NoCodeBlock ) {

            if (Ident .equals( "") || Summary.pError) {
                return;
            }

            switch(Ident.lower()) {
                case "signed" :
                    UnsignedDeclare = false;
                    Ident = Identifier();
                    VariableBlock(Ident, FrameExpression, NoCodeBlock);
                    return;

                case "unsigned" :
                    UnsignedDeclare = true;
                    Ident = Identifier();
                    VariableBlock(Ident, FrameExpression, NoCodeBlock);
                    return;

                case "byte" :
                case "bool" :
                case "boolean" :
                    Syntax.DeclareVariable(Types.CurrentType, "byte", FrameExpression, NoCodeBlock);
                    break;

                case "word" :
                    Syntax.DeclareVariable(Types.CurrentType, "word", FrameExpression, NoCodeBlock);
                    break;

                case "dword" :
                    Syntax.DeclareVariable(Types.CurrentType, "dword", FrameExpression, NoCodeBlock);
                    break;

                case "float" :
                    Syntax.DeclareVariable(Types.CurrentType, "float", FrameExpression, NoCodeBlock);
                    break;

                case "string" :
                    Syntax.DeclareString(Types.CurrentType, FrameExpression, NoCodeBlock);
                    break;

                default:
                    if (Types.IsType(Ident)) {
                        Types.AssignType(Identifier(), Ident);
                    } else {
                        Summary.ErrMessage("unknown identifier -> '" + Ident + "'");
                        return;
                    }

                    break;
            }

            UnsignedDeclare = false;
        }

        public static String Identifier() {
            BytesBuffer result = new BytesBuffer();
            result.pop(1);
            
            SkipBlank();
            char Value = 0;

            if (Position - 1 < Source.length()) {
                Value = Source.upper().charAt(Position - 1);
            }

            if (Value == '.' && WithIdent.length() != 0) {
                result.add(WithIdent.getBytes());
            }

            while ((Value >= 'A' && Value <= 'Z' )|| Value == '.' || Value == '_') {
                int c1 = Source.charAt(Position);
                while (c1 >= '0' && c1 <= '9') {
                    result.add(Source.charAt(Position - 1));
                    Position++;
                    c1 = Source.charAt(Position);
                }

                result.add(Source.charAt(Position - 1));
                Position++;
                Value = Source.upper().charAt(Position - 1);
            }

            String res = result.toString();
            
            if (IsSymbol(":")) {
                Syntax.DeclareLabel(res);
                res = Identifier();
            }
            
            return res;
        }

        public static void Skip(int NumberOfChars ) {
            Position = Position + 1 + NumberOfChars;
        }

        public static void SkipBlank() {
            char Value = 0, Value2 = 0;
            int src_len = Source.length();
            if (Position < src_len){
                Value = Source.charAt(Position - 1);
                Value2 = Source.charAt(Position);
            }
            while (Value == ' ' || Value == '\r' || Value == '\n' || Value == '\t' || (Value == '/' && Value2 == '/')) {
                if (Value == '/' && Value2 == '/') {
                   int eol = Source.indexOf('\n', Position - 1);
                    if (eol == -1){
                        Summary.ErrMessage("found end of code");
                        return;
                    }
                    Position = eol + 1;
                }
                Position++;
                if (Position - 1 < src_len) {
                    Value = Source.charAt(Position - 1);
                    if (Position < src_len){
                        Value2 = Source.charAt(Position);
                    }else{
                        Value2 = 0;
                    }
                } else {
                    Value = Value2 = 0;
                }
            }
        }

        public static void SkipIdent() {
            Identifier();
        }

        public static void Symbol(char Value) {
            SkipBlank();
            if (Source.charAt(Position - 1) == Value) {
                Position++;
            } else {
                Summary.ErrMessage("expected symbol '" + Value + "' but found '" + Source.substring(Position - 1, Position - 1 + Math.min(1, Source.length() - (Position - 1))) + "'");
            }
        }

        public static bool IsIdent(String Word) {
            bool result = false;
            SkipBlank();
            return IsSymbol(Word);
        }

        public static char getChar(int pos){
            return Source.charAt(Position - 1 + pos);
        }
        
        public static String getText(int len){
            return Source.substring(Position - 1, Math.min(2, Source.length() - (Position - 1)));
        }
        
        public static bool IsSymbol(char c) {
            int np = Position - 1;
            if (np < Source.length() && (Source.charAt(np) == c)) {
                return true;
            }
            return false;
        }
        
        public static bool IsSymbol(String Value) {
            int np = Position - 1;
            if (np < Source.length() && (Source.indexOf(Value, np) == np)) {
                return true;
            }
            return false;
        }

        public static void Blank() {
            if (Source.charAt(Position - 1) == ' ') {
                Position++;
            } else {
                Summary.ErrMessage("expected blank ' ' but found '" + Source.substring(Position - 1, Position - 1 + Math.min(1, Source.length() - (Position - 1))) + "'");
            }
        }

        public static void BodyEnd() {
            if (Source.charAt(Position - 1) == '}') {
                Position++;
            } else {
                Summary.ErrMessage("expected terminator (}) but found '" + Source.substring(Position - 1, Position - 1 + Math.min(1, Source.length() - (Position - 1))) + "'");
                return;
            }
        }
        
        public static void BodyBegin() {
            if (Source.charAt(Position - 1) == ':') {
                Position++;
            } else {
                Summary.ErrMessage("expected terminator ({) but found '" + Source.substring(Position - 1, Position - 1 + Math.min(1, Source.length() - (Position - 1))) + "'");
            }
        }
        
        public static void Terminator() {
            if (Source.charAt(Position - 1) == ';') {
                Position++;
            } else {
                Summary.ErrMessage("expected terminator (;) but found '" + Source.substring(Position - 1, Position - 1 + Math.min(1, Source.length() - (Position - 1))) + "'");
                return;
            }
        }

        public static bool IsVariable(String Name) {
            int i = 0;
            int __e = Symbols.Symbols.length();

            for (i = 0; i < __e; i++) {
                if (Symbols.Symbols[i].Name.equals(Name)) {
                    if (Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_BYTE || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_WORD || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_DWORD || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_SINGLE || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_US_BYTE || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_US_WORD || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_US_DWORD || Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_STRING) {
                        return true;
                    }

                    return false;
                }
            }

            return false;
        }

        public static bool IsEndOfCode(int Value) {
            if (Value > Strings.Len(Source)) {
                Summary.ErrMessage("found end of code. but expected ')' or ','");
                return true;
            }

            return false;
        }

        public static bool IsVariableExpression() {
            bool result = false;
            char c = Source.charAt(Position - 1);

            if (c >= 'A' && c <= 'Z') {
                result = true;
            }

            return result;
        }

        public static bool IsStringExpression() {
            return Source.charAt(Position - 1) == '"';
        }

        public static bool IsdoubleExpression() {
            bool result = false;
            int i = Position - 1;
            String Strdouble = "";

            char c = Source.charAt(i);
            if (c == '-'){
                c = Source.charAt(++i);
            }
            bool dot = false;
            while ((c >= '0' && c <= '9') || c == '-' || c == '.') {
                if (c == '.'){
                    dot = true;
                }
                i++;
                c = Source.charAt(i);
            }
            return dot;
        }

        public static bool IsNumberExpression() {
            bool result = false;
            int i = 0;
            char c = Source.charAt(Position - 1);

            if ((c >= '0' && c <= '9') || c == '-' || c == '$') {
                result = true;
            } else if (IsConstantExpression()) {
                int __e = Symbols.Constants.length;

                for (i = 1; i < __e; i++) {
                    if (IsIdent(Symbols.Constants[i].Name)) {
                        return true;
                    }
                }
            }

            return result;
        }

        public static bool IsConstantExpression() {
            bool result = false;
            char c = Source.upper().charAt(Position - 1);

            if ((c >= 'A' && c <= 'Z') ) {
                result = true;
            } else if (IsSymbol('[')) {
                result = true;
            }

            return result;
        }

        public static String NumberExpression() {
            String result = "";

            int i = 0;
            bool CToHex = false;
            String Str2Hex = "";
            SkipBlank();
            bool IsNegative = false;
            bool IsdoubleRec = false;
            bool bfloat = false;
            String AfterPoint = "";

            if (IsSymbol('$')) {
                Symbol('$');
                CToHex = true;
                char c  =Source.upper().charAt(Position - 1);
                String str = "";
                int count = 0;
                while ((c >= '0' && c <= '9') || c == '-' || c == 'A' || c == 'B'|| c == 'C'|| c == 'D'|| c == 'E'|| c == 'F') {                    
                    count++;
                    Position++;
                    c = Source.upper().charAt(Position - 1);
                }
                result = Source.substring(Position - count - 1,Position - 1);
            } else {
                char c = Source.charAt(Position - 1);

                while ((c >= '0' && c <= '9') || c == '-' || c == '.') {
                    if (c == '.') {
                        bfloat = true;
                        Position++;
                        c = Source.charAt(Position - 1);
                        while ((c >= '0' && c <= '9')) {
                            AfterPoint = AfterPoint.append(c);
                            Position++;
                            c = Source.charAt(Position - 1);
                        }
                        Position--;
                        AfterPoint = "0." + AfterPoint;
                        float value = (result.parseFloat()) + (AfterPoint).parseFloat();
                        if (IsNegative) {
                            value *= -1;
                        }
                        result = "" + value;
                    } else if (c == '-') {
                        IsNegative = true;
                    } else {
                        result = result + c;
                    }
                    Position++;
                    c = Source.charAt(Position - 1);
                }

                if (AfterPoint.length() == 0) {
                    if (IsNegative) {
                        result = "" + result.parseLong() * (-1);
                    }
                }
            }

            if (CToHex) {
                result = "" + (("0x" + result)).parseHex();
            }

            if (result.parseLong() == 0) {
                int __e = Symbols.Constants.length;

                for (i = 1; i < __e; i++) {
                    if (IsIdent(Symbols.Constants[i].Name)) {
                        return "" + Symbols.GetConstant(Identifier());
                    }
                }
            }

            return result;
        }

        public static void InsertSource(String sISource) {
            String Header = Source.substring(0, Math.min(Position - 1, Source.length()));
            String Footer = Source.substring(Position - 1, Position - 1 + Math.min(Strings.Len(Source) - Position + 1, Source.length() - (Position - 1)));
            Source = Header + sISource + Footer;
        }

        public static int ConstantExpression() {
            int result = 0;

            if (IsSymbol('[')) {
                Symbol('[');

                while (!IsSymbol(']')) {
                    result = (int)(NumberExpression().parseInt());

                    if (IsSymbol('+')) {
                        Symbol('+');
                        result = (int)(result + NumberExpression().parseInt());
                    } else if (IsSymbol('-')) {
                        Symbol('-');
                        result = (int)(result - NumberExpression().parseInt());
                    } else if (IsSymbol("|")) {
                        Symbol('|');

                        if (IsSymbol("!")) {
                            Symbol('!');
                            result = result | ~(int)(NumberExpression().parseInt());
                        } else {
                            result = result | (int)(NumberExpression().parseInt());
                        }
                    } else if (IsSymbol("&")) {
                        Symbol('&');

                        if (IsSymbol("!")) {
                            Symbol('!');
                            result = result & ~(int)(NumberExpression().parseInt());
                        } else {
                            result = result & (int)(NumberExpression().parseInt());
                        }
                    } else if (IsSymbol("~")) {
                        Symbol('~');
                        result = result ^ (int)(NumberExpression().parseInt());
                    } else {
                        Summary.ErrMessage("invalid constant value");
                        return result;
                    }

                    if (Position >= Strings.Len(Source)) {
                        Summary.ErrMessage("found end of code. but expected ')' or ','");
                        return result;
                    }
                }

                Symbol(']');
            } else {
                result = Symbols.GetConstant(Identifier());
            }

            return result;
        }

        public static String VariableExpression() {
            SkipBlank();
            return Identifier();
        }

        public static String StringExpression() {
            BytesBuffer result = new BytesBuffer();
            result.pop(1);
            
            SkipBlank();
            Symbol('"');
            char Value = Source.charAt(Position - 1);

            while (Value != '"') {
                result.add(Value);
                
                if (Source.indexOf("\\n",Position) == Position){
                    Position += 2;
                    result.add(new byte[]{'\r', '\n'}, 0, 2);
                }

                if (Source.indexOf("\\t",Position) == Position){
                    Position += 2;
                    result.add('\t');
                }

                
                if (Position < Source.length()){
                    Value = Source.charAt(Position);
                }else{
                    Value = 0;
                }
               
                Position++;
                
                if (Value == '\r' || Value == 0 ) {
                    Summary.ErrMessage("unterminated String");
                    return result.toString();
                }
            }

            Symbol('"' );
            return result.toString();
        }
    };
};