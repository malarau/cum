/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package taller2.controller;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;
import taller2.model.Client;
import taller2.model.Metodos_BD;
import taller2.model.Status;
import taller2.view.JVentana;
import taller2.view.clients.JClientsAddPanel;
import taller2.view.clients.JClientsBySectorPanel;
import taller2.view.clients.JClientsModifyPanel;
import taller2.view.clients.JClientsStatePanel;

/**
 *
 * @author Matias Lara
 */
public class ClientsController {

    private static final Metodos_BD M_BD = new Metodos_BD();
    
    private final JVentana jVentana;
    // Add client Listener
    private ActionListener addButtonListener;
    private ActionListener searchButtonListener;
    private ActionListener modifyButtonListener;
    private ActionListener filterButtonListener;
    // Active/Inactive
    private ActionListener activeButtonListener;
    private ActionListener inactiveButtonListener;
    
    public ClientsController(JVentana jVentana) {
        this.jVentana = jVentana;
    }
    
    public void init(){
        jVentana.setVisible(true);
        setActionListeners();
    }
    
    private void setActionListeners() {
        // ADD
        addButtonListener = (ActionEvent e) -> {
            JClientsAddPanel panel = this.jVentana.getClientPanel().getUsersAddPanel();
            if (panel.getRUT().isBlank() || panel.getNombre().isBlank() || panel.getApellido().isBlank() ){
                JOptionPane.showMessageDialog(jVentana, "Debe completar todos los campos.","Sistema", JOptionPane.WARNING_MESSAGE);
            }else{
                Client client = new Client();                
                client.setRUT(panel.getRUT());
                client.setNombre(panel.getNombre());
                client.setApellido(panel.getApellido());
                client.setSector(panel.getSector());
                client.setEstado(panel.getEstado());
                // Send to database
                M_BD.addClient(client);
                
                // Update View
                panel.cleanView();                
            }
        };
        jVentana.setCustomAddListener(addButtonListener);
        
        // SEARCH
        searchButtonListener = (ActionEvent e) -> {
            JClientsModifyPanel panel = this.jVentana.getClientPanel().getModifyPanel();
            
            if (panel.getRUT().isBlank()){
                JOptionPane.showMessageDialog(jVentana, "Debe ingresar un RUT.","Sistema", JOptionPane.ERROR_MESSAGE);
            }else{
                // Search in database
                String[] dataClient = M_BD.searchClient(panel.getRUT());
                // Update values on view
                if( dataClient != null ) {
                    panel.setNombre(dataClient[0]);
                    panel.setApellido(dataClient[1]);
                    panel.setSector(dataClient[2]);
                    panel.setEstado(dataClient[3]);
                    panel.setModifyButtonStatus(true);
                }
            }
        };
        jVentana.setCustomSearchListener(searchButtonListener);
        
        // MODIFY
        modifyButtonListener = (ActionEvent e) -> {
            JClientsModifyPanel panel = this.jVentana.getClientPanel().getModifyPanel();
            
            if (panel.getRUT().isBlank()){
                JOptionPane.showMessageDialog(jVentana, "Debe ingresar un RUT.","Sistema", JOptionPane.ERROR_MESSAGE);
            }else{
                // TODO: SI INGRESA RUT, PERO NO ES VALIDADO SU FORMATO!!!
                if ( panel.getNombre().isBlank() || panel.getApellido().isBlank() ){
                    JOptionPane.showMessageDialog(jVentana, "Debe completar todos los campos.","Sistema", JOptionPane.WARNING_MESSAGE);
                }else{
                    // TODO: Buscar en base de datos.
                    
                    // Si no existe resultado será null. Se lo contrario, modificar objeto cliente y actualizar DB
                    Client client = new Client();                
                    client.setRUT(panel.getRUT());
                    client.setNombre(panel.getNombre());
                    client.setApellido(panel.getApellido());
                    client.setSector(panel.getSector());
                    client.setEstado(panel.getEstado());
                    // Send to database
                    M_BD.modifyClient(client);
                    
                    // Update view
                    panel.setNombre("");
                    panel.setApellido("");
                    panel.setSector("-");
                    panel.setEstado("-");
                    panel.setModifyButtonStatus(false);
                }
            }
        };
        jVentana.setCustomModifyListener(modifyButtonListener);
        
        // FILTER
        filterButtonListener = (ActionEvent e) -> {
            JClientsBySectorPanel panel = this.jVentana.getClientPanel().getUsersBySectorPanel();
            String sector = panel.getSector();
            // Create a default table
            DefaultTableModel tableModel = createDefaultTable();
            // Set the new table model to the view
            panel.setTableModel(tableModel);
            // Send to database, and update it
            M_BD.filterBySector(tableModel, sector);            
        };
        jVentana.setCustomFilterListener(filterButtonListener);
        
        // ACTIVE
        activeButtonListener = (ActionEvent e) -> {
            JClientsStatePanel panel = this.jVentana.getClientPanel().getUsersStateActivePanel();
            // Create a default table
            DefaultTableModel tableModel = createDefaultTable();
            // Set the new table model to the view
            panel.setTableModel(tableModel);    
            // Send to database, and update it
            M_BD.filterByStatus(tableModel, Status.ACTIVO.getTextValue()); 
            
        };
        jVentana.setActiveClientsListener(activeButtonListener);
        
        // INACTIVE
        inactiveButtonListener = (ActionEvent e) -> {
            JClientsStatePanel panel = this.jVentana.getClientPanel().getUsersStateInactivePanel();
            // Create a default table
            DefaultTableModel tableModel = createDefaultTable();
            // Set the new table model to the view
            panel.setTableModel(tableModel);    
            // Send to database, and update it
            M_BD.filterByStatus(tableModel, Status.INACTIVO.getTextValue()); 
        };
        jVentana.setInactiveClientsListener(inactiveButtonListener);
    }

    private DefaultTableModel createDefaultTable(){
        // Create a default table
        DefaultTableModel tableModel = new DefaultTableModel();
        tableModel.addColumn("RUT");
        tableModel.addColumn("Nombre");
        tableModel.addColumn("Apellido");
        tableModel.addColumn("Sector");
        return tableModel;
    }
}
