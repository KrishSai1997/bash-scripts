# slazy
Randomly search for Slack API tokens.

## Installation
1. Save slazy.sh to a file
2. `chmod 777 slazy.sh`
3. Get a Slack API token from your account-> [Can be generated here] (https://api.slack.com/web)
4. Put that token into a file and save it

## Usage
Default `./slazy.sh`

Use a valid token for testing if the connection is alive.
`./slazy.sh --slack-token-file token`

Search for a specific number of valid tokens to find and number to try as 1,000.
`./slazy.sh --max-find 10 --max-try 1000`

Specify all of the output files, look for 1 token, only test 10 tokens, and use a heat check.
`./slazy.sh --max-find 1 --slack-token-file token --max-try 10 --valid-tokens v.v --invalid-tokens i.i --benchmark-file b.b`

## Options
```
-b | --benchmark-file FILE
	Text FILE to write the benchmark report to. Data will be appended.
	Default: benchmark.log
-h | --help
	Displays this help message.
-H | --heat-value NUM(2)
	Two digit number specifying the random check value to determine if a heat check will occur for the current loop iteration. This value is largely irrelevent, I just put it here because I could.
-i | --invalid-tokens FILE
	Text FILE to write the tokens that tested as "not authorized."
	Default: invalid.tokens
-m | --max-find COUNT
 	Specifies the number of valid tokens to find before this tool stops.
	Default: 1.	
-M | --max-try COUNT
	Specifies the maximum number of tokens to attempt before the tool stops.
	Default: infinate.
-v | --valid-tokens FILE
	Specifies the output file where valid tokens will be saved.
	Default: GOOD.tokens
-t | --slack-token-file  FILE
	Text FILE containing the Slack API token used to make sure that our testing IP has not yet been blocked.
```

## Sample Input Files
token:
```
xoxp-0123456789-0123456789-01234567890-ABCDEF
```
