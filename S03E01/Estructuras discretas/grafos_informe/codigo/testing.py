
import networkx as nx
import time

from app import read_data

"""
    CHANGE THIS <-------------
"""
TIMES = 25
TEST = "kruskal" # "prim" or "kruskal"
"""
    CHANGE THIS <-------------
"""

def run_test(G, test):
    # Prim time
    start_time_prim = time.time_ns()
    nx.minimum_spanning_tree(G, algorithm=test)
    return time.time_ns() - start_time_prim

def run_time_test():
    G, _ = read_data()
    print(f"Running {TEST} test {TIMES} times...")

    sum = 0
    for _ in range(TIMES):
        sum = sum + run_test(G, "prim")
    
    print(f"Mean: {(sum/TIMES)/1_000_000_000} s")

def calculate_density():
    G, _ = read_data()
    print(nx.density(G))

if __name__ == "__main__":
    #run_time_test()
    calculate_density()