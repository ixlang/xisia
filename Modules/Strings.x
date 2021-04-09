//xlang Source, Name:Strings.x
//Date: Fri Mar 05:18:09 2021

class Strings {
    public static int Len(String s) {
        return s.length();
    }

    public static String readString(FileInputStream fis) {
        int len = fis.readShortLE();
        byte [] data = new byte [len];
        fis.read(data, 0, len);
        return new String(data);
    }

    public static void writeString(FileOutputStream fos, String str) {
        fos.writeShort(str.length());
        byte [] data = str.getBytes();
        fos.write(data);
    }

    public static int CompareOrdinal(String src, String dst) {
        int il = src.length() - dst.length();

        if (il != 0) {
            return il;
        }

        for (int i = 0; i < src.length(); i++) {
            int c = src.charAt(i) - dst.charAt(i);

            if (c != 0) {
                return c;
            }
        }

        return 0;
    }
};