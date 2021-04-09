
package Xisia {
    public static class MemoryFiles
    {
        public static const int EX_ENTRY = 0;
        public static const int EX_MODULE = 1;
        public static const int EX_DIALOG = 2;

        public static class TYPE_VIRTUAL_FILE
        {
            public String Name;
            public int Extension;
            public String Content;
            public bool Used;
            public static TYPE_VIRTUAL_FILE CreateInstance() {
                TYPE_VIRTUAL_FILE result = new TYPE_VIRTUAL_FILE();
                result.Name = "";
                result.Content = "";
                return result;
            }
        };

        public static TYPE_VIRTUAL_FILE[] VirtualFiles = nilptr;

        public static void InitVirtualFiles() {
            VirtualFiles = ArraysHelper<TYPE_VIRTUAL_FILE>.InitializeArray(1);
        }

        public static void CreateMemoryFile(String Name, int Extension, String Content) {
            VirtualFiles = ArraysHelper<TYPE_VIRTUAL_FILE>.RedimPreserve(VirtualFiles, new TYPE_VIRTUAL_FILE[VirtualFiles.length + 1]);
            VirtualFiles[VirtualFiles.length - 1].Name = Name;
            VirtualFiles[VirtualFiles.length - 1].Extension = Extension;
            VirtualFiles[VirtualFiles.length - 1].Content = Content;
            VirtualFiles[VirtualFiles.length - 1].Used = true;
        }

        static bool VirtualFileExists(String Name) {
            int i = 0;
            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    return true;
                }
            }

            return false;
        }

        static bool ChangeVirtualFileName(String Name, String ToName) {
            int i = 0;

            if (Name .equals( ToName)) {
                if (VirtualFileExists(ToName)) {
                    _system_.consoleWrite("'" + ToName + "' is already used" );
                    return false;
                }
            }

            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    VirtualFiles[i].Name = ToName;
                    return true;
                }
            }

            return false;
        }

        public static int GetVirtualFileExtension(String Name) {
            int i = 0;
            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    return VirtualFiles[i].Extension;
                }
            }

            return -1;
        }

        static String GetVirtualFileContent(String Name) {
            int i = 0;
            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    return VirtualFiles[i].Content;
                }
            }

            return "";
        }

        static Object DeleteVirtualFile(String Name) {
            int i = 0;
            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    VirtualFiles[i].Used = false;
                    return nilptr;
                }
            }

            return nilptr;
        }

        static Object SetVirtualFileContent(String Name, String Content) {
            int i = 0;
            int __e = VirtualFiles.length - 1;

            for (i = 0; i <= __e; i++) {
                if (VirtualFiles[i].Name.equals(Name)) {
                    VirtualFiles[i].Content = Content;
                    return nilptr;
                }
            }

            return nilptr;
        }
    };
};