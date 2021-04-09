
package Xisia {
    static class Linker
    {

        public enum ENUM_APP_TYPE
        {
            GUI = 2,
            CUI = 3
        };

        public enum ENUM_SECTION_TYPE
        {
            Data = 1,
            Code = 2,
            Import = 3,
            Export = 4,
            Resource = 5,
            Linker = 6,
            Relocate = 7
        };

        public enum ENUM_SECTION_CHARACTERISTICS
        {
            CH_CODE = 0x20,
            CH_INITIALIZED_DATA = 0x40,
            CH_UNINITIALIZED_DATA = 0x80,
            CH_MEM_DISCARDABLE = 0x2000000,
            CH_MEM_NOT_CHACHED = 0x4000000,
            CH_MEM_NOT_PAGED = 0x8000000,
            CH_MEM_SHARED = 0x10000000,
            CH_MEM_EXECUTE = 0x20000000,
            CH_MEM_READ = 0x40000000,
            CH_MEM_WRITE = ( 0x80000000)
        };


        public static class TYPE_SECTION
        {
            public String Name;
            public BytesBuffer Bytes = new BytesBuffer();
            public ENUM_SECTION_TYPE SectionType;
            public ENUM_SECTION_CHARACTERISTICS Characteristics;
            public static TYPE_SECTION CreateInstance() {
                TYPE_SECTION result = new TYPE_SECTION();
                result.Name = "";
                return result;
            }
        };

        public static ObjectArray<TYPE_SECTION> Section = new ObjectArray<TYPE_SECTION>();
        public static int SizeOfHeader = 0;
        public static ENUM_APP_TYPE AppType = (ENUM_APP_TYPE) 0;
        public static int SizeOfAllSectionsBefore = 0;
        public static int SizeOfAllSectionsBeforeRaw = 0;

        public static void InitLinker() {
            Resources.GenerateResources();
            Imports.GenerateImportTable(false);
            Exports.GenerateExportTable();

            if (Exports.IsDLL) {
                Exports.WriteRelocations();
            }

            OutputDOSHeader();
            OutputDOSStub();
            OutputPEHeader();
            OutputSectionTable();
            OutputSections();
        }

        public static void InitSections() {
            TYPE_SECTION s = Section.addOne();
            s.Name = ".link";
            s.SectionType = (ENUM_SECTION_TYPE) 0;
            s.Characteristics = (ENUM_SECTION_CHARACTERISTICS) 0;
        }


        public static void Link(String sFile, bool Run) {
            int i = 0;

            try {
                if (Exports.IsDLL) {
                    sFile = sFile.substring(0, Math.min(Strings.Len(sFile) - 3, sFile.length()));
                    sFile = sFile + "DLL";
                }

                XPlatform.deleteFile(sFile);
                FileOutputStream fos = new FileOutputStream(sFile);
                fos.write(Section[0].Bytes.getBuffer(), 1, Section[0].Bytes.length() - 1);
                fos.close();
                Summary.sFileToRun = sFile;
                System.out.println("build success :" + sFile);
            } catch(Exception e) {
                Summary.ErrMessage("build Error: can't write file :"  + sFile);
            }
        }

        public static void OutputDOSHeader() {
            OutputDWord(0x805A4D);
            OutputDWord(0x1);
            OutputDWord(0x100004);
            OutputDWord(0xFFFFFFFF);
            OutputDWord(0x140);
            OutputBytes(new byte[4]);
            OutputDWord(0x40);
            OutputBytes(new byte[32]);
            OutputDWord(0x80);
        }

        public static void OutputDOSStub() {
            OutputDWord(0xEBA1F0E);
            OutputDWord(( 0xCD09B400));
            OutputDWord(0x4C01B821);
            OutputDWord(0x687421CD);
            OutputDWord(0x70207369);
            OutputDWord(0x72676F72);
            OutputDWord(0x63206D61);
            OutputDWord(0x6F6E6E61);
            OutputDWord(0x65622074);
            OutputDWord(0x6E757220);
            OutputDWord(0x206E6920);
            OutputDWord(0x20534F44);
            OutputDWord(0x65646F6D);
            OutputDWord(0x240A0D2E);

            OutputBytes(new byte[8]);
        }

        public static void OutputPEHeader() {
            OutputDWord(0x4550); //Signature = "PE"
            OutputWord(0x14C); //Machine 0x014C;i386
            OutputWord(NumberOfSections()); //NumberOfSections = 4
            OutputBytes(new byte[12]);
            OutputWord(0xE0); //SizeOfOptionalHeader

            if (Exports.IsDLL) {
                OutputWord(0x210E); //Characteristics
            } else {
                OutputWord(0x818F); //Characteristics
            }

            OutputWord(0x10B); //Magic
            OutputByte(0x5); //MajorLinkerVersion
            OutputByte(0x0); //MinerLinkerVersion
            DeclareAttribute("SizeOfCode"); //SizeOfCode
            DeclareAttribute("SizeOfInitializedData"); //SizeOfInitializedData
            DeclareAttribute("SizeOfUnInitializedData"); //SizeOfUnInitializedData
            DeclareAttribute("AddressOfEntryPoint"); //AddressOfEntryPoint
            DeclareAttribute("BaseOfCode"); //BaseOfCode
            DeclareAttribute("BaseOfData"); //BaseOfData
            OutputDWord(0x400000); //ImageBase
            OutputDWord(0x1000); //SectionAlignment
            OutputDWord(0x200); //FileAlignment
            OutputWord(0x1); //MajorOSVersion
            OutputBytes(new byte[6]);
            OutputWord(0x4); //MajorSubSystemVerion
            OutputBytes(new byte[6]);
            DeclareAttribute("SizeOfImage"); //SizeOfImage
            DeclareAttribute("SizeOfHeaders"); //SizeOfHeaders
            OutputBytes(new byte[4]); //CheckSum
            OutputWord((int) AppType); //SubSystem = 2:GUI; 3:CUI
            OutputBytes(new byte[2]); //DllCharacteristics
            OutputDWord(0x10000); //SizeOfStackReserve
            OutputDWord(0x10000); //SizeOfStackCommit
            OutputDWord(0x10000); //SizeOfHeapReserve
            OutputBytes(new byte[8]); //SizeOfHeapRCommit
            OutputDWord(0x10); //NumberOfDataDirectories

            DeclareAttribute("ExportTable.Entry");
            DeclareAttribute("ExportTable.length");

            DeclareAttribute("ImportTable.Entry");
            DeclareAttribute("ImportTable.length");

            DeclareAttribute("ResourceTable.Entry");
            DeclareAttribute("ResourceTable.length");

            OutputBytes(new byte[16]); // Exception_Table + Certificate_Table

            DeclareAttribute("RelocationTable.Entry");
            DeclareAttribute("RelocationTable.length");

            OutputBytes(new byte[80]); // Debug_Data + Architecture + Global_PTR + TLS_Table + Load_Config_Table + BoundImportTable + ImportAddressTable + DelayImportDescriptor + COMplusRuntimeHeader + Reserved
        }

        public static void OutputSectionTable() {
            int i = 0;
            int ni = 0;

            for (i = 1; i < Section.length(); i++) {
                if (Section[i].Bytes.length() != 1) {
                    byte [] ndata = new byte[8];
                    byte [] _n = Section[i].Name.getBytes();
                    _system_.arrayCopy(_n, 0, ndata, 0, Math.min(ndata.length, _n.length));
                    OutputBytes(ndata);
                    DeclareAttribute(Section[i].Name + ".VirtualSize");
                    DeclareAttribute(Section[i].Name + ".VirtualAddress");
                    DeclareAttribute(Section[i].Name + ".lengthOfRawData");
                    DeclareAttribute(Section[i].Name + ".PointerToRawData");
                    DeclareAttribute(Section[i].Name + ".PointerToRelocations");
                    OutputBytes(new byte[8]); //PointerToLinenumbers + PointerToLinenumbers + NumberOfLinenumbers
                    OutputDWord((int) Section[i].Characteristics); //Characteristics
                }
            }

            int ii = 0;
            int HowBig = 0;

            SizeOfHeader = Section[0].Bytes.length() - 1;
            int __e3 = SizeOfHeader + 512;

            for (ii = 0; ii <= __e3; ii += 512) {
                HowBig = ii;
            }

            for (ii = SizeOfHeader; ii < HowBig; ii++) {
                AddSectionNameByte(".link", 0x0);
            }

            SizeOfHeader = Section[0].Bytes.length() - 1;
            FixAttribute("SizeOfHeaders", SizeOfHeader);
            SizeOfAllSectionsBeforeRaw = SizeOfHeader;
        }

        public static void FixTableEntry(int SectionID) {
            switch(Section[SectionID].SectionType) {
            case ENUM_SECTION_TYPE.Code :
                FixAttribute("AddressOfEntryPoint", SizeOfAllSectionsBefore);
                break;

            case ENUM_SECTION_TYPE.Import :
                FixAttribute("ImportTable.Entry", SizeOfAllSectionsBefore);
                break;

            case ENUM_SECTION_TYPE.Export :
                FixAttribute("ExportTable.Entry", SizeOfAllSectionsBefore);
                break;

            case ENUM_SECTION_TYPE.Resource :
                FixAttribute("ResourceTable.Entry", SizeOfAllSectionsBefore);
                break;

            case ENUM_SECTION_TYPE.Relocate :
                FixAttribute("RelocationTable.Entry", SizeOfAllSectionsBefore);
                break;
            }
        }

        public static void FixTableSize(int SectionID, int Size) {
            switch(Section[SectionID].SectionType) {
            case ENUM_SECTION_TYPE.Import :
                FixAttribute("ImportTable.length", Size);
                break;

            case ENUM_SECTION_TYPE.Export :
                FixAttribute("ExportTable.length", Size);
                break;

            case ENUM_SECTION_TYPE.Resource :
                FixAttribute("ResourceTable.length", Size);
                break;

            case ENUM_SECTION_TYPE.Relocate :
                FixAttribute("RelocationTable.length", Size);
                break;
            }
        }

        public static void OutputSections() {
            int i = 0;
            int ii = 0;
            int PhysicalSize = 0;

            SizeOfAllSectionsBefore = 0x1000;

            int __e = Section.length();

            for (i = 1; i < __e; i++) {

                int __e2 = 0;
                int __e3 = 0;

                if (Section[i].Bytes.length() != 1) {

                    FixAttribute(Section[i].Name + ".VirtualSize", Section[i].Bytes.length() - 1);

                    FixTableSize(i, Section[i].Bytes.length() - 1);

                    PhysicalSize = PhysicalSizeOf(Section[i].Bytes.length(), 0);

                    for (ii = Section[i].Bytes.length() - 1; ii < PhysicalSize; ii++) {
                        AddSectionNameByte(Section[i].Name, 0x0);
                    }

                    FixTableEntry(i);

                    if (Section[i].Name .equals( ".reloc")) {
                        FixAttribute(".code.PointerToRelocations", SizeOfAllSectionsBefore);
                    }

                    FixAttribute(Section[i].Name + ".VirtualAddress", SizeOfAllSectionsBefore);
                    SizeOfAllSectionsBefore += VirtualSizeOf(Section[i].Bytes.length(), 0);

                    FixAttribute(Section[i].Name + ".PointerToRawData", SizeOfAllSectionsBeforeRaw);
                    SizeOfAllSectionsBeforeRaw += PhysicalSize;

                    FixAttribute(Section[i].Name + ".lengthOfRawData", PhysicalSize);
                    AddSectionNameBytes(".link", Section[i].Bytes.getBuffer(), 1, Section[i].Bytes.length() - 1);

                    for (ii = 0; ii <= 0x1000 * 0xFFFF; ii += 0x1000) {
                        if (PhysicalSize == ii) {
                            SizeOfAllSectionsBefore -= 0x1000;
                        }
                    }
                }
            }

            FixAttribute("SizeOfImage", SizeOfAllSectionsBefore);
        }

        public static int PhysicalSizeOf(int bytesize, int ExtraSub) {
            int result = 0;
            int i = 0;

            if (bytesize == 1) {
                return 0;
            }

            int __e = bytesize + 512 - ExtraSub;

            for (i = 0; i < __e; i += 512) {
                result = i;
            }

            return result;
        }

        public static int VirtualSizeOf(int bytesize, int ExtraSub) {
            int result = 0;
            int i = 0;

            if (bytesize - 1 == 0) {
                result = 0;
            } else {

                for (i = 0x1000; i <= 0x1000 * 0xFFFF; i += 0x1000) {
                    if (i > (bytesize - 1 - ExtraSub)) {
                        result = i;
                        break;
                    }
                }
            }

            return result;
        }

        public static void DeclareAttribute(String Name) {
            Symbols.AddSymbol(Name, Section[0].Bytes.length() - 1, ENUM_SECTION_TYPE.Linker, Symbols.ENUM_SYMBOL_TYPE.ST_RVA, false);
            OutputDWord(0x0);
        }

        public static void FixAttribute(String Name, int Value) {
            FixDWord(Symbols.GetSymbolOffset(Name), Value);
        }

        public static int OffsetOf(String Name) {
            byte i = 0;
            int __e = Section.length();

            for (i = 1; i < __e; i++) {
                if (Section[i].Name.equals(Name)) {
                    return Section[i].Bytes.length() - 1;
                }
            }

            return 0;
        }

        public static Object FixDWord(int Offset, int Value) {
            Section[0].Bytes.set(Offset + 1, Mather.LoByte(Mather.LoWord(Value)));
            Section[0].Bytes.set(Offset + 2, Mather.HiByte(Mather.LoWord(Value)));
            Section[0].Bytes.set(Offset + 3, Mather.LoByte(Mather.HiWord(Value)));
            Section[0].Bytes.set(Offset + 4, Mather.HiByte(Mather.HiWord(Value)));
            return nilptr;
        }

        public static int NumberOfSections() {
            int result = 0;
            byte i = 0;
            int __e = Section.length();

            for (i = 1; i < __e; i++) {
                if (Section[i].Bytes.length() > 1) {
                    result++;
                }
            }

            return result;
        }

        public static bool SectionExists(String Name) {
            byte i = 0;
            int __e = Section.length() ;

            for (i = 1; i < __e; i++) {
                if (Section[i].Name.equals(Name)) {
                    return true;
                }
            }

            return false;
        }

        public static byte SectionID(String Name) {
            byte i = 0;
            int __e = Section.length();

            for (i = 1; i < __e; i++) {
                if (Section[i].Name.equals(Name)) {
                    return i;
                }
            }

            return 0;
        }
        public static void OutputBytes(byte []Value) {
            AddSectionNameBytes(".link", Value, 0, Value.length);
        }

        public static void OutputBytes(byte []Value, int pos, int len) {
            AddSectionNameBytes(".link", Value, pos, len);
        }

        public static void OutputByte(byte Value) {
            AddSectionNameByte(".link", Value);
        }

        public static void OutputWord(int Value) {
            AddSectionNameWord(".link", Value);
        }

        public static void OutputDWord(int Value) {
            AddSectionNameDWord(".link", Value);
        }

        public static void AddSectionBytes(byte [] Value, int pos, int len) {
            int lID = GetSectionIDByName(Syntax.CurrentSection);
            Section[lID].Bytes.add(Value, pos, len);
        }
        public static void AddSectionBytes(byte [] Value) {
            AddSectionBytes(Value, 0, Value.length);
        }
        public static void AddSectionByte(byte Value) {
            int lID = GetSectionIDByName(Syntax.CurrentSection);
            Section[lID].Bytes.add(Value);
        }

        public static void AddSectionWord(int Value) {
            AddSectionByte(Mather.LoByte(Value));
            AddSectionByte(Mather.HiByte(Value));
        }

        public static void AddSectionDWord(int Value) {
            AddSectionWord(Mather.LoWord(Value));
            AddSectionWord(Mather.HiWord(Value));
        }

        public static void AddSectionNameBytes(String Name, byte[] Value, int pos, int len) {
            int lID = GetSectionIDByName(Name);
            Section[lID].Bytes.add(Value, pos, len);
        }

        public static void AddSectionNameByte(String Name, byte Value) {
            int lID = GetSectionIDByName(Name);
            Section[lID].Bytes.add(Value);
        }

        public static void AddSectionNameWord(String Name, int Value) {
            AddSectionNameByte(Name, Mather.LoByte(Value));
            AddSectionNameByte(Name, Mather.HiByte(Value));
        }

        public static void AddSectionNameDWord(String Name, int Value) {
            AddSectionNameWord(Name, Mather.LoWord(Value));
            AddSectionNameWord(Name, Mather.HiWord(Value));
        }

        public static void AddSectionNameSingle(String Name, double Value) {
            long v = Math.doubleBitsToLong(Value);
            int iv = (((v >> 63) & 1) << 31) | ((( (v >> 51) & 0x7ff) & 0xff) << 22) | ((v & 0xfffffffffffffl) & 0x7FFFFFl);
            AddSectionNameByte(Name, iv & 0xff);
            AddSectionNameByte(Name, (iv >> 8) & 0xff);
            AddSectionNameByte(Name, (iv >> 16) & 0xff);
            AddSectionNameByte(Name, (iv >> 24) & 0xff);
        }

        public static int GetSectionIDByName(String Name) {
            byte i = 0;
            int __e = Section.length() - 1;

            for (i = 0; i <= __e; i++) {
                if (Section[i].Name.equals(Name)) {
                    return i;
                }
            }

            Summary.ErrMessage("section " + Name + "not found!");
            return 0;
        }
    };
};