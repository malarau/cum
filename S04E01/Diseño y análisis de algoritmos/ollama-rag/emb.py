import ollama, chromadb

text_file = "paul_graham_essay.txt"
model = "phi3"
collection_name = "docs"

"""
    Step 1: Generate embeddings
"""

# Chromadb
client = chromadb.Client()
client = chromadb.PersistentClient(path="./data")


try:
    collection = client.get_collection(name=collection_name)
except:
    collection = client.create_collection(name=collection_name)

    # txt file
    document = []
    with open(text_file) as file:
        for line in file.readlines():
            if line != '\n':
                document.append(line.replace('\n', ''))

    # store each document in a vector embedding database
    for i, d in enumerate(document):
        response = ollama.embeddings(model=model, prompt=d)
        embedding = response["embedding"]
        collection.add(
            ids=[str(i)],
            embeddings=[embedding],
            documents=[d]
        )
        print(f'Line {i}/{len(document)}')

"""
    Step 2: Retrieve
"""
# an example prompt
prompt = "What did the author do growing up?"

# generate an embedding for the prompt and retrieve the most relevant doc
response = ollama.embeddings(
  prompt=prompt,
  model=model
)
results = collection.query(
  query_embeddings=[response["embedding"]],
  n_results=1
)
data = results['documents'][0][0]

"""
    Step 3: Generate
"""

print(f"\n\nUsing this data: \n{data}. \n\nRespond to this prompt: \n{prompt}")

# generate a response combining the prompt and data we retrieved in step 2
output = ollama.generate(
  model=model,
  prompt=f"Using this data: {data}. Respond to this prompt: {prompt}"
)

print(f"\n\nResponse: \n{output['response']}")