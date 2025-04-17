from app import read_data
import networkx as nx
from memory_profiler import memory_usage, profile
import time


def calculate_density(G):
    print()

@profile
def kruskal_algorithm(G):
    K = nx.minimum_spanning_tree(G, algorithm="kruskal")
    print(nx.density(K))

@profile
def prim_algorithm(G):
    P = nx.minimum_spanning_tree(G, algorithm="prim")
    print(nx.density(P))

def memory_usage_test(G):
    # Medir la memoria utilizada por el algoritmo de Kruskal
    kruskal_memory = memory_usage((kruskal_algorithm, (G,), {}))
    print("Uso de memoria de Kruskal:", max(kruskal_memory) - min(kruskal_memory))

    # Medir la memoria utilizada por el algoritmo de Prim
    prim_memory = memory_usage((prim_algorithm, (G,), {}))
    print("Uso de memoria de Prim:", max(prim_memory) - min(prim_memory))


if __name__ == "__main__":
    G, _ = read_data()
    memory_usage_test(G)
    #prim_algorithm(G)
    #kruskal_algorithm(G)
    
