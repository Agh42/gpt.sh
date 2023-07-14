# gpt.sh

This is a shell script that utilizes the OpenAI GPT language model to generate text based on a prompt. It provides a convenient way to interact with the GPT model and retrieve generated text.

## Prerequisites

Before using this script, ensure that you have the following requirements:

- An OpenAI API key. You can obtain one from the OpenAI website.
- The `curl` and `jq` command-line tools installed. You can install them using your package manager (e.g., `pacman`, `apt`, `brew`, `yum`).

## Usage

To use this script, follow the steps below:

1. Set your OpenAI API key by exporting it as an environment variable:
   ```
   export OPENAI_API_KEY=<your-api-key>
   ```

2. Run the script with the desired prompt and options:
   ```
   ./gpt.sh <Your_Prompt> [OPTIONS]
   ```

   For example:
   ```
   ./gpt.sh 'Write a bash script to split a file into 2MiB chunks.'
   ```

3. The script will generate text based on the prompt using the specified options and print the output to the console.

## Options

The script supports the following options:

- `--model=[gpt-3.5-turbo|gpt-4|gpt-4-32k|...]`: Specify the model to use. The default is `gpt-3.5-turbo`.

- `--system="You are a helpful assistant."`: Provide a system message as a primer for the model. The default is "You are a helpful assistant."

## Examples

- Using a system message as a primer:
  ```
  ./gpt.sh 'How much is the fish?' --system='You are an interpreter of techno music.'
  ```

- Using a different model:
  ```
  ./gpt.sh 'How much is the fish?' --model=gpt-4
  ```

- Example: use `find` to work on multiple files, applying a prompt from `prompt.txt` before. Also use a system message and the model with the largest context size:
  ```
  find -name "recipe_*.txt" -exec sh -c 'content=$(cat "$1"); result="$(cat ~/prompt.txt) $content"; gpt.sh "$result" --system="You are a master chef for Indian cuisine." --model=gpt-4-32k > "${1}_out.out"' sh {} \;
  ```

Make sure to replace `<your-api-key>` with your actual OpenAI API key.

**Note:** The script calculates the approximate number of tokens based on the provided prompt and system message. It then sets the maximum number of tokens to generate accordingly. The default values for temperature, top_p, frequency, and presence can be modified in the script if desired.

Feel free to modify and adapt this script to suit your specific needs.

```
> gpt.sh "Write an encouraging  last sentence for a github README about  a shell script."
```

"Embrace the power of automation and take your command line skills to the next level with this versatile shell script. Your productivity will soar as you simplify complex tasks and unleash your full potential."