/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package taller2.view;

import java.awt.BorderLayout;
import java.awt.HeadlessException;
import java.awt.event.ActionListener;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTabbedPane;

/**
 *
 * @author Matias Lara
 */

public class JVentana extends JFrame implements CustomClientListener{   
    
    public static final String WINDOW_NAME = "Cooperativa Rau Ltda.";
    //
    public final int W_WIDTH = 860;
    public final int W_HEIGHT = 640;
    
    private JPanel basePanel;
    // Clientes
    private JClientsPanel jClientPanel;
    
    public JVentana() throws HeadlessException {
        super(WINDOW_NAME);
        this.setUpWindow();   
    }
    
    public JClientsPanel getClientPanel(){
        return jClientPanel;
    }
    
    private void setUpWindow() {
        this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        this.setLayout(new BorderLayout());
        this.setLocation(150, 100);
        
        basePanel = new JPanel(new BorderLayout());
        this.add(basePanel);
        // Adds panels to basePanel
        this.addPanels();
        // Set windows size
        this.setSize(W_WIDTH, W_HEIGHT);
    }

    // Add panels
    private void addPanels() {
        // Panel creation
        this.jClientPanel = new JClientsPanel(this);
        
        // Match every tab with a Panel
        JTabbedPane tabs = new JTabbedPane();
        tabs.setTabPlacement(JTabbedPane.TOP);
        tabs.addTab("Gestión de usuarios", this.jClientPanel);
        tabs.addTab("Gestión de lecturas", new JEmptyPanel("Gestión de lecturas"));
        tabs.addTab("Módulo de pagos", new JEmptyPanel("Módulo de pagos"));
        tabs.addTab("Módulo de convenios", new JEmptyPanel("Módulo de convenios"));
        basePanel.add(tabs, BorderLayout.CENTER);

        // Adding bottom panel
        this.addBottomPanel();
    }

    // Just to decorate
    private void addBottomPanel() {
        JPanel bottomPanel = new JPanel(new BorderLayout());
        bottomPanel.add(new JLabel(WINDOW_NAME), BorderLayout.EAST);
        basePanel.add(bottomPanel, BorderLayout.PAGE_END);
    }

    @Override
    public void setCustomAddListener(ActionListener buttonListener) {
        jClientPanel.setCustomAddListener(buttonListener);
    }

    @Override
    public void setCustomModifyListener(ActionListener buttonListener) {
        jClientPanel.setCustomModifyListener(buttonListener);
    }

    @Override
    public void setCustomFilterListener(ActionListener buttonListener) {
        jClientPanel.setCustomFilterListener(buttonListener);
    }

    @Override
    public void setCustomSearchListener(ActionListener buttonListener) {
        jClientPanel.setCustomSearchListener(buttonListener);
    }
    
    public void setActiveClientsListener(ActionListener activeButtonListener) {
        jClientPanel.setActiveClientsListener(activeButtonListener);
    }    

    public void setInactiveClientsListener(ActionListener inactiveButtonListener) {
        jClientPanel.setInactiveClientsListener(inactiveButtonListener);
    }
}
