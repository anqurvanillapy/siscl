#   Lexer
#   =====
#
#   Tokenize the flow of bytes by creating an array of specialized strings as
#   tokens, without reordering them by the syntax.
#
#   Note: Use printf '%s\n' "${tokens[@]}" to print the elements of tokens array
#   separated by newlines.
#
#   XXX: Use associative arrays to store the valid tokens, especially the
#   operators combined by some non-alphanumeric letters. 

# Global settings
shopt -s extglob    # now *(...) is usable

# Source file offset.
row=1
col=0

# Token buffer and array.
tokens=()
buf=""

# Error messages.
INVALID_SYNTAX="invalid syntax"

# Recognise a token and append to the token array, or raise a error message.
function tokenize() {
    # If a whitespace/newline given.
    if [[ $# -lt 1 ]]; then
        if [[ "$buf" != "" ]]; then
            case "$buf" in
                *([0-9]))
                    tokens+=("NAT $buf")
                    buf=""
                    ;;
                [+\-*/])
                    tokens+=("OPT $buf")
                    buf=""
                    ;;
                *)
                    echo "$row:$col "$INVALID_SYNTAX" \"$buf\""
                    exit 1
                    ;;
            esac
        fi
    # If a valid character given.
    else
        case "$buf" in
            "")
                buf="$buf$1"
                ;;
            *([0-9]))
                if [[ "$1" == [+\-*/] ]]; then
                    tokens+=("NAT $buf")
                    buf="$1"
                else
                    buf="$buf$1"
                fi
                ;;
            [+\-*/])
                if [[ "$1" == [0-9] ]]; then
                    tokens+=("OPT $buf")
                    buf="$1"
                else
                    echo "$row:$col "$INVALID_SYNTAX" \"$buf$1\""
                    exit 1
                fi
                ;;
        esac
    fi
}

# Main loop of the scanner.
while IFS= read -N 1 c; do
    ((col++))
    case "$c" in
        $'\n')
            ((row++))
            ((col=0))
            tokenize
            ;;
        $' ')
            tokenize
            ;;
        [0-9+\-*/])
            tokenize "$c"
            ;;
        *)
            echo "$row:$col "$INVALID_SYNTAX" \"$buf$c\""
            exit 1
            ;;
    esac
done <&0

printf '%s\n' "${tokens[@]}"
