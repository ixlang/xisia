
package Xisia {
    static class DataManager
    {
        public static int lUniqueID = 0;
        public static int sUniqueID = 0;
        public static int dUniqueID = 0;
        public static int fUniqueID = 0;

        public static void InitData() {
            lUniqueID = 0;
            sUniqueID = 0;
            dUniqueID = 0;
            fUniqueID = 0;
        }

        public static void DeclareDataSingle(String Name, float Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_SINGLE, false);
            Compiler.AddDataSingle(Value);
        }

        public static void DeclareDataDWord(String Name, int Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_DWORD, false);
            Compiler.AddDataDWord(Value);
        }

        public static void DeclareDataWord(String Name, int Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_WORD, false);
            Compiler.AddDataWord(Value);
        }

        public static void DeclareDataByte(String Name, byte Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_BYTE, false);
            Compiler.AddDataByte(Value);
        }

        public static void DeclareDataUnsignedDWord(String Name, int Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_US_DWORD, false);
            Compiler.AddDataDWord(Value);
        }

        public static void DeclareDataUnsignedWord(String Name, int Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_US_WORD, false);
            Compiler.AddDataWord(Value);
        }

        public static void DeclareDataUnsignedByte(String Name, byte Value) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_US_BYTE, false);
            Compiler.AddDataByte(Value);
        }

        public static void DeclareDataString(String Name, String Text, int Space) {
            int i = 0;
            Symbols.AddSymbol(Name, Linker.OffsetOf(".data"), Linker.ENUM_SECTION_TYPE.Data, Symbols.ENUM_SYMBOL_TYPE.ST_STRING, false);

            Compiler.AddDataBytes(Text.getBytes());

            if (Space > 0 && Space >= (Text).length()) {
                byte [] data = new byte[Space - (Text).length() + 1];
                Compiler.AddDataBytes(data);
            }

            Compiler.AddDataByte(0x0);
        }
    };
};