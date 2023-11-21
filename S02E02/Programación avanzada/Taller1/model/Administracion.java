package model;

public interface Administracion {
    
    public Trabajador buscarTrabajador(String mRUT);

    public void agregarTrabajador(Trabajador mTrabajador);

    public void aumentarSueldoTrabajador(String mRUT, int aumento);

    public void filtrarPorSueldo(int sueldoMin, int sueldoMax);

    public void buscaTrabajadoresPorDepartamento(String mNombre);

    public void despedirTrabajador(String mRUT);

    public void cambiarSueldo(String mRUT, int sueldo);

    public void cambiarSueldoDepartamento(String departamento, int sueldo);

    public void trabajadoresDespedidos();

    public void trabajadoresActivos();
}
