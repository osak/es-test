import json
import openai
import tiktoken
import sys
import os
import os.path

def chunk(text):
    encoding = tiktoken.encoding_for_model('text-embedding-3-small')
    enc = encoding.encode(text.replace("\n", " "))
    if len(enc) <= 8192:
        return [text]
    else:
        lines = text.split("\n")
        l, r = 0, len(lines)
        while l + 1 < r:
            mid = (l + r) // 2
            pre_str = "\n".join(lines[:mid])
            pre_enc = encoding.encode(pre_str)
            if len(pre_enc) <= 8000:
                l = mid
            else:
                r = mid
        chunk_post = chunk("\n".join(lines[l:]))
        return ["\n".join(lines[:l])] + chunk_post

def load_content(path):
    with open(path) as f:
        return f.read()

def save_embeddings(path, name, embeddings):
    obj = {
            'model': 'text-embedding-3-small',
            'file': f'{name}.txt',
            'embeddings': embeddings,
          }
    with open(path, 'w') as f:
        json.dump(obj, f)

if __name__ == '__main__':
    client = openai.OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

    print(f"processing {sys.argv[1]}")
    name = os.path.basename(sys.argv[1]).replace('.txt', '')

    content = load_content(sys.argv[1])
    chunks = chunk(content)
    embeddings = []
    for chunk in chunks:
        vec = client.embeddings.create(input=chunk, model='text-embedding-3-small').data[0].embedding
        embeddings.append(vec)
    save_embeddings(f'data/embeddings/{name}.json', name, embeddings)
