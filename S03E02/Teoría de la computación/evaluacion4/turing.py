import logging

"""
    <current state> <current symbol> <new symbol> <direction> <new state>
    --

    Every position is a state, so index 0 is state 0:
        self.transition_functions = []

    Inside every state, we have a dict:    
        self.transition_functions = [{} for _ in range(n)]

    The key for the dict is the input symbol, and the value is de transition itself, so:
        self.transition_functions[current state][current symbol] => [<new symbol>, <direction>, <new state>]

    [
        # State 0
        {
            "a": ["a", "d", 2],
            "b": ["b", "i", 0],
            "-": ["a", "d", 1]
        },
        
        # State 1
        {
            "a": ["-", "i", 1],
            "b": ["b", "d", 0],
            "-": ["a", "d", 2]
        },

        # State n
        ...
    ]
"""
class TuringMachine:
    def __init__(self):
        self.input_symbols = None
        self.transition_functions = []
        self.use_cases = []

    def run(self, filename):
        try:
            self.read_data(filename)
            self.print_initial_data()
            
            print(f"Casos disponibles: {(len(self.use_cases))}")
            for i, case in enumerate(self.use_cases):
                self.process_tape(i, case)

            return True
        except Exception as err:
            logging.error(err)
            return False

    def process_tape(self, i, case):
        print(f"\nCinta de entrada para el caso {i+1}:")
        print(f'\t| {" | ".join(case)} |')
        print('\t  ^')

        self.turing_machine(case)

    def turing_machine(self, tape):
        current_state = 0
        tape_head = 0
        current_symbol = None
        
        while True:
            # Get current symbol, if it is out of bounds then it's an empty space "-"
            if 0 <= tape_head < len(tape):
                current_symbol = tape[tape_head]
            else:
                current_symbol = "-"

            # transition = [<new symbol>, <direction>, <new state>]
            transition = self.transition_functions[current_state].get(current_symbol, ["", "", -1])

            # Print data
            logging.info(f"current_state: {current_state}")
            logging.info(f"current_symbol: {current_symbol}")
            logging.info(f"tape_head: {tape_head}")
            logging.info(f"transition: {transition}")
            logging.info("-")

            # Update tape
            if 0 <= tape_head < len(tape):
                tape[tape_head] = transition[0]
            else:
                if 0 > tape_head:
                    tape.insert(0, '-')
                elif tape_head >= len(tape):
                    tape.append('-')

            # Move the tape head
            if transition[1] == "i":
                tape_head -= 1
            elif transition[1] == "d":
                tape_head += 1
            # Update current state
            if transition[2] == -1:
                break
            else:
                current_state = transition[2]

        # Final print
        print("\tLa cinta queda:")
        print(f'\t| {" | ".join(tape)} |')
        print(f'\t  {"    "*(tape_head)}^')
        print("\tPosición del cabezal:", tape_head)
        if current_state == 0 and current_symbol == '-':
            print("\t[La cadena es aceptada]")
        else:  
            print("\t[La cadena no es aceptada]")

    def print_initial_data(self):
        # States
        print(f"\nEstados: {len(self.transition_functions)}")

        # Input symbols
        print(f"Símbolos ({len(self.input_symbols)}): {'  '.join(self.input_symbols)}")
        
        # Table (Thanks ChatGPT!!)
        max_length = 3  # Adjust as needed
        #
        # Print header
        header = f"{'':^{max_length}}   {' '.join(f'{symbol:^{(max_length*4)}}' for symbol in self.input_symbols)}"
        separator = f"{'-' * max_length} + {'-' * (max_length * len(self.input_symbols) * 4 + 2)}"
        print(header)
        print(separator)
        #
        # Print transition table
        for state, transitions in enumerate(self.transition_functions):
            row = f"{state:^{max_length}} | "
            for symbol in self.input_symbols:
                transition = transitions.get(symbol, [""] * 3)
                row += f"{transition[0]:^{max_length}} {transition[1]:^{max_length}} {transition[2]:^{max_length}} |"
            print(row[:-1])
        #
        # End table (Thanks ChatGPT!!)

    def read_data(self, filename):
        with open(filename) as data:
            lines = data.readlines()

            # First line => n,m
            line = lines.pop(0).split(" ")
            n = int(line[0])
            m = int(line[1])
                # n => n states + the final state (-1)
            self.transition_functions = [{} for _ in range(n)]

            # Second line => Tape alphabet
            self.input_symbols = lines.pop(0).replace('\n', '').split(" ")
            
            # Process next n*m lines => Transition functions
            for _ in range(n*m):
                line = lines.pop(0).replace('\n', '').split(" ")
                current_state = int(line[0])

                # We store the transition directly in the dictionary corresponding to the current state
                # AND WE ASSUME THAT IS A DETERMINISTIC ONE, then is always a 1:1 match
                self.transition_functions[current_state][line[1]] = [line[2], line[3], int(line[4])]

            # Use cases, string to list (tape)
            for _ in range(int(lines.pop(0))):
                line = lines.pop(0).replace('\n', '')
                self.use_cases.append(list(line))

"""
    <current state> <current symbol> <new symbol> <direction> <new state>
"""

if __name__ == "__main__":
    logging.basicConfig(level=logging.WARNING)
    tm = TuringMachine()
    tm.run("data.txt")
