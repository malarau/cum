import logging
from app import PagingSystem
from data_handling import generate_txt

# Tipos de ajuste
fit_types = ["First Fit", "Best Fit", "Worst Fit"]

"""
    Run {n} times, every time it runs, it does for the 3 adjust algorithms (first, best, worst).
    Then save data into {results}

    results {
        {
            "First Fit":{
                waiting_on_queue: {...dict},
                memory_history_log = [...array]
            },
            "Best Fit":{
                waiting_on_queue: {...dict},
                memory_history_log = [...array]
            },
            "Worst Fit":{
                waiting_on_queue: {...dict},
                memory_history_log = [...array]
            }
        },
        { 
            ... 
        }
    }
"""
def run_experiments(number_of_experiments, number_of_process, compact_percent):
    results = []
    results_compacting = []

    print("Current: ")
    for i in range(number_of_experiments):
        #print(f"\tExperiment #{i+1}")
        # Get a new txt file every time
        generate_txt(number_of_process)

        # Normal
        data = {}
        for fit_type in fit_types:
            exp = PagingSystem()
            waiting_on_queue, memory_history_log, t = exp.run_algorithm(fit_type)
            data[fit_type] = {"waiting_on_queue": waiting_on_queue, "memory_history_log": memory_history_log, "total_time": t}
        results.append(data)

        # Compacting
        data_compacting = {}
        for fit_type in fit_types:
            exp = PagingSystem(compact_percent)
            waiting_on_queue, memory_history_log, t = exp.run_algorithm(fit_type)
            data_compacting[fit_type] = {"waiting_on_queue": waiting_on_queue, "memory_history_log": memory_history_log, "total_time": t}
        results_compacting.append(data_compacting)

    return results, results_compacting

def print_all_results(results):
    for experiment_num, fit_data in enumerate(results):
        print(f"Experiment {experiment_num}:")
        for fit_type, metrics in fit_data.items():
            print(f"\t{fit_type}:")
            print(f"\t\tWaiting on Queue: {metrics['waiting_on_queue']}")
            print(f"\t\tMemory History Log: ")
            for block in metrics['memory_history_log']:
                print(f"\t\t\t{block}")
            print("\t---")
        print("---")

def print_results(title, sum, counted):
    print(title)
    for fit_type in fit_types:
        print(f"\t{fit_type:9}: {round(sum[fit_type]/counted[fit_type], 4)}")

def average_free_memory_blocks(results):
    # Promedio de bloques de memoria libre para cada t
    total_blocks = {fit_type: 0 for fit_type in fit_types}
    total_times = {fit_type: 0 for fit_type in fit_types}

    # For every experiment
    for experiment in results:
        # -> For every fit type (best, worst, first)
        for fit_type, data in experiment.items():
            # -> For every t, check how many blocks of free memory
            for free_mem_blocks in data['memory_history_log']:
                total_blocks[fit_type] += len(free_mem_blocks)
            total_times[fit_type] += len(data['memory_history_log'])
    
    print_results("Average free blocks for every t:", total_blocks, total_times)

def average_waiting_time(results):
    total_wait_time = {fit_type: 0 for fit_type in fit_types}
    total_times = {fit_type: 0 for fit_type in fit_types}

    # For every experiment
    for experiment in results:
        # -> For every fit type (best, worst, first)
        for fit_type, data in experiment.items():
            # -> Sums all the waiting times
            for process, wait_time in data['waiting_on_queue'].items():
                total_wait_time[fit_type] += wait_time
                total_times[fit_type] += 1
    
    print_results("Average waiting time:", total_wait_time, total_times)

def average_block_extension(results):
    total_extension = {fit_type: 0 for fit_type in fit_types}
    total_blocks = {fit_type: 0 for fit_type in fit_types}

    for experiment in results:
        for fit_type, data in experiment.items():

            for memory_log in data["memory_history_log"]:
                for block in memory_log:
                    total_extension[fit_type] += block[1]
                    total_blocks[fit_type] += 1
    
    print_results("Average block extension for free memory blocks:", total_extension, total_blocks)

def average_time_to_complete(results):
    total_time = {fit_type: 0 for fit_type in fit_types}
    total_count = {fit_type: 0 for fit_type in fit_types}

    for experiment in results:
        for fit_type, data in experiment.items():
            total_time[fit_type] += data['total_time']
            total_count[fit_type] += 1
    
    print_results("Average total time to complete:", total_time, total_count)

if __name__ == "__main__":
    logging.basicConfig(level=logging.CRITICAL)

    # (number_of_experiments, number_of_process)
    number_of_experiments = 1000
    number_of_process = 50
    results, results_compacting = run_experiments(number_of_experiments, number_of_process, .4)
    #print_all_results(results)

    print(f"After {number_of_experiments} experiments")

    # Promedio de bloques de memoria libre para cada t
    average_free_memory_blocks(results)
    average_free_memory_blocks(results_compacting)
    print()

    # Tiempo Medio de Espera
    average_waiting_time(results)
    average_waiting_time(results_compacting)
    print()

    # Extensión Promedio de Bloques
    average_block_extension(results)
    average_block_extension(results_compacting)
    print()

    # Tiempo que ha tomado en completar la lista de procesos
    average_time_to_complete(results)
    average_time_to_complete(results_compacting)