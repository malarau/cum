#!/bin/bash

#
# EXCEPTIONS
# 

# Checks for number of args
if [ $# -ne 1 ]; then
    echo "Usage: ${0} <text_file>"
    exit 1
fi

# Checks if file exist and is not empty 
if [ ! -s "$1" ]; then
    echo "The file $1 does not exist or is empty."
    exit 1
fi

#
# CODE
#
: '
########################################
sed - stream editor for filtering and transforming text

    DESCRIPTION
        Attempt to match regexp against the pattern space. If successful, replace that portion matched with replacement.
        The replacement may contain the special character & to refer to that portion of the pattern space which matched.

    ####################
    IN THIS FUNCTION:
        The idea is first, remove all special chars and then, transform every upper case char for a lower case.

    s/regexp/replacement/ file
        - s             The s stands for substitute
        - regexp        The regular expression (i.e. pattern)
        - replacement   The replacement
        - file          Where to look
    
    s/[.,;:\x27"!?—()-]//g; s/.*/\L&/ $1 -----> Removed some characters which mess with the multi-line comment

        Contains 2 expresions:

            s/[.,;:\x27"!?—()-]//g $1

                - s             s
                    Substitute

                - regexp        [.,;:"!?-]
                    A character set in regular expressions, matches any single character within the brackets
                    In this case: period, comma, semicolon, colon, single quote (removed for comment), double quote, exclamation mark, question mark, or hyphen
                
                - replacement     
                    Replaces every match character in the set for nothing
                
                - g             Global, affects all instances, not just the first
                
                - $1            The file

            s/.*/\L&/ $1

                s               s
                    Substitute
                
                - regexp        .*
                    Matches any sequence of characters (including none)

                - replacement   \L&    
                    Converts the matched text to lowercase 
                    \L 
                        Is an escape sequence in sed that and convert the characters to lowercase
                    &  
                        Means that it should convert the entire matched text, in this case all (.*)
            
                - $1            The file

########################################
tr - translate or delete characters
    
    DESCRIPTION
        Translate, squeeze, and/or delete characters from standard input, writing to standard output.

    ####################
    IN THIS FUNCTION:
        Now that we have a clean text (no special chars or uppercase letters), conver the entire
        text on a single column list. So, replace every empty space for a new line seq.

    tr ' ' '\n'       
        tr      The command
        ' '     Looking for empty spaces
        '\n'    Replace every one for a new line sequence

########################################
sort - sort lines of text files

    DESCRIPTION
       Write sorted concatenation of all FILE(s) to standard output.

    ####################
    IN THIS FUNCTION:
        We have a list of words, now we have to sort it.

    Example, transforms this input:
        grape
        orange
        banana
        apple
        banana
        grape
    To this:
        apple
        banana
        banana
        grape
        grape
        orange

########################################
uniq - report or omit repeated lines

    DESCRIPTION
       Filter adjacent matching lines from INPUT (or standard input), writing to OUTPUT (or standard output).

    ####################
    IN THIS FUNCTION:
        We have a sorted -column- list of words, now we need to count adjacent lines and filter repeated ones.
    
    uniq -c
        uniq    The command
        -c      Prefix lines by the number of occurrences

    Example, count and filter this:
        apple
        banana
        banana
        grape
        grape
        orange
    Output:
        1 apple
        2 banana
        2 grape
        1 orange

########################################
sort - (Again)

    ####################
    IN THIS FUNCTION:
        We have to sort the last output using the number of occurrences.
        So, we have to use the first column, and it should be from the highest number.

    sort -k1,1 -r -n 

        sort    The command

        -k1,1   Filter using this

            k 
                -k, --key=KEYDEF
                sort via a key; KEYDEF gives location and type
            
            1,1
                Starts with the first column and ends using with the same

            r
                -r, --reverse
                Reverse the result of comparisons

                So, it will sort from highest number

            n
                -n, --numeric-sort
                Compare according to string numerical value

                Otherwise:
                    8 for
                    7 out
                    7 one
                    7 me
                    7 man
                    7 him
                    62 the <------------ As a string it is ok, but we should treat it as a number
                    6 they
                    6 not
                    5 what

        Example, transform this:
            1 apple
            2 banana
            2 grape
            1 orange
        To this:
            2 grape
            2 banana
            1 orange
            1 apple      

########################################
head - output the first part of files

    DESCRIPTION
       Print the first 10 lines of each FILE to standard output.
       With more than one FILE, precede each with a header giving the file name.

    ####################
    IN THIS FUNCTION:
        Now, just print the first 10 lines

    -n, --lines=[-]NUM
        print the first NUM lines instead of the first 10; with the leading '-',
        print all but the last NUM lines of each file
'

# Clean file using regexp (no upper, no special chars)
clean_file="$(sed 's/[.,;:\x27"!?—()-]//g; s/.*/\L&/' "$1")"

# COUNTING WORDS
#
count_words() {
    # Ugly? Use "| awk... etc" at the end
    echo "$clean_file" | tr ' ' '\n' | sort | uniq -c | sort -k1,1 -r -n | head
}

: '
########################################
tr - translate or delete characters (Again)

    ####################
    IN THIS FUNCTION:
        Remove all new lines and spaces, so we got a single line
        (which is a word resulting after concatenate all words)

    tr -d '\n '

        tr      The command

        d       Do not translate, DELETE.

        '\n '   If we found a new line or a space, DELETE IT!

########################################
grep - print lines that match patterns

    DESCRIPTION
       grep  searches  for  PATTERNS in each FILE.  PATTERNS is one or more patterns separated by newline characters, and grep prints each line that matches a
       pattern.  Typically PATTERNS should be quoted when grep is used in a shell command

    ####################
    IN THIS FUNCTION:
        In this case, we have to put every letter on a new line

    grep -o .
        grep        The command

        o           -o, --only-matching
                    Print only the matched (non-empty) parts of a matching line,
                    with each such part on a separate output line

        .           Represents any single character in a regular expression

'

# COUNTING LETTERS
#
count_letters(){
    echo "$clean_file" | tr -d '\n ' | grep -o . | sort | uniq -c | sort -k1,1 -r -n | head -n 5
}

echo "Most common words:"
count_words
echo "Most common letters:"
count_letters