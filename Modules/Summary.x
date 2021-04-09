
package Xisia {
    static class Summary
    {
        public static int Errors = 0;
        public static bool pError = false;
        public static bool ShowSummary = false;
        public static String sFileToRun = "";
        public static int LenIncludes = 0;
        public static int LenProcModules = 0;

        public static void InitSummary() {
            Errors = 0;
            pError = false;
            LenIncludes = 0;
        }

        public static void ErrMessage(String Text) {
            pError = true;
            Errors++;
            int i = 0;
            LenProcModules = 0;
            int __e = MemoryFiles.VirtualFiles.length - 1;

            for (i = 1; i <= __e; i++) {
                if (MemoryFiles.VirtualFiles[i].Name .equals( Syntax.CurrentModule)) {
                    LenProcModules += Strings.Len("module " + "\"" + MemoryFiles.VirtualFiles[i].Name + "\"" + ";" + "\r\n");
                    break;
                } else {
                    LenProcModules = LenProcModules + Strings.Len(MemoryFiles.VirtualFiles[i].Content) + Strings.Len("module " + "\"" + MemoryFiles.VirtualFiles[i].Name + "\"" + ";" + "\r\n");
                }
            }

            System.out.print(Text + " [" + Syntax.CurrentModule + ".Line:" + GetLineNumber(Parser.Position - 1 - LenIncludes - LenProcModules) + "]" + "\r\n");
        }

        public static void InfMessage(String Text) {
            //szSummary = szSummary + Text + "\r\n";
            System.out.println(Text);
        }

        static String GetLineNumber(int CurrentPosition) {
            if (CurrentPosition > 0) {
                return "" + Parser.Source.substring(0, CurrentPosition).countChar('\n');
            }

            return "0";
        }
    };
};