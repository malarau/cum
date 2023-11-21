package model;

public class Trabajador {
    String mRUT;
    String nMombre;
    int mSueldo;
    Departamento mDepa;

    public Trabajador(){}

    public Trabajador(String mRUT, String nMombre, int mSueldo, Departamento mDepa) {
        this.mRUT = mRUT;
        this.nMombre = nMombre;
        this.mSueldo = mSueldo;
        this.mDepa = mDepa;
    }

    public String getmRUT() {
        return mRUT;
    }

    public void setmRUT(String mRUT) {
        this.mRUT = mRUT;
    }

    public String getnMombre() {
        return nMombre;
    }

    public void setnMombre(String nMombre) {
        this.nMombre = nMombre;
    }

    public int getmSueldo() {
        return mSueldo;
    }

    public void setmSueldo(int mSueldo) {
        this.mSueldo = mSueldo;
    }

    public Departamento getmDepa() {
        return mDepa;
    }

    public void setmDepa(Departamento mDepa) {
        this.mDepa = mDepa;
    }

    @Override
    public String toString() {
        return "Trabajador: \n\tRUT: " + mRUT + ", Nombre: " + nMombre + ", Sueldo: " + mSueldo + ", \n\t" + mDepa.toString();
    }
}
