package Xisia {
    static class Exports
    {

        public static class TYPE_EXPORT
        {
            public String Name;
            public short Ordinal;
            public static TYPE_EXPORT CreateInstance() {
                TYPE_EXPORT result = new TYPE_EXPORT();
                result.Name = "";
                return result;
            }
        };

        public static class TYPE_RELOCATION
        {
            public int Offset;
            public static TYPE_RELOCATION CreateInstance() {
                TYPE_RELOCATION result = new TYPE_RELOCATION();
                return result;
            }
        };

        public static bool IsDLL = false;
        public static TYPE_EXPORT[] Exports = nilptr;
        public static TYPE_RELOCATION[] Relocations = nilptr;

        public static void InitExports() {
            IsDLL = false;
            Exports = ArraysHelper<TYPE_EXPORT>.InitializeArray(1);
            Relocations = ArraysHelper<TYPE_RELOCATION>.InitializeArray(1);
        }

        public static void AddExport(String Name) {
            Exports = ArraysHelper<TYPE_EXPORT>.RedimPreserve(Exports, new TYPE_EXPORT[Exports.length + 1]);
            Exports[Exports.length - 1].Name = Name;
        }

        public static void AddRelocation(int Offset) {
            Relocations = ArraysHelper<TYPE_RELOCATION>.RedimPreserve(Relocations, new TYPE_RELOCATION[Relocations.length + 1]);
            Relocations[Relocations.length - 1].Offset = Offset;
        }

        public static void WriteRelocations() {
            int i = 0;
            Syntax.CurrentSection = ".reloc";

            Linker.AddSectionDWord(Fixups.VirtualAddressOf(Linker.ENUM_SECTION_TYPE.Code));
            Fixups.AddFixup("Reloc_Last", Linker.OffsetOf(".reloc"), Linker.ENUM_SECTION_TYPE.Relocate, ((Fixups.VirtualAddressOf(Linker.ENUM_SECTION_TYPE.Relocate)) * (-1)));
            Linker.AddSectionDWord(0x0);

            for (i = 1; i < Relocations.length; i++) {
                if (Relocations[i].Offset != 0) {
                    Linker.AddSectionWord(Relocations[i].Offset + 0x3000);
                }
            }

            Symbols.AddSymbol("Reloc_Last", Linker.OffsetOf(".reloc"), Linker.ENUM_SECTION_TYPE.Relocate, Symbols.ENUM_SYMBOL_TYPE.ST_RVA, false);
        }

        public static void SortExports() {
            int i = 0;

            String[] Elements = StringArraysHelper.InitializeArray(Exports.length);


            for (i = 1; i < Exports.length; i++) {
                Elements[i] = Exports[i].Name;
            }

            Sorter.SortStringArray(Elements, 1, Elements.length - 1);

            for (i = 1; i < Elements.length; i++) {
                Exports[i].Name = Elements[i];
                Exports[i].Ordinal = (short) i;
            }
        }

        public static void GenerateExportTable() {
            int i = 0;
            int ii = 0;

            if (Exports.length < 2) {
                return;
            }

            Syntax.CurrentSection = ".edata";

            SortExports();

            Linker.AddSectionDWord(0);
            Linker.AddSectionDWord(0);
            Linker.AddSectionDWord(0);
            Fixups.AddFixup("DLL_NAME", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
            Linker.AddSectionDWord(0);
            Linker.AddSectionDWord(1);

            Linker.AddSectionDWord(Exports.length - 1);
            Linker.AddSectionDWord(Exports.length - 1);
            Fixups.AddFixup("ADDRESSES_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
            Linker.AddSectionDWord(0);
            Fixups.AddFixup("NAMES_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
            Linker.AddSectionDWord(0);
            Fixups.AddFixup("ORDINAL_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
            Linker.AddSectionDWord(0);

            Symbols.AddSymbol("ADDRESSES_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, Symbols.ENUM_SYMBOL_TYPE.ST_EXPORT, false);
            int __e = Exports.length;

            for (i = 1; i < __e; i++) {
                Fixups.AddFixup(Exports[i].Name + ".Address", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
                Linker.AddSectionDWord(0);
            }

            Symbols.AddSymbol("NAMES_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, Symbols.ENUM_SYMBOL_TYPE.ST_EXPORT, false);
            int __e2 = Exports.length;

            for (i = 1; i < __e2; i++) {
                Fixups.AddFixup("_" + Exports[i].Name, Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, 0);
                Linker.AddSectionDWord(0);
            }

            Symbols.AddSymbol("ORDINAL_TABLE", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, Symbols.ENUM_SYMBOL_TYPE.ST_EXPORT, false);
            int __e3 = Exports.length;

            for (i = 1; i < __e3; i++) {
                Linker.AddSectionWord(Exports[i].Ordinal - 1);
            }

            Symbols.AddSymbol("DLL_NAME", Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, Symbols.ENUM_SYMBOL_TYPE.ST_EXPORT, false);
            Linker.AddSectionBytes(Compiler.NameDLL.upper().getBytes());
            Linker.AddSectionByte(0);

            int __e5 = Exports.length;

            for (i = 1; i < __e5; i++) {
                Symbols.AddSymbol("_" + Exports[i].Name, Linker.OffsetOf(".edata"), Linker.ENUM_SECTION_TYPE.Export, Symbols.ENUM_SYMBOL_TYPE.ST_EXPORT, false);
                Linker.AddSectionBytes(Exports[i].Name.getBytes());
                Linker.AddSectionByte(0);
            }
        }
    };
};