# Comentarios en espanglish

#
# g) Seleccionar e implementar una metodología de exploración de nodos (LIFO, FIFO, etc.).
#

# Implementar LIFO (Pila)
# Breadth-first: Prioriza amplitud
class LIFO():
    def __init__(self):
        self.nodes = []

    def add(self, node):
        self.nodes.append(node)

    def remove(self):
        if self.nodes:
            return self.nodes.pop()
        else:
            print("La estructura está vacía.")

# Implementar FIFO (Cola)
# Depth-first: Prioriza profundidad
class FIFO():
    def __init__(self):
        self.nodes = []

    def add(self, node):
        self.nodes.append(node)

    def remove(self):
        if self.nodes:
            return self.nodes.pop(0)
        else:
            print("La estructura está vacía.")

#
# d) Proponer e implementar una estructura de datos para guardar los nodos explorados en el B&B.
#
class Node:
    def __init__(self, index, bound, value, a_c, items):
        self.item_index = index             # Item index (or current level)
        self.upper_bound = bound            # The current upper bound
        self.accumulated_value = value      # Accumulated value
        self.accumulated_constraints = a_c  # Accumulated constraints
        self.items = items                  # {0,1} if node is taken or not

    def print_node(self):
        print(f"Index: {self.item_index}, Accmtd_Const..: {self.accumulated_constraints}, Profit: {self.accumulated_value}, Upper_bnd: {self.upper_bound}")

class Item:
    def __init__(self, value, constraints):
        self.value = value              # Value o profit
        self.constraints = constraints  # List of constraints

    def print_item(self):
        print(f"Values: {self.value}, \n\tConstraints: {self.constraints}")

# Data from txt
#   The data is represented as follows:
#   Line1       - {Number of constraints for the knapsack} (space) {Capacities of each constraint for the knapsack, space separated}
#   Line2       - Value for each item
#   From Line3  - Constraints for each item, every line a different constraint
def get_data():
    with open("data.txt", 'r') as file:
            lines = file.readlines()
            # 1st line: 
            #   Number of constraints, values of every constraint
            line = lines.pop(0).replace("\n", "").split(" ")
            n_constraints = int(line.pop(0))
            print("n_constraints", n_constraints)
            constraints = []
            for c in line:
                constraints.append(int(c))

            # 2nd line: 
            #   Items value
            line_values = lines.pop(0).replace("\n", "").split(" ")

            # 3rd to n-line: 
            #   Constraints values for all items
            items_constraints = []
            for remaining_line in lines:
                items_constraints.append(remaining_line.replace("\n", "").split(" "))

            print(line_values)
            print(items_constraints)

            # To int
            txt_data = [int(x) for x in line_values]
            matrix_data = [[int(x) for x in subarray] for subarray in items_constraints]

            # To items
            items = []
            [items.append(Item(int(a), b)) for a, b in zip(txt_data, zip(*matrix_data))]

            return constraints, items

##
# Sort data
#
# e) Proponer e implementar dos criterios para seleccionar las variables a ramificar
#
def sort_by_value(item):
    return item.value

def sort_by_ratio(item):
    return item.value / sum(item.constraints)

def print_items(items):
    for i in items:
        i.print_item()

def main(sort_function, Tree):
    best_result = 0
    best_node = None
    visited_nodes = []
    
    # Get data
    constraints, items = get_data()

    # Sort data
    items.sort(key=sort_function, reverse=True)
    print_items(items)

    # Add root to Tree, using:
    #   ub = v + (W – w)(vi+1/wi+1), modified to multiple constraints
    uv_next_item_ratio = items[0].value / sum(items[0].constraints)
    up_next_w_diff = sum(constraints) # ... + 0
    upper_bound = (up_next_w_diff * uv_next_item_ratio)

    print(f"\nUpper: {upper_bound}")
    print(constraints)
    print(f"\tNew value: 0 + (up_next_w_diff:{up_next_w_diff}, uv_next_item_ratio:{uv_next_item_ratio})")

    # Create root node
    # Index, upper_b, acc_value, acc_constraints, selected_items
    root = Node(0, upper_bound, 0, ([0]*len(constraints)), [])
    Tree.add(root)

    while( len(Tree.nodes) > 0 ):
        # Get node
        current_node = Tree.remove()
        visited_nodes.append(current_node)

        print("\n> Current node: ")
        current_node.print_node()
        print(current_node.items)

        # Check if is the best
        if current_node.accumulated_value > best_result:
            best_result = current_node.accumulated_value
            best_node = current_node

        # Get current item index
        current_item_index = current_node.item_index

        #
        # f) Implementar criterios de acotamiento propios del algoritmo B&B
        #
        # Check if the current node CAN'T provide better solutions
        if len(Tree.nodes) > 0:
            if all(current_node.upper_bound < existing_node.upper_bound for existing_node in Tree.nodes):
                print("\tEl nodo no povee una mejor solución.")
                continue
        
        # Outbounds for next item
        if current_item_index < (len(items)-1):
            uv_next_item_ratio = items[current_item_index + 1].value / sum(items[current_item_index + 1].constraints)        
        elif current_item_index == (len(items)-1):
            print("\tLast item")
            uv_next_item_ratio = 0
        else:
            print("\tOut of the bounds!")
            continue

        #################
        #               #
        #    X_i = 0    #
        #               #
        #################

        # New value
        new_value = current_node.accumulated_value + 0
        # New constraints
        new_constraints = current_node.accumulated_constraints.copy()
        # New upper bound
        up_next_w_diff = sum(constraints) - sum(new_constraints)        
        new_upper_bound = new_value + (up_next_w_diff * uv_next_item_ratio)
        print("Sin x: ", new_upper_bound)
        print(f"\tNew value: {new_value} + (up_next_w_diff:{up_next_w_diff}, uv_next_item_ratio:{uv_next_item_ratio})")

        constraints_ok = True
        for i, c in enumerate(constraints):
            if new_constraints[i] > c:
                constraints_ok = False
        
        if constraints_ok:
            selected_items = current_node.items.copy()
            selected_items.append(0)
            print("\t", selected_items)
            # Index, upper_b, acc_value, acc_constraints, selected_items
            new_node_0 = Node(current_item_index+1, new_upper_bound, new_value, new_constraints, selected_items)
            print("\tAgregar nodo sin X")
            Tree.add(new_node_0)

        #################
        #               #
        #    X_i = 1    #
        #               #
        #################

        # New value
        new_value = current_node.accumulated_value + items[current_item_index].value
        # New constraints
        new_constraints = current_node.accumulated_constraints.copy()
        for i in range(len(constraints)):
            new_constraints[i] += items[current_item_index].constraints[i]
        # New upper bound
        up_next_w_diff = sum(constraints) - sum(new_constraints)
        new_upper_bound = new_value + (up_next_w_diff * uv_next_item_ratio)
        print("Con x: ", new_upper_bound)
        print("\tNew constraints", new_constraints)
        print(f"\tNew value: {new_value} + (up_next_w_diff:{up_next_w_diff}, uv_next_item_ratio:{uv_next_item_ratio})")

        constraints_ok = True
        for i, c in enumerate(constraints):
            if new_constraints[i] > c:
                constraints_ok = False
        
        if constraints_ok:
            selected_items = current_node.items.copy()
            selected_items.append(1)
            print("\t", selected_items)
            new_node_1 = Node(current_item_index+1, new_upper_bound, new_value, new_constraints, selected_items)
            print("\tAgregar nodo con X")
            Tree.add(new_node_1)
        else:
            print("\tNo agregar nodo con X, no cumple restricciones.")

    print("\nBest result: ")
    best_node.print_node()
    for i, selected in enumerate(best_node.items):
        if selected:
            items[i].print_item()

    print("\nNumber of visited nodes: ", len(visited_nodes))

if __name__ == "__main__":
    # Sort function
    #   - sort_by_value
    #   - sort_by_ratio
    sort_function = sort_by_ratio
    # Used approach
    #   - FIFO()
    #   - LIFO()
    Tree = LIFO()

    main(sort_function, Tree)