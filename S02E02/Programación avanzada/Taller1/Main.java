/**
 * Taller n°1: Programacion Orientada a Objetos
 * INF-223/Inform´atica
 * 25/10/2022
 * Nombre: Matias Lara
 * RUT: 17823858-2
 */

import java.util.Scanner;
import model.Departamento;
import model.Empresa;
import model.Trabajador;

class Main {
    public static Scanner scan;
    public static void main(String[] args) {
        Empresa empresa = new Empresa();
        scan = new Scanner(System.in);
        int opcion;
        boolean finalizar = false;
        do {
            mostrarMenu();
            opcion = solicitarNumero("\nIngrese una opción: ");
            switch (opcion){
                case 1:
                    crearTrabajador(empresa);
                    break;
                case 2:
                    buscarTrabajador(empresa, true);
                    break;
                case 3:
                    aumentarSueldoTrabajador(empresa);
                    break;
                case 4:
                    filtrarPorSueldo(empresa);
                    break;
                case 5:
                    filtrarPorDepartamento(empresa);
                    break;
                case 6:
                    despedirTrabajador(empresa);
                    break;
                case 7:
                    cambiarSueldo(empresa);
                    break;
                case 8:
                    cambiarSueldoDepartamento(empresa);
                    break;
                case 9:
                    verTrabajadores(empresa);
                    break;
                case 10:
                    verDespedidos(empresa);
                    break;
                case 11:
                    verContratados(empresa);
                    break;
                case 12:
                    finalizar = true;
                    break;
                default:
                    System.out.println("La opción ingresada no existe.");            
            }
            presioneParaContinuar();
        } while(!finalizar);
        scan.close();
    }

    private static void presioneParaContinuar() {
        System.out.print("\nPresione Enter para continuar...");
        try{
            scan.nextLine();
        }catch(Exception e){}
    }

    private static void crearTrabajador(Empresa empresa) {
        System.out.println("\n> CREAR TRABAJADOR");
        System.out.print("\nIngrese el RUT del trabajador: ");
        String RUT = scan.nextLine().toLowerCase();
        Trabajador trabajador = empresa.buscarTrabajador(empresa.FormatearRUT(RUT));
        if( trabajador != null ){
            System.out.println("\nEl Trabajador ya existe.");
        }else{
            trabajador = empresa.buscarDespedidos(empresa.FormatearRUT(RUT));
            if( trabajador != null ){
                System.out.println("\nEl Trabajador se encuentra despedido.");
            }else{
                System.out.print("Ingrese el nombre del trabajador: ");
                String nombre = scan.nextLine();
                int sueldo = solicitarNumero("Ingrese el sueldo del trabajador: ");
                int opcion;
                Departamento departamento = null;
                do{
                    System.out.println("Seleccione el departamento: ");
                    System.out.println("1.- Administración.");
                    System.out.println("2.- Producción.");
                    opcion = solicitarNumero("Ingrese una opción: ");
                    switch (opcion) {
                        case 1:
                            departamento = new Departamento(Departamento.Produccion);
                            break;                    
                        case 2:
                            departamento = new Departamento(Departamento.Administracion);
                            break;
                        default:
                            System.out.println("La opción ingresada no está entre las alternativas.");
                            break;
                    }
                } while(opcion > 2 || opcion < 1);
                trabajador = new Trabajador(RUT, nombre, sueldo, departamento);
                empresa.agregarTrabajador(trabajador);
            }
        }
    }

    private static Trabajador buscarTrabajador(Empresa empresa, boolean mostrar) {
        System.out.println("\n> BUSCAR TRABAJADOR ");
        System.out.print("\nIngrese el RUT del trabajador: ");
        String query = scan.nextLine().toLowerCase();
        Trabajador trabajador = empresa.buscarTrabajador(empresa.FormatearRUT(query));
        if( trabajador != null ){
            if( mostrar ){
                System.out.println(trabajador.toString());
            }
        }else{
            System.out.print("\nEl RUT ingresado no existe en la base de datos.");
        }
         return trabajador;
    }

    private static void aumentarSueldoTrabajador(Empresa empresa) {
        System.out.println("\n> AUMENTAR SUELDO DE TRABJADOR");
        Trabajador trabajador = buscarTrabajador(empresa, false);
        if( trabajador != null ){
            int sueldo = solicitarNumero("\nIngrese el aumento de sueldo: ");    
            // Checkear si corresponde como mucho al máx de su sueldo actual.
            if( sueldo > trabajador.getmSueldo()/2 ){
                System.out.println("\nEl aumento supera el máximo permitido (máx: mitad actual).");
            }else{                
                System.out.println("\nSe ha aumentado el sueldo exitosamente.");
                empresa.aumentarSueldoTrabajador(trabajador.getmRUT(), sueldo);
            }
        }
    }

    private static void filtrarPorSueldo(Empresa empresa) {
        System.out.println("\n> FILTRAR POR SUELDO");
        int min = solicitarNumero("Ingrese el límite inferior: ");
        int max = solicitarNumero("Ingrese el límite superior: ");
        if( min > max ){
            System.out.println("\nError, el límite inferior es mayor que el límite superior.");
        }else{
            empresa.filtrarPorSueldo(min, max);
        }    
    }

    // ORDEN

    private static int solicitarNumero(String solicitud) {
        int numero = -1;
        String sueldoAux = "";
        do{
            System.out.print(solicitud);
            try{
                sueldoAux = scan.nextLine(); 
                numero = Integer.parseInt(sueldoAux);
            }catch(Exception ex){
                System.out.println("El valor ingresado no es un número.");
            }
            return numero;
        }while(true);
    }

    private static String obtenerDepartamento(){
        int opcion;
        String departamento = null;
        do{
            System.out.println("Seleccione el departamento: ");
            System.out.println("\t1.- Administración.");
            System.out.println("\t2.- Producción.");
            opcion = solicitarNumero("Ingrese una opción: ");
            switch (opcion) {
                case 1:
                    departamento = Departamento.Administracion;
                    break;                    
                case 2:
                    departamento = Departamento.Produccion;
                    break;
                default:
                    System.out.println("La opción ingresada no está entre las alternativas.");
                    break;
            }
        } while(opcion > 2 || opcion < 1);
        return departamento;
    }

    private static void filtrarPorDepartamento(Empresa empresa) {
        System.out.println("\n> FILTRAR POR DEPARTAMENTO");
        String departamento = obtenerDepartamento();
        if( departamento != null ){
            empresa.buscaTrabajadoresPorDepartamento(departamento);
        }
    }

    private static void despedirTrabajador(Empresa empresa) {
        System.out.println("\n> DESPEDIR TRABAJADOR");
        Trabajador trabajador = buscarTrabajador(empresa, false);
        if( trabajador != null ){   
            empresa.despedirTrabajador(trabajador.getmRUT()); // Se indica que debe ser con RUT.
            System.out.println("\nSe ha despedico el trabajador.");
        }
    }

    private static void cambiarSueldo(Empresa empresa) {
        System.out.println("\n> CAMBIAR SUELDO TRABAJADOR");
        Trabajador trabajador = buscarTrabajador(empresa, false);
        if( trabajador != null ){
            int nuevoSalario = solicitarNumero("Ingrese el nuevo salario: ");
            if( nuevoSalario > 500000 || nuevoSalario < 350000 ){
                System.out.println("\nEl nuevo salario se encuentra fuera de los márgenes ($350000-$500000).");
            }else{
                empresa.cambiarSueldo(trabajador.getmRUT(), nuevoSalario);
                System.out.println("\nEl nuevo salario ha sido asignado exitosamente.");
            }
        }
    }

    private static void cambiarSueldoDepartamento(Empresa empresa) {
        System.out.println("\n> CAMBIAR SUELDO DEL DEPARTAMENTO");
        String departamento = obtenerDepartamento();
        if( departamento != null ){
            int nuevoSalario = solicitarNumero("Ingrese el nuevo salario de departamento: ");
            if( nuevoSalario > 500000 || nuevoSalario < 350000 ){
                System.out.println("\nEl nuevo salario se encuentra fuera de los márgenes ($350000-$500000).");
            }else{
                empresa.cambiarSueldoDepartamento(departamento, nuevoSalario);
                System.out.println("\nEl nuevo salario de departamento ha sido asignado exitosamente.");
            }
        }
    }

    private static void verContratados(Empresa empresa) {
        System.out.println("\n> VER TRABAJADORES CONTRATADOS");
        empresa.trabajadoresActivos();
    }

    private static void verDespedidos(Empresa empresa) {
        System.out.println("\n> VER TRABAJADORES DESPEDIDOS");
        empresa.trabajadoresDespedidos();
    }

    private static void verTrabajadores(Empresa empresa) {
        System.out.println("\n\t> VER TRABAJADORES");
        verContratados(empresa);
        verDespedidos(empresa);
    }

    private static void mostrarMenu() {
        System.out.println();
        System.out.println("> MENÚ PRINCIPAL:");
        System.out.println("1.)  CREAR TRABAJADOR");
        System.out.println("2.)  BUSCAR TRABAJADOR");
        System.out.println("3.)  AUMENTAR SUELDO TRABAJADOR");
        System.out.println("4.)  FILTRAR POR SUELDO");
        System.out.println("5.)  FILTRAR POR DEPARTAMENTO");
        System.out.println("6.)  DESPEDIR TRABAJADOR");
        System.out.println("7.)  CAMBIAR SUELDO TRABAJADOR");
        System.out.println("8.)  CAMBIAR SUELDO DEPARTAMENTO");
        System.out.println("9.)  VER TRABAJADORES");
        System.out.println("10.) VER DESPEDIDOS");
        System.out.println("11.) VER CONTRATADOS");
        System.out.println("12.) SALIR");
    }

}