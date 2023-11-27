import random

FILENAME = "entrada.txt"

# Total memory variables
UPPER_LIMIT = 200
LOWER_LIMIT = 100
STEP = 10

# Max process duration
MAX_DURATION = 12

# How much space will use processes in t0
T0_FILL_PERCENT = .8

"""
    Primera línea: Un valor numérico natural factor de 10, que se encuentra entre 100 y 200.
"""
def calculate_total_mem():
    # Gen a value between 0 and 10
    random_step = random.randint(0, (UPPER_LIMIT-LOWER_LIMIT)/STEP)

    # So:
    return LOWER_LIMIT + (random_step * STEP)

"""
    Líneas 2 hasta i-ésima: Procesos que se encuentran en memoria en el tiempo t0 (la suma de
    sus pesos no puede ser mayor al tamaño total de memoria).

    Los procesos generados no superarán la mitad de la memoria máxima.
"""
def get_firts_processes(max_memory):
    process_list = []
    current_memmory = 0

    # We can't use all memory on t0
    for i in range(1, int(max_memory/STEP)):
        # Get values

            # > Random memory value, between 1 and (max_mem/2)
        p_memory = random.randint(1, int(max_memory/STEP))*STEP  
        
        # Check current used mem is lower, if not: BREAK and not add the process
        current_memmory = current_memmory + p_memory     
        if current_memmory >= max_memory:
            break

            # > Get process duration time
        p_time = random.randint(1, MAX_DURATION)

        # Adding values
        process_list.append(f"P{(str(len(process_list)+1)).zfill(2)},  t0, {p_time}, {p_memory} kb")
    return process_list

def get_last_n_processes(n, size_firts_n, max_memory):
    process_list = []

    # We can't fill memory on t0
    for i in range(0, n):
        # Get values

            # > Random memory value, between 1 and (max_mem/2)
        p_memory = random.randint(1, int((max_memory/2)/STEP) )*STEP  
        
            # > Get process duration time
        p_time = random.randint(1, MAX_DURATION)

        # Adding values
        process_list.append(f"P{(str(len(process_list)+size_firts_n+1)).zfill(2)}, t{str(i+1)}, {p_time}, {p_memory} kb")
    return process_list

"""
    Generates a txt file.
    
    La información de cada proceso es:     
    [Nombre proceso | tiempo relativo de inicio | duración en memoria | peso en kb]  
"""
def generate_txt(n):
    # Memory
    total_mem = calculate_total_mem()
    with open(FILENAME, 'w') as file:
        file.write(f"{total_mem} kb\n")

    # Process
        # t_0 -> t_i
    firts_p = get_firts_processes(total_mem*T0_FILL_PERCENT)
        # t_i -> t_n
    last_p = get_last_n_processes(n-len(firts_p), len(firts_p), total_mem)

    process_list = firts_p + last_p
    with open(FILENAME, 'a') as file:
        for line in process_list:
            file.write(f"{line}\n")

# read_txt
# Return memory, process_list
def read_txt():
    try:
        with open(FILENAME, 'r') as file:
            # Read all lines
            lines = file.readlines()

            # Total memory
            memory = int(lines.pop(0).replace(" kb", ""))

            # Processes
            process_list = []    
            for line in lines:
                # Line
                p_data = line.split(",")
                    # Name
                name = p_data[0].strip()
                    # Start time
                start_time = int(p_data[1].strip().replace("t", ""))
                    # Duration
                duration = int(p_data[2].strip())                
                    # Memory
                mem = int(p_data[3].strip().replace(" kb", ""))
                # Append data
                process_list.append([name, start_time, duration, mem])

            return memory, process_list

    except FileNotFoundError:
        print(f"El archivo '{FILENAME}' no fue encontrado.")
        return None
    except Exception as e:
        print(f"Error al leer el archivo: {e}")
        return None

if __name__ == "__main__":

    """
        EJ: GENERA UN NUEVO TEXTO, CON 15 PROCESOS
        generate_txt(15)
    """
    generate_txt(15)
    
    mem, data = read_txt()
    for d in data:
        print(d)
    