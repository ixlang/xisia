package Xisia {
    static class Fixups
    {
        public static class  TYPE_FIXUP
        {
            public String Name = "";
            public int Offset;
            public int Value;
            public int ExtraAdd;
            public Linker.ENUM_SECTION_TYPE Section;
            public bool Deleted;
            public  TYPE_FIXUP(String) {}
            public  TYPE_FIXUP() {}
            public static TYPE_FIXUP CreateInstance() {
                TYPE_FIXUP result = new TYPE_FIXUP();
                result.Name = "";
                return result;
            }
        };

        public static ObjectArray<TYPE_FIXUP>Fixups = new ObjectArray<TYPE_FIXUP>();

        public static void InitFixups() {
            Fixups.addOne();
        }

        public static void AddCodeFixup(String Name) {
            AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Compiler.AddCodeDWord(0);
        }

        public static void DeleteFixup(String Name) {
            int i = 0;
            int __e = Fixups.length() - 1;

            for (i = 0; i <= __e; i++) {
                if (Fixups[i].Name.equals(Name)) {
                    Fixups[i].Deleted = true;
                    return;
                }
            }
        }

        public static void AddFixup(String Name, int Offset, Linker.ENUM_SECTION_TYPE Section, int ExtraAdd) {
            TYPE_FIXUP f = Fixups.addOne();
            f.Name = Name;
            f.Offset = Offset;
            f.Section = Section;
            f.ExtraAdd = ExtraAdd;
        }

        static Object LinkerFix(int Offset, int Value) {
            Linker.Section[0].Bytes.set(Offset + 1, Mather.LoByte(Mather.LoWord(Value)));
            Linker.Section[0].Bytes.set(Offset + 2, Mather.HiByte(Mather.LoWord(Value)));
            Linker.Section[0].Bytes.set(Offset + 3, Mather.LoByte(Mather.HiWord(Value)));
            Linker.Section[0].Bytes.set(Offset + 4, Mather.HiByte(Mather.HiWord(Value)));
            return nilptr;
        }

        public static int PhysicalAddressOf(Linker.ENUM_SECTION_TYPE EST) {
            int result = 0;
            byte i = 0;
            result = Linker.SizeOfHeader;
            int __e = Linker.Section.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Linker.Section[i].SectionType == EST) {
                    return result;
                }

                result += Linker.PhysicalSizeOf(Linker.Section[i].Bytes.length(), 1);
            }

            return result;
        }

        public static int VirtualAddressOf(Linker.ENUM_SECTION_TYPE EST) {
            int result = 0;
            byte i = 0;
            result = 0x1000;
            int __e = Linker.Section.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (Linker.Section[i].SectionType == EST) {
                    return result;
                }

                result += Linker.VirtualSizeOf(Linker.Section[i].Bytes.length(), 1);
            }

            return result;
        }

        public static void DoFixups() {
            int i = 0;
            int ii = 0;
            bool Found = false;

            int __e = Fixups.length() - 1;

            for (i = 1; i <= __e; i++) {
                if (!Fixups[i].Deleted) {
                    int __e2 = Symbols.Symbols.length() - 1;

                    for (ii = 1; ii <= __e2; ii++) {
                        if (!Symbols.Symbols[ii].IsProto) {
                            if (Fixups[i].Name .equals( Symbols.Symbols[ii].Name)) {
                                if (Symbols.Symbols[ii].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_LABEL || Symbols.Symbols[ii].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_DWORD || Symbols.Symbols[ii].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_FLOAT || Symbols.Symbols[ii].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_LOCAL_STRING || Symbols.Symbols[ii].SymType == Symbols.ENUM_SYMBOL_TYPE.ST_FRAME) {
                                    LinkerFix(PhysicalAddressOf(Fixups[i].Section) + Fixups[i].Offset, Symbols.Symbols[ii].Offset - Fixups[i].Offset - 4 + Fixups[i].ExtraAdd);

                                } else {
                                    LinkerFix(PhysicalAddressOf(Fixups[i].Section) + Fixups[i].Offset, VirtualAddressOf(Symbols.Symbols[ii].Section) + Symbols.Symbols[ii].Offset + Fixups[i].ExtraAdd);
                                }

                                Found = true;
                                break;
                            }
                        }
                    }

                    if (!Found) {
                        if ((Fixups[i].Name.indexOf(".HeapHandle") + 1) != 0) {
                            Summary.ErrMessage("'" + Fixups[i].Name.substring(0, Math.min(Fixups[i].Name.indexOf('.'), Fixups[i].Name.length())) + "' is not an array.");
                            return;
                        } else
                            if ((Fixups[i].Name.indexOf(".PtrToArray") + 1) != 0) {
                                Summary.ErrMessage("'" + Fixups[i].Name.substring(0, Math.min(Fixups[i].Name.indexOf('.'), Fixups[i].Name.length())) + "' is not an array.");
                                return;
                            } else
                                if ((Fixups[i].Name.indexOf("AddressToString") + 1) != 0) {
                                    Summary.ErrMessage("cannot compare String with value");
                                    return;
                                } else {
                                    Summary.ErrMessage("symbol '" + Fixups[i].Name + "' doesn't exist. ");
                                    return;
                                }
                    }

                    Found = false;

                    if (!Compiler.IsCmdCompile) {
                        //ReflectionHelper.LetMember(ReflectionHelper.GetMember(frmMain.DefInstance, "Panels"), "Caption", "Fixups.. (" + (int)(i / ((double) Fixups.length - 1) * 100) + "% done..)");
                    }
                }
            }
        }
    };
};