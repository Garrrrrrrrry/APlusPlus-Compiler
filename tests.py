import subprocess

input_files = ["input.txt", "test/bubble.aplusplus", "test/fib.aplusplus", "mil_tests/part1.txt"]
output_files = ["output.txt", "test/output_bubble.txt", "test/output_fib.txt", "mil_tests/output_part1.txt"]

for input_file, output_file in zip(input_files, output_files):
    with open(input_file, 'r', encoding="utf-8") as infile:
        with open(output_file, 'w') as outfile:
            content = infile.read()  # Read the content from the input file
            subprocess.run(["./parser.exe"], input=content, text=True, stdout=outfile)