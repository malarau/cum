/**
 * ESTRUCTURAS DE DATOS-S1 
 * Proyecto Edatos 2022
 * Selección aleatoria de turnos
 * ***************
 * - Matías Lara
 * Fecha:
 * 07/07/2022
 * ***************
 */

#include <stdio.h>
#include <stdlib.h>

/**
  **********************************************************
  * MANEJO DE ARCHIVO
  **********************************************************
 */

#define FILENAME_IN "guardias.in"
#define FILENAME_OUT "guardias.out"

void append_text(char* c, char* FILENAME){
    FILE *fptr = fopen(FILENAME, "a");
    fprintf(fptr, "%s", c);
    fclose(fptr);
}

void write_to_file(int value1, int value2, char* FILENAME){
        char auxBuff[9];
        if (value1 == value2){
            sprintf(auxBuff, "%d", value1);
            append_text(auxBuff, FILENAME);
        }else{
            sprintf(auxBuff, "%d %d", value1, value2);
            append_text(auxBuff, FILENAME);
        }
}

/**
  **********************************************************
  * ESTRUCTURA DE DATOS BÁSICA
  **********************************************************
 */

struct guard {
    struct guard *prev;
    int pos;
    struct guard *next;    
};

/**
 * @brief Inserta nuevo elemento al final de la lista.
 * 
 * @param p Dirección de memoria del último elemento.
 * @param value Valor a insertar en el nuevo elemento.
 * @return struct guard* Dirección de memoria del nuevo último elemento.
 */

struct guard* insert(struct guard* p, int value){
        struct guard *newP = (struct guard *) malloc(sizeof(struct guard));
        newP->pos = value;
        newP->prev = p;
        p->next = newP;
        return newP;
}

/**
 * @brief Creación de una lista doblemente enlazada a partir de los 3 datos entregados (N k m).
 * 
 * @param data Corresponde a una línea del archivo guardias.in
 * @return struct guard* Dirección de memoria de la cabecera.
 */

struct guard* create_list(char *data, int N){
    if (N == 0) {
        return NULL;
    }    
    // Create head
    struct guard *head = (struct guard *) malloc(sizeof(struct guard));
    if( head == NULL){
        printf("Error asignando memoria.");
        exit(1);
    }
    head->pos = 1;
    // Using aux to save head
    struct guard *aux = head;
    //
    // Create d-linked list
    for (int i = 2; i <= N; i++){
        aux = insert(aux, i);        
    }
    aux->next = head;
    head->prev = aux;

    return head;    
}

/**
 * @brief Elimina un nodo de la lista y libera la memoria. Se libera hasta el último nodo.
 * 
 * @param node El nodo a eliminar.
 * @return struct guard* Retorna el siguiente nodo o bien, nulo si corresponde al último nodo.
 */
struct guard* delete(struct guard* node){
    //printf("Deleting: %d\n", node->pos);
    if (node->next == node && node->prev == node){ // The last one
        free(node);
        return NULL;
    }else{
        struct guard* toReturn = node->next;
        (node->prev)->next = node->next;
        (node->next)->prev = node->prev;
        free(node);
        //printf("To return: %d\n", toReturn->pos);
        return toReturn;
    }
}

/**
  **********************************************************
  * FUNCIONES DE PROYECTO
  **********************************************************
 */

/**
 * @brief A partir de la cabecera de ua lista doblemente enlazada, genera el proceso solicitado.
 * 
 *      1.- Selecciona las posiciones de los guardias luego de los conteos k y m.
 *      2.- Teniendo las posiciones, elimina primero K y luego M.
 *      3.- Si son iguales, solo K y M pasa a tener el mismo nodo cabecera que K.
 *      4.- Si son distintos, para borrar M se debe revisar si actualmente corresponde a K, de ser así, se le asigna el siguiente nodo a K.
 *      5.- Casos finales:
 *          a.- Que queden 2 nodos a eliminar: El primero se borra normalmente, el segundo queda con NULL.
 *          b.- Que quede 1 nodo seleccionado para K y M, por ambos encargados, k y m: Se elimina el primero retornando NULL y se asigna manualmente NULL a M.
 * 
 * @param head Cabecera
 * @param k Encargado de k
 * @param m Encargado de m
 */

void determite_order(struct guard* head, int k, int m, char* FILENAME){
    struct guard* KPtr = head;
    struct guard* MPtr = head->prev; // Tail
    append_text(" ", FILENAME); // The example has a space at the start of every line, so...
    do
    {
        //printf("\tCabezera en K: %d // Cabezera en  M: %d\n", KPtr->pos, MPtr->pos);
        // Select guards: K
        for (int i = 1; i < k; i++){ // It does count from the guard that is facing the person that is in charge, Mr K. 
            KPtr = KPtr->next;            
        }        
        int selectedByK = KPtr->pos;

        // Select guards: M
        for (int i = 1; i < m; i++){
            MPtr = MPtr->prev;
        }        
        int selectedByM = MPtr->pos;

        write_to_file(selectedByK, selectedByM, FILENAME);

        // Delete node selected by K
        KPtr = delete(KPtr);
        // Delete node selected by M
        if (selectedByK != selectedByM){ // Check if it's not the same.
            if(MPtr == KPtr){ // Maybe the new KPtr is going to be eliminated now (Note: KPrt->next is asigned before elimination)
                KPtr = KPtr->next;
            }
            if (MPtr->next == MPtr->prev){ // Is the last.
                MPtr = delete(MPtr);
            }else{ // Not the last.
                MPtr = delete(MPtr)->prev; // Use his own head (not the same as K), we suppose has not been eliminated
            }
        }else{
            if(KPtr != NULL){ // It's not the last member of the list.
                MPtr = KPtr->prev; // Use the same head now, because they finished in the same position
            }else{ // It's the last member of the list.
                MPtr = NULL;
            }
        }               
        if(KPtr != NULL && MPtr != NULL){
            append_text(",", FILENAME);
        }
    } while (KPtr != NULL && MPtr != NULL); //  || KPtr->prev != KPtr && (MPtr != NULL || KPtr != NULL)
    // New line, new combination.
    append_text("\n", FILENAME);
}

/**
 * @brief Solo para ir graficando el actual estado.
 * 
 * @param p El nodo de referencia para iniciar conteo.
 * @param reverse Verdadero si va en reversa.
 */
void show_list(struct guard *p, int reverse){
    int startingPos = p->pos;
    do{
        if (reverse){
            p = p->prev;
            printf(" Elem: %d,", p->pos);
        }else{
            printf(" Elem: %d,", p->pos);
            p = p->next;
        }
    } while (startingPos != p->pos);
    printf("\n");
}

int random(){
    return rand () % 1000 + 1;
}

void generar_guardias_in(){
    int maxValues = 10;
    for (int i = 0; i < maxValues; i++){
        int N = random();
        write_to_file(N, N, FILENAME_IN);
        append_text(" ", FILENAME_IN);
        //
        int k = random();
        write_to_file(k, k, FILENAME_IN);
        append_text(" ", FILENAME_IN);
        //
        int m = random();
        write_to_file(m, m, FILENAME_IN);
        append_text(" ", FILENAME_IN);
        append_text("\n", FILENAME_IN);
    }
    append_text("0 0 0", FILENAME_IN);
}

int main(){
    // For testing:
    //generar_guardias_in();
    //return 0;

    printf("\n");
    char line[13]; //_999_999_999_
    int i = 0;
    FILE* file = fopen(FILENAME_IN, "r");

    if (file == NULL){
        printf("No se ha podido encontrar/usar el archivo.");
        return 1;
    }else{    
        struct guard *head = NULL;    
        while( fgets(line, sizeof(line), file) != NULL ){
            int N, k, m;
            sscanf(line, "%d %d %d", &N, &k, &m);
            if (N == 0){
                fclose(file);
                return 0;
            }
            if((N<1&&N>999) || (k<1&&k>999) || (m<1&&m>999)){
                printf("\nUno de los valores ingresados no cumple con los requisitos:\n\t 0 < X < 1000\n");
                fclose(file);
                return 1;
            }
            // We simulate the circle, given correlative numbers to every guard.
            head = create_list(line, N);
            determite_order(head, k, m, FILENAME_OUT);
        }
    }    
    fclose(file);
    return 0;
}