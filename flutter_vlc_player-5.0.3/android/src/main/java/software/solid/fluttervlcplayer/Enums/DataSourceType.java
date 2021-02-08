package software.solid.fluttervlcplayer.Enums;

public enum DataSourceType {

    ASSET(0),
    NETWORK(1),
    FILE(2);

    private int mType;

    DataSourceType (int type)
    {
        this.mType = type;
    }

    public int getNumericType() {
        return mType;
    }

}
