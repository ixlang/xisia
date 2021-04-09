package Xisia {
    static class General
    {
        public static int GridSize = 0;
        public static int ExitCode = 0;
        public static int hWndProg = 0;
        public static bool DoCreateObject = false;


        public const int SHCNE_ASSOCCHANGED = 0x8000000;
        public const int SHCNF_IDLIST = 0x0;
        public const int PROCESS_ALL_ACCESS = 0x1F0FFF;
        public const int STILL_ACTIVE = 0x103;
        public const int INFINITE = 0xFFFF;
        public const int WM_SYSCOMMAND = 0x112;

        public static double DbgCounter = 0;

        public static void StartCounter() {
            DbgCounter = _system_.currentTimeMillis();
        }

        static double EndCounter() {
            return (double) ((_system_.currentTimeMillis() - DbgCounter) / 1000f);
        }
    };
};