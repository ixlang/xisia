
package Xisia {
    static class Types
    {
        public static class TYPE_TYPE
        {
            public String Name;
            public String Source;
            public static TYPE_TYPE CreateInstance() {
                TYPE_TYPE result = new TYPE_TYPE();
                result.Name = "";
                result.Source = "";
                return result;
            }

            public void load(FileInputStream fis) {
                Name = Strings.readString(fis);
                Source = Strings.readString(fis);
            }

            public void write(FileOutputStream fis) {
                Strings.writeString(fis, Name);
                Strings.writeString(fis, Source);
            }
        };

        public static ObjectArray<TYPE_TYPE> Types = new ObjectArray<TYPE_TYPE>();
        public static String CurrentType = "";
        public static int TypesLeft = 0;

        public static void InitTypes() {
            CurrentType = "";
            TypesLeft = 0;
            Types.addOne();
        }


        public static void AssignType(String Ident, String AsIdent) {
            int i = 0;
            int ii = 0;
            String myType = "";
            String myIdent = "";
            int myLastPos = 0;
            Parser.Terminator();

            int __e = Types.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Types[i].Name .equals( AsIdent)) {
                    Symbols.AddSymbol(Ident, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_TYPE, false);
                    Parser.InsertSource(Types[i].Source + "}");
                    Summary.LenIncludes += Strings.Len(Types[i].Source);
                    myType = Ident;
                    CurrentType = Ident;
                    TypesLeft = 0;

                    while (!Parser.IsSymbol('}')) {
                        myIdent = Parser.Identifier();

                        if (IsType(myIdent)) {
                            myType = myIdent;
                            myIdent = Parser.Identifier();
                            CurrentType = CurrentType + "." + myIdent;
                            Parser.Terminator();
                            int __e2 = Types.length() - 1;

                            for (ii = 1; ii <= __e2; ii++) {
                                if (Types[ii].Name .equals( myType)) {
                                    Symbols.AddSymbol(CurrentType, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_TYPE, false);
                                    Parser.InsertSource(Types[ii].Source + "}");
                                    Summary.LenIncludes += Strings.Len(Types[ii].Source);
                                    TypesLeft++;
                                }
                            }
                        } else {
                            Parser.VariableBlock(myIdent, false, true);
                        }

                        if (Parser.Position == myLastPos) {
                            Summary.ErrMessage("expected '}' but could not process '" + AsIdent + "'.");
                            return;
                        }

                        if (Parser.Position >= Strings.Len(Parser.Source)) {
                            Summary.ErrMessage("expected '}' but found end of code.");
                            return;
                        }

                        myLastPos = Parser.Position;
                        Parser.SkipBlank();

                        if (Parser.IsSymbol('}') && TypesLeft > 0) {
                            Parser.Skip(0);
                            TypesLeft--;
                            CurrentType = Ident;
                        }
                    }

                    if (Parser.IsSymbol('}')) {
                        Parser.Skip(0);
                    }

                    CurrentType = "";
                    Parser.SkipBlank();
                    Parser.CodeBlock();
                }
            }
        }

        public static bool IsAssignedType(String Ident) {
            int i = 0;
            int __e = Symbols.Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols.Symbols[i].Name.equals(Ident)) {
                    if (Symbols.Symbols[i].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_TYPE) {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool IsType(String Ident) {
            int i = 0;
            int __e = Types.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Types[i].Name .equals( Ident)) {
                    return true;
                }
            }

            return false;
        }
    };
};