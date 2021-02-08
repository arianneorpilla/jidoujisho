package software.solid.fluttervlcplayer.Enums;

public enum HwAcc {

    AUTOMATIC(-1),
    DISABLED(0),
    DECODING(1),
    FULL(2);

    private int mType;

    HwAcc (int type)
    {
        this.mType = type;
    }

    public int getNumericType() {
        return mType;
    }
}
