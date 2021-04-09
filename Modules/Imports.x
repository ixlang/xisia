package Xisia {
    static class Imports
    {

        public static class TYPE_IMPORT
        {
            public String Name = "";
            public String Alias = "";
            public String Library = "";
            public int pCount;
            public bool Used;
            public  TYPE_IMPORT(String) {}
            public  TYPE_IMPORT() {}
            public static TYPE_IMPORT CreateInstance() {
                TYPE_IMPORT result = new TYPE_IMPORT();
                return result;
            }

            public void load(FileInputStream fis) {
                Name = Strings.readString(fis);
                Alias = Strings.readString(fis);
                Library = Strings.readString(fis);
                pCount = fis.readIntLE();
                fis.readShort();
            }

            public void write(FileOutputStream fis) {
                Strings.writeString(fis, Name);
                Strings.writeString(fis, Alias);
                Strings.writeString(fis, Library);
                fis.writeInt(pCount);
                fis.writeShort(0);
            }
        };

        public static TYPE_IMPORT[] Imports = nilptr;

        public static void InitImports() {
            Imports = ArraysHelper<TYPE_IMPORT>.InitializeArray(1);
        }

        static bool IsImportUsed(int AliasID) {
            return Imports[AliasID].Used;
        }

        static bool ImportExists(String Name) {
            int i = 0;
            int __e = Imports.length - 1;

            for (i = 0; i <= __e; i++) {
                if (Imports[i].Name.equals(Name)) {
                    return true;
                }
            }

            return false;
        }

        public static void AddImport(String Name, String Library, int pCount, String Alias, bool Used) {
            if (ImportExists(Name)) {
                return;
            }

            Imports = ArraysHelper<TYPE_IMPORT>.RedimPreserve(Imports, new TYPE_IMPORT[Imports.length + 1]);
            Imports[Imports.length - 1].Name = Name;
            Imports[Imports.length - 1].pCount = pCount;
            Imports[Imports.length - 1].Library = Library;
            Imports[Imports.length - 1].Used = Used;

            if (Alias .length() != 0) {
                Imports[Imports.length - 1].Alias = Alias;
            } else {
                Imports[Imports.length - 1].Alias = Name;
            }

        }

        public static Object SetImportUsed(String Name, int Offset) {
            int i = 0;
            int __e = Imports.length - 1;

            for (i = 1; i <= __e; i++) {
                if (Imports[i].Alias.equals(Name)) {
                    Imports[i].Used = true;
                    Exports.AddRelocation(Offset);
                    return nilptr;
                }
            }

            return nilptr;
        }

        public static int ImportPCountByName(String Name) {
            int i = 0;
            int __e = Imports.length - 1;

            for (i = 1; i <= __e; i++) {
                if (Imports[i].Alias.equals(Name)) {
                    return Imports[i].pCount;
                }
            }

            return 0;
        }

        public static bool IsImport(String Ident) {
            int i = 0;
            int __e = Imports.length - 1;

            for (i = 1; i <= __e; i++) {
                if (Imports[i].Alias.equals(Ident)) {
                    return true;
                }
            }

            return false;
        }

        public static void GenerateImportTable(bool NoSymbols) {
            int i = 0;
            int ii = 0;
            bool Duplicate = false;
            String[] Libraries = {""};

            Syntax.CurrentSection = ".idata";


            if (Imports.length - 1 == 0) {
                return;
            }

            int __e = Imports.length - 1;

            for (i = 1; i <= __e; i++) {
                bool exitfor = false;

                while (!IsImportUsed(i)) {
                    i++;

                    if (i > Imports.length - 1) {
                        exitfor = true;
                        break;
                    }
                }

                if (exitfor) {
                    break;
                }

                int __e2 = Libraries.length - 1;

                for (ii = 1; ii <= __e2; ii++) {
                    if (Libraries[ii].equalsIgnoreCase(Imports[i].Library)) {
                        Duplicate = true;
                    }
                }

                if (!Duplicate) {
                    Libraries = StringArraysHelper.RedimPreserve(Libraries, new String[Libraries.length + 1]);
                    Libraries[Libraries.length - 1] = Imports[i].Library.upper();
                }

                Duplicate = false;

            }

            int __e3 = Libraries.length - 1;

            for (i = 1; i <= __e3; i++) {
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
                Fixups.AddFixup(Libraries[i] + "_NAME", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, 0);
                Linker.AddSectionDWord(0x0);
                Fixups.AddFixup(Libraries[i] + "_TABLE", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, 0);
                Linker.AddSectionDWord(0x0);
            }

            if (Libraries.length - 1 > 0) {
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
                Linker.AddSectionDWord(0x0);
            }

            int __e4 = Libraries.length - 1;

            for (i = 1; i <= __e4; i++) {
                Symbols.AddSymbol(Libraries[i] + "_TABLE", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, Symbols.ENUM_SYMBOL_TYPE.ST_RVA, false);
                int __e5 = Imports.length - 1;

                for (ii = 1; ii <= __e5; ii++) {
                    if (Imports[ii].Library.equalsIgnoreCase(Libraries[i])) {
                        if (Imports[ii].Used) {
                            Symbols.AddSymbol(Imports[ii].Alias, Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, Symbols.ENUM_SYMBOL_TYPE.ST_IMPORT, false);
                            Fixups.AddFixup(Imports[ii].Name + "_ENTRY", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, 0);
                            Linker.AddSectionDWord(0x0);
                        }
                    }
                }

                Linker.AddSectionDWord(0x0);
            }

            int __e6 = Libraries.length - 1;

            for (i = 1; i <= __e6; i++) {
                Symbols.AddSymbol(Libraries[i] + "_NAME", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, Symbols.ENUM_SYMBOL_TYPE.ST_RVA, false);
                Linker.AddSectionBytes(Libraries[i].upper().getBytes());
                Linker.AddSectionByte(0);
            }

            int __e8 = Imports.length - 1;

            for (i = 1; i <= __e8; i++) {
                if (Imports[i].Used) {
                    Symbols.AddSymbol(Imports[i].Name + "_ENTRY", Linker.OffsetOf(".idata"), Linker.ENUM_SECTION_TYPE.Import, Symbols.ENUM_SYMBOL_TYPE.ST_RVA, false);
                    Linker.AddSectionWord(0);
                    Linker.AddSectionBytes(Imports[i].Name.getBytes());
                    Linker.AddSectionByte(0);
                }
            }

        }

        public static void ImportLibrary() {
            int i = 0;
            int lIID = 0;
            int NumberOfItems = 0;

            //On Error GoTo InvalidLibrary

            Parser.SkipBlank();
            String Ident = Parser.StringExpression();

            FileInputStream fis = new FileInputStream(_system_.getAppDirectory().appendPath("include").appendPath(Ident));
            NumberOfItems = fis.readIntLE();

            Imports = ArraysHelper<Imports.TYPE_IMPORT>.RedimPreserve(Imports, new TYPE_IMPORT[Imports.length + NumberOfItems ]);
            int __e = NumberOfItems;

            for (i = 1; i <= __e; i++) {
                //UPGRADE_WARNING: (2080) Get was upgraded to FileGet and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
                Imports[Imports.length - 1 - NumberOfItems + i].load(fis);
                Imports[Imports.length - 1 - NumberOfItems + i].Used = false;
            }

            //UPGRADE_WARNING: (2080) Get was upgraded to FileGet and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
            NumberOfItems = fis.readIntLE();
            Types.Types.addSome(NumberOfItems);

            int __e2 = NumberOfItems;

            for (i = 1; i <= __e2; i++) {
                //UPGRADE_WARNING: (2080) Get was upgraded to FileGet and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
                Types.Types[Types.Types.length() - 1 - NumberOfItems + i].load(fis);
            }

            //UPGRADE_WARNING: (2080) Get was upgraded to FileGet and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
            NumberOfItems = fis.readIntLE();
            Symbols.Constants = ArraysHelper<Symbols.TYPE_CONSTANT>.RedimPreserve(Symbols.Constants, new Symbols.TYPE_CONSTANT[Symbols.Constants.length + NumberOfItems]);
            int __e3 = NumberOfItems;

            for (i = 1; i <= __e3; i++) {
                //UPGRADE_WARNING: (2080) Get was upgraded to FileGet and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
                Symbols.Constants[Symbols.Constants.length - 1 - NumberOfItems + i].load(fis);
            }

            fis.close();

            if (Parser.IsSymbol(',')) {
                Parser.Symbol(',');
                ImportLibrary();
                return;
            }

            Parser.Terminator();
            Parser.CodeBlock();
            return;

            Summary.ErrMessage("Invalid Library Format => " + Ident);
            fis.close();
        }

        public static void ExportLibrary() {
            int i = 0;
            Summary.InfMessage("Building Library..");
            String sFileName =  "FileName";
            sFileName = sFileName.substring(0, Math.min(Strings.Len(sFileName) - 4, sFileName.length()));
            sFileName = sFileName + ".lib";
            FileOutputStream fos = new FileOutputStream(sFileName);



            //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
            fos.writeInt(Imports.length - 1);
            int __e = Imports.length - 1;

            for (i = 1; i <= __e; i++) {
                //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
                Imports[i].write(fos);
            }

            //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
            fos.writeInt(Types.Types.length() - 1);
            int __e2 = Types.Types.length() - 1;

            for (i = 1; i <= __e2; i++) {
                //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080

                Types.Types[i].write(fos);
            }

            //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
            fos.writeInt(Symbols.Constants.length - 1);
            int __e3 = Symbols.Constants.length - 1;

            for (i = 1; i <= __e3; i++) {
                //UPGRADE_WARNING: (2080) Put was upgraded to FilePutObject and has a new behavior. More Information: https://docs.mobilize.net/vbuc/ewis#2080
                Symbols.Constants[i].write(fos);
            }

            fos.close();

            Summary.InfMessage("library compiled. => " + sFileName);
        }
    };
};