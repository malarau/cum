/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Enum.java to edit this template
 */
package taller2.model;

/**
 *
 * @author Matias Lara
 */
public enum Sector {
    
    Colbun("Colbun"),
    Panimavida("Panimavida"),
    Maule_Sur("Maule Sur"),
    La_Guardia("La Guardia"),
    San_Nicolas("San Nicolas"),
    Quinamavida("Quinamavida"),
    Rari("Rari"),
    Capilla_Palacio("Capilla Palacio");
    
    private final String value;
    
    private Sector(String valor){
        this.value = valor;
    }
    public String getTextValue(){
        return this.value;
    }
    
    public int getIndex(String value){
        return Sector.valueOf(value).ordinal();
    }
    
    public static String[] getAll(){
        Sector[] value = Sector.values();
        String[] textValues = new String[value.length];
        for( int i = 0; i < value.length; i++ ){
            textValues[i] = value[i].getTextValue();
        }
        return textValues;
    }
    
    
}
