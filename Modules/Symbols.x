
package Xisia {
    static class Symbols
    {
        public enum ENUM_SYMBOL_TYPE
        {
            ST_RVA = 1,
            ST_LABEL = 2,
            ST_DWORD = 3,
            ST_WORD = 4,
            ST_BYTE = 5,
            ST_US_DWORD = 6,
            ST_US_WORD = 7,
            ST_US_BYTE = 8,
            ST_STRING = 9,
            ST_TYPE = 10,
            ST_IMPORT = 11,
            ST_EXPORT = 12,
            ST_RESOURCE = 13,
            ST_FRAME = 14,
            ST_LOCAL_DWORD = 15,
            ST_LOCAL_STRING = 16,
            ST_LOCAL_FLOAT = 17,
            ST_SINGLE = 18
        };

        public static class TYPE_SYMBOL
        {
            public String Name;
            public int Offset;
            public Linker.ENUM_SECTION_TYPE Section;
            public ENUM_SYMBOL_TYPE SymType;
            public bool IsProto;
            public static TYPE_SYMBOL CreateInstance() {
                TYPE_SYMBOL result = new TYPE_SYMBOL();
                result.Name = "";
                return result;
            }
        };

        public static class TYPE_CONSTANT
        {
            public String Name;
            public String Value;
            public static TYPE_CONSTANT CreateInstance() {
                TYPE_CONSTANT result = new TYPE_CONSTANT();
                result.Name = "";
                result.Value = "";
                return result;
            }

            public void load(FileInputStream fis) {
                Name = Strings.readString(fis);
                Value = Strings.readString(fis);
            }

            public void write(FileOutputStream fis) {
                Strings.writeString(fis, Name);
                Strings.writeString(fis, Value);
            }
        };

        public static TYPE_CONSTANT[] Constants = nilptr;
        public static ObjectArray<TYPE_SYMBOL> Symbols = new ObjectArray<TYPE_SYMBOL>();
        public static void InitSymbols() {
            Symbols.add(TYPE_SYMBOL.CreateInstance());
            Constants = ArraysHelper<TYPE_CONSTANT>.InitializeArray(1);
        }

        public static void AddSymbol(String Name, int Offset, Linker.ENUM_SECTION_TYPE Section, ENUM_SYMBOL_TYPE SymType, bool IsProto ) {
            if (SymbolExists(Name)) {
                Summary.ErrMessage("symbol '" + Name + "' already exists");
                return;
            }

            TYPE_SYMBOL s = Symbols.addOne();
            s.Name = Name;
            s.Offset = Offset;
            s.Section = Section;
            s.SymType = SymType;
            s.IsProto = IsProto;
        }

        public static bool SymbolExists(String Name) {
            int i = 0;
            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name.equals(Name)) {
                    if (!Symbols[i].IsProto) {
                        return true;
                    }
                }
            }

            return false;
        }

        public static int GetSymbolOffset(String Name) {
            int i = 0;
            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name.equals(Name)) {
                    return Symbols[i].Offset;
                }
            }

            Summary.ErrMessage("symbol '" + Name + "' does not exist!");
            return 0;
        }

        public static int GetSymbolSpace(String Ident) {
            int i = 0;
            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name .equals(Ident)) {
                    //GetSymbolSpace = Symbols(i).Space
                    return 0;
                }
            }

            return 0;
        }

        public static int GetSymbolSize(String Ident) {
            int result = 0;
            int i = 0;

            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name .equals( Ident)) {
                    if (Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_DWORD || Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_US_DWORD || Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_SINGLE) {
                        result = 4;
                    } else
                        if (Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_WORD || Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_US_WORD) {
                            result = 2;
                        } else
                            if (Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_BYTE || Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_US_BYTE) {
                                result = 1;
                            } else
                                if (Symbols[i].SymType == ENUM_SYMBOL_TYPE.ST_STRING) {
                                    //GetSymbolSize = Symbols(i).Space
                                } else {
                                    Summary.ErrMessage("unknown symbol type '" + Ident + "'");
                                }

                    return result;
                }
            }

            return result;
        }

        public static ENUM_SYMBOL_TYPE GetSymbolType(String Ident) {
            int i = 0;
            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name.equals( Ident)) {
                    return Symbols[i].SymType;
                }
            }

            return (ENUM_SYMBOL_TYPE) 0;
        }

        public static int GetSymbolID(String Ident) {
            int i = 0;
            int __e = Symbols.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Symbols[i].Name .equals( Ident)) {
                    return i;
                }
            }

            return 0;
        }

        public static int GetConstant(String Name) {
            int i = 0;

            if (Name .equals( "")) {
                return 0;
            }

            int __e = Constants.length - 1;

            for (i = 1; i <= __e; i++) {
                if (Name .equals( Constants[i].Name)) {
                    return (int)((Constants[i].Value).parseDouble());
                }
            }

            Summary.ErrMessage("unknown constant '" + Name + "'");
            return 0;
        }

        public static void AddConstant(String Name, String Value) {
            Constants = ArraysHelper<TYPE_CONSTANT>.RedimPreserve(Constants, new TYPE_CONSTANT[Constants.length + 1]);
            Constants[Constants.length - 1].Name = Name;
            Constants[Constants.length - 1].Value = Value;
        }
    };
};