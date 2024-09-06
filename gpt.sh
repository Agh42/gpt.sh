#!/bin/bash

# uncomment for debugging:
#set -x
#set -v


if [ $# -lt 1 ]; then
    echo "Usage: $0 <Your_Prompt> [OPTIONS]"
    echo ""
    echo ""
    echo "> gpt.sh 'Write a bash script to split a file into 2MiB chunks.'"
    echo ""
    echo "Using a system message as a primer:"
    echo "> gpt.sh 'How much is the fish?' --system='You are an interpreter of techno music.' "
    echo ""
    echo "Using a different model:"
    echo "> gpt.sh 'How much is the fish?' --model=gpt-4-32k"
    echo ""
    echo "Read input from input.txt and write to output.txt:"
    echo "> input=\$(cat input.txt); ./gpt.sh \"\$input\" --system=\"Summarize this text.\" > output.txt"
    echo ""
    echo "Example using find for multiple files, for each add a prompt from prompt.txt. Also use a system message and the model with the largest context size:"
    echo "> find -name \"recipe_*.txt\" -exec sh -c 'content=\$(cat \"\$1\"); result=\"\$(cat ~/prompt.txt) \$content\"; gpt.sh  \"\$result\" --system=\"You are a master chef for Indian cuisine.\" --model=gpt-4-32k> \"\${1}_out.out\"' sh {} \;"
    echo ""
    echo "Expects your API Key in the environment: export OPENAI_API_KEY=<yourkey>"
    echo ""
    echo "OPTIONS:"
    echo "--model=[gpt-3.5-turbo|gpt-4|gpt-4-32k|gpt-4-1106-preview]"
    echo "--system=\"You are a helpful assistant.\""
    exit 1
fi

# Set the prompt to use as input for the language model
PROMPT="$1"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model=*)
            model="${1#*=}"
            shift
            ;;
        --system=*)
            system="${1#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# DEFAULTS:
	## Set the model to use (e.g. "gpt-3.5-turbo-0301") - this is the cheapest model
	#MODEL="gpt-3.5-turbo-0301" snapshot, deprecated 3 months after new version releases
	#MODEL="gpt-4" 
	#MODEL="gpt-4-32k" #4x context length
	#MODEL="gpt-3.5-turbo"
	MODEL="gpt-4o"
	#MODEL="${model:-gpt-4}"
SYSTEMMSG="${system:-You are a helpful assistant.}"


# Set your OpenAI API key
#export OPENAI_API_KEY="Your OPENAI API KEY"


# Set the max number of tokens to generate (approx) as whole integer
num_tokens=$(echo "$PROMPT $SYSTEMMSG" | wc -w)
#TOKEN_COUNT=$(echo "((4000 - ($num_tokens*1.8)))/1" | bc) # for bc, 123.45/1 equals 123
#TOKEN_COUNT=$(echo "((4000 - ($num_tokens*2.6)))/1" | bc) # for bc, 123.45/1 equals 123
TOKEN_COUNT=$(echo "((4000 - ($num_tokens*2.8)))/1" | bc) # for bc, 123.45/1 equals 123

# Set the temperature
TEMPERATURE=0.5

# Set the top_p value
TOP_P=1

# Set the frequency
FREQUENCY=0.5

# Set the presence
PRESENCE=0.5

# escape for json:
PROMPTJSON=$(jq -n --arg multiline "$PROMPT" '$multiline | @json')


# Generate text using the language model
OUTPUT=$(curl -sk -X POST -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEMMSG\"},{\"role\":\"user\",\"content\": $PROMPTJSON}],\"temperature\":$TEMPERATURE,\"top_p\":$TOP_P,\"frequency_penalty\":$FREQUENCY,\"presence_penalty\":$PRESENCE,\"max_tokens\":$TOKEN_COUNT}" https://api.openai.com/v1/chat/completions)

# Extract the text from the response
ERROR_MESSAGE=$(echo "$OUTPUT" | jq -r '.error.message')
if [ "$ERROR_MESSAGE" != "null" ]; then
    OUTPUT=$(echo "$OUTPUT" | jq -r '.error.message')
else
    OUTPUT=$(echo "$OUTPUT" | jq -r '.choices[0].message.content')
fi

# Print the output
echo "$OUTPUT"
