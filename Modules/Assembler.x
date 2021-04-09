package Xisia {
    static class comAssembler
    {
        public static void PopEAX() {
            if (!Optimizer.OptimizeAble("PopEAX", "")) {
                Compiler.AddCodeByte(0x58);
            }
        }

        public static void PopEBX() {
            Compiler.AddCodeByte(0x5B);
        }

        public static void PopECX() {
            Compiler.AddCodeByte(0x59);
        }

        public static void PopEDX() {
            Compiler.AddCodeByte(0x5A);
        }

        public static void PushEAX() {
            Compiler.AddCodeByte(0x50);
        }

        public static void PushECX() {
            Compiler.AddCodeByte(0x51);
        }

        public static void DecECX() {
            Compiler.AddCodeByte(0x49);
        }

        public static void IncECX() {
            Compiler.AddCodeByte(0x41);
        }

        public static void StoreECX() {
            //mov [variable],ecx
            Compiler.AddCodeWord(0xD89);
            Fixups.AddCodeFixup("$Intern.Loop");
        }

        public static void RestoreECX() {
            //mov ecx,[variable]
            Compiler.AddCodeWord(0xD8B);
            Fixups.AddCodeFixup("$Intern.Loop");
        }

        public static void Push(int Value ) {
            //push dword Value
            Compiler.AddCodeByte(0x68);
            Compiler.AddCodeDWord(Value);
        }

        public static void PushF(double Value ) {
            //push dword Value
            Compiler.AddCodeByte(0x68);
            Compiler.AddCodeSingle(Value);
        }

        public static void PushContent(String Variable) {
            //push [Variable]
            Compiler.AddCodeWord(0x35FF);
            Fixups.AddFixup(Variable, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Exports.AddRelocation(Linker.OffsetOf(".code"));
            Compiler.AddCodeDWord(0x0);
        }

        public static void PushAddress(String Variable) {
            //push Variable
            Compiler.AddCodeByte(0x68);
            Fixups.AddFixup(Variable, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Exports.AddRelocation(Linker.OffsetOf(".code"));
            Compiler.AddCodeDWord(0x0);
        }

        public static void PushdoubleEAX() {
            DataManager.fUniqueID++;
            DataManager.DeclareDataSingle("$double" + DataManager.fUniqueID, 0);
            AssignEAX("$double" + DataManager.fUniqueID);
            PushdoubleContent("$double" + DataManager.fUniqueID);
        }

        public static void PushdoubleEDX() {
            DataManager.fUniqueID++;
            DataManager.DeclareDataSingle("$double" + DataManager.fUniqueID, 0);
            AssignEDX("$double" + DataManager.fUniqueID);
            PushdoubleContent("$double" + DataManager.fUniqueID);
        }

        public static void Pushdouble(double Value) {
            DataManager.fUniqueID++;
            DataManager.DeclareDataSingle("$double" + DataManager.fUniqueID, Value);
            PushdoubleContent("$double" + DataManager.fUniqueID);
        }

        public static void PushdoubleContent(String Name) {
            Compiler.AddCodeWord(0x5D9);
            Fixups.AddCodeFixup(Name);
        }

        public static void Invoke() {
            Compiler.AddCodeWord(0x15FF);
        }

        public static void InvokeByName(String Name) {
            Invoke();
            Imports.SetImportUsed(Name, Linker.OffsetOf(".code"));
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprAdd() {
            PopEDX();
            PopEAX();
            //add eax,edx
            Compiler.AddCodeWord(0xD001);
        }

        public static void ExprdoubleAdd() {
            PopEDX();
            PopEAX();
            PushdoubleEAX();
            PushdoubleEDX();
            //faddp
            Compiler.AddCodeWord(0xC1DE);
            //fstp variable
            Compiler.AddCodeWord(0x1DD9);
            Fixups.AddCodeFixup("$Intern.double");
            MovEAX("$Intern.double");
        }

        public static void ExprdoubleSub() {
            PopEDX();
            PopEAX();
            PushdoubleEAX();
            PushdoubleEDX();
            //fsubp
            Compiler.AddCodeWord(0xE9DE);
            //fstp variable
            Compiler.AddCodeWord(0x1DD9);
            Fixups.AddCodeFixup("$Intern.double");
            MovEAX("$Intern.double");
        }

        public static void ExprdoubleMul() {
            PopEDX();
            PopEAX();
            PushdoubleEAX();
            PushdoubleEDX();
            //fmulp
            Compiler.AddCodeWord(0xC9DE);
            //fstp variable
            Compiler.AddCodeWord(0x1DD9);
            Fixups.AddCodeFixup("$Intern.double");
            MovEAX("$Intern.double");
        }

        public static void ExprdoubleDiv() {
            PopEDX();
            PopEAX();
            PushdoubleEAX();
            PushdoubleEDX();
            //fdivp
            Compiler.AddCodeWord(0xF9DE);
            //fstp variable
            Compiler.AddCodeWord(0x1DD9);
            Fixups.AddCodeFixup("$Intern.double");
            MovEAX("$Intern.double");
        }

        public static void ExprdoubleMod() {
            PopEDX();
            PopEAX();
            PushdoubleEAX();
            PushdoubleEDX();
            //fprem
            Compiler.AddCodeWord(0xF8D9);
            //fstp variable
            Compiler.AddCodeWord(0x1DD9);
            Fixups.AddCodeFixup("$Intern.double");
            MovEAX("$Intern.double");
        }

        public static void ExprSub() {
            PopEDX();
            PopEAX();
            //sub eax,edx
            Compiler.AddCodeWord(0xD029);
        }

        public static void ExprDiv() {
            PopEDX();
            PopEAX();
            //mov ebx,edx
            Compiler.AddCodeWord(0xD389);
            //mov edx,0
            Compiler.AddCodeByte(0xBA);
            Compiler.AddCodeDWord(0x0);
            //idiv ebx
            Compiler.AddCodeWord(0xFBF7);
        }

        public static void ExprMul() {
            PopEDX();
            PopEAX();
            //mov ebx,edx
            Compiler.AddCodeWord(0xD389);
            //mul ebx
            Compiler.AddCodeWord(0xE3F7);
        }

        public static void ExprMod() {
            PopEDX();
            PopEAX();
            //mov ebx,edx
            Compiler.AddCodeWord(0xD389);
            //mov edx,0
            Compiler.AddCodeByte(0xBA);
            Compiler.AddCodeDWord(0x0);
            //idiv ebx
            Compiler.AddCodeWord(0xFBF7);
            //mov eax,edx
            Compiler.AddCodeWord(0xC28B);
        }

        public static void ExprShl() {
            PopECX();
            PopEAX();
            //shl eax,cl
            Compiler.AddCodeWord(0xE0D3);
        }

        public static void ExprShr() {
            PopECX();
            PopEAX();
            //shl eax,cl
            Compiler.AddCodeWord(0xE8D3);
        }

        public static void ExprAnd() {
            PopEBX();
            PopEAX();
            //and eax,ebx
            Compiler.AddCodeWord(0xC323);
        }

        public static void ExprOr() {
            PopEBX();
            PopEAX();
            //or eax,ebx
            Compiler.AddCodeWord(0xC30B);
        }

        public static void ExprXor() {
            PopEBX();
            PopEAX();
            //xor eax,ebx
            Compiler.AddCodeWord(0xC333);
        }

        public static void ExprNeg() {
            Compiler.AddCodeWord(0xD8F7);
        }

        public static void ExprNot() {
            Compiler.AddCodeWord(0xD0F7);
        }

        public static void MovEAX(String Name) {
            //mov eax,[name]
            Compiler.AddCodeByte(0xA1);
            Fixups.AddCodeFixup(Name);
        }

        public static void MovEAXAddress(String Name) {
            //mov eax,name
            Compiler.AddCodeByte(0xB8);
            Fixups.AddCodeFixup(Name);
        }

        public static void MovEDX(String Name) {
            //mov edx,[name]
            Compiler.AddCodeWord(0x158B);
            Fixups.AddCodeFixup(Name);
        }

        public static void ExprCompare(String Variable, String Variable2) {
            if ((Expressions.CompareOne .equals("") == false) && Expressions.CompareTwo .equals("")) {
                MovEAX(Expressions.CompareOne);
                MovEDX(Variable2);
            } else
                if (Expressions.CompareOne .equals("") && (Expressions.CompareTwo .equals("") == false)) {
                    MovEAX(Variable);
                    MovEDX(Expressions.CompareTwo);
                } else
                    if ((Expressions.CompareOne .equals("") == false) && (Expressions.CompareTwo .equals("") == false)) {
                        MovEAX(Expressions.CompareOne);
                        MovEDX(Expressions.CompareTwo);
                    } else {
                        MovEAX(Variable);
                        MovEDX(Variable2);
                    }

            //cmp eax,edx
            Compiler.AddCodeWord(0xD039);
            Expressions.CompareOne = "";
            Expressions.CompareTwo = "";
        }

        public static void ExprCompareS(String Variable, String Variable2) {
            PushContent(Variable2);
            PushContent(Variable);
            InvokeByName("lstrcmp");
            //cmp eax,0
            Compiler.AddCodeByte(0x3D);
            Compiler.AddCodeDWord(0x0);
        }

        public static void AssignEAX(String Variable) {
            //mov [variable],eax
            Compiler.AddCodeByte(0xA3);
            Fixups.AddFixup(Variable, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Compiler.AddCodeDWord(0);
        }

        public static void AssignEDX(String Variable) {
            //mov [variable],edx
            Compiler.AddCodeWord(0x1589);
            Fixups.AddFixup(Variable, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0x400000);
            Compiler.AddCodeDWord(0);
        }

        public static void ExprJE(String Name) {
            Compiler.AddCodeWord(0x840F);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJNE(String Name) {
            Compiler.AddCodeWord(0x850F);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJL(String Name) {
            Compiler.AddCodeWord(0x8C0F);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJLE(String Name) {
            Compiler.AddCodeByte(0xF);
            Compiler.AddCodeByte(0x8E);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJA(String Name) {
            Compiler.AddCodeWord(0x8F0F);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJAE(String Name) {
            Compiler.AddCodeWord(0x8D0F);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprJump(String Name) {
            Compiler.AddCodeByte(0xE9);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord(0x0);
        }

        public static void ExprLoop(String Name) {
            //loop label
            Compiler.AddCodeByte(0xE2);
            Compiler.AddCodeByte((byte) (0xFF - ((byte) (Linker.OffsetOf(".code") - Symbols.GetSymbolOffset(Name)))));
        }

        public static void ExprCall(String Name) {
            Compiler.AddCodeByte(0xE8);
            Fixups.AddFixup(Name, Linker.OffsetOf(".code"), Linker.ENUM_SECTION_TYPE.Code, 0);
            Compiler.AddCodeDWord( 0xFFFFFFFF);
        }

        public static void StartFrame() {
            Compiler.AddCodeByte(0x55);
            Compiler.AddCodeByte(0x89);
            Compiler.AddCodeByte(0xE5);
        }

        public static void EndFrame(int Value) {
            Compiler.AddCodeByte(0xC9);
            Compiler.AddCodeByte(0xC2);
            Compiler.AddCodeWord(Value);
        }

        public static void InitializeDLL() {
            StartFrame();
            Compiler.AddCodeByte(0xB8);
            Compiler.AddCodeDWord(0x1);
            EndFrame(0xC);
        }
    };
};