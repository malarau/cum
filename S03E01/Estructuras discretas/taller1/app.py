from flask import Flask, render_template, request
from data.appdata import read_actors, read_movies, search_actors, search_movies


app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    search_type = request.args.get('searchtype', default=None)
    print("Search: ", search_type)

    if search_type == None:
        return render_template('index.html')
    else:
        query = request.args.get('search')
        print("Q: ", query)
        if search_type == 'actors':
            data = search_actors(query, actors_dict, movies_dict, names_dict)
            print("data:\n", data)
            return render_template('index.html', results=data,  search_type=search_type, query=query)
        elif search_type == 'movies':
            data = search_movies(query, movies_dict, words_dict)
            return render_template('index.html', results=data, search_type=search_type, query=query)
        else:
            return render_template('index.html')
        
names_dict = actors_dict = {}
words_dict = movies_dict = {}
if __name__ == '__main__':
    names_dict, actors_dict = read_actors()
    words_dict, movies_dict = read_movies()
    app.run(debug=True)
