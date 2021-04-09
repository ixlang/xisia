
package Xisia {
    static class ObjScan
    {
        public static class TYPE_SCAN_OBJECT
        {
            public String Category;
            public String Parent;
            public int Position;
            public static TYPE_SCAN_OBJECT CreateInstance() {
                TYPE_SCAN_OBJECT result = new TYPE_SCAN_OBJECT();
                result.Category = "";
                result.Parent = "";
                return result;
            }
        };

        public static TYPE_SCAN_OBJECT[] ScanObjects = nilptr;

        public static void InitScanObjects() {
            ScanObjects = ArraysHelper<TYPE_SCAN_OBJECT>.InitializeArray(1);
        }

        public static void AddScanObject(String Category, String Parent, int Position) {
            ScanObjects = ArraysHelper<TYPE_SCAN_OBJECT>.RedimPreserve(ScanObjects, new TYPE_SCAN_OBJECT[ScanObjects.length + 1]);
            ScanObjects[ScanObjects.length - 1].Category = Category;
            ScanObjects[ScanObjects.length - 1].Parent = Parent;
            ScanObjects[ScanObjects.length - 1].Position = Position;
        }

        static bool IsCategoryUsed(String Category) {
            int i = 0;
            int __e = ScanObjects.length - 1;

            for (i = 1; i <= __e; i++) {
                if (ScanObjects[i].Category.equals(Category)) {
                    return true;
                }
            }

            return false;
        }


    };
};