
package Xisia {
    static class Sorter
    {


        //If comparing this code to other sorting code for speed, //    be sure to test under equal Option Compare conditions


        //===================================================================================
        //                                SORTING MODULE
        //
        //  Author:  John Korejwa  <korejwa@tiac.net>
        //  Version: 29/DEC/2002
        //
        //  Resubmitted to PSC on 8/November/2003
        //
        //  Description:
        //    This module applies the QuickSort algorithm for sorting an array of values.
        //
        //    Quicksort is the fastest known general sorting algorithm for large arrays.
        //    However, once the number of elements in a partitioned subarray is smaller than
        //    some threshhold, Insertion Sort becomes faster.  So this code uses QuickSort
        //    for large subarrays, and Insertion Sort for small subarrays.
        //
        //    Quicksort is generally implemented recursively, but this code is non-recursive.
        //    To avoid recursion, a very simple Stack is used within the sorting procedure.
        //
        //    It is possible to get access to pointers to strings using the CopyMemory API
        //    call and the undocumented VarPtr() function.  Accessing pointers speeds things
        //    up enormously, particularly when swapping two strings.
        //
        //===================================================================================


        private static const int QTHRESH = 7; //Threshhold for switching from QuickSort to Insertion Sort
        private static const int MinLong = ((int) 0x80000000);

        //UPGRADE_NOTE: (2041) The following line was commented. More Information: https://docs.mobilize.net/vbuc/ewis#2041
        //[DllImport("kernel32.dll", EntryPoint = "RtlMoveMemory", CharSet = CharSet.Ansi, SetLastError = true, ExactSpelling = true)]
        //extern public static void CopyMemory(System.IntPtr Destination, System.IntPtr Source, int Length);


        public static int SwpVal_SwapStrings = 0;
        public static void SwapStrings(String [] String1, int i1,  String [] String2, int i2) {
            String tmp = String1[i1];
            String1[i1] = String2[i2];
            String2[i2] = tmp;
        }
        public static int c_SwapLong = 0;
        private static void SwapLong(int a, int b) {
            c_SwapLong = a;
            a = b;
            b = c_SwapLong;
        }


        public static void SortStringArray(String[] TheArray, int LowerBound, int UpperBound ) {
            int f = 0; //Subarray Minimum
            int g = 0; //Subarray Maximum
            int h = 0; //Subarray Middle
            int i = 0; //Subarray Low  Scan Index
            int j = 0; //Subarray High Scan Index

            int[] s = new int[64]; //Stack space for pending Subarrays

            String swp = ""; //Swap variable

            if (LowerBound == MinLong) {
                f = 0;
            } else {
                f = LowerBound;
            }

            if (UpperBound == MinLong) {
                g = TheArray.length - 1;
            } else {
                g = UpperBound;
            }

            int t = 0; //Stack pointer

            do {
                if (g - f < QTHRESH) {
                    //Insertion Sort this small subarray
                    int __e = g;

                    for (j = f + 1; j <= __e; j++) {
                        swp = TheArray[j];
                        int __e2 = f;

                        for (i = j - 1; i >= __e2; i--) {
                            if (Strings.CompareOrdinal(TheArray[i], swp) <= 0) {
                                break;
                            }

                            TheArray[i + 1] = TheArray[i];
                        }

                        TheArray[i + 1] = swp;
                    }

                    if (t == 0) {
                        break;
                    } //Finished sorting <<<

                    g = s[t - 1]; //Pop stack and begin new partitioning round
                    f = s[t - 2];
                    t -= 2;
                } else {
                    //QuickSort this large subarray
                    h = (f + g) / 2;
                    SwapStrings(TheArray, h, TheArray, f + 1);

                    if (Strings.CompareOrdinal(TheArray[f], TheArray[g]) > 0) {
                        SwapStrings(TheArray, f, TheArray, g);
                    }

                    if (Strings.CompareOrdinal(TheArray[f + 1], TheArray[g]) > 0) {
                        SwapStrings(TheArray, f + 1, TheArray, g);
                    }

                    if (Strings.CompareOrdinal(TheArray[f], TheArray[f + 1]) > 0) {
                        SwapStrings(TheArray, f, TheArray, f + 1);
                    }

                    i = f + 1; //Initialize pointers for partitioning
                    j = g; //swp is partitioning element
                    swp = TheArray[f + 1];

                    do {
                        do {
                            //Scan up to find element > swp
                            i++;
                        } while(Strings.CompareOrdinal(TheArray[i], swp) < 0);

                        do {
                            //Scan down to find element < swp
                            j--;
                        } while(Strings.CompareOrdinal(TheArray[j], swp) > 0);

                        if (j < i) {
                            break;
                        } //Scan Elements crossed ... Partitioning complete

                        SwapStrings(TheArray, i, TheArray, j);
                    } while(true);

                    //Insert partitioning element
                    TheArray[f + 1] = TheArray[j];
                    TheArray[j] = swp;

                    t += 2; //Push larger subarray onto stack; Sort smaller subarray first

                    if (g - i + 1 >= j - f) {
                        s[t - 1] = g;
                        s[t - 2] = i;
                        g = j - 1;
                    } else {
                        s[t - 1] = j - 1;
                        s[t - 2] = f;
                        f = i;
                    }
                }
            } while(true);
        }


        public static void SortLongArray(int[] TheArray, int LowerBound, int UpperBound ) {
            int f = 0; //Subarray Minimum
            int g = 0; //Subarray Maximum
            int h = 0; //Subarray Middle
            int i = 0; //Subarray Low  Scan Index
            int j = 0; //Subarray High Scan Index

            int[] s = new int[64]; //Stack space for pending Subarrays

            int swp = 0; //Swap variable

            if (LowerBound == MinLong) {
                f = 0;
            } else {
                f = LowerBound;
            }

            if (UpperBound == MinLong) {
                g = TheArray.length - 1;
            } else {
                g = UpperBound;
            }

            int t = 0; //Stack pointer

            do {
                if (g - f < QTHRESH) {
                    //Insertion Sort this small subarray
                    int __e = g;

                    for (j = f + 1; j <= __e; j++) {
                        swp = TheArray[j];
                        int __e2 = f;

                        for (i = j - 1; i >= __e2; i--) {
                            if (TheArray[i] <= swp) {
                                break;
                            }

                            TheArray[i + 1] = TheArray[i];
                        }

                        TheArray[i + 1] = swp;
                    }

                    if (t == 0) {
                        break;
                    } //Finished sorting <<<

                    g = s[t - 1]; //Pop stack and begin new partitioning round
                    f = s[t - 2];
                    t -= 2;
                } else {
                    //QuickSort this large subarray
                    h = (f + g) / 2;
                    SwapLong(TheArray[h], TheArray[f + 1]);

                    if (TheArray[f] > TheArray[g]) {
                        SwapLong(TheArray[f], TheArray[g]);
                    }

                    if (TheArray[f + 1] > TheArray[g]) {
                        SwapLong(TheArray[f + 1], TheArray[g]);
                    }

                    if (TheArray[f] > TheArray[f + 1]) {
                        SwapLong(TheArray[f], TheArray[f + 1]);
                    }

                    i = f + 1; //Initialize pointers for partitioning
                    j = g; //swp is partitioning element
                    swp = TheArray[f + 1];

                    do {
                        do {
                            //Scan up to find element > swp
                            i++;
                        } while(TheArray[i] < swp);

                        do {
                            //Scan down to find element < swp
                            j--;
                        } while(TheArray[j] > swp);

                        if (j < i) {
                            break;
                        } //Scan Elements crossed ... Partitioning complete

                        SwapLong(TheArray[i], TheArray[j]);
                    } while(true);

                    TheArray[f + 1] = TheArray[j]; //Insert partitioning element
                    TheArray[j] = swp;

                    t += 2; //Push larger subarray onto stack; Sort smaller subarray first

                    if (g - i + 1 >= j - f) {
                        s[t - 1] = g;
                        s[t - 2] = i;
                        g = j - 1;
                    } else {
                        s[t - 1] = j - 1;
                        s[t - 2] = f;
                        f = i;
                    }
                }
            } while(true);

        }


        public static void SortStringIndexArray(String[] TheArray, int[] TheIndex, int LowerBound, int UpperBound ) {
            int f = 0;
            int g = 0;
            int h = 0;
            int i = 0;
            int j = 0;

            int[] s = new int[64];

            String swp = "";
            int indxt = 0;

            if (LowerBound == MinLong) {
                f = 0;
            } else {
                f = LowerBound;
            }

            if (UpperBound == MinLong) {
                g = TheIndex.length - 1;
            } else {
                g = UpperBound;
            }

            int t = 0;

            do {
                if (g - f < QTHRESH) {
                    int __e = g;

                    for (j = f + 1; j <= __e; j++) {
                        indxt = TheIndex[j];
                        swp = TheArray[indxt];
                        int __e2 = f;

                        for (i = j - 1; i >= __e2; i--) {
                            if (Strings.CompareOrdinal(TheArray[TheIndex[i]], swp) <= 0) {
                                break;
                            }

                            TheIndex[i + 1] = TheIndex[i];
                        }

                        TheIndex[i + 1] = indxt;
                    }

                    if (t == 0) {
                        break;
                    }

                    g = s[t - 1];
                    f = s[t - 2];
                    t -= 2;
                } else {
                    h = (f + g) / 2;
                    SwapLong(TheIndex[h], TheIndex[f + 1]);

                    if (Strings.CompareOrdinal(TheArray[TheIndex[f]], TheArray[TheIndex[g]]) > 0) {
                        SwapLong(TheIndex[f], TheIndex[g]);
                    }

                    if (Strings.CompareOrdinal(TheArray[TheIndex[f + 1]], TheArray[TheIndex[g]]) > 0) {
                        SwapLong(TheIndex[f + 1], TheIndex[g]);
                    }

                    if (Strings.CompareOrdinal(TheArray[TheIndex[f]], TheArray[TheIndex[f + 1]]) > 0) {
                        SwapLong(TheIndex[f], TheIndex[f + 1]);
                    }

                    i = f + 1;
                    j = g;
                    indxt = TheIndex[f + 1];
                    swp = TheArray[indxt];

                    do {
                        do {
                            i++;
                        } while(Strings.CompareOrdinal(TheArray[TheIndex[i]], swp) < 0);

                        do {
                            j--;
                        } while(Strings.CompareOrdinal(TheArray[TheIndex[j]], swp) > 0);

                        if (j < i) {
                            break;
                        }

                        SwapLong(TheIndex[i], TheIndex[j]);
                    } while(true);

                    TheIndex[f + 1] = TheIndex[j];
                    TheIndex[j] = indxt;

                    t += 2;

                    if (g - i + 1 >= j - f) {
                        s[t - 1] = g;
                        s[t - 2] = i;
                        g = j - 1;
                    } else {
                        s[t - 1] = j - 1;
                        s[t - 2] = f;
                        f = i;
                    }
                }
            } while(true);

        }


        public static void SortLongIndexArray(int[] TheArray, int[] TheIndex, int LowerBound, int UpperBound ) {
            int f = 0;
            int g = 0;
            int h = 0;
            int i = 0;
            int j = 0;

            int[] s = new int[64];

            int swp = 0;
            int indxt = 0;

            if (LowerBound == MinLong) {
                f = 0;
            } else {
                f = LowerBound;
            }

            if (UpperBound == MinLong) {
                g = TheIndex.length - 1;
            } else {
                g = UpperBound;
            }

            int t = 0;

            do {
                if (g - f < QTHRESH) {
                    int __e = g;

                    for (j = f + 1; j <= __e; j++) {
                        indxt = TheIndex[j];
                        swp = TheArray[indxt];
                        int __e2 = f;

                        for (i = j - 1; i >= __e2; i--) {
                            if (TheArray[TheIndex[i]] <= swp) {
                                break;
                            }

                            TheIndex[i + 1] = TheIndex[i];
                        }

                        TheIndex[i + 1] = indxt;
                    }

                    if (t == 0) {
                        break;
                    }

                    g = s[t - 1];
                    f = s[t - 2];
                    t -= 2;
                } else {
                    h = (f + g) / 2;
                    SwapLong(TheIndex[h], TheIndex[f + 1]);

                    if (TheArray[TheIndex[f]] > TheArray[TheIndex[g]]) {
                        SwapLong(TheIndex[f], TheIndex[g]);
                    }

                    if (TheArray[TheIndex[f + 1]] > TheArray[TheIndex[g]]) {
                        SwapLong(TheIndex[f + 1], TheIndex[g]);
                    }

                    if (TheArray[TheIndex[f]] > TheArray[TheIndex[f + 1]]) {
                        SwapLong(TheIndex[f], TheIndex[f + 1]);
                    }

                    i = f + 1;
                    j = g;
                    indxt = TheIndex[f + 1];
                    swp = TheArray[indxt];

                    do {
                        do {
                            i++;
                        } while(TheArray[TheIndex[i]] < swp);

                        do {
                            j--;
                        } while(TheArray[TheIndex[j]] > swp);

                        if (j < i) {
                            break;
                        }

                        SwapLong(TheIndex[i], TheIndex[j]);
                    } while(true);

                    TheIndex[f + 1] = TheIndex[j];
                    TheIndex[j] = indxt;

                    t += 2;

                    if (g - i + 1 >= j - f) {
                        s[t - 1] = g;
                        s[t - 2] = i;
                        g = j - 1;
                    } else {
                        s[t - 1] = j - 1;
                        s[t - 2] = f;
                        f = i;
                    }
                }
            } while(true);

        }
    };
};