//xlang Source, Name:Modules/BytesBuffer.x
//Date: Sun Mar 20:16:51 2021

class BytesBuffer {
    byte [] data = new byte [4096];
    int size = 1;

    public void add(byte b) {
        if (size == data.length) {
            enlarge(1);
        }

        data[size++] = b;
    }

    public void add(byte [] b) {
        int len = b.length;

        if (size + len >= data.length) {
            enlarge(size + len);
        }

        _system_.arrayCopy(b, 0, data, size, len);
        size += len;
    }

    public void add(byte [] b, int start, int len) {
        if (size + len >= data.length) {
            enlarge(size + len);
        }

        _system_.arrayCopy(b, start, data, size, len);
        size += len;
    }

    public void pop(int i) {
        if (size >= i) {
            size -= i;
        }
    }

    public void set(int n, byte b) {
        data[n] = b;
    }

    public byte get(int n) {
        return data[n];
    }

    private void enlarge(int minsize) {
        int nminsize = Math.max(size + minsize * 2, (int)data.length * 2);
        byte [] _data = new byte [nminsize];
        _system_.arrayCopy(data, 0, _data, 0, size);
        data = _data;
    }

    public byte [] getData() {
        byte [] _data = new byte [size];
        _system_.arrayCopy(data, 0, _data, 0, size);
        return _data;
    }

    public byte [] getBuffer() {
        return data;
    }

    public int length() {
        return size;
    }

    public String toString() {
        return new String(data, 0, size);
    }

    public void clear() {
        size = 0;
    }
};