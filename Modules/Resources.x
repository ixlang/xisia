
package Xisia {
    public static class Resources
    {

        public static class TYPE_RES_RESOURCE
        {
            public int Value;
            public String FileName;
            public String SymbolName;

            public static TYPE_RES_RESOURCE CreateInstance() {
                TYPE_RES_RESOURCE result = new TYPE_RES_RESOURCE();
                result.FileName = "";
                result.SymbolName = "";
                return result;
            }
        };


        public static class TYPE_RES_ITEM
        {
            public int Value;
            public TYPE_RES_RESOURCE[] RE;
        };


        public static class TYPE_RES_DIRECTORY
        {
            public int Value;
            public TYPE_RES_ITEM[] IT;
        };

        public static TYPE_RES_DIRECTORY[] D = nilptr;
        public static int lUniqueBMP = 0;

        public static void InitResources() {
            lUniqueBMP = 0;
            D = ObjectArraysHelper<TYPE_RES_DIRECTORY>.InitializeArray(1);
        }

        //--------------------------------------------------------------
        //Parsing And Adding Resources
        //--------------------------------------------------------------

        public static void DeclareBitmap() {

            lUniqueBMP++;
            String Ident = Parser.Identifier();
            Parser.Symbol(',');
            String sFile = Parser.StringExpression();
            Parser.Terminator();

            int i = FindDirIDByType(2);

            if (i == -1) {
                i = AddResourceDirectory(2);
            }

            AddResourceItem(i, lUniqueBMP);
            AddResourceResource(i, GetDirItemUBound(i), 2, sFile, Ident);

            Parser.CodeBlock();
        }

        public static int GetDirItemUBound(int DirID) {
            return D[DirID].IT.length - 1;
        }

        public static int FindDirIDByType(int DirType) {
            int i = 0;
            int __e = D.length - 1;

            for (i = 1; i <= __e; i++) {
                if (D[i].Value == DirType) {
                    return i;
                }
            }

            return -1;
        }

        public static int AddResourceDirectory(int Value) {
            D = ObjectArraysHelper<TYPE_RES_DIRECTORY>.RedimPreserve(D, new TYPE_RES_DIRECTORY[D.length + 1]);
            D[D.length - 1].Value = Value;
            D[D.length - 1].IT = ObjectArraysHelper<TYPE_RES_ITEM>.InitializeArray(1);
            return D.length - 1;
        }

        public static void AddResourceItem(int DirID, int Value) {
            D[DirID].IT = ObjectArraysHelper<TYPE_RES_ITEM>.RedimPreserve(D[DirID].IT, new TYPE_RES_ITEM[D[DirID].IT.length + 1]);
            D[DirID].IT[D[DirID].IT.length - 1].Value = Value;
            D[DirID].IT[D[DirID].IT.length - 1].RE = ObjectArraysHelper<TYPE_RES_RESOURCE>.InitializeArray(1);
        }

        public static void AddResourceResource(int DirID, int ItemID, int Value, String FileName, String SymbolName) {
            D[DirID].IT[ItemID].RE = ArraysHelper<TYPE_RES_RESOURCE>.RedimPreserve(D[DirID].IT[ItemID].RE, new TYPE_RES_RESOURCE[D[DirID].IT[ItemID].RE.length + 1]);
            D[DirID].IT[ItemID].RE[D[DirID].IT[ItemID].RE.length - 1].Value = Value;
            D[DirID].IT[ItemID].RE[D[DirID].IT[ItemID].RE.length - 1].FileName = FileName;
            D[DirID].IT[ItemID].RE[D[DirID].IT[ItemID].RE.length - 1].SymbolName = SymbolName;
        }

        //--------------------------------------------------------------
        //Generate
        //--------------------------------------------------------------

        public static void AddResSymbol(String Name) {
            Symbols.AddSymbol(Name, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, Symbols.ENUM_SYMBOL_TYPE.ST_LABEL, false);
        }

        public static void AddResResource(String Name) {
            Linker.AddSectionDWord(0);
            Fixups.AddFixup(Name, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, Linker.OffsetOf(".rsrc") + 4);
            Linker.AddSectionDWord(0);
        }

        public static void AddResSubDirectory(String Name, int DirType) {
            Linker.AddSectionDWord(DirType);
            Fixups.AddFixup(Name, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, ((int) 0x80000000) + Linker.OffsetOf(".rsrc") + 4);
            Linker.AddSectionDWord(0);
        }

        public static void GenerateResources() {
            int i = 0;
            int ii = 0;
            int iii = 0;

            if (D.length - 1 == 0) {
                return;
            }

            Syntax.CurrentSection = ".rsrc";
            AddResSymbol("resource_root");
            Linker.AddSectionDWord(0);
            Linker.AddSectionDWord(0);
            Linker.AddSectionDWord(0);
            Linker.AddSectionWord(0);
            Linker.AddSectionWord(D.length - 1);

            int __e = D.length - 1;

            for (i = 1; i <= __e; i++) {
                AddResSubDirectory("Directory_" + i, D[i].Value);
            }

            int __e2 = D.length - 1;

            for (i = 1; i <= __e2; i++) {
                AddResSymbol("Directory_" + i);
                Linker.AddSectionDWord(0);
                Linker.AddSectionDWord(0);
                Linker.AddSectionDWord(0);
                Linker.AddSectionWord(0);
                Linker.AddSectionWord(D[i].IT.length - 1);
                int __e3 = D[i].IT.length - 1;

                for (ii = 1; ii <= __e3; ii++) {
                    AddResSubDirectory("ID_" + ii, D[i].IT[ii].Value);
                }
            }

            int __e4 = D.length - 1;

            for (i = 1; i <= __e4; i++) {
                int __e5 = D[i].IT.length - 1;

                for (ii = 1; ii <= __e5; ii++) {
                    AddResSymbol("ID_" + ii);
                    Linker.AddSectionDWord(0);
                    Linker.AddSectionDWord(0);
                    Linker.AddSectionDWord(0);
                    Linker.AddSectionWord(0);
                    Linker.AddSectionWord(D[i].IT[ii].RE.length - 1);
                    int __e6 = D[i].IT[ii].RE.length - 1;

                    for (iii = 1; iii <= __e6; iii++) {
                        AddResResource("ID_" + ii + "_resource_" + iii);
                    }
                }
            }

            int __e7 = D.length - 1;

            for (i = 1; i <= __e7; i++) {
                int __e8 = D[i].IT.length - 1;

                for (ii = 1; ii <= __e8; ii++) {
                    int __e9 = D[i].IT[ii].RE.length - 1;

                    for (iii = 1; iii <= __e9; iii++) {
                        if (D[i].IT[ii].RE[iii].FileName.startsWith("\\")) {
                            D[i].IT[ii].RE[iii].FileName = "FileName" + D[i].IT[ii].RE[iii].FileName;
                        }

                        AddResSymbol("ID_" + ii + "_resource_" + iii);
                        ChooseResource(i, ii, iii);
                    }
                }
            }

            int __e10 = D.length - 1;

            for (i = 1; i <= __e10; i++) {
                int __e11 = D[i].IT.length - 1;

                for (ii = 1; ii <= __e11; ii++) {
                    int __e12 = D[i].IT[ii].RE.length - 1;

                    for (iii = 1; iii <= __e12; iii++) {
                        if (Symbols.SymbolExists(D[i].IT[ii].RE[iii].SymbolName)) {
                            Summary.ErrMessage("resource '" + D[i].IT[ii].RE[iii].SymbolName + "' already exists!");
                            return;
                        }

                        WriteResource(i, ii, iii);
                    }
                }
            }

        }

        public static void ChooseResource(int DirID, int ItemID, int ResID) {
            int lSize = 0;

            switch(D[DirID].IT[ItemID].RE[ResID].Value) {
            case 2 :
                Fixups.AddFixup(D[DirID].IT[ItemID].RE[ResID].SymbolName, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, 0);
                Linker.AddSectionDWord(0);
                Linker.AddSectionDWord((int) (XPlatform.SystemFileSize((D[DirID].IT[ItemID].RE[ResID].FileName)) - 0xE));
                Linker.AddSectionDWord(0);
                Linker.AddSectionDWord(0);
                break;

            case 5 :

                break;

            case 3 :
                //caution
                lSize = DWordFromFile(D[DirID].IT[ItemID].RE[ResID].FileName, 14);
                Fixups.AddFixup(D[DirID].IT[ItemID].RE[ResID].SymbolName, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, 0);
                Compiler.AddResourceDWord(0);
                Compiler.AddResourceDWord(lSize);
                Compiler.AddResourceDWord(0);
                Compiler.AddResourceDWord(0);
                break;

            default:
                break;
            }
        }

        public static byte [] readData(String file, int start) {
            try {
                FileInputStream fis = new FileInputStream(file);
                fis.seek(Stream.SeekBegin, start);
                byte [] data = fis.read();
                fis.close();
                return data;
            } catch(Exception e) {

            }

            return nilptr;
        }
        public static void WriteResource(int DirID, int ItemID, int ResID) {
            int i = 0;
            byte filec = 0;
            int lPos = 0;
            int lSize = 0;

            switch(D[DirID].IT[ItemID].RE[ResID].Value) {
            case 2 :
                Symbols.AddSymbol(D[DirID].IT[ItemID].RE[ResID].SymbolName, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, Symbols.ENUM_SYMBOL_TYPE.ST_RESOURCE, false);
                byte [] data = readData(D[DirID].IT[ItemID].RE[ResID].FileName, 0xE + 1);

                if (data == nilptr) {
                    Summary.pError = true;
                    Summary.ErrMessage("can't read file :" + D[DirID].IT[ItemID].RE[ResID].FileName);
                    return ;
                }

                for (i = 0; i < data.length; i++) {
                    Linker.AddSectionByte(data[i]);
                }

                //ResAlign
                break;

            case 3 :
                lPos = DWordFromFile(D[DirID].IT[ItemID].RE[ResID].FileName, 18);
                lSize = DWordFromFile(D[DirID].IT[ItemID].RE[ResID].FileName, 14);
                Symbols.AddSymbol(D[DirID].IT[ItemID].RE[ResID].SymbolName, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, Symbols.ENUM_SYMBOL_TYPE.ST_RESOURCE, false);

                byte [] data = readData(D[DirID].IT[ItemID].RE[ResID].FileName, 0xE + 1);
                int __e = lPos + lSize - 1;

                for (i = lPos; i <= __e; i++) {
                    Linker.AddSectionByte(data[i - lPos]);
                }

                break;

            case 14 :
                Fixups.AddFixup("$" + ItemID + "_header_" + ResID, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, 0);
                Compiler.AddResourceDWord(6 + (1 * 14));
                Compiler.AddResourceDWord(0);
                Compiler.AddResourceDWord(0);
                Symbols.AddSymbol("$" + ItemID + "_header_" + ResID, Linker.OffsetOf(".rsrc"), Linker.ENUM_SECTION_TYPE.Resource, Symbols.ENUM_SYMBOL_TYPE.ST_RESOURCE, false);
                Compiler.AddResourceWord(0);
                Compiler.AddResourceWord(1);
                Compiler.AddResourceWord(Mather.LoWord(1));

                byte [] data = readData(D[DirID].IT[ItemID].RE[ResID].FileName, 0xE + 1);
                int __e = 16 + 22 - 1;

                for (i = lPos; i <= __e; i++) {
                    Linker.AddSectionByte(data[i - lPos]);
                }

                break;

            default:
                break;
            }
        }

        public static int DWordFromFile(String sFileName, int lPosition) {
            int lTmp = 0;
            FileInputStream fis =  new FileInputStream(sFileName);
            fis.seek(Stream.SeekBegin, lPosition + 1);
            lTmp = fis.readIntLE();
            fis.close();
            return lTmp;
        }
    };
};