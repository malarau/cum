
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package taller2;

import taller2.view.JVentana;
import javax.swing.UIManager;
import taller2.controller.ClientsController;

/**
 *
 * @author Matias Lara
 */
public class Taller2 {

    /**
     * ORGANIZACIÓN:
     * 
     * 1.- SE GENERA UN JFrame EN JVentana.
     * 2.- ALLÍ, SE AGREGAN LOS POSIBLES MÓDULOS CON LOS QUE TRABAJARÍA "RAU".
     *      EN FORMA DE TABS. TODO VA DENTRO DEL JPanel basePanel. 
     *      SOLO EL TAB JClientsPanel CONTIENE LO QUE SE PIDE EN ESTE TRABAJO.
     * 3.- DENTRO DE JClientsPanel EXISTE UN PANEL LATERAL Y OTRO DE CONTENIDO.
     *      EN EL PANEL LATERAL EXISTEN 5 BOTONES CON LOS 5 REQUERIMIENTOS
     *      SOLICITADOS EN ESTE TRABAJO.
     *      CADA VEZ QUE SE PRESIONA UNO DE ESOS BOTONES LATERALES, ACTUALIZA
     *      EL PANEL DE CONTENIDO CON EL FRAME CORRESPONDIENTE.
     * 4.- POR MEDIO DE LISTENERS SE COMUNICA ENTRE JVentana, JClientsPanel,
     *      CADA UNO DE LOS REPECTIVOS PANELES (LOS 5 REQUERIMIENTOS), HASTA
     *      LLEGAR A CADA ELEMENTO, COMO LOS JButton.
     */
    public static void main(String[] args) {
        try {
            // Set cross-platform Java L&F (also called "Metal")
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
        } catch (Exception e){
            // Just catch the error
        }
        // Create Window
        JVentana jVentana = new JVentana();
        // Pass it to the clients controller
        ClientsController clientsController = new ClientsController(jVentana);
        clientsController.init();
    }
    
}
