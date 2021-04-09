//xlang Source, Name:Modules/BytesBuffer.x
//Date: Sun Mar 20:16:51 2021

class ObjectArray<T> {
    T [] data = new T [0];
    int size = 0;
    Map<String, int> _indexs = new Map<String, int>();

    public void setIndex(String s, int i) {
        _indexs.put(s, i);
    }

    public T find(String s) {
        Map.Iterator<String, int> it = _indexs.find(s);

        if (it != nilptr) {
            return data[it.getValue()];
        }

        return nilptr;
    }

    public T addOne() {
        return add(T.CreateInstance());
    }

    public void addSome(int n) {
        for (int i = 0; i < n ; i ++) {
            addOne();
        }
    }
    public T add(T t) {
        if (size == data.length) {
            enlarge(1);
        }

        data[size++] = t;
        return t;
    }

    public T get(int n) {
        return data[n];
    }

    private void enlarge(int minsize) {
        int nminsize = Math.max(size + minsize * 2, (int)data.length * 2);
        T [] _data = new T [nminsize];
        _system_.arrayCopy(data, 0, _data, 0, size);
        data = _data;
    }

    public T operator [](int n) {
        return data[n];
    }

    public T [] getBuffer() {
        return data;
    }

    public int length() {
        return size;
    }

    public void clear() {
        size = 0;
    }
};