import time
from data_handling import STEP, generate_txt, read_txt
import logging, copy


class PagingSystem():
    def __init__(self, compact_threshold=0):
        self.compact_threshold = compact_threshold
        # mem
        self.mem = 0
        # [0:Nombre proceso | 1:tiempo de inicio | 2:tiempo restante | 3:bloque de inicio | 4:bloques usados] 
        self.memory_schema = []
        # [0:bloque de inicio | 1:bloques disponibles] 
        self.free_memory_schema = []
        # Every process comes to this array, if no available spaces, stays there until the next loop
        self.queue = []

        # Statistics
        #
        #   > Dict (Process: Time waiting)
        #   > +1 for every time on Q waiting
        self.waiting_on_queue = {}
        #   > A picture of the free mem schema for every t
        self.memory_history_log = []


    def get_available_space_index(self, next_process_mem, fit_type):
        if fit_type == "First Fit":
            return self.first_fit(next_process_mem)
        elif fit_type == "Best Fit":
            return self.best_fit(next_process_mem)
        elif fit_type == "Worst Fit":
            return self.worst_fit(next_process_mem)
        else:
            logging.debug("Not a valid option.")
            return -1

    def best_fit(self, next_process_mem):
        logging.debug("Using Best Fit...")

        best_index = -1
        best_block = None

        # Sort by free available blocks: x[1], ASC
        self.free_memory_schema.sort(key=lambda x: x[1])

        # Iterate to find a block with enough space
        for i in range(len(self.free_memory_schema)):
            if next_process_mem <= self.free_memory_schema[i][1]:
                # Obtener el índice del bloque encontrado
                best_block = self.free_memory_schema[i]
                logging.debug(f"\tYes, we have a block with enough space: {best_block[1]}")
                break

        if best_block != None:
            # Update values
            best_index = best_block[0]
            best_block[0] += next_process_mem
            best_block[1] -= next_process_mem

            # Check if now is a empty block
            if best_block[1] == 0:
                self.free_memory_schema.pop(i) 
        else:
            logging.debug("\tNo, we don't have enough space, queuing...")

        # Standar sort
        self.free_memory_schema.sort(key=lambda x: x[0])
        return best_index

    def worst_fit(self, next_process_mem):
        logging.debug("Using Worst Fit...")

        worst_index = -1
        worst_block = None

        #print("Len self.free_memory_schema", len(self.free_memory_schema))

        # Sort by free available blocks: x[1], DESC
        self.free_memory_schema.sort(key=lambda x: x[1], reverse=True)

        # Iterate to find a block with enough space
        if len(self.free_memory_schema) > 0 and next_process_mem <= self.free_memory_schema[0][1]: 
            # Obtener el índice del bloque encontrado
            worst_block = self.free_memory_schema[0]
            logging.debug(f"\tYes, we have a block with enough space: {worst_block}")


        if worst_block != None:
            # Update values
            worst_index = worst_block[0]
            worst_block[0] += next_process_mem
            worst_block[1] -= next_process_mem

            # Check if now is a empty block
            if worst_block[1] == 0:
                pop_elem = self.free_memory_schema.pop(0) 
                logging.debug("pop elem: {pop_elem}")
        else:
            logging.debug("\tNo, we don't have enough space, queuing...")

        # Standar sort
        self.free_memory_schema.sort(key=lambda x: x[0])
        return worst_index


    def first_fit(self, next_process_mem):
        logging.debug("Cheking for free space...")

        # Iterates over every free memory block
        for i, space in enumerate(self.free_memory_schema):
            # Is there enough space?
            if next_process_mem <= space[1]:
                logging.debug(f"\tYes, we have a block with enough space: {space}")
                index = space[0]
                # Update index on starting block
                space[0] = space[0] + next_process_mem
                space[1] = space[1] - next_process_mem
                # Delete block if no space remaining
                if space[1] == 0:
                    self.free_memory_schema.pop(i)
                return index
        else:
            logging.debug("\tNo, we have not enough space, to queue...")

        return -1

    def add_to_mem_schema(self, p, avaiable_index):
        blocks = int(p[3]/STEP)
        
        for i, working_process in enumerate(self.memory_schema):
            if working_process[3] > avaiable_index:
                self.memory_schema.insert(i, [p[0], p[1], p[2], avaiable_index, blocks])
                return
        # Is the last
        self.memory_schema.append([p[0], p[1], p[2], avaiable_index, blocks])    

    def check_fragmentation(self):
        # If compact_threshold = .2
        #   Will call compact_memory() if:
        #       len(self.free_memory_schema) = 2
        #       self.mem/STEP = 10
        #   Because 10*.2 = 2
        #
        # If compact_threshold = 0: No
        if 0 < self.compact_threshold <= 1:
            if len(self.free_memory_schema) >= (self.mem/STEP) * self.compact_threshold:
                self.compact_memory()

    # [0:Nombre proceso | 1:tiempo de inicio | 2:tiempo restante | 3:bloque de inicio | 4:bloques usados] 
    def compact_memory(self):
        logging.debug("> Compacting memory!")
        used_blocks = 0
        tmp_memory_schema = []

        for i,p in enumerate(self.memory_schema):
            if i == 0:
                tmp_memory_schema.append([p[0], p[1], p[2], 0, p[4]])
            else:
                starting_block = tmp_memory_schema[i-1][3] + tmp_memory_schema[i-1][4]
                tmp_memory_schema.append([p[0], p[1], p[2], starting_block, p[4]])

            used_blocks += p[4]

        # New mem schema
        self.memory_schema = tmp_memory_schema
        # New free mem schema
        self.free_memory_schema = [[used_blocks, int(self.mem/STEP) - used_blocks]]
    
        self.print_memory_schema()
        self.print_free_mem_schema()

    # [0:Nombre proceso | 1:tiempo de inicio | 2:tiempo restante | 3:bloque de inicio | 4:bloques usados] 
    # The process is no longer active, append his mem to free memory schema:
    #       It has to put the new free memory block on a specific position in the free_memory_schema
    def on_free_memory(self, process):
        inserted = False
        # Iterate over free memory schema finding when a starting block for a already free block of memory is greater than the starting block of the new one.
        for i, free_block in enumerate(self.free_memory_schema):
            if process[3] < free_block[0]:
                # If new starting block < some current starting block, insert on that specific position
                self.free_memory_schema.insert(i, [process[3], process[4]])
                inserted = True
                break

        # What if the new block was the latest block or there is no free memory blocks until now?
        if not inserted or (self.free_memory_schema and process[3] >= self.free_memory_schema[-1][0] + self.free_memory_schema[-1][1]):
            # Just append
            self.free_memory_schema.append([process[3], process[4]])

        # COMBINE BLOCKS
        i = 0
        tmp_free_memory_schema = []
        while i < len(self.free_memory_schema):
            # We have to check if just behind, there is a block of free memory, so we can combine
            # [ free_block | process ] <---- Combine
            if i+1 < len(self.free_memory_schema) and self.free_memory_schema[i][0] + self.free_memory_schema[i][1] == self.free_memory_schema[i+1][0]:
                logging.debug(f"\tCombinando {self.free_memory_schema[i]} con {self.free_memory_schema[i+1]}")
                tmp_free_memory_schema.append([self.free_memory_schema[i][0], self.free_memory_schema[i][1]+self.free_memory_schema[i+1][1]])
                try:
                    logging.debug(f"\tComparando tmp_free_memory_schema[-1][0]+tmp_free_memory_schema[-1][1]: {tmp_free_memory_schema[-1][0]+tmp_free_memory_schema[-1][1]}, con self.free_memory_schema[i+2][0]: {self.free_memory_schema[i+2][0]}")
                    logging.debug(f"\tY si i+2 {i+2} es < a len(tmp_free_memory_schema): {len(self.free_memory_schema)}")
                except Exception:
                    pass
                # Now, we check if we are on the middle, between 2 free blocks of memory
                # [ [ free_block | process ] | free_block ] <---- Combine
                if i+2 < len(self.free_memory_schema) and tmp_free_memory_schema[-1][0]+tmp_free_memory_schema[-1][1] == self.free_memory_schema[i+2][0]:
                    last_added = tmp_free_memory_schema.pop()
                    logging.debug(f"\t\tCombinando {last_added} con {self.free_memory_schema[i+2]}")
                    tmp_free_memory_schema.append([last_added[0], last_added[1]+self.free_memory_schema[i+2][1]])
                    i += 3
                else:
                    i += 2
            else:
                tmp_free_memory_schema.append(self.free_memory_schema[i])
                i += 1
        self.free_memory_schema = tmp_free_memory_schema
        
    def remove_inactive_processes(self):
        tmp_memory = []
            
        for working_process in self.memory_schema:
            # Check if process has remaining time = active
            if working_process[2] > 0:
                # Save it
                tmp_memory.append(working_process)
            else:
                # Dont save it (remove from memory_schema)
                logging.debug(f"Process {working_process} is no longer active")
                self.on_free_memory(working_process)
                self.print_free_mem_schema()

        self.memory_schema = tmp_memory

    def print_free_mem_schema(self):
        logging.debug("> free_memory_schema:")
        if len(self.free_memory_schema) != 0:
            for p in self.free_memory_schema:
                logging.debug(p)
        else:
            logging.debug("[]")

    def print_queue(self):
        logging.debug("> queue:")
        if len(self.queue) != 0:
            for p in self.queue:
                logging.debug(p)
        else:
            logging.debug("[]")

    def print_memory_schema(self):
        logging.debug("> memory_schema:")
        if len(self.memory_schema) != 0:
            for p in self.memory_schema:
                logging.debug(p)
        else:
            logging.debug("[]")

    def print_memory_history_log(self):
        logging.debug("> memory_history_log:")
        for p in self.memory_history_log:
            logging.debug(p)

    def print_memory_status(self, t, is_waiting):
        # [ process_name | start_block | end_block ]
        mem_blocks = []

        # Append all mem blocks
        for mem_block in self.memory_schema:
            mem_blocks.append([mem_block[0], mem_block[3], mem_block[4]])
        # Append all free mem blocks
        for free_mem_block in self.free_memory_schema:
            mem_blocks.append(["   ", free_mem_block[0], free_mem_block[1]])

        # Sort using start_block
        mem_blocks.sort(key=lambda x: x[1])

        # Print values
        mem_buffer = ">>"
        for block in mem_blocks:
            mem_buffer = mem_buffer + "["
            for _ in range(block[2]):
                mem_buffer = f"{mem_buffer} {block[0]:1} |"
            mem_buffer = mem_buffer[:-1]
            mem_buffer = mem_buffer + "]"
            
        mem_buffer = mem_buffer + "<<"

        logging.info(f"\n\t[t = {t}]")
        
        logging.info("Memory:")
        logging.info("\t"+mem_buffer)
        
        logging.info("Is waiting?")
        logging.info(f"\t {is_waiting == -1}")
        
        logging.info("Queue:")
        msg_queue = "["
        for p in self.queue:
            msg_queue = f"{msg_queue} {p[0]}"
        msg_queue = f"{msg_queue} ]"
        if len(self.queue) != 0:
            logging.info("\t"+msg_queue)
        else:
            logging.info("\t[]")


    def run_algorithm(self, fit_type):
        # Read data
        self.mem, p_list = read_txt()

        # From: t_0 -> t_i
        used_blocks = 0
            
        for p in p_list:
            # Loop {p_list} until start time is no longer 0
            if p[1] != 0:
                break

            # Transform memory kb to blocks
            blocks = int(p[3]/STEP)

            # memory_schema:
                # [0:Nombre proceso | 1:tiempo de inicio | 2:tiempo restante | 3:bloque de inicio | 4:bloques usados] 

            # Put every process inside memory schema, if empty, start block: 0, otherwise: calculate {starting_block} 
            if len(self.memory_schema) == 0:
                self.memory_schema.append([p[0], p[1], p[2], 0, blocks])
            else:
                starting_block = self.memory_schema[-1][3] + self.memory_schema[-1][4]
                self.memory_schema.append([p[0], p[1], p[2], starting_block, blocks])

            # How many blocks used?
            used_blocks = used_blocks + blocks

        # Remove from inicial process list {p_list} the firts {len(memory_schema)} process (starting time: 0)
        p_list = p_list[len(self.memory_schema):]

        # free_memory_schema
            # [0:bloque de inicio | 1:bloques disponibles]
        
        # Calculate free memory
        self.free_memory_schema.append([used_blocks, int(self.mem/STEP) - used_blocks])
                
        # From: t_i -> t_n
        t = 1
        # While remaining process on txt file or Q:
        while(len(p_list) > 0 or len(self.queue) > 0):
            #time.sleep(0.5)
            logging.debug(f"\n\t[t = {t}]")
            t += 1
            
            self.print_memory_schema()
            self.print_queue()
            self.print_free_mem_schema()

            # STATISTICS HERE
            #   The free memory log: For every t, capture a copy on the actual state of free memory schema
            self.memory_history_log.append(copy.deepcopy(self.free_memory_schema))
            #self.print_memory_history_log()

            self.check_fragmentation()

            # If remainig time = 0, delete from memory
            self.remove_inactive_processes()        

            # Add process to the Q, if Q is empty then will be processed now
            if len(p_list) > 0:
                self.queue.append(p_list.pop(0))

            # Check if there are any free space available
            avaiable_index = self.get_available_space_index(int(self.queue[0][3]/STEP), fit_type)

            if avaiable_index != -1:
                new_process = self.queue.pop(0)
                logging.debug(f"\tAdding process: {new_process}]")
                self.add_to_mem_schema(new_process, avaiable_index)           

            for working_process in self.memory_schema:
                working_process[2] -= 1

            # STATISTICS HERE
            #   Waiting on Q: Every time a process is waiting a time, count it on {waiting_on_queue}
            for p in self.queue:
                self.waiting_on_queue[p[0]] = self.waiting_on_queue.get(p[0], 0) + 1

            logging.debug("---------------")
            self.print_memory_status(t, avaiable_index)
            
        return self.waiting_on_queue, self.memory_history_log, t 

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    fit_types = ["First Fit", "Best Fit", "Worst Fit"]    

    # Get a new file
    for i in range(1):
        print("i: ", i)
        generate_txt(15)

        exp = PagingSystem()
        exp.run_algorithm(fit_types[0])
        print("\tDone:",fit_types[0])
        
        """
        exp = PagingSystem()
        exp.run_algorithm(fit_types[1])
        print("\tDone:",fit_types[1])
        
        exp = PagingSystem()
        exp.run_algorithm(fit_types[2])
        print("\tDone:",fit_types[2])
        """
