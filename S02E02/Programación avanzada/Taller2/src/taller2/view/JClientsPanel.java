/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package taller2.view;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.border.Border;
import taller2.view.clients.JClientsAddPanel;
import taller2.view.clients.JClientsBySectorPanel;
import taller2.view.clients.JClientsModifyPanel;
import taller2.view.clients.JClientsStatePanel;


/**
 *
 * @author Matias Lara
 */
public class JClientsPanel extends JPanel implements CustomClientListener{
    
    private JPanel menuPanel;
    private JPanel contentPanel;
    // Content Panels
    private JClientsAddPanel usersAddPanel; 
    private JClientsModifyPanel usersModifyPanel;
    private JClientsStatePanel usersStateActivePanel;
    private JClientsStatePanel usersStateInactivePanel;
    private JClientsBySectorPanel usersBySectorPanel;
    //
    private JButton activeClientesButton;
    private JButton inactiveClientesButton;
    

    public JClientsPanel(JVentana parent) {
        this.setLayout(new BorderLayout());
        // Content panel, to add, show info, etc.
        this.setContentPanel();
        
        // Menu panel, where abailable options are
        this.setMenuPanel();        
    }
    
    private final int MENU_PANEL_WIDTH = 200;
    private final int MENU_PANEL_HEIGHT = 40;
    private final int BUTTONS_HALF_SEPARATION = 2;
    // TXT
    private final String USERS_ADD = "Añadir Cliente";
    private final String USERS_MODIFY = "Modificar Cliente";
    private final String USERS_STATE_ACTIVE = "Ver Clientes Activos";
    private final String USERS_STATE_INACTIVE = "Ver Clientes Inactivos";
    private final String USERS_BY_SECTOR = "Ver Filtro por Sector";
            
    private void setMenuPanel() {
        menuPanel = new JPanel();
        menuPanel.setLayout(new BorderLayout());
                
        // Add options
        JPanel menuPanelOptions = new JPanel();
        menuPanelOptions.setLayout(new BoxLayout(menuPanelOptions, BoxLayout.Y_AXIS));
        //menuPanelOptions.setPreferredSize(new Dimension(MENU_PANEL_WIDTH, this.getHeight() ));
        
        Border padding = BorderFactory.createEmptyBorder(BUTTONS_HALF_SEPARATION, 0, BUTTONS_HALF_SEPARATION, 0);
        menuPanelOptions.setBorder(padding);
        
        // Add content
        menuPanelOptions.add(this.createNewMenu(USERS_ADD));
        menuPanelOptions.add(this.createNewMenu(USERS_MODIFY));
        menuPanelOptions.add(this.createNewMenu(USERS_STATE_ACTIVE));
        menuPanelOptions.add(this.createNewMenu(USERS_STATE_INACTIVE));
        menuPanelOptions.add(this.createNewMenu(USERS_BY_SECTOR));
        menuPanel.add(menuPanelOptions, BorderLayout.PAGE_START);

        // Set logo
        JPanel menuPanelLogo = new JPanel(new BorderLayout());
        this.setLogo(menuPanelLogo);
        menuPanel.add(menuPanelLogo, BorderLayout.PAGE_END);
        
        // Add all
        this.add(menuPanel, BorderLayout.WEST);
    }
    
    private JPanel createNewMenu(String title) {
        // Container
        JPanel panel = new JPanel(new BorderLayout());
        panel.setPreferredSize(new Dimension(menuPanel.getWidth(), MENU_PANEL_HEIGHT));
        // Borders
        Border padding = BorderFactory.createEmptyBorder(BUTTONS_HALF_SEPARATION, 10, BUTTONS_HALF_SEPARATION, 10);
        panel.setBorder(padding);
        
        JButton button = new JButton(title);
        button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                CardLayout cl = (CardLayout)(contentPanel.getLayout());
                cl.show(contentPanel, title);
            }
        });
        
        /*
        Lo más similar a tabular al instanciar:
        
        Los paneles o ventanas de Ver clientes Activos y Ver clientes Inactivo, contendrán un
        JTable que se tabularán sus datos al momento de instanciar (Constructor) a esta operación.
        Las columnas a visualizar son: Rut, Nombre, Apellido y Sector.
        */
        if( title.equals(USERS_STATE_ACTIVE) ){
            activeClientesButton = button;
        }
        if( title.equals(USERS_STATE_INACTIVE) ){
            inactiveClientesButton = button;
        }
        
        panel.add(button, BorderLayout.CENTER);        
        return panel;
    }
    
    private void setLogo(JPanel menuPanelLogo) {
        try {
            BufferedImage myPicture = ImageIO.read(getClass().getClassLoader().getResource("res/logo.jpg"));
            Image dimg = myPicture.getScaledInstance(MENU_PANEL_WIDTH, 344, Image.SCALE_SMOOTH);
            JLabel picLabel = new JLabel(new ImageIcon(dimg));
            picLabel.setMaximumSize(new Dimension(MENU_PANEL_WIDTH, 344));
            menuPanelLogo.add(picLabel, BorderLayout.CENTER);
        } catch (IOException ex) {
            Logger.getLogger(JClientsPanel.class.getName()).log(Level.SEVERE, null, ex);
        }
    }   

    private void setContentPanel() {
        contentPanel = new JPanel();
        contentPanel.setLayout(new CardLayout());
        contentPanel.setBackground(Color.GRAY);

        // Create panels
        usersAddPanel = new JClientsAddPanel();
        contentPanel.add(usersAddPanel, USERS_ADD);
        
        usersModifyPanel = new JClientsModifyPanel();
        contentPanel.add(usersModifyPanel, USERS_MODIFY);
//        
        usersStateActivePanel = new JClientsStatePanel();
        contentPanel.add(usersStateActivePanel, USERS_STATE_ACTIVE);
//        
        usersStateInactivePanel = new JClientsStatePanel();
        contentPanel.add(usersStateInactivePanel, USERS_STATE_INACTIVE);
//        
        usersBySectorPanel = new JClientsBySectorPanel();
        contentPanel.add(usersBySectorPanel, USERS_BY_SECTOR);
        // Add all
        this.add(contentPanel, BorderLayout.CENTER);
    }

    public JClientsAddPanel getUsersAddPanel() {
        return usersAddPanel;
    }
    
    public JClientsModifyPanel getModifyPanel() {
        return usersModifyPanel;
    }
    
    public JClientsModifyPanel getUsersModifyPanel() {
        return usersModifyPanel;
    }

    public JClientsStatePanel getUsersStateActivePanel() {
        return usersStateActivePanel;
    }

    public JClientsStatePanel getUsersStateInactivePanel() {
        return usersStateInactivePanel;
    }

    public JClientsBySectorPanel getUsersBySectorPanel() {
        return usersBySectorPanel;
    }
    
    @Override
    public void setCustomAddListener(ActionListener buttonListener) {
        usersAddPanel.setCustomAddListener(buttonListener);
    }

    @Override
    public void setCustomModifyListener(ActionListener buttonListener) {
        usersModifyPanel.setCustomModifyListener(buttonListener);
    }

    @Override
    public void setCustomFilterListener(ActionListener buttonListener) {
        usersBySectorPanel.setCustomFilterListener(buttonListener);
    }

    @Override
    public void setCustomSearchListener(ActionListener addButtonListener) {
        usersModifyPanel.setCustomSearchListener(addButtonListener);
    }

    public void setActiveClientsListener(ActionListener addButtonListener){
        activeClientesButton.addActionListener(addButtonListener);
    }

    void setInactiveClientsListener(ActionListener activeButtonListener) {
        inactiveClientesButton.addActionListener(activeButtonListener);
    }
}
