
package Xisia {
    static class Memory
    {

        public static void ReserveArray(String Ident, int Size) {
            DataManager.DeclareDataDWord(Ident + ".PtrToArray", 0);
            DataManager.DeclareDataDWord(Ident + ".HeapHandle", 0);
            DataManager.DeclareDataDWord(Ident + ".ubound", 0);
            DataManager.DeclareDataDWord(Ident + ".lbound", 0);
            DataManager.DeclareDataDWord(Ident + ".Array", 0);

            if (Function.CurrentFrame .length() != 0) {
                comAssembler.Push(0);
                comAssembler.Push(0);
                comAssembler.Push(0);
                comAssembler.InvokeByName("HeapCreate"); //Create Heap
                comAssembler.AssignEAX(Ident + ".HeapHandle"); //Save Handle of HeapCreate

                comAssembler.Push(Symbols.GetSymbolSize(Ident) * Size);
                comAssembler.Push(8); //Size in Bytes: 8 = ZeroMemory
                comAssembler.PushContent(Ident + ".HeapHandle"); //Push Handle of HeapCreate
                comAssembler.InvokeByName("HeapAlloc"); //Allocate Heap
                comAssembler.AssignEAX(Ident + ".PtrToArray"); //Save Individual Ptr to Allocated Memory for Ident variable

                comAssembler.Push(0);
                comAssembler.PopEAX();
                comAssembler.AssignEAX(Ident + ".lbound");
                comAssembler.Push(Size);
                comAssembler.PopEAX();
                comAssembler.AssignEAX(Ident + ".ubound");
            }

        }

        public static void GetArray(String Ident) {
            Expressions.Expression(Ident + ".Array");
            comAssembler.Push(Symbols.GetSymbolSize(Ident));
            comAssembler.PushContent(Ident + ".Array");
            comAssembler.Push(Symbols.GetSymbolSize(Ident));
            comAssembler.ExprMul();
            comAssembler.PushEAX();
            comAssembler.PushContent(Ident + ".PtrToArray");
            comAssembler.ExprAdd();
            comAssembler.PushEAX();
            comAssembler.PushAddress(Ident);

            comAssembler.InvokeByName("MoveMemory");
            comAssembler.PushContent(Ident);
        }

        public static void SetArray(String Name) {
            Parser.Symbol('(');
            Expressions.Expression("$Intern.Array");
            Parser.Symbol(')');
            Parser.Symbol('=');
            Expressions.Expression(Name);

            comAssembler.Push(Symbols.GetSymbolSize(Name));
            comAssembler.PushAddress(Name);
            comAssembler.PushContent("$Intern.Array");
            comAssembler.Push(Symbols.GetSymbolSize(Name));
            comAssembler.ExprMul();
            comAssembler.PushEAX();
            comAssembler.PushContent(Name + ".PtrToArray");
            comAssembler.ExprAdd();
            comAssembler.PushEAX();

            comAssembler.InvokeByName("MoveMemory");
        }

        public static void StatementPreserve() {
            String Ident = Parser.Identifier();
            Parser.Symbol('(');
            Expressions.Expression("$Intern.Array");
            Parser.Symbol(')');
            Parser.Terminator();

            comAssembler.PushContent("$Intern.Array");
            comAssembler.Push(1);
            comAssembler.PushContent(Ident + ".HeapHandle");
            comAssembler.InvokeByName("HeapAlloc");

            comAssembler.PushContent("$Intern.Array");
            comAssembler.PopEAX();
            comAssembler.AssignEAX(Ident + ".ubound");

            Parser.CodeBlock();
        }

        public static void StatementReserve() {
            String Ident = Parser.Identifier();
            Parser.Symbol('(');
            Expressions.Expression("$Intern.Array");
            Parser.Symbol(')');
            Parser.Terminator();

            comAssembler.Push(0);
            comAssembler.Push(0);
            comAssembler.Push(0);
            comAssembler.InvokeByName("HeapCreate"); //Create Heap
            comAssembler.AssignEAX(Ident + ".HeapHandle"); //Save Handle of HeapCreate

            comAssembler.PushContent("$Intern.Array");
            comAssembler.Push(Symbols.GetSymbolSize(Ident));
            comAssembler.ExprMul();
            comAssembler.PushEAX();
            comAssembler.Push(8); //8 = ZeroMemory
            comAssembler.PushContent(Ident + ".HeapHandle"); //Push Handle of HeapCreate
            comAssembler.InvokeByName("HeapAlloc"); //Allocate Heap
            comAssembler.AssignEAX(Ident + ".PtrToArray"); //Save Individual Ptr to Allocated Memory for Ident variable

            comAssembler.PushContent("$Intern.Array");
            comAssembler.PopEAX();
            comAssembler.AssignEAX(Ident + ".ubound");

            Parser.CodeBlock();
        }

        public static void StatementDestroy() {
            String Ident = Parser.Identifier();
            Parser.Terminator();

            if (Symbols.SymbolExists(Ident + ".HeapHandle")) {
                comAssembler.PushContent(Ident + ".HeapHandle");
                comAssembler.InvokeByName("HeapDestroy"); //Destroy Heap
                comAssembler.Push(0);
                comAssembler.PopEAX();
                comAssembler.AssignEAX(Ident + ".ubound");
            } else {
                Summary.ErrMessage("cannot destroy '" + Ident + "' has not been reserved before.");
                return;
            }

            Parser.CodeBlock();
        }

        public static void StatementUBound() {
            Parser.Symbol('(');
            String Ident = Parser.Identifier();
            Parser.Symbol(')');
            comAssembler.PushContent(Ident + ".ubound");
        }

        public static void StatementLBound() {
            Parser.Symbol('(');
            String Ident = Parser.Identifier();
            Parser.Symbol(')');
            comAssembler.PushContent(Ident + ".lbound");
        }
    };
};