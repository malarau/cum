/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package taller2.model;

/**
 *
 * @author Matias Lara
 */
public enum Status {
    
    ACTIVO("Activo"),
    INACTIVO("Inactivo");
    
    private final String value;
    
    private Status(String valor){
        this.value = valor;
    }
    public String getTextValue(){
        return this.value;
    }
    
    public static String[] getAll(){
        Status[] values = Status.values();
        String[] textValues = new String[values.length];
        for( int i = 0; i < values.length; i++ ){
            textValues[i] = values[i].getTextValue();
        }
        return textValues;
    }
}
