//xlang
package System {
    public class out{
        public static int println(String text) {
            return _system_.consoleWrite(text + "\n");
        }
        public static int print(String text) {
            return _system_.consoleWrite(text);
        }
    };
};

using { System; FileStream; Xisia;};

int main(String [] args) {
    System.out.println("Xisia Compiler for Windows(x86), powered by xlang [https://xlang.link/].");

    if (args.length > 4) {
        MemoryFiles.InitVirtualFiles();

        for (int i = 1; i < args.length; ) {
            if (args[i].equals("-e")) {
                i++;

                if (i < args.length) {
                    byte [] data = Resources.readData(args[i], 0);

                    if (data != nilptr) {
                        MemoryFiles.CreateMemoryFile("Entry Point", MemoryFiles.EX_ENTRY, new String(data));
                        i++;
                    } else {
                        System.out.println("can't open file :" + args[i]);
                        break;
                    }
                }
            } else
                if (args[i].equals("-c")) {
                    i++;

                    while (i < args.length) {
                        if (args[i].startsWith("-") == false) {
                            byte [] data = Resources.readData(args[i], 0);

                            if (data != nilptr) {
                                MemoryFiles.CreateMemoryFile("Module", MemoryFiles.EX_MODULE, new String(data));
                            } else {
                                System.out.println("can't open file :" + args[i]);
                            }

                            i++;
                        } else {
                            break;
                        }
                    }
                } else
                    if (args[i].equals("-o")) {
                        i++;
                        Compiler.Compile(args[i], false);
                        _system_.output("complete ");
                        System.out.println("Done.");
                        break;
                    } else {
                        System.out.println("Invalid CommandLine.\r\neg:\r\n\txisia -e main.xia -c modules.xia -o main.exe.");
                        break;
                    }
        }
    } else {
        System.out.println("Invalid CommandLine.\r\neg:\r\n\txisia -e main.xia -c modules.xia -o main.exe.");
    }

    return 0;
}
