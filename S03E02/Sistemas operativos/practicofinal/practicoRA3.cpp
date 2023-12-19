#include <iostream>
#include <string>
#include <limits>  // numeric_limits
#include <cstdlib> // system("pause") al final (opcional)
#include <fstream> // Para tratar con archivoss
#include <cstring> // Para copiar el registro encontrado y enviarlo como nuevo, no una referencia a una variable local

using namespace std;

const char* fileName = "registros_directos.bin";

// Estructura para el nuevo registro
struct Record {
    char firstName[50];
    char lastName[50];
    char company[50];
    char address[50];
    char city[50];
    char county[50];
    char stateProvince[50];
    char zipCode[20];
    char phone1[20];
    char phone2[20];
    char email[50]; // Clave principal
    char web[50];
};

void printRecord(const Record& record) {
    std::cout << "\n\tFirst Name: " << record.firstName << std::endl;
    std::cout << "\tLast Name: " << record.lastName << std::endl;
    std::cout << "\tCompany: " << record.company << std::endl;
    std::cout << "\tAddress: " << record.address << std::endl;
    std::cout << "\tCity: " << record.city << std::endl;
    std::cout << "\tCounty: " << record.county << std::endl;
    std::cout << "\tState/Province: " << record.stateProvince << std::endl;
    std::cout << "\tZIP/Postal Code: " << record.zipCode << std::endl;
    std::cout << "\tPhone 1: " << record.phone1 << std::endl;
    std::cout << "\tPhone 2: " << record.phone2 << std::endl;
    std::cout << "\tEmail: " << record.email << std::endl;
    std::cout << "\tWeb: " << record.web << std::endl;
}

// Almacenamos en foundRecord
//  Entregamos uno vacío o entregamos una copia del encontrado
void searchOnFile(char* key, Record& foundRecord) {
    ifstream archivoDir(fileName, ios::in | ios::binary);

    if (!archivoDir) {
        cerr << "\n\tError al abrir el archivo." << endl;
        foundRecord = Record();
    }

    Record currentRecord;
    bool found = false;

    while (archivoDir.read(reinterpret_cast<char*>(&currentRecord), sizeof(Record))) {
        //std::cout << "Acceso Directo - Email: " << currentRecord.email << ", Nombre: " << currentRecord.firstName << std::endl;
        
        if (strcmp(key, currentRecord.email) == 0) {
            foundRecord = currentRecord;  // Copiar el registro encontrado a foundRecord
            found = true;
            break;
        }
    }

    archivoDir.close();

    if (!found) {
        foundRecord = Record();
    }
}


void writeRecordToFile(const Record& newRecord) {
    // Escribir datos con acceso directo
    fstream archivoDir(fileName, ios::out | ios::in | ios::binary | ios::trunc);

    if (!archivoDir) {
        cerr << "\n\tError al abrir el archivo." << endl;
        return;
    }

    // seek p, para put
    // seek g, para get
    // ios::end, para estar al final y 0, porque no habrá movimiento desde ese punto. Pej: -10, dejería 10 bytes más atrás del final.
    archivoDir.seekp(0, ios::end);

    // Escribir el nuevo registro en el archivo
    archivoDir.write(reinterpret_cast<const char*>(&newRecord), sizeof(Record));

    // Cerrar el archivo
    archivoDir.close();

    cout << "\n\tNuevo registro agregado al archivo." << endl;
}

// Función para crear un nuevo registro
// Retorna el creado o uno vacío si ya existe otro con la misma clave
Record createNewRecord() {
    Record newRecord;

    cout << "\tEmail (clave principal): ";
    cin.getline(newRecord.email, 50);

    // Consultar si el registro existe:
    Record tmpRecord;
    searchOnFile(newRecord.email, tmpRecord);

    // Se ha retornado un Record... Tiene info o está vacío?
    if (strlen(newRecord.email) == 0) { // Consultar si está vacío
        cout << "\tEl registro ya existe!";
        return Record();
    }

    cout << "\tFirst Name: ";
    cin.getline(newRecord.firstName, 50);

    cout << "\tLast Name: ";
    cin.getline(newRecord.lastName, 50);

    cout << "\tCompany: ";
    cin.getline(newRecord.company, 50);

    cout << "\tAddress: ";
    cin.getline(newRecord.address, 50);

    cout << "\tCity: ";
    cin.getline(newRecord.city, 50);

    cout << "\tCounty: ";
    cin.getline(newRecord.county, 50);

    cout << "\tState/Province: ";
    cin.getline(newRecord.stateProvince, 50);

    cout << "\tZIP/Postal Code: ";
    cin.getline(newRecord.zipCode, 20);

    cout << "\tPhone 1: ";
    cin.getline(newRecord.phone1, 20);

    cout << "\tPhone 2: ";
    cin.getline(newRecord.phone2, 20);

    cout << "\tWeb: ";
    cin.getline(newRecord.web, 50);

    return newRecord;
}

// Agregar un nueuvo registro
void addNewRecord() {
    cout << "\nIngrese los siguientes datos: \n";    
    Record newRecord = createNewRecord();

    // Se ha retornado un Record... Tiene info o está vacío?
    if (strlen(newRecord.email) == 0) { // Consultar si está vacío
        cout << "\tNo se puede agregar el registro porque ya existe." << endl;
        return;
    }else{
        // Agregar a archivo
        writeRecordToFile(newRecord);
    }    
}

/*
    BUSCAR REGISTRO
*/

void searchRecord() {
    cout << "\nBuscar por email:\n";

    // Consultar qué es lo que se busca
    char key[50];
    cin.getline(key, 50);

    // Buscar y almacenar en foundRecord
    Record foundRecord;
    searchOnFile(key, foundRecord);

    // Se ha retornado un Record... Tiene info o está vacío?
    if (strlen(foundRecord.email) == 0) { // Consultar si está vacío
        cout << "\n\tRegistro no existe.\n";
    }else{
        printRecord(foundRecord);       
    }
}

void modifyRecord() {
    // Consultar qué email se desea modificar
    cout << "Ingrese el email del registro que desea modificar: ";
    char key[50];
    cin.getline(key, 50);

    // Buscar y almacenar en foundRecord, o uno vacío si no existe
    Record foundRecord;
    searchOnFile(key, foundRecord);

    // Se ha retornado un Record... Tiene info o está vacío?
    if (strlen(foundRecord.email) == 0) { // Consultar si está vacío
        cout << "\n\tRegistro no encontrado.\n";
    } else {
        // Mostrar el registro actual antes de la modificación
        cout << "\nRegistro actual:\n";
        printRecord(foundRecord);

        // Solicitar las modificaciones al usuario
        cout << "\nIngrese las nuevas modificaciones:\n";
        cout << "(Deje en blanco para mantener el valor actual)\n";

        std::string input;

        cout << "\tFirst Name: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.firstName, input.c_str(), sizeof(foundRecord.firstName) - 1);
        }

        cout << "\tLast Name: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.lastName, input.c_str(), sizeof(foundRecord.lastName) - 1);
        }

        cout << "\tCompany: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.company, input.c_str(), sizeof(foundRecord.company) - 1);
        }

        cout << "\tAddress: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.address, input.c_str(), sizeof(foundRecord.address) - 1);
        }

        cout << "\tCity: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.city, input.c_str(), sizeof(foundRecord.city) - 1);
        }

        cout << "\tCounty: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.county, input.c_str(), sizeof(foundRecord.county) - 1);
        }

        cout << "\tState/Province: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.stateProvince, input.c_str(), sizeof(foundRecord.stateProvince) - 1);
        }

        cout << "\tZIP/Postal Code: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.zipCode, input.c_str(), sizeof(foundRecord.zipCode) - 1);
        }

        cout << "\tPhone 1: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.phone1, input.c_str(), sizeof(foundRecord.phone1) - 1);
        }

        cout << "\tPhone 2: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.phone2, input.c_str(), sizeof(foundRecord.phone2) - 1);
        }

        cout << "\tWeb: ";
        getline(cin, input);
        if (!input.empty()) {
            strncpy(foundRecord.web, input.c_str(), sizeof(foundRecord.web) - 1);
        }

        // Guardar las modificaciones en el archivo
        writeRecordToFile(foundRecord);

        cout << "\n\tRegistro modificado exitosamente.\n";
    }
}


// Función principal que muestra el menú
void mostrarMenu() {
    cout << "\nMenú:\n";
    cout << "1. Ingresar registro\n";
    cout << "2. Buscar registro\n";
    cout << "3. Modificar registro\n";
    cout << "4. Salir\n";
}

int obtenerEntero() {
    int valor;
    while (!(cin >> valor)) {
        // Si la entrada no es un entero, limpiamos el buffer y mostramos un mensaje de error
        cout << "Error: Ingrese un valor entero válido: ";
        cin.clear();
        cin.ignore(numeric_limits<streamsize>::max(), '\n');
    }
    return valor;
}

int main() {
    int opcion;

    do {
        mostrarMenu();
        cout << "Ingrese una opción: ";
        opcion = obtenerEntero();
        cin.ignore();

        switch (opcion) {
            case 1:
                addNewRecord();
                break;
            case 2:
                searchRecord();
                break;
            case 3:
                modifyRecord();
                break;
            case 4:
                cout << "Hasta luego!\n";
                break;
            default:
                cout << "Opción no válida. Inténtelo nuevamente.\n";
        }
    } while (opcion != 4);

    return 0;
}
