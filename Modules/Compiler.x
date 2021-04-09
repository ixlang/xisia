
package Xisia {
    public static class Compiler
    {
        public static bool bLibrary = false;
        public static String LibraryName = "";
        public static String NameDLL = "";
        public static bool IsCmdCompile = false;

        public static void Compile(String sFile, bool bRun) {
            //On Error GoTo CompileFailed
            Summary.InitSummary();
            Summary.InfMessage("..");

            Linker.InitSections();
            Symbols.InitSymbols();
            Resources.InitResources();
            Imports.InitImports();
            Exports.InitExports();
            Fixups.InitFixups();
            Function.InitFrames();
            DataManager.InitData();
            Types.InitTypes();
            Parser.InitParser();

            Summary.InfMessage("compiling...");
            Parser.Parse();

            if (Exports.IsDLL) {
                NameDLL = sFile.replaceExtension("DLL");
            }

            if (Summary.pError) {
                return;
            }

            if (bLibrary) {
                Imports.ExportLibrary();
                return;
            }

            Linker.InitLinker();

            if (Summary.pError) {
                return;
            }

            Fixups.DoFixups();
            Linker.Link(sFile, bRun);
            return;
        }

        public static void AddCodeBytes(byte []Value) {
            AddCodeBytes(Value, 0, Value.length);
        }

        public static void AddCodeBytes(byte []Value, int pos, int len) {
            Linker.Section[2].Bytes.add(Value, pos, len);
        }

        public static void AddCodeByte(byte Value) {
            Linker.Section[2].Bytes.add(Value);
        }

        public static void AddCodeWord(int Value) {
            AddCodeByte(Mather.LoByte(Value));
            AddCodeByte(Mather.HiByte(Value));
        }

        public static void AddCodeSingle(double Value) {
            int iv = Math.doubleBitsToInt(Value);
            AddCodeByte(iv & 0xff);
            AddCodeByte((iv >> 8) & 0xff);
            AddCodeByte((iv >> 16) & 0xff);
            AddCodeByte((iv >> 24) & 0xff);
        }

        public static void AddCodeDWord(int Value) {
            AddCodeWord(Mather.LoWord(Value));
            AddCodeWord(Mather.HiWord(Value));
        }

        public static void AddDataByte(byte Value) {
            Linker.Section[1].Bytes.add(Value);
        }

        public static void AddDataBytes(byte []Value) {
            AddDataBytes(Value, 0, Value.length);
        }

        public static void AddDataBytes(byte []Value, int pos, int len) {
            Linker.Section[1].Bytes.add(Value, pos, len);
        }

        public static void AddDataWord(int Value) {
            AddDataByte(Mather.LoByte(Value));
            AddDataByte(Mather.HiByte(Value));
        }

        public static void AddDataSingle(float Value) {
            int iv = Math.floatBitsToInt(Value);
            AddDataByte(iv & 0xff);
            AddDataByte((iv >> 8) & 0xff);
            AddDataByte((iv >> 16) & 0xff);
            AddDataByte((iv >> 24) & 0xff);
        }

        public static void AddDataDWord(int Value) {
            AddDataWord(Mather.LoWord(Value));
            AddDataWord(Mather.HiWord(Value));
        }

        //------------------------------------------------------------------------
        public static void AddImportByte(byte Value) {
            Linker.AddSectionNameByte(".idata", Value);
        }

        public static void AddImportWord(int Value) {
            Linker.AddSectionNameWord(".idata", Value);
        }

        public static void AddImportDWord(int Value) {
            Linker.AddSectionNameDWord(".idata", Value);
        }

        public static void AddExportByte(byte Value) {
            Linker.AddSectionNameByte(".edata", Value);
        }

        public static void AddExportWord(int Value) {
            Linker.AddSectionNameWord(".edata", Value);
        }

        public static void AddExportDWord(int Value) {
            Linker.AddSectionNameDWord(".edata", Value);
        }

        public static void AddResourceByte(byte Value) {
            Linker.AddSectionNameByte(".rsrc", Value);
        }

        public static void AddResourceWord(int Value) {
            Linker.AddSectionNameWord(".rsrc", Value);
        }

        public static void AddResourceDWord(int Value) {
            Linker.AddSectionNameDWord(".rsrc", Value);
        }

        public static void AddRelocationByte(byte Value) {
            Linker.AddSectionNameByte(".reloc", Value);
        }

        public static void AddRelocationWord(int Value) {
            Linker.AddSectionNameWord(".reloc", Value);
        }

        public static void AddRelocationDWord(int Value) {
            Linker.AddSectionNameDWord(".reloc", Value);
        }
    };
};