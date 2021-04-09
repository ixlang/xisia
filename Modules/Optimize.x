
package Xisia {
    static class Optimizer
    {

        public static bool OptimizeAble(String ByInstruction, String Variable) {
            bool result = false;
            byte B1 = 0;
            byte B2 = 0;
            byte B3 = 0;
            byte B4 = 0;

            try {

                switch(ByInstruction) {
                case "PopEAX" :
                    if (Linker.Section[2].Bytes.get( Linker.Section[2].Bytes.length() - 1) == 0x50) {
                        //Kill PushEAX and do not add PopEAX
                        Linker.Section[2].Bytes.pop(1);
                        result = true;
                    } else
                        if (Linker.Section[2].Bytes.get( Linker.Section[2].Bytes.length() - 5) == 0x68) {
                            //If a Push Number is made and then pop eax this can be -> mov eax,Number
                            B1 = Linker.Section[2].Bytes.get(Linker.Section[2].Bytes.length() - 1 - 3);
                            B2 = Linker.Section[2].Bytes.get(Linker.Section[2].Bytes.length() - 1 - 2);
                            B3 = Linker.Section[2].Bytes.get(Linker.Section[2].Bytes.length() - 1 - 1);
                            B4 = Linker.Section[2].Bytes.get(Linker.Section[2].Bytes.length() - 1);
                            Linker.Section[2].Bytes.pop(5);
                            //mov eax,Value
                            Compiler.AddCodeByte(0xB8);
                            Compiler.AddCodeByte(B1);
                            Compiler.AddCodeByte(B2);
                            Compiler.AddCodeByte(B3);
                            Compiler.AddCodeByte(B4);
                            result = true;
                        }

                    break;

                default:
                    break;
                }
            } catch(Exception e) {
            }

            return result;
        }
    };
};