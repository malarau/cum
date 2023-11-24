from data_handling import STEP, read_txt
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
            logging.info("Not a valid option.")
            return -1

    def best_fit(self, next_process_mem):
        logging.info("Using Best Fit...")

        best_index = -1
        best_size = float('inf')  # Biggest value

        for i, space in enumerate(self.free_memory_schema):
            if next_process_mem <= space[1] < best_size:
                best_index = space[0]
                best_size = space[1] # This is the best fit... Just for now

        if best_index != -1:
            # We have a winner! Updating values
            self.free_memory_schema[i][0] += next_process_mem
            self.free_memory_schema[i][1] -= next_process_mem
            # Check if the used block now is a empty block, if so, delete it
            if self.free_memory_schema[i][1] == 0:
                self.free_memory_schema.pop(i)
            return best_index

        logging.info("\tNo, we don't have enough space, queuing...")
        return -1

    def worst_fit(self, next_process_mem):
        logging.info("Using Worst Fit...")

        worst_index = -1
        worst_size = -1  # Small value

        for i, space in enumerate(self.free_memory_schema):
            if next_process_mem <= space[1] > worst_size:
                worst_index = space[0]
                worst_size = space[1]

        if worst_index != -1:
            # We have a winner, update values
            self.free_memory_schema[i][0] += next_process_mem
            self.free_memory_schema[i][1] -= next_process_mem
            # Check if the used block now is a empty block, if so, delete it
            if self.free_memory_schema[i][1] == 0:
                self.free_memory_schema.pop(i)
            return worst_index

        logging.info("\tNo, we don't have enough space, queuing...")
        return -1


    def first_fit(self, next_process_mem):
        logging.info("Cheking for free space...")

        # Iterates over every free memory block
        for i, space in enumerate(self.free_memory_schema):
            # Is there enough space?
            if next_process_mem <= space[1]:
                logging.info(f"\tYes, we have a with enough space: {space}")
                index = space[0]
                # Update index on starting block
                space[0] = space[0] + next_process_mem
                space[1] = space[1] - next_process_mem
                # Delete block if no space remaining
                if space[1] == 0:
                    self.free_memory_schema.pop(i)
                return index
        else:
            logging.info("\tNo, we have not enough space, to queue...")

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
        logging.info("> Compacting memory!")
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


    # The process is no longer active, append his mem to free memory schema
    def on_free_memory(self, process):    
        for i, free_block in enumerate(self.free_memory_schema):
            # If starting process block is less than {free_block}
            if process[3] < free_block[0]:
                # If there are no gaps, update {free_block}
                if process[3] + process[4] == free_block[0]:
                    # [ process | free_block ] <---- Combine
                    free_block[0] = process[3]
                    free_block[1] = free_block[1] + process[4]
                elif i != 0 and self.free_memory_schema[i-1][0] + self.free_memory_schema[i-1][1] == free_block[0]:
                    #[ free_memory_schema[i-1] | process | free_block ] <---- Combine all
                    self.free_memory_schema[i-1][1] = self.free_memory_schema[i-1][1] + free_block[1]
                    self.free_memory_schema.pop(i)
                else:
                    # Otherwise, just append
                    self.free_memory_schema.insert(i, [process[3], process[4]])
                return
        # It was the last block
        self.free_memory_schema.append([process[3], process[4]])

    def remove_inactive_processes(self):
        tmp_memory = []
            
        for working_process in self.memory_schema:
            # Check if process has remaining time = active
            if working_process[2] > 0:
                tmp_memory.append(working_process)
            else:
                logging.info(f"Process {working_process} is no longer active")
                self.on_free_memory(working_process)
                self.print_free_mem_schema()

        self.memory_schema = tmp_memory

    def print_free_mem_schema(self):
        logging.info("> free_memory_schema:")
        for p in self.free_memory_schema:
            logging.info(p)

    def print_queue(self):
        logging.info("> queue:")
        for p in self.queue:
            logging.info(p)

    def print_memory_schema(self):
        logging.info("> memory_schema:")
        for p in self.memory_schema:
            logging.info(p)

    def print_memory_history_log(self):
        logging.info("> memory_history_log:")
        for p in self.memory_history_log:
            logging.info(p)

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
            logging.info(f"\n\t[t = {t}]")
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
                self.add_to_mem_schema(self.queue.pop(0), avaiable_index)           

            for working_process in self.memory_schema:
                working_process[2] -= 1

            # STATISTICS HERE
            #   Waiting on Q: Every time a process is waiting a time, count it on {waiting_on_queue}
            for p in self.queue:
                self.waiting_on_queue[p[0]] = self.waiting_on_queue.get(p[0], 0) + 1

            logging.info("---------------")
            
        return self.waiting_on_queue, self.memory_history_log

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    fit_types = ["First Fit", "Best Fit", "Worst Fit"]    

    exp = PagingSystem()
    exp.run_algorithm(fit_types[0])

    # {'P3': 1, 'P4': 2, 'P5': 2}