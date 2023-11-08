import subprocess

# Open input file
input_file = "input.txt"
with open(input_file, 'r', encoding='utf-8') as infile:
    # Open output file
    with open("output.txt", 'w') as outfile:
        for line in infile:
            # Run parser.exe with the line as input, writing the output to output.txt
            subprocess.run(["./parser.exe"], input=line, text=True, stdout=outfile)