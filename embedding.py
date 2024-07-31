import openai
import sys
import os

def print_vec(vec):
    line = ['[']
    for (i, v) in enumerate(vec):
        if i == 0:
            line.append(f"{v:.8f}")
        else:
            line.append(f",{v:.8f}")
    line.append(']')
    print("\n".join(line))

client = openai.OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

query = input("> ")
vec = client.embeddings.create(input=query, model='text-embedding-3-small').data[0].embedding
print_vec(vec)
