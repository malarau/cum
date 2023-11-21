package model;

public class Departamento {
    public static final String Produccion = "Producción";
    public static final String Administracion = "Administración";

    String mNombre;
    String mDescripcion;

    public Departamento(){}

    public Departamento(String departamento){
        if( departamento == Produccion ){
            this.mNombre = Produccion;
            this.mDescripcion = "Donde producen.";    
        }else{
            this.mNombre = Administracion;
            this.mDescripcion = "Donde administran.";
        }        
    }

    public String getmNombre() {
        return mNombre;
    }

    public void setmNombre(String mNombre) {
        this.mNombre = mNombre;
    }

    public String getmDescripcion() {
        return mDescripcion;
    }

    public void setmDescripcion(String mDescripcion) {
        this.mDescripcion = mDescripcion;
    }

    @Override
    public String toString() {
        return "Departamento:\n\t\tNombre: " + mNombre + ", Descripcion: " + mDescripcion;
    }

    
}
