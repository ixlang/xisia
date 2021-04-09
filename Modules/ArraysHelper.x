//xlang Source, Name:ArraysHelper.x
//Date: Fri Mar 03:55:02 2021
package Xisia {
    public class ArraysHelper<T>{
        public static T [] InitializeArray(int size) {
            T [] ta = new T[size];

            for (int i = 0; i < ta.length; i++) {
                ta[i] = T.CreateInstance();
            }

            return ta;
        }
        public static T[] RedimPreserve(T[] _old, T[] _new) {
            _system_.arrayCopy(_old, 0, _new, 0, Math.min(_old.length, _new.length));

            for (int i = _old.length; i < _new.length; i++) {
                _new[i] = T.CreateInstance();
            }

            return _new;
        }
    };

    public class StringArraysHelper{
        public static String [] InitializeArray(int size) {
            String [] ta = new String[size];

            for (int i = 0; i < ta.length; i++) {
                ta[i] = "";
            }

            return ta;
        }
        public static String[] RedimPreserve(String[] _old, String[] _new) {
            _system_.arrayCopy(_old, 0, _new, 0, Math.min(_old.length, _new.length));

            for (int i = _old.length; i < _new.length; i++) {
                _new[i] = "";
            }

            return _new;
        }
    };

    public class PodArraysHelper<T>{
        public static T [] InitializeArray(int size) {
            return new T[size];
        }

        public static T[] RedimPreserve(T[] _old, T[] _new) {
            _system_.arrayCopy(_old, 0, _new, 0, Math.min(_old.length, _new.length));
            return _new;
        }
    };

    public class ObjectArraysHelper<T>{
        public static T [] InitializeArray(int size) {
            T [] ta = new T[size];

            for (int i = 0; i < ta.length; i++) {
                ta[i] = new T();
            }

            return ta;
        }

        public static T[] RedimPreserve(T[] _old, T[] _new) {
            _system_.arrayCopy(_old, 0, _new, 0, Math.min(_old.length, _new.length));

            for (int i = _old.length; i < _new.length; i++) {
                _new[i] = new T();
            }

            return _new;
        }
    };
};