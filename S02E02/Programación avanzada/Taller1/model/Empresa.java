package model;

import java.util.ArrayList;
import java.util.Random;

public class Empresa implements Administracion{
    ArrayList<Trabajador> mListaDeActivos;
    ArrayList<Trabajador> mListaDespedidos;
    //
    public Empresa() {
        this.mListaDeActivos = new ArrayList<>();
        this.mListaDespedidos = new ArrayList<>();
        init();
    }

    private void init() {
        // Crea 2 departamentos
        Departamento depProduccion = new Departamento(Departamento.Produccion);
        Departamento depAdministracion = new Departamento(Departamento.Administracion);
        Random random = new Random();
        // Crear 5 trabajadores activos y 5 despedidos
        for(int i = 0, j = 0; i < 5; i++){
            if (random.nextInt(2) == 0){
                mListaDeActivos.add(new Trabajador(FormatearRUT((20000000+j)+"k"), "Juan Perez"+i, 350000+(25000*i), depProduccion)); j++;
                mListaDespedidos.add(new Trabajador(FormatearRUT((20000000+j)+"k"), "Pedro Soto"+i, 350000+(25000*i), depProduccion)); j++;
            }else{
                mListaDeActivos.add(new Trabajador(FormatearRUT((20000000+j)+"k"), "Juan Perez"+i, 350000+(25000*i), depAdministracion)); j++;
                mListaDespedidos.add(new Trabajador(FormatearRUT((20000000+j)+"k"), "Pedro Soto"+i, 350000+(25000*i), depAdministracion)); j++;
            }            
        }
    }

    // Obtenido de Internet: https://qis.cl/formatear-rut-en-java/
    public String FormatearRUT(String rut) {
        int cont = 0;
        String format;
        rut = rut.replace(".", "");
        rut = rut.replace("-", "");
        format = "-" + rut.substring(rut.length() - 1);
        for (int i = rut.length() - 2; i >= 0; i--) {
            format = rut.substring(i, i + 1) + format;
            cont++;
            if (cont == 3 && i != 0) {
                format = "." + format;
                cont = 0;
            }
        }
        return format;
    }

    @Override
    public void agregarTrabajador(Trabajador mTrabajador) {
        mListaDeActivos.add(mTrabajador);
    }

    @Override
    public Trabajador buscarTrabajador(String mRUT) {
        for( Trabajador t: mListaDeActivos ){
            if( t.getmRUT().equals(mRUT) ){
                return t;
            }
        }
        return null;
    }

    public Trabajador buscarDespedidos(String mRUT) {
        Trabajador trabajador = null;
        for( Trabajador t: mListaDespedidos ){
            if( t.getmRUT().equals(mRUT) ){
                trabajador = t;
                break;
            }
        }
        return trabajador;
    }

    @Override
    public void aumentarSueldoTrabajador(String mRUT, int aumento) {
        Trabajador trabajador = buscarTrabajador(mRUT);
        trabajador.setmSueldo(trabajador.getmSueldo() + aumento);        
    }

    @Override
    public void filtrarPorSueldo(int sueldoMin, int sueldoMax) {
        for(Trabajador t : mListaDeActivos){
            if( t.getmSueldo() > sueldoMin && t.getmSueldo() < sueldoMax ){
                System.out.println(t.toString());
            }
        }
    }

    @Override
    public void buscaTrabajadoresPorDepartamento(String mNombreDep) {
        for(Trabajador t : mListaDeActivos){
            if( t.mDepa.getmNombre().equals(mNombreDep) ){
                System.out.println(t.toString());
            }
        }
    }

    @Override
    public void despedirTrabajador(String mRUT) {
        Trabajador t = buscarTrabajador(mRUT); // Ya validado que no es null
        mListaDeActivos.remove(t);
        mListaDespedidos.add(t);
    }

    @Override
    public void cambiarSueldo(String mRUT, int sueldo) {
        Trabajador trabajador = buscarTrabajador(mRUT);
        trabajador.setmSueldo(sueldo);
    }

    @Override
    public void cambiarSueldoDepartamento(String departamento, int sueldo) {
        for( Trabajador t : mListaDeActivos ){
            if( t.getmDepa().getmNombre().equals(departamento) ){
                t.setmSueldo(sueldo);
            }
        }
    }

    @Override
    public void trabajadoresDespedidos() {
        for( Trabajador t : mListaDespedidos ){
            System.out.println(t.toString());
        }
    }

    @Override
    public void trabajadoresActivos() {
        for( Trabajador t : mListaDeActivos ){
            System.out.println(t.toString());
        }       
    }
}
