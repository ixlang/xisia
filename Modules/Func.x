
package Xisia {
    static class Function
    {
        public static class TYPE_FRAME
        {
            public String Name = "";
            public String Declares = "";
            public String ReturnAs = "";
            public bool Property;
            public  TYPE_FRAME(String) {}
            public  TYPE_FRAME() {}
            public static TYPE_FRAME CreateInstance() {
                TYPE_FRAME result = new TYPE_FRAME();
                return result;
            }
        };

        public static bool IsCallFrame = false;
        public static ObjectArray<TYPE_FRAME> Frames = new ObjectArray<TYPE_FRAME>();
        public static int ArgCount = 0;
        public static String CurrentFrame = "";
        public static int fcUniqueID = 0;

        public static void InitFrames() {
            fcUniqueID = 0;
            Frames.addOne();
        }

        public static void AddFrameDeclare(String VarName) {
            TYPE_FRAME t = Frames[Frames.length() - 1];
            t.Declares = t.Declares + VarName + ",";
        }

        public static void AddFrame(String Name, bool IsProperty) {
            TYPE_FRAME t = Frames.addOne();
            t.Name = Name;
            t.Property = IsProperty;
            CurrentFrame = Name;
        }

        public static bool IsLocalVariable(String Ident) {
            int i = 0;
            int __e = Symbols.Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols.Symbols[i].Name.equals(  CurrentFrame + "." + Ident)) {
                    return true;
                }
            }

            return false;
        }

        public static int GetFrameIDByName(String Name) {
            int i = 0;
            int __e = Frames.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Frames[i].Name.equals(Name)) {
                    return i;
                }
            }

            return 0;
        }

        public static String GetReturnType(String Name) {
            int i = 0;
            int __e = Frames.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Frames[i].Name.equals(Name)) {
                    return Frames[i].ReturnAs;
                }
            }

            return "";
        }

        public static String [] _lsplit(String txt, char c) {
            int start = 0;

            if (txt.length() == 0) {
                String [] r = {txt};
                return r;
            }

            int pos = txt.indexOf(c, start);
            Vector<String> vs = new Vector<String>();

            while (pos != -1) {
                vs.add(txt.substring(start, pos));
                start = pos + 1;

                if (start != txt.length()) {
                    pos = txt.indexOf(c, start);
                } else {
                    vs.add("");
                    break;
                }
            }

            return vs.toArray(new String[0]);
        }
        public static void CallFrame(String Ident, bool FromExpression) {
            int i = 0;
            int iLabel = 0;

            IsCallFrame = true;
            int fID = GetFrameIDByName(Ident);

            String[] FrameDeclares = _lsplit(Frames[fID].Declares, ',');
            Expressions.ReverseParams(); //UBound(FrameDeclares)

            Parser.Symbol('(');

            for (i = FrameDeclares.length - 1 - 1; i >= 0; i--) {
                if (Symbols.GetSymbolType(Frames[fID].Name + "." + FrameDeclares[i]) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD || Symbols.GetSymbolType(Frames[fID].Name + "." + FrameDeclares[i]) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT) {
                    Expressions.Expression("");
                } else
                    if (Symbols.GetSymbolType(Frames[fID].Name + "." + FrameDeclares[i]) == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING) {
                        Expressions.Expression("");
                    } else {
                        Expressions.Expression(Frames[fID].Name + "." + FrameDeclares[i]);
                        comAssembler.PushContent(Frames[fID].Name + "." + FrameDeclares[i]);
                    }

                if (Parser.IsSymbol(',')) {
                    Parser.Position++;
                }
            }

            Parser.Symbol(')');
            IsCallFrame = false;

            if (!FromExpression) {
                Parser.Terminator();
            }

            comAssembler.ExprCall(Ident);

            if (!FromExpression) {
                Parser.CodeBlock();
            }
        }

        public static void CallProperty(String Ident, bool FromExpression) {
            int i = 0;
            int fID = 0;
            int iLabel = 0;
            Object FrameDeclares = nilptr;

            IsCallFrame = true;
            Parser.SkipBlank();

            if (!FromExpression) {
                Parser.Symbol('=');
                Expressions.Expression("$Intern.Property");
                comAssembler.PushContent("$Intern.Property");
                Parser.Terminator();
            }

            IsCallFrame = false;

            if (CurrentFrame .equals(Ident) == false) {
                comAssembler.ExprCall(Ident);
            }

            if (!FromExpression) {
                Parser.CodeBlock();
            }
        }

        public static bool IsFrame(String Name) {
            int i = 0;
            int __e = Frames.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Frames[i].Name.equals(Name)) {
                    return true;
                }
            }

            return false;
        }

        public static bool IsProperty(String Name) {
            int i = 0;
            int __e = Frames.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Frames[i].Name.equals(Name)) {
                    if (Frames[i].Property) {
                        return true;
                    }
                }
            }

            return false;
        }

        public static void StatementReturn() {
            Parser.Symbol('(');
            Expressions.Expression("$Intern.Return");
            comAssembler.PushContent("$Intern.Return");
            comAssembler.ExprJump(CurrentFrame + ".end");
            Parser.Symbol(')');
            Parser.Terminator();
            Parser.CodeBlock();
        }

        public static void DeclareFrame(bool IsExport, bool NoCodeBlock, bool IsProto, bool IsProperty ) {
            int pCount = 0;
            String fAlias = "";
            String Name = "";
            String Method = "";
            String RetAs = "";

            ArgCount = 0;

            if (IsProperty) {
                Method = Parser.Identifier();

                if ((Method .equals ( "set" ) == false) && (Method .equals ( "get" ) == false )) {
                    Summary.ErrMessage("property 'set'/'get'");
                } else {
                    Method = "." + Method;
                }
            }

            String Ident = Parser.Identifier();
            AddFrame(Ident + Method, IsProperty);

            Parser.Symbol('(');

            for (;;) {
                String IdentII = Parser.Identifier();

                if (IdentII .length() != 0) {
                    Parser.VariableBlock(IdentII, true, false);
                    ArgCount++;
                }

                if (Parser.IsSymbol(',')) {
                    Parser.Symbol(',');
                    continue;
                } else
                    if (Parser.IsSymbol(')')) {
                        Parser.Symbol(')');

                        if (Parser.IsIdent("as")) {
                            Parser.SkipIdent();
                            RetAs = Parser.Identifier();

                            if (RetAs .equals( "dword" ) || RetAs .equals( "float") || RetAs .equals( "string")) {
                                Frames[Frames.length() - 1].ReturnAs = RetAs;
                            } else {
                                Summary.ErrMessage("'" + RetAs + "' is not allowed as return type for '" + CurrentFrame + "'");
                                return;
                            }

                            Parser.SkipBlank();
                        }

                        Parser.Terminator();
                    } else {
                        Summary.ErrMessage("unexpected '" + Parser.Source.substring(Parser.Position - 1, Parser.Position - 1 + Math.min(1, Parser.Source.length() - (Parser.Position - 1))) + "'");
                        return;
                    }

                break;
            }

            if (IsProto) {
                Symbols.AddSymbol(Ident + Method, Linker.OffsetOf(".code"), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_FRAME, true);
                Symbols.AddSymbol(Ident + Method + ".Address", Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_DWORD, true);
            } else {
                Symbols.AddSymbol(Ident + Method, Linker.OffsetOf(".code"), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_FRAME, false);
                Symbols.AddSymbol(Ident + Method + ".Address", Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, Symbols.ENUM_SYMBOL_TYPE.ST_DWORD, false);
            }

            if (!IsProto) {
                if (IsExport) {
                    Exports.AddExport(Ident + Method);
                }
            }

            if (!IsProto) {
                comAssembler.StartFrame();
                Parser.CodeBlock();
                //UPGRADE_WARNING: (6021) Casting 'int' to Enum may cause different behaviour. More Information: https://docs.mobilize.net/vbuc/ewis#6021
                Symbols.AddSymbol(Ident + Method + ".end", Linker.OffsetOf(".code"), (Linker.ENUM_SECTION_TYPE) 0, Symbols.ENUM_SYMBOL_TYPE.ST_FRAME, false);
                EndProc();
                comAssembler.EndFrame(ArgCount * 4);

                if (!NoCodeBlock) {
                    Parser.CodeBlock();
                }
            }
        }

        public static void EndProc() {
            if (Parser.IsIdent("end")) {
                Parser.SkipIdent();
                Parser.Terminator();
                CurrentFrame = "";

                if (!Compiler.IsCmdCompile) {
                    String s = "Processing... (" + (Parser.Position / ((double)Strings.Len(Parser.Source)) * 100) + "% Completed.. | Profress: " + Parser.Position + " )";
                }

                return;
            } else {
                Summary.ErrMessage("unexpected end of " + CurrentFrame + "'");
                return;
            }
        }

        public static void Align4(String SectionName) {
            int i = 0;

            if (Linker.OffsetOf(SectionName) == Math.floor(Linker.OffsetOf(SectionName) / 4) * 4) {
                return;
            }

            int __e = Math.floor((Linker.OffsetOf(SectionName) / 4) + 1) * 4 - 1;

            for (i = Linker.OffsetOf(SectionName); i <= __e; i++) {
                Linker.AddSectionNameByte(SectionName, 0);
            }
        }
    };
};