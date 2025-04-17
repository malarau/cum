import csv
from functools import reduce

actors_filename='data/names.tsv'
titles_filename='data/titles.tsv'

names_dict = actors_dict = {}
words_dict = movies_dict = {}

# ACTORS
# ACTORS

# nconst	primaryName	birthYear	deathYear	primaryProfession	knownForTitles
def read_actors():    
    # 1.- Get every name to create tokens
    name_tokens = set()    
    with open(actors_filename, newline='', encoding = 'ISO-8859-1') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter='\t')
        next(csv_reader) # Header
        for row in csv_reader:
            if "actor" in row[4].split(","): # "actor" in primaryProfession
                [name_tokens.add(t.lower()) for t in row[1].split(" ")]
    
    # 2.- Create a dict with every token and then, link them with every coincidence.
    names_dict = dict({t:set() for t in name_tokens})
    actors_dict = {}
    with open(actors_filename, newline='', encoding = 'ISO-8859-1') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter='\t')
        next(csv_reader) # Header
        for row in csv_reader:
            if "actor" in row[4].split(","): # "actor" in primaryProfession    
                for t in row[1].lower().split(" "): # Lower of primaryName
                    names_dict[t].add(row[0]) # Save the ID
                
                # ALSO: Save the entry
                actors_dict[row[0]] = {"name": row[1], "knownForTitles":row[5]}
            
    return names_dict, actors_dict

def search_actor_in_dict(q, names_dict):
    try:
        return names_dict[q]
    except:
        return set()

"""
    Return  set()
    Every element contains a dict:
        {
            "name": String with the name,
            "knownForTitles": String "," separated with the id of every title
        }
"""
def search_actors(query, actors_dict, movies_dict, names_dict):
    results = []
    for q in query.lower().split(" "):
        results.append(search_actor_in_dict(q, names_dict))
    final_intersection = reduce(set.intersection, results)

    final_results = []
    for actor_id in final_intersection:
        actor_dict = {}
        actor_dict['id'] = actor_id
        actor_dict['name'] = actors_dict[actor_id]['name']

        knownForTitles = []
        for title_id in actors_dict[actor_id]['knownForTitles'].split(","):
            try:
                knownForTitles.append( { "id": title_id, "title": movies_dict[title_id] } )
            except Exception as err:
                print("search_actors", err)
        actor_dict['knownForTitles'] = knownForTitles

        final_results.append(actor_dict)

    return final_results

# MOVIES
# MOVIES

# tconst	titleType	primaryTitle	originalTitle	isAdult	startYear	endYear	runtimeMinutes	genres
def read_movies():    
    # 1.- Get every movie title to create tokens
    title_tokens = set()    
    with open(titles_filename, newline='', encoding = 'ISO-8859-1') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter='\t')
        next(csv_reader) # Header
        for row in csv_reader:
            # Add exactly the same: 
            # "Los resultados deben considerar el uso de mayusculas o minusculas, asi como tambien el uso de caracteres especiales."
            [title_tokens.add(t) for t in row[3].split(" ")]                
    
    # 2.- Create a dict with every token and then, link them with every coincidence.
    words_dict = dict({t:set() for t in title_tokens})
    movies_dict = {}
    with open(titles_filename, newline='', encoding = 'ISO-8859-1') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter='\t')
        next(csv_reader) # Header
        for row in csv_reader:
            if row[1] == "movie": # titleType == movie
                for t in row[3].split(" "): # originalTitle
                    words_dict[t].add(row[0]) # Save the ID
                    
                # ALSO: Save the entry
                movies_dict[row[0]] = row[3] # ID -> Title

    return words_dict, movies_dict

def search_movie_in_dict(q, words_dict):
    try:
        return words_dict[q]
    except:
        return set()

"""
    Return  set()
    Every element contains a dict:
        {
            "primaryTitle": String, movie id
        }
"""
def search_movies(query, movies_dict, words_dict):
    results = []
    for q in query.split(" "):
        results.append(search_movie_in_dict(q, words_dict))
    final_intersection = reduce(set.intersection, results)

    final_results = []
    for movie_id in final_intersection:
        movie_dict = {}
        movie_dict['id'] = movie_id
        movie_dict['name'] = movies_dict[movie_id]
        final_results.append(movie_dict)

    return final_results

if __name__ == "__main__":
    names_dict, actors_dict = read_actors()
    words_dict, movies_dict = read_movies()    
    
    flag = True
    while flag:
        print("1.- Buscar por actor.")
        print("2.- Buscar películas.")
        print("3.- Salir")
        try:
            search_option = 0
            while search_option > 3 or search_option < 1:
                search_option = int(input("Ingrese una opción: "))
        except Exception as err:
            print(str(err))
            
        if search_option == 1:
            query = input("Ingrese el nombre del actor: ")
            results = search_actors(query, actors_dict, movies_dict, names_dict)
            print(results)
        elif search_option == 2:
            query = input("Ingrese los términos para buscar: ")
            results = search_movies(query, movies_dict, words_dict)
            print(results)
        else:
            flag = False


    