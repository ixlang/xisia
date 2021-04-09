
package Xisia {
    static class Mather
    {
        public static class TYPE_QWORD
        {
            public double Value;
        };

        private static class TYPE_LOHIQWORD
        {
            public int lLoDWord;
            public int lHiDWord;
        };

        public static byte HiByte(int iWord) {
            return (byte) ((iWord & 0xFF00) / 0x100);
        }

        public static byte LoByte(int iWord) {
            return (byte) (iWord & 0xFF);
        }

        public static int HiWord(int lDword) {
            return (lDword & ((int) 0xFFFF0000)) / 0x10000;
        }

        public static int LoWord(int lDword) {
            if ((lDword & 0x8000) != 0) {
                return lDword | ((int) 0xFFFF0000);
            } else {
                return lDword & 0xFFFF;
            }
        }

        public static int HiSWord(double lDword) {
            return (((int)lDword) & ((int) 0xFFFF0000)) / 0x10000;
        }

        public static int LoSWord(double lDword) {
            if (((int)(lDword) & 0x8000) != 0) {
                return (int)(lDword) | ((int) 0xFFFF0000);
            } else {
                return (int)(lDword) & 0xFFFF;
            }
        }

        public static int LoDWord(double cQWord) {
            TYPE_QWORD QWord = new TYPE_QWORD();
            TYPE_LOHIQWORD LoHiQword = new TYPE_LOHIQWORD();
            QWord.Value = (double) (((double) cQWord) / 10000);
            //UPGRADE_ISSUE: (1002) LSet cannot assign one type to another. More Information: https://docs.mobilize.net/vbuc/ewis#1002
            //LSet(LoHiQword, QWord);
            return LoHiQword.lLoDWord;
        }

        public static int HiDWord(double cQWord) {
            TYPE_QWORD QWord = new TYPE_QWORD();
            TYPE_LOHIQWORD LoHiQword = new TYPE_LOHIQWORD();
            QWord.Value = (double) (((double) cQWord) / 10000);
            //UPGRADE_ISSUE: (1002) LSet cannot assign one type to another. More Information: https://docs.mobilize.net/vbuc/ewis#1002
            //LSet(LoHiQword, QWord);
            return LoHiQword.lHiDWord;
        }

        public static double MakeQWord(int lHiDWord, int lLoDWord) {
            TYPE_QWORD QWord = new TYPE_QWORD();
            TYPE_LOHIQWORD LoHiQword = new TYPE_LOHIQWORD();
            LoHiQword.lHiDWord = lHiDWord;
            LoHiQword.lLoDWord = lLoDWord;
            //UPGRADE_ISSUE: (1002) LSet cannot assign one type to another. More Information: https://docs.mobilize.net/vbuc/ewis#1002
            //LSet(QWord, LoHiQword);
            return QWord.Value * 10000;
        }
    };
};