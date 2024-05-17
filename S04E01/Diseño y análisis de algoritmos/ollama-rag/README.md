# Ollama RAG

Using external data ([Paul Graham's essay, "What I Worked On"](https://paulgraham.com/worked.html)) to feed an LLM (Ollama) and prompt based on it.

```Python
# generate a response combining the prompt and data

output = ollama.generate(
  model=model,
  prompt=f"Using this data: {data}. Respond to this prompt: {prompt}"
)
```

# Installation

## Ollama

#### Before
```shell
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl
```

#### 1. Download Ollama

- Info: https://ollama.com/download/linux
- Command:

```shell
curl -fsSL https://ollama.com/install.sh | sh
```

#### 2. Download some models to use

- Info: https://ollama.com/library
- Example (using phi3):

```shell
ollama pull phi3
```

Or `run` to (download and) use the model:

```shell
ollama run phi3
```

## Python

#### Before
Pip:
```shell
sudo apt install python3-pip
```

#### 1. Ollama

```shell
pip install ollama
```

#### (opt) 2. Chroma

[chroma](https://www.trychroma.com/): the AI-native open-source embedding database 

```shell
pip install chromadb
```

## Text

#### Paul Graham's essay, "What I Worked On"

Get it from [here](https://raw.githubusercontent.com/run-llama/llama_index/main/docs/docs/examples/data/paul_graham/paul_graham_essay.txt)

# Usage

- Embeddings: [example](https://ollama.com/blog/embedding-models)

## Misc
- Transforms 75,0 kB txt file into 12,4 MB sqlite3 files
- Takes some time (~10 min on a R7 3700X)

# Results

#### Code
```python
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
```

#### Results using phi3

```
Using this data: 
Now that I could write essays again, I wrote a bunch about topics I'd had stacked up. I kept writing essays through 2020, but I also started to think about other things I could work on. How should I choose what to do? Well, how had I chosen what to work on in the past? I wrote an essay for myself to answer that question, and I was surprised how long and messy the answer turned out to be. If this surprised me, who'd lived it, then I thought perhaps it would be interesting to other people, and encouraging to those with similarly messy lives. So I wrote a more detailed version for others to read, and this is the last sentence of it.. 

Respond to this prompt: 
What did the author do growing up?


Response: 
The provided information doesn't explicitly detail what you personally have done in your own life, as it seems to be discussing someone else's experiences. However, based on how individuals often reflect on their past choices and actions when considering future directions, we can surmise a general scenario of an author growing up:

The author likely faced various challenges and opportunities while growing up that influenced the way they approached work and self-expression. Perhaps these experiences contributed to them developing strong writing skills as well as an ability to critically analyze their own life journey, leading them to write essays about personal growth and reflection. The messiness in their lives might have prompted a deep introspection which is evident from how they tackled the complexity of defining their work focus through extensive self-analysis in their written works. This pattern indicates that during growing up, the author likely engaged with writing as both an outlet for expression and a tool to better understand themselves and their aspirations.
```
