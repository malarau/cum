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
def run_experiments(n):
    results = []

    for _ in range(n):
        # Get a new txt file every time
        #generate_txt(number_of_process)

        data = {}
        for fit_type in fit_types:
            exp = PagingSystem()
            waiting_on_queue, memory_history_log = exp.run_algorithm(fit_type)
            data[fit_type] = {"waiting_on_queue": waiting_on_queue, "memory_history_log": memory_history_log}
        results.append(data)

    return results

def print_results(results):
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

if __name__ == "__main__":
    logging.basicConfig(level=logging.CRITICAL)
    results = run_experiments(2)

    print_results(results)