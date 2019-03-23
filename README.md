<p align="center">
    <img src="https://lptstr.github.io/lptstr-images/proj/awesome-prompts/logo.jpg" width="20%" />
    <h1>awesome-prompts</h1>
</p>

A non-curated list of awesome prompts for your favorite shells!

> **NOTE** This project is ongoing, so just because you don't see your favorite shell here does not mean we have some religious hatred toward your shell - it just means we haven't ported any of the prompts yet to your shell.

> Pull requests will be greatly appreciated!

## Usage
Go to the `prompts/` directory and choose a prompt.
All the prompts in this repository are designed to be used as such:
```powershell
# in your profile
. "path/to/prompt.sh"
```
Simply download the appropriate file from any of the prompts in this repository and add it to `~`, then reference or `source` it in your shell's profile.

## Adding your prompt
### Rules
All prompts that follow the following rules are welcome:
- Prompt must either be awesome or mimic an awesome prompt from another shell.
- The prompt must be written by the person submitting the prompt. (No submitting code you didn't write!!)
- The prompt must be self-contained, i.e. should not be spread out over more than one file.
- Prompt **must** be completely cross-platform.
- **(Optional)** Prompt code should be compatible with all recent versions of their respective shells.
    - E.g. a PowerShell prompt should be compatible with both PowerShell 5 and PowerShell 6.

### Submitting the prompt
1. Create a folder in the `prompts/` directory with the name of your prompt, and create a file in that folder as `<prompt>-<shell>.sh`. 
2. If you want, you can also create a README in that directory describing the prompt. 
3. When you make a PR with your changes, be sure to include a screenshot.

If you're unsure whether the prompt you have is awesome, just create an issue describing your prompt with a screenshot.

## License
- MIT (c) all `awesome-prompt` contributers
