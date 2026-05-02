@echo off
:: Path to a file containing MINIMAX_API_KEY=your_key_here
:: Change this to wherever you store your MiniMax API key
set CREDENTIALS_FILE=%USERPROFILE%\.credentials\minimax.env

for /f "tokens=1,* delims==" %%A in ('findstr /i "MINIMAX_API_KEY" "%CREDENTIALS_FILE%"') do (
    if /i "%%A"=="MINIMAX_API_KEY" set "MINIMAX_KEY=%%B"
)
set ANTHROPIC_BASE_URL=https://api.minimax.io/anthropic
set ANTHROPIC_AUTH_TOKEN=%MINIMAX_KEY%
set ANTHROPIC_MODEL=MiniMax-M2.7
set ANTHROPIC_DEFAULT_SONNET_MODEL=MiniMax-M2.7
set ANTHROPIC_DEFAULT_OPUS_MODEL=MiniMax-M2.7
set ANTHROPIC_DEFAULT_HAIKU_MODEL=MiniMax-M2.7
set API_TIMEOUT_MS=3000000
"%USERPROFILE%\.claudmax-install\node_modules\@anthropic-ai\claude-code\bin\claude.exe" %*
