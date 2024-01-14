import subprocess

input_files = ["input.txt", "Lex_Bison_tests/bubble.aplusplus", "Lex_Bison_tests/fib.aplusplus", "mil_tests/part1.txt", "mil_tests/full_errors.txt"]
output_files = ["output.txt", "Lex_Bison_tests/output_bubble.txt", "Lex_Bison_tests/output_fib.txt", "mil_tests/output_part1.txt", "mil_tests/output_full_errors.txt"]

for input_file, output_file in zip(input_files, output_files):
    with open(input_file, 'r', encoding="utf-8") as infile:
        with open(output_file, 'w') as outfile:
            content = infile.read()  # Read the content from the input file
            subprocess.run(["./parser.exe"], input=content, text=True, stdout=outfile)