import tiktoken
import sys

encoding = tiktoken.encoding_for_model('gpt-4')

with open(sys.argv[1]) as f:
    content = f.read().replace("\n", " ")
    enc = encoding.encode(content)
    print(f"{sys.argv[1]}: {len(enc)} tokens")
